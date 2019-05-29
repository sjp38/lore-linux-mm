Return-Path: <SRS0=FSMz=T5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SPF_HELO_NONE,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2A0BBC28CC0
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 16:27:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C7D7323D80
	for <linux-mm@archiver.kernel.org>; Wed, 29 May 2019 16:27:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="ekW1+hYr";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="l1h9Ya5F"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C7D7323D80
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3A4BF6B026C; Wed, 29 May 2019 12:27:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 354FD6B026D; Wed, 29 May 2019 12:27:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21BF26B026E; Wed, 29 May 2019 12:27:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f70.google.com (mail-io1-f70.google.com [209.85.166.70])
	by kanga.kvack.org (Postfix) with ESMTP id 024816B026C
	for <linux-mm@kvack.org>; Wed, 29 May 2019 12:27:26 -0400 (EDT)
Received: by mail-io1-f70.google.com with SMTP id n24so2197753ioo.23
        for <linux-mm@kvack.org>; Wed, 29 May 2019 09:27:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=X4eoqNRmc3LMmVaz3RomiWqkEf9IsoofKVkNtQpF48A=;
        b=DnFdfhWflE+Qm4PvS90caicXIJmmUygUOBE5mmjoJ4YQGCdq12H83wYZkmcHa9bBP1
         f48Qdu21tTm6l1eNlnbaoAqmjZXUwG1UXCCZTRkk1z6z3reTNGalcReQtQDxSWrXYL7a
         7zxCRuy8Z2NH2Yh8L2QUpoZGR9RcPOcvzTrxwN6InPfGkj0B7YLPueb6D12PDi7L+J3W
         SuHk9C1MFJp2PzN5XyUnyFwwLfgXLMJhBPB+qjDtKceehXYlvCDmMsX59frpalOmA544
         H5MOuxgZuudrgBLT6cuBE0+ShgWGtRiaKfUAHjSqe0JXQ5g9DcXkIIkySAqmEGpevp16
         O4JA==
X-Gm-Message-State: APjAAAVUO6y0aRHD8QhamiifSY70uvsaLEBYjisyGIkwir01fOzoTqxU
	Ln2JrBTsgDrwxmKwFPHP9UV4dXNpVDFAmtoX8XsPiHd75UrgtpnLgQUXIqqZxUdbpZ9qzHzOOG2
	/gwYE4gsTuNxIz3TE37zVUNZscbqHplsAMA4YnksEDzWexSFPGT2cyv1Ss3d1P0tFIg==
X-Received: by 2002:a6b:6304:: with SMTP id p4mr21002269iog.211.1559147245747;
        Wed, 29 May 2019 09:27:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxtvKbYXjikasdB8CdvkFQsGkIdLQ3p9bSzMk3biHwVbmhEbl7mUryUXg1ME7NxgysUSORb
X-Received: by 2002:a6b:6304:: with SMTP id p4mr21002234iog.211.1559147245127;
        Wed, 29 May 2019 09:27:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559147245; cv=none;
        d=google.com; s=arc-20160816;
        b=V9pWogN6qpBN3vUg/Z6LFY8QkQEmzlSJmS4Ezt1EfxYuXVHYfGoJ0pfMsOFyUQAW0U
         zUO/TWKIkkOlyhFfoM22xiusIBwdjeNg/VVD6MMEYxzjjZp0l9a3LaW0XTdD2kkeR/40
         bWNIlx9i6GzOP6wuqakrFgbWJ48TO+CBX64Oz7r8NGCI+eKKfcrgswsxiYvL+JkiSMdK
         iprLR+piEtmzIQU3uxjirk6pdK5osat97kpemSqFrFEyk9aNh2Ij9yoicnWxrmqPN5ZQ
         fy7yp0hrurrp6gqFlvFcaPieliSEQuSAnvSklpubjSPbfrWaOi0ZgOp5nsxgyonWMuT0
         xm1w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=X4eoqNRmc3LMmVaz3RomiWqkEf9IsoofKVkNtQpF48A=;
        b=qMaxge4RjJGjZgxL/hnDh8ieL37OqI80eSi9yiZjFEvibdIyIbQP/HRj4yaKyCESUg
         ZDiUqbY0DQUNS0m6GsSbC4tORIi4hEHOBXLHV0OYix+agu+KspOo/QR8+1i5hftNrPjD
         xEjKt8RtDFeM3rJ0o3YMC+rBzV6K5ENUTkhw7cPX0yzBE79VXFlu9bWizA6MsnTj+15T
         uaP9PUl7+RN41bG+G3osjcSaQWH54FBy+HQgDZt6sZIqHN+Vh7kFIn+wLuta46ehU1gd
         D+Iabbtuy1/FKxgyPVf+Wm7XorjR3hpw2BEQOOZHgF5RJNxpnewNGXR46CDxptGjyq+j
         QY2Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ekW1+hYr;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=l1h9Ya5F;
       spf=pass (google.com: domain of prvs=10523188fa=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10523188fa=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id s67si102518itb.61.2019.05.29.09.27.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 May 2019 09:27:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=10523188fa=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=ekW1+hYr;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=l1h9Ya5F;
       spf=pass (google.com: domain of prvs=10523188fa=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=10523188fa=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x4TGIlwS004991;
	Wed, 29 May 2019 09:26:47 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=X4eoqNRmc3LMmVaz3RomiWqkEf9IsoofKVkNtQpF48A=;
 b=ekW1+hYrEPN/8s5feZ6V82PdbWryQuWR6mL0syPRfnelA/rxBaaUty24NM69xkutC59x
 jpN1PIlWi6aJuKmjtkPKHg8fnNBqDLuI+0l3QV+otXQH/dOxxr5M6ZbJZla1kqSebiPS
 /kLWExZ75CtJG6lQkxUqocSoqVwtrbUFdKM= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2ssvdura4s-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 29 May 2019 09:26:47 -0700
Received: from prn-mbx01.TheFacebook.com (2620:10d:c081:6::15) by
 prn-hub05.TheFacebook.com (2620:10d:c081:35::129) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 29 May 2019 09:26:46 -0700
Received: from prn-hub02.TheFacebook.com (2620:10d:c081:35::126) by
 prn-mbx01.TheFacebook.com (2620:10d:c081:6::15) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 29 May 2019 09:26:46 -0700
Received: from NAM04-BN3-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.26) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 29 May 2019 09:26:46 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=X4eoqNRmc3LMmVaz3RomiWqkEf9IsoofKVkNtQpF48A=;
 b=l1h9Ya5FsbFDb5dlRSJRnty1ezE57/Kf7+RtWDiWe35mLJUihhRuYA72iX1XIc2TkCjmPWQdlnLoy8q1rqwSrUMdR3Zem+IzYVYo0asyPL2PQ1rUA3TCm2vhB/ZtXdtl2ZK8z7DQrRWCgIbKq+E+WROPislmRn6xAF5Q9zXyiRo=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3029.namprd15.prod.outlook.com (20.178.238.90) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1922.15; Wed, 29 May 2019 16:26:43 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1922.021; Wed, 29 May 2019
 16:26:43 +0000
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
Subject: Re: [PATCH v3 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Thread-Topic: [PATCH v3 4/4] mm/vmap: move BUG_ON() check to the unlink_va()
Thread-Index: AQHVFHAFBgyZ0nJ640yaup+zuj/dD6aAsSSAgAFzHYCAACl0gA==
Date: Wed, 29 May 2019 16:26:43 +0000
Message-ID: <20190529162638.GB3228@tower.DHCP.thefacebook.com>
References: <20190527093842.10701-1-urezki@gmail.com>
 <20190527093842.10701-5-urezki@gmail.com>
 <20190528225001.GI27847@tower.DHCP.thefacebook.com>
 <20190529135817.tr7usoi2xwx5zl2s@pc636>
In-Reply-To: <20190529135817.tr7usoi2xwx5zl2s@pc636>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO2PR05CA0009.namprd05.prod.outlook.com
 (2603:10b6:102:2::19) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::3:d07b]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: ee927282-3083-4aab-f95c-08d6e4526f70
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:BYAPR15MB3029;
x-ms-traffictypediagnostic: BYAPR15MB3029:
x-microsoft-antispam-prvs: <BYAPR15MB302984381AAAD3AA5C4C66F9BE1F0@BYAPR15MB3029.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:10000;
x-forefront-prvs: 0052308DC6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(136003)(376002)(39860400002)(396003)(366004)(189003)(199004)(6916009)(186003)(476003)(14454004)(478600001)(2906002)(11346002)(46003)(7416002)(6436002)(33656002)(66476007)(66556008)(64756008)(66446008)(256004)(53936002)(66946007)(316002)(446003)(6116002)(5660300002)(14444005)(73956011)(76176011)(1076003)(6512007)(305945005)(9686003)(54906003)(102836004)(7736002)(68736007)(4326008)(6486002)(86362001)(8936002)(6506007)(52116002)(486006)(386003)(229853002)(8676002)(81166006)(81156014)(99286004)(25786009)(71190400001)(6246003)(1411001)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3029;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: LcC68bM6F9+mEA32eqgXfaPu7PWFGl6jGge7jt4ZFeWMD37mlo3B10xFVnumYwjtlAPv0ABp5r5Mqv+UZPyHqSCH1wNNES+qXBYT8Esw60N4TmlWvponjD1oJxCLhit/6PTxTjVjt48mMw8kzqzAQvGRxJcHWzZmF/Liw9unDNBQ2jCrnHQ6JxoZ1SxR+IX0Qv/qpk0rncSawFLFXq0AmVUWn43E5A1jMq8IbVZT90DdJozVIY4pxjnQ81/LOTfpon/XjlZ1uF//0xmUm6Wm6ncPiDz5v6I6G3WtEz67SXmecoB24V7IRtFhHVELOMfdWZW5DPK3rGWfcBXYXRJnrH0yi32RgZiEv0FdnGq1L/vZABQII8ou7nbzxIQDXimY9naMx2QGkpF7zBQ9f+zAJbh6lwLGEfirnYyu4xLAUlE=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <9DE781A594B98E4EB961CFA26CC32854@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: ee927282-3083-4aab-f95c-08d6e4526f70
X-MS-Exchange-CrossTenant-originalarrivaltime: 29 May 2019 16:26:43.0828
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: guro@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3029
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-29_08:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1905290107
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, May 29, 2019 at 03:58:17PM +0200, Uladzislau Rezki wrote:
> Hello, Roman!
>=20
> > > Move the BUG_ON()/RB_EMPTY_NODE() check under unlink_va()
> > > function, it means if an empty node gets freed it is a BUG
> > > thus is considered as faulty behaviour.
> >=20
> > It's not exactly clear from the description, why it's better.
> >=20
> It is rather about if "unlink" happens on unhandled node it is
> faulty behavior. Something that clearly written in stone. We used
> to call "unlink" on detached node during merge, but after:
>=20
> [PATCH v3 3/4] mm/vmap: get rid of one single unlink_va() when merge
>=20
> it is not supposed to be ever happened across the logic.
>=20
> >
> > Also, do we really need a BUG_ON() in either place?
> >=20
> Historically we used to have the BUG_ON there. We can get rid of it
> for sure. But in this case, it would be harder to find a head or tail
> of it when the crash occurs, soon or later.
>=20
> > Isn't something like this better?
> >=20
> > diff --git a/mm/vmalloc.c b/mm/vmalloc.c
> > index c42872ed82ac..2df0e86d6aff 100644
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -1118,7 +1118,8 @@ EXPORT_SYMBOL_GPL(unregister_vmap_purge_notifier)=
;
> > =20
> >  static void __free_vmap_area(struct vmap_area *va)
> >  {
> > -       BUG_ON(RB_EMPTY_NODE(&va->rb_node));
> > +       if (WARN_ON_ONCE(RB_EMPTY_NODE(&va->rb_node)))
> > +               return;
> >
> I was thinking about WARN_ON_ONCE. The concern was about if the
> message gets lost due to kernel ring buffer. Therefore i used that.
> I am not sure if we have something like WARN_ONE_RATELIMIT that
> would be the best i think. At least it would indicate if a warning
> happens periodically or not.
>=20
> Any thoughts?

Hello, Uladzislau!

I don't have a strong opinion here. If you're worried about losing the mess=
age,
WARN_ON() should be fine here. I don't think that this event will happen of=
ten,
if at all.

Thanks!

