Return-Path: <SRS0=rceO=VX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-0.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,
	SPF_PASS autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82384C7618F
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 21:20:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 24C8322BE8
	for <linux-mm@archiver.kernel.org>; Fri, 26 Jul 2019 21:20:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="GDd2/Bif";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="VJc46yTU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 24C8322BE8
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A04126B0003; Fri, 26 Jul 2019 17:20:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9B51D8E0003; Fri, 26 Jul 2019 17:20:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8569D8E0002; Fri, 26 Jul 2019 17:20:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 65D2F6B0003
	for <linux-mm@kvack.org>; Fri, 26 Jul 2019 17:20:31 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id k21so40588245ywk.2
        for <linux-mm@kvack.org>; Fri, 26 Jul 2019 14:20:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=jVnRWhXm2MWCV1Qc5izacs5GiuNHypcF1Ji6eqWRSVs=;
        b=FsjZmMpCPkp6kk2pbXB/fKreQNlRq3mkEfHapvpoIFk3QdWQ3ADyBP7h88cNjPlAFH
         GIyjl0lDJyIKVfRTgyXF9UVpkkhbKN+tkdK35oeVbjeqnKA/ECMxQhpwuO8Npw/CxGlw
         aaTYSLfraJbMwrE0Nb55oFtJb76cZYHr2sJVp0aHjZcqEKWNeLIthr5W3CYAM4RcTJOU
         yfpSOmqS25LjNVHpRv8IQmqE7xBYDIrmtGaH4QVtYDeVwd7Pcxe///sH6Vy9Yx9Y5beG
         JNW/W/uAiLbKaKOYd5Vc7QUq1MFyQbpOcqaVwG7lXiatUZvBoT9EkyZzzB/EOX9y5XQy
         8QEQ==
X-Gm-Message-State: APjAAAVK67JYiyOT7Mb1Su85GEfpHF5Q2rJ8UKYKx1ienxXwBnK9wV0L
	o3rytsdDPTwrPO0MLml9cn/cESRobyoplcuOFuJw0wDLia34k/1JOM/4ostdvp/mxneAfNTrJj1
	lWwiyXerDKnokyLjNLHunW0Pzva0j35JoB7a8yEAHRtIUDtlCEMI150Wqg7u3cy1uzg==
X-Received: by 2002:a25:2c08:: with SMTP id s8mr61711753ybs.457.1564176031061;
        Fri, 26 Jul 2019 14:20:31 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzaCBdlb9u6SMjOKiEAIIlMPnuGLtGiGF81vRddZTp1s96IOt0Snbqi1QCa+7Q3iiWPnj7+
X-Received: by 2002:a25:2c08:: with SMTP id s8mr61711705ybs.457.1564176030110;
        Fri, 26 Jul 2019 14:20:30 -0700 (PDT)
ARC-Seal: i=2; a=rsa-sha256; t=1564176030; cv=pass;
        d=google.com; s=arc-20160816;
        b=RIXOtzURKikpO4hgUIzWOLYzF86PpLQEpLAwoPhrnXk3P8f9wz99sOmS3wRh8k8HxL
         aHn2O53Io/WkQkIt7ZqzkuEjna2cJaQaXQQ9Sr6GYrAcoYdIT01yicmHGffk2PsbZyZk
         kcZzI6aHwn648kvMO2nKohcnVhqwIhh2P+9RLx5FAUVp4oeLIyXpN9d/M/mwjcJEUqPQ
         q60n1GTSCF7JYbIPyD0moGavHtK57Hm1dhQHb48c4lzyZJPkF0CkFFLOB6yvIXivzt57
         KMe+iHNFaNRe85nnx8461Uq+XKj8GTSmwROT6G301Mgq8BVt/FYcAgksaVV0/Y+bm7va
         /a2g==
ARC-Message-Signature: i=2; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=jVnRWhXm2MWCV1Qc5izacs5GiuNHypcF1Ji6eqWRSVs=;
        b=yUxAMhYbMYhGHb6z+GP+ytetyWnbsmf8N8sMuM6JPKcZycLrNPapJqs941i8/gcC2h
         lDalFGuAK8sf90eLopNnEBJOKgU8fFGpzJ+T3mXdhqFr8fjz6aQWD14hYJF4/I/88Y9k
         gMOpTJoZYX14vKk72FtaYxbeT9jBaPlhFlKxpFmH3mkJQlr6X7K49QhT//w1tYYqRtus
         XAi++LisIwEx5HV6Rark7Oz7/NUSCE4xppk1MeN16+P7ueuH6vuAbdsN9IXAuriHTuhu
         Mzu3eEpyuZ4tqXWgTpvKmJvSqH6FzojWWA9NTjo3QmuktNwPuk4C6uSeHrLLeHcJCUH8
         HgnA==
ARC-Authentication-Results: i=2; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="GDd2/Bif";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=VJc46yTU;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21101f516b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id p16si19322876yba.446.2019.07.26.14.20.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Jul 2019 14:20:30 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b="GDd2/Bif";
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector2-fb-onmicrosoft-com header.b=VJc46yTU;
       arc=pass (i=1 spf=pass spfdomain=fb.com dkim=pass dkdomain=fb.com dmarc=pass fromdomain=fb.com);
       spf=pass (google.com: domain of prvs=21101f516b=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=21101f516b=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109334.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x6QLHUtC008904;
	Fri, 26 Jul 2019 14:19:57 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=jVnRWhXm2MWCV1Qc5izacs5GiuNHypcF1Ji6eqWRSVs=;
 b=GDd2/BifOW6FME0UHZB3Ztga0MHxlksvfUGzkmrL1yqGNuaP0t+U8cu5jlWZK+wyLDLW
 6YJ8m6ChHtJnFFRDWoAuvy4+c5V1hW90/2oeMRW8ocImjVjfopI+Zop7cuc1tW+oleRh
 vzbiVVtbAJkB+nevgVVFA1bxzbHgS0JikwI= 
Received: from maileast.thefacebook.com ([163.114.130.16])
	by mx0a-00082601.pphosted.com with ESMTP id 2u02eb9qpx-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128 verify=NOT);
	Fri, 26 Jul 2019 14:19:56 -0700
Received: from ash-exhub101.TheFacebook.com (2620:10d:c0a8:82::e) by
 ash-exhub103.TheFacebook.com (2620:10d:c0a8:82::c) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256) id
 15.1.1713.5; Fri, 26 Jul 2019 14:19:55 -0700
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (100.104.31.183)
 by o365-in.thefacebook.com (100.104.35.173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256) id 15.1.1713.5
 via Frontend Transport; Fri, 26 Jul 2019 14:19:55 -0700
ARC-Seal: i=1; a=rsa-sha256; s=arcselector9901; d=microsoft.com; cv=none;
 b=mUv2Rgmw0JEXe+8Os+s7g2qKB+4vJazLXSS8LqDR7NN766nZwayjSi4klqRSkDR06C4VrQKhPiZQrCKHA9czKBkRrbL2sPSiwfkqis7+e7JkdxJSN6Bawp7yflYMSenFuQY93h3RwOP2jXTBUtRgbqoNpdNppevFzRlMgtVjgKgPhA/wNbGwF9IjlZDovsrEiB6We4QN/qciitxFC0KjpgW0SqIHp7KBlpyBSqLFsF9hw7Dv09mYWVfr+bJNGk3ebOBUtG03Cn2lxlOhkpxydN1reUpPJJ9S9KJIhA/I2qTmBtLotPPqOK0qca/qRW/RLV2Al+G2vAoONiEVedTP8g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=microsoft.com;
 s=arcselector9901;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jVnRWhXm2MWCV1Qc5izacs5GiuNHypcF1Ji6eqWRSVs=;
 b=htf+1g10xLW9/JYhj45EQV6sNqC7v84F4TGe+ajpys9MyTwU0i1C7Ni9kjyom0RT6SXkCsPi/22fqgJutb0x2mGB/sjNnXUNqN6l4cY638E660iwM8PChCpCVrL+1IiPaB4fShUN3+TBY2eVrGPqig9762hPTwpcNNU6/ZFSFMfjiy4Cu8m+UvI2CIQ89sCv3Z7tdhDD3GaW6Qv6eCiQyQWIkvliaoRP1uV4DYqrJLc2LIGzoda7mKLXMG52m60jOdL30gaVTX7TP6dfcElHJSvVKXBAww++FXxw8099R9oWqk81MD2+QeywnZPyMKzQbptXp9ZYpv7tb5lJ0ZI+VA==
ARC-Authentication-Results: i=1; mx.microsoft.com 1;spf=pass
 smtp.mailfrom=fb.com;dmarc=pass action=none header.from=fb.com;dkim=pass
 header.d=fb.com;arc=none
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector2-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=jVnRWhXm2MWCV1Qc5izacs5GiuNHypcF1Ji6eqWRSVs=;
 b=VJc46yTU0dfVj3ldRlDlfbkiWLcz1y0Qc6EmLjEX7mrsDnHhVX1iz729W69xGK8Tr/PpxVToBR5+5A+7km34DT7kuW87bEapBqvT8Hwid6MzRImrRTRA5hXjfpnVEcyGVT2UXBPzhVE+1oK+ESTY5iXDKIGXEjUHt02+7w/I084=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.3.22) by
 MWHPR15MB1902.namprd15.prod.outlook.com (10.174.255.21) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.2094.16; Fri, 26 Jul 2019 21:19:54 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::4066:b41c:4397:27b7]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::4066:b41c:4397:27b7%7]) with mapi id 15.20.2094.013; Fri, 26 Jul 2019
 21:19:54 +0000
From: Song Liu <songliubraving@fb.com>
To: Oleg Nesterov <oleg@redhat.com>
CC: lkml <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>,
        "Andrew Morton" <akpm@linux-foundation.org>,
        "matthew.wilcox@oracle.com"
	<matthew.wilcox@oracle.com>,
        "kirill.shutemov@linux.intel.com"
	<kirill.shutemov@linux.intel.com>,
        "peterz@infradead.org"
	<peterz@infradead.org>,
        "rostedt@goodmis.org" <rostedt@goodmis.org>,
        "Kernel
 Team" <Kernel-team@fb.com>,
        "william.kucharski@oracle.com"
	<william.kucharski@oracle.com>
Subject: Re: [PATCH v8 2/4] uprobe: use original page when all uprobes are
 removed
Thread-Topic: [PATCH v8 2/4] uprobe: use original page when all uprobes are
 removed
Thread-Index: AQHVQfsnepoAlMhPK0qmuIU0gpphb6bZpE2AgAB5kgCAAOAOAIAAqHSAgADyToCAANMVgA==
Date: Fri, 26 Jul 2019 21:19:54 +0000
Message-ID: <4398BBD5-31AB-4342-9572-32763B016175@fb.com>
References: <20190724083600.832091-1-songliubraving@fb.com>
 <20190724083600.832091-3-songliubraving@fb.com>
 <20190724113711.GE21599@redhat.com>
 <BCE000B2-3F72-4148-A75C-738274917282@fb.com>
 <20190725081414.GB4707@redhat.com>
 <A0D24D6F-B649-4B4B-8C33-70B7DCB0D814@fb.com>
 <20190726084423.GA16112@redhat.com>
In-Reply-To: <20190726084423.GA16112@redhat.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.104.11)
x-originating-ip: [2620:10d:c090:180::1:bb04]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: bb4ea2bf-d7ea-4df1-4355-08d7120f00c9
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600148)(711020)(4605104)(1401327)(2017052603328)(7193020);SRVR:MWHPR15MB1902;
x-ms-traffictypediagnostic: MWHPR15MB1902:
x-microsoft-antispam-prvs: <MWHPR15MB1902354F2CEBE716297B9D33B3C00@MWHPR15MB1902.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:8273;
x-forefront-prvs: 01106E96F6
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(39860400002)(346002)(366004)(376002)(136003)(52314003)(199004)(189003)(14454004)(486006)(6116002)(229853002)(6436002)(25786009)(50226002)(8676002)(46003)(316002)(256004)(6512007)(53936002)(478600001)(99286004)(476003)(54906003)(5660300002)(446003)(305945005)(186003)(14444005)(2616005)(76176011)(11346002)(86362001)(6486002)(53546011)(71190400001)(64756008)(33656002)(71200400001)(68736007)(76116006)(102836004)(66446008)(2906002)(6916009)(6246003)(66946007)(36756003)(4326008)(6506007)(81156014)(4744005)(57306001)(8936002)(91956017)(81166006)(66476007)(66556008)(7736002);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1902;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: v8CgET2JkHFHThws0wOB1vMi97P7LEaiDWlJmwDXBc4vgsVlB2/o9A1XTyHSxXbKsGy6WKloWW4DpF3f1ao2p06o8hhs5DfyZJnDiN6IEnCCwZdxxrSAY6F8cE0Tjz62FpxeNEXIN9W2Lu6TOeizRHxpEV5ZKkQuOvFbH7ewXHWoRaAzQVqPpoUH7B6ec3OebsF8qRnHEon8L+/vYokuWGb35CdPNg+4fdUjnb1GvKBNXcGf1YRTdQpqpyXicDzRh5vs/oEy9m3NW80YcEmWrU21CLvWVa6OkF/IaOh4P5oIsxnG3I91CfuM91BgHafQoz8CnndFlnx1u65SjgRX3cTHHpQ8eWlRl1tHal53QAB8jZhq8rIHP4MT8UGCHHIt95XxW3Fk75do/r9q3xYdVfjvvC14eDywqn1QZWkfiEs=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <8092EDAF1C73394291E86563B64E33D3@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: bb4ea2bf-d7ea-4df1-4355-08d7120f00c9
X-MS-Exchange-CrossTenant-originalarrivaltime: 26 Jul 2019 21:19:54.0952
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-userprincipalname: songliubraving@fb.com
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1902
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-07-26_15:,,
 signatures=0
X-Proofpoint-Spam-Details: rule=fb_default_notspam policy=fb_default score=0 priorityscore=1501
 malwarescore=0 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0
 clxscore=1015 lowpriorityscore=0 mlxscore=0 impostorscore=0
 mlxlogscore=710 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1906280000 definitions=main-1907260241
X-FB-Internal: deliver
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Jul 26, 2019, at 1:44 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>=20
> On 07/25, Song Liu wrote:
>>=20
>> I guess I know the case now. We can probably avoid this with an simp=10l=
e=20
>> check for old_page =3D=3D new_page?
>=20
> better yet, I think we can check PageAnon(old_page) and avoid the unneces=
sary
> __replace_page() in this case. See the patch below.

I added PageAnon(old_page) check in v9 of the patch.=20

>=20
> Anyway, why __replace_page() needs to lock both pages? This doesn't look =
nice
> even if it were correct. I think it can do lock_page(old_page) later.
>=20

Agreed. I have changed the v9 to only unmap old_page. So it should be clean=
er.=20

Thanks again for these good suggestions,
Song=

