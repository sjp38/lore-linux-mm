Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D8AEC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:07:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 964FD265A9
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 21:07:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="NluOZS1M";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="ithPb5CE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 964FD265A9
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0585C6B0269; Mon,  3 Jun 2019 17:07:21 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F23CE6B026F; Mon,  3 Jun 2019 17:07:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D77B86B0270; Mon,  3 Jun 2019 17:07:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f70.google.com (mail-yw1-f70.google.com [209.85.161.70])
	by kanga.kvack.org (Postfix) with ESMTP id AEF8E6B0269
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 17:07:20 -0400 (EDT)
Received: by mail-yw1-f70.google.com with SMTP id k134so17358855ywe.7
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 14:07:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=ovxddd77OdiO0CKS6PJ14syNig1ZwGsAqCS1t72RgDY=;
        b=oFxS67vBTT1DUHvIq6PlPc42PPAxdPbdfidOV5gX8alvYrUwpeVLdxBwChWICJLaRN
         gTm2LYo4ex9QaVf/XrSP4R/QSCQy+ghxjO9BVUZGHxlS6idedvWuj/smREUaFBm9jqzy
         Yb1PXZs9RYdv81xmlpHfLAULpWhAXbLDYIHmdig0mShSeIxDAbD82KRu3YKJbDqNo4TW
         FXSEnpeFuoT9EBmLJLu05kR8MEAZOEpjzDLPLW42yR+2vVEjTo0LEWzw21GB35qCk9US
         pw6kylmAilyD2nXT2/XFoLqjv9r/JxaRwcyofAYtWH5u+mfNeaDE/zKXg1nBQxBnb1Yp
         KUcQ==
X-Gm-Message-State: APjAAAXvP3iYt6HischTBr5KgaNiYBBW/RbIWxVJc7fXeKtN0L5H2/j6
	VbTAaKVkHUyElUOddHk4lbfP7cmwabzomZOaOTiGOR7FC3Idud3/zeG0mlyTVw66XB/7OFK52B4
	6GFcHZx8WytnATT+akxl8xlsH3ODmOQMYyItpvK8OxeYFfDAlVTjjPtVrN4XxXfuwDQ==
X-Received: by 2002:a25:26c5:: with SMTP id m188mr14149123ybm.16.1559596040402;
        Mon, 03 Jun 2019 14:07:20 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxMhGeOKPNFX42O1z1CrYmhinNV+n4BJI4xfwFKgjMFB8iMOuy2cZ83BmUE4hvzMsWV/mOy
X-Received: by 2002:a25:26c5:: with SMTP id m188mr14149076ybm.16.1559596039439;
        Mon, 03 Jun 2019 14:07:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559596039; cv=none;
        d=google.com; s=arc-20160816;
        b=NUgqeC5bzRFLragr+0VKHx4SKdM0AJpvGuJI8o/FD1bwle8cw/IAxhGb7q23GRYJQM
         khNv8+MWDRdPxO3Jh/UYfjJU4KgWY+ZhtU3dEfnSCcLaiwQYaBt37jlA6ls6ji8fG8pR
         9F9+2/CFXWC8zKW4rwxIyu8I+qdugF/9HlJFM1Tv5iPuuRz+s31OjNA6MyfKR/ZlaUrK
         gMbJnD/MJxxleNEoQRQJF9qoZonSap8Mzuwg5jM+UGUrs8jBPROIslhsa8bSOOlEGF+X
         FNXHXAEt6H9AT9atuOk8KZ3TRRE88WFFc7A4d46ln2SSvOQLdFsoU+RP9a/6VqoZrT84
         cQGg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=ovxddd77OdiO0CKS6PJ14syNig1ZwGsAqCS1t72RgDY=;
        b=I71cDuL0OKh3w8YI3OYnViiZdxE/wbZgafGbx32jZCfcYQILS4qHRiZC6rbNjnm1aT
         G6kcJanYIU70hTssiogiwpQM61bmZgATlb0kvH3VKXM+6mRMDB1rZRFMdEKtC1RLkJRg
         i3qpvmOP9wFO5a0hRfQWn8ZPelZoOM/f1PP7cuhD8iPDjCTR6F7wYc9o7aJCMZ9XUyuC
         mSL4n8+WxDliTViiA6gq4sjf3/t0nVCD/UCUEQJghbbfGl9vktrTFYZjLj+x3lcHAFGN
         yk2X9cB3G7mSc4o8e3FrxS9ltdcaIHDzTY7D6C6Jm93ygt6vJylyhHP6Ru+4Yc+B52a4
         qRTQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=NluOZS1M;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=ithPb5CE;
       spf=pass (google.com: domain of prvs=1057c191d7=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1057c191d7=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id p205si4630704yba.322.2019.06.03.14.07.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Jun 2019 14:07:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=1057c191d7=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=NluOZS1M;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=ithPb5CE;
       spf=pass (google.com: domain of prvs=1057c191d7=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=1057c191d7=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x53Kq9Qf014018;
	Mon, 3 Jun 2019 14:06:41 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=ovxddd77OdiO0CKS6PJ14syNig1ZwGsAqCS1t72RgDY=;
 b=NluOZS1MQlmayReLIYdV6ZGE6C1S7TmOJNIEy6Lpz+IbNP4klV2cGVV2vHHdZPqSYf9o
 TL0WbE8wnFVCB+aV6BZleBDo6QarqeU4wOp++ytpc0GHBwLjXv5tDxgne6LgZScBluFe
 bW8BN2bziuItqz1rjJE1a1ez6B4YB1AqYqE= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0b-00082601.pphosted.com with ESMTP id 2swa6s076t-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Mon, 03 Jun 2019 14:06:41 -0700
Received: from ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) by
 ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 3 Jun 2019 14:06:40 -0700
Received: from ash-exhub201.TheFacebook.com (2620:10d:c0a8:83::7) by
 ash-exopmbx201.TheFacebook.com (2620:10d:c0a8:83::8) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Mon, 3 Jun 2019 14:06:40 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.36.101) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id 15.1.1713.5
 via Frontend Transport; Mon, 3 Jun 2019 14:06:40 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=ovxddd77OdiO0CKS6PJ14syNig1ZwGsAqCS1t72RgDY=;
 b=ithPb5CEnA6CWezoAiL/NH4NNbEnfuUBJYnjGUIze1BPQLW+K2xLSRGlFc3IjN9/uBA0W2LfPZ+Z9w+OP08cxg3q8l8bcNEgKCWqZWQDL8R4TUuLkFVia+WTuJHkiPkydgQRFyVKzjdk1QtfK+meGL2rHIC3jM26XWVAuP4BY5E=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2855.namprd15.prod.outlook.com (20.178.206.84) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1943.22; Mon, 3 Jun 2019 21:06:37 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1943.018; Mon, 3 Jun 2019
 21:06:37 +0000
From: Roman Gushchin <guro@fb.com>
To: Uladzislau Rezki <urezki@gmail.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        Hillf Danton <hdanton@sina.com>, Michal Hocko
	<mhocko@suse.com>,
        Matthew Wilcox <willy@infradead.org>,
        LKML
	<linux-kernel@vger.kernel.org>,
        Thomas Garnier <thgarnie@google.com>,
        Oleksiy
 Avramchenko <oleksiy.avramchenko@sonymobile.com>,
        Steven Rostedt
	<rostedt@goodmis.org>,
        Joel Fernandes <joelaf@google.com>,
        Thomas Gleixner
	<tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>,
        Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/4] mm/vmap: preload a CPU with one object for split
 purpose
Thread-Topic: [PATCH v3 2/4] mm/vmap: preload a CPU with one object for split
 purpose
Thread-Index: AQHVFHAH7qEvKKmW0EiXhNmDjWGv56aArvuAgAF9XoD//647gIAIZvgAgAAyZACAAAOhgA==
Date: Mon, 3 Jun 2019 21:06:37 +0000
Message-ID: <20190603210633.GD14526@tower.DHCP.thefacebook.com>
References: <20190527093842.10701-1-urezki@gmail.com>
 <20190527093842.10701-3-urezki@gmail.com>
 <20190528224217.GG27847@tower.DHCP.thefacebook.com>
 <20190529142715.pxzrjthsthqudgh2@pc636>
 <20190529163435.GC3228@tower.DHCP.thefacebook.com>
 <20190603175312.72td46uahgchfgma@pc636>
 <20190603205334.qfxm6qiv45p4a326@pc636>
In-Reply-To: <20190603205334.qfxm6qiv45p4a326@pc636>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR1401CA0005.namprd14.prod.outlook.com
 (2603:10b6:301:4b::15) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::5409]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 0c9d1ef6-6101-4845-9397-08d6e8675de1
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB2855;
x-ms-traffictypediagnostic: BYAPR15MB2855:
x-microsoft-antispam-prvs: <BYAPR15MB2855394CD79F2BA264E5790ABE140@BYAPR15MB2855.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:6108;
x-forefront-prvs: 0057EE387C
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(136003)(366004)(39860400002)(376002)(396003)(189003)(199004)(33656002)(186003)(6486002)(6512007)(6436002)(9686003)(14454004)(229853002)(5660300002)(66946007)(11346002)(66446008)(64756008)(6506007)(486006)(76176011)(52116002)(73956011)(66556008)(476003)(446003)(25786009)(66476007)(478600001)(46003)(54906003)(8676002)(6246003)(1076003)(102836004)(386003)(4326008)(8936002)(7416002)(81166006)(6116002)(7736002)(305945005)(81156014)(53936002)(6916009)(1411001)(86362001)(99286004)(14444005)(71190400001)(256004)(71200400001)(2906002)(68736007)(316002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2855;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: QihVY+JFeOLiQ2p/g4DZ4aOnJAbzPe6kzXw62spLiT3tesMckemfzdF8/oehI4cMSxwX7rjV6s992BzPviOh4k3C0wTUm7Dp5/ZIl2ojOIXeDwrP+BSrnRwM3G1Fq0/+RZ2UAGEb44t2FvZDTX98vm41h2nWY5Q0KLS56aKvKCampfJCRy4QHQoPX2FR8ATyyAvS8dfix8/uEyNc3cz/vFUjyntuk6bovO/PCee0BwkZeTos7qfjDnTW1s+aTr/wyAtLdXFG3A4nf8gTumE1Hq6xhUgjtNSkSaRNgO7JeP+HY4+nigG/2HkJi55KrmRnO+np5381Nj+x/o/wwvGhaMOsBa4o8C0V+05KFZ/tLAIBN6S/ULANCp1zrJOYS6j380HVBgwK381zVsdVQaZoCjMjphtk/Mnc137XS8a2CSk=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F4DAA8DD1FD9F042A981D2EB52C70FFD@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 0c9d1ef6-6101-4845-9397-08d6e8675de1
X-MS-Exchange-CrossTenant-originalarrivaltime: 03 Jun 2019 21:06:37.6832
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2855
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-06-03_16:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=904 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1906030141
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 03, 2019 at 10:53:34PM +0200, Uladzislau Rezki wrote:
> On Mon, Jun 03, 2019 at 07:53:12PM +0200, Uladzislau Rezki wrote:
> > Hello, Roman!
> >=20
> > On Wed, May 29, 2019 at 04:34:40PM +0000, Roman Gushchin wrote:
> > > On Wed, May 29, 2019 at 04:27:15PM +0200, Uladzislau Rezki wrote:
> > > > Hello, Roman!
> > > >=20
> > > > > On Mon, May 27, 2019 at 11:38:40AM +0200, Uladzislau Rezki (Sony)=
 wrote:
> > > > > > Refactor the NE_FIT_TYPE split case when it comes to an
> > > > > > allocation of one extra object. We need it in order to
> > > > > > build a remaining space.
> > > > > >=20
> > > > > > Introduce ne_fit_preload()/ne_fit_preload_end() functions
> > > > > > for preloading one extra vmap_area object to ensure that
> > > > > > we have it available when fit type is NE_FIT_TYPE.
> > > > > >=20
> > > > > > The preload is done per CPU in non-atomic context thus with
> > > > > > GFP_KERNEL allocation masks. More permissive parameters can
> > > > > > be beneficial for systems which are suffer from high memory
> > > > > > pressure or low memory condition.
> > > > > >=20
> > > > > > Signed-off-by: Uladzislau Rezki (Sony) <urezki@gmail.com>
> > > > > > ---
> > > > > >  mm/vmalloc.c | 79 ++++++++++++++++++++++++++++++++++++++++++++=
+++++++++++++---
> > > > > >  1 file changed, 76 insertions(+), 3 deletions(-)
> > > > >=20
> > > > > Hi Uladzislau!
> > > > >=20
> > > > > This patch generally looks good to me (see some nits below),
> > > > > but it would be really great to add some motivation, e.g. numbers=
.
> > > > >=20
> > > > The main goal of this patch to get rid of using GFP_NOWAIT since it=
 is
> > > > more restricted due to allocation from atomic context. IMHO, if we =
can
> > > > avoid of using it that is a right way to go.
> > > >=20
> > > > From the other hand, as i mentioned before i have not seen any issu=
es
> > > > with that on all my test systems during big rework. But it could be
> > > > beneficial for tiny systems where we do not have any swap and are
> > > > limited in memory size.
> > >=20
> > > Ok, that makes sense to me. Is it possible to emulate such a tiny sys=
tem
> > > on kvm and measure the benefits? Again, not a strong opinion here,
> > > but it will be easier to justify adding a good chunk of code.
> > >=20
> > It seems it is not so straightforward as it looks like. I tried it befo=
re,
> > but usually the systems gets panic due to out of memory or just invokes
> > the OOM killer.
> >=20
> > I will upload a new version of it, where i embed "preloading" logic dir=
ectly
> > into alloc_vmap_area() function.
> >=20
> just managed to simulate the faulty behavior of GFP_NOWAIT restriction,
> resulting to failure of vmalloc allocation. Under heavy load and low
> memory condition and without swap, i can trigger below warning on my
> KVM machine:
>=20
> <snip>
> [  366.910037] Out of memory: Killed process 470 (bash) total-vm:21012kB,=
 anon-rss:1700kB, file-rss:264kB, shmem-rss:0kB
> [  366.910692] oom_reaper: reaped process 470 (bash), now anon-rss:0kB, f=
ile-rss:0kB, shmem-rss:0kB
> [  367.913199] stress-ng-fork: page allocation failure: order:0, mode:0x4=
0800(GFP_NOWAIT|__GFP_COMP), nodemask=3D(null),cpuset=3D/,mems_allowed=3D0
> [  367.913206] CPU: 3 PID: 19951 Comm: stress-ng-fork Not tainted 5.2.0-r=
c3+ #999
> [  367.913207] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIO=
S 1.10.2-1 04/01/2014
> [  367.913208] Call Trace:
> [  367.913215]  dump_stack+0x5c/0x7b
> [  367.913219]  warn_alloc+0x108/0x190
> [  367.913222]  __alloc_pages_slowpath+0xdc7/0xdf0
> [  367.913226]  __alloc_pages_nodemask+0x2de/0x330
> [  367.913230]  cache_grow_begin+0x77/0x420
> [  367.913232]  fallback_alloc+0x161/0x200
> [  367.913235]  kmem_cache_alloc+0x1c9/0x570
> [  367.913237]  alloc_vmap_area+0x98b/0xa20
> [  367.913240]  __get_vm_area_node+0xb0/0x170
> [  367.913243]  __vmalloc_node_range+0x6d/0x230
> [  367.913246]  ? _do_fork+0xce/0x3d0
> [  367.913248]  copy_process.part.46+0x850/0x1b90
> [  367.913250]  ? _do_fork+0xce/0x3d0
> [  367.913254]  _do_fork+0xce/0x3d0
> [  367.913257]  ? __do_page_fault+0x2bf/0x4e0
> [  367.913260]  do_syscall_64+0x55/0x130
> [  367.913263]  entry_SYSCALL_64_after_hwframe+0x44/0xa9
> [  367.913265] RIP: 0033:0x7f2a8248d38b
> [  367.913268] Code: db 45 85 f6 0f 85 95 01 00 00 64 4c 8b 04 25 10 00 0=
0 00 31 d2 4d 8d 90 d0 02 00 00 31 f6 bf 11 00 20 01 b8 38 00 00 00 0f 05 <=
48> 3d 00 f0 ff ff 0f 87 de 00 00 00 85 c0 41 89 c5 0f 85 e5 00 00
> [  367.913269] RSP: 002b:00007fff1b058c30 EFLAGS: 00000246 ORIG_RAX: 0000=
000000000038
> [  367.913271] RAX: ffffffffffffffda RBX: 00007fff1b058c30 RCX: 00007f2a8=
248d38b
> [  367.913272] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 000000000=
1200011
> [  367.913273] RBP: 00007fff1b058c80 R08: 00007f2a83d34300 R09: 00007fff1=
b1890a0
> [  367.913274] R10: 00007f2a83d345d0 R11: 0000000000000246 R12: 000000000=
0000000
> [  367.913275] R13: 0000000000000020 R14: 0000000000000000 R15: 000000000=
0000000
> [  367.913278] Mem-Info:
> [  367.913282] active_anon:45795 inactive_anon:80706 isolated_anon:0
>                 active_file:394 inactive_file:359 isolated_file:210
>                 unevictable:2 dirty:0 writeback:0 unstable:0
>                 slab_reclaimable:2691 slab_unreclaimable:21864
>                 mapped:80835 shmem:80740 pagetables:50422 bounce:0
>                 free:12185 free_pcp:776 free_cma:0
> [  367.913286] Node 0 active_anon:183180kB inactive_anon:322824kB active_=
file:1576kB inactive_file:1436kB unevictable:8kB isolated(anon):0kB isolate=
d(file):840kB mapped:323340kB dirty:0kB writeback:0kB shmem:322960kB shmem_=
thp: 0kB shmem_pmdmapped: 0kB anon_thp: 0kB writeback_tmp:0kB unstable:0kB =
all_unreclaimable? no
> [  367.913287] Node 0 DMA free:4516kB min:724kB low:904kB high:1084kB act=
ive_anon:2384kB inactive_anon:0kB active_file:48kB inactive_file:0kB unevic=
table:0kB writepending:0kB present:15992kB managed:15908kB mlocked:0kB kern=
el_stack:1256kB pagetables:4516kB bounce:0kB free_pcp:0kB local_pcp:0kB fre=
e_cma:0kB
> [  367.913292] lowmem_reserve[]: 0 948 948 948
> [  367.913294] Node 0 DMA32 free:44224kB min:44328kB low:55408kB high:664=
88kB active_anon:180252kB inactive_anon:322824kB active_file:992kB inactive=
_file:1332kB unevictable:8kB writepending:252kB present:1032064kB managed:9=
95428kB mlocked:8kB kernel_stack:43260kB pagetables:197172kB bounce:0kB fre=
e_pcp:3252kB local_pcp:480kB free_cma:0kB
> [  367.913299] lowmem_reserve[]: 0 0 0 0
> [  367.913301] Node 0 DMA: 46*4kB (UM) 45*8kB (UM) 12*16kB (UM) 9*32kB (U=
M) 2*64kB (M) 2*128kB (UM) 2*256kB (M) 3*512kB (M) 1*1024kB (M) 0*2048kB 0*=
4096kB =3D 4480kB
> [  367.913310] Node 0 DMA32: 966*4kB (UE) 552*8kB (UME) 648*16kB (UME) 26=
5*32kB (UME) 75*64kB (UME) 12*128kB (ME) 1*256kB (U) 1*512kB (E) 1*1024kB (=
U) 2*2048kB (UM) 1*4096kB (M) =3D 43448kB
> [  367.913322] Node 0 hugepages_total=3D0 hugepages_free=3D0 hugepages_su=
rp=3D0 hugepages_size=3D2048kB
> [  367.913323] 81750 total pagecache pages
> [  367.913324] 0 pages in swap cache
> [  367.913325] Swap cache stats: add 0, delete 0, find 0/0
> [  367.913325] Free swap  =3D 0kB
> [  367.913326] Total swap =3D 0kB
> [  367.913327] 262014 pages RAM
> [  367.913327] 0 pages HighMem/MovableOnly
> [  367.913328] 9180 pages reserved
> [  367.913329] 0 pages hwpoisoned
> [  372.338733] systemd-journald[195]: /dev/kmsg buffer overrun, some mess=
ages lost.
> <snip>
>=20
> Whereas with "preload" logic i see only OOM killer related messages:
>=20
> <snip>
> [  136.787266] oom-kill:constraint=3DCONSTRAINT_NONE,nodemask=3D(null),cp=
uset=3D/,mems_allowed=3D0,global_oom,task_memcg=3D/,task=3Dsystemd-journal,=
pid=3D196,uid=3D0
> [  136.787276] Out of memory: Killed process 196 (systemd-journal) total-=
vm:56832kB, anon-rss:512kB, file-rss:336kB, shmem-rss:820kB
> [  136.790481] oom_reaper: reaped process 196 (systemd-journal), now anon=
-rss:0kB, file-rss:0kB, shmem-rss:820kB
> <snip>
>=20
> i.e. vmalloc still able to allocate.
>=20
> Probably i need to update the commit message by this simulation and findi=
ng.

Ah, perfect! Than it makes total sense to me.

Thanks!

