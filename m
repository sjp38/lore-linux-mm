Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D0ABC282DA
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 23:03:07 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25A7B2183F
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 23:03:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="PpC6OFyQ";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="jQ1wEpk5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25A7B2183F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B87A36B0005; Wed, 17 Apr 2019 19:03:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B38036B0006; Wed, 17 Apr 2019 19:03:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9D77F6B0007; Wed, 17 Apr 2019 19:03:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE1A6B0005
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 19:03:06 -0400 (EDT)
Received: by mail-pl1-f197.google.com with SMTP id x9so288757pln.0
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 16:03:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=SEEpP0WYkh4k0MJtvadNPgeueJmDQbdqvnqLPlyDGFU=;
        b=qlSsuIQ9JQT7JcbeJaTale3mqXdaBz/FnqdYSRuIQVKlMGBGvYykd8d5W2FZ7i9n76
         wE7NgxzoXZBeCb4IfI6xfl4TaNvGWDxAGqMINu0rJGkee3K2jiDz9+/62RgueHP36RFh
         XfjnNsrtEN3tEW+ISQZQ2s1Ch4/54UuUZ3KttBXG0MBmW4mRqXPYngNkmC7T2rMQH9E9
         k9/5ayvwv3xThLJaz1uCa05QnjLKXS/DoIj6MTMDOWTgRtfmdsyGl8Q1fzDtmx+bVrJR
         psvFCpsCrRhgi+IJtLTMOQOlRi/npJ96TQQH8WnAxt75XKZN74ophew+vHBe2Q7FBK3U
         18ug==
X-Gm-Message-State: APjAAAUNP0PaqjUAy5LiR88ynjmtjgv3xq4DneDr/TwaxD8+G1PcHLXY
	upHVsHMI4aDa9e6hqFwQ2j1ft/1JlfBzZ0FVdQXXb+qpE6rO1t4tshr8yuVwA322UCOuN1cFXqm
	DqDM+IdE7jWW3iazqjb/v9Ec7gq51+COiM7V6eOt+GnwCzjN7kg6dSq43+6AO2YKF5Q==
X-Received: by 2002:aa7:91c8:: with SMTP id z8mr92799739pfa.110.1555542185798;
        Wed, 17 Apr 2019 16:03:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwvxDx159VGJbWQBG1OivNYek5GVX/J5HPniKoBAOFDMpiAAdMRtIx2ueNA+FW5KlbievjL
X-Received: by 2002:aa7:91c8:: with SMTP id z8mr92799655pfa.110.1555542184969;
        Wed, 17 Apr 2019 16:03:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555542184; cv=none;
        d=google.com; s=arc-20160816;
        b=tvX8w2s+yYpd3/C9YIYMi/dg0DH8XDv7n9stq0mK902s8tM+kIr1OWIi4xUNZcXzRF
         rHW0KS9JzAyFjHv6Rnp2se9FeU1ZnuXBdgKwTGgQyzadoYxxO9V+dMHGh4Smx4YorALB
         Lc5tgKe/WiB3jmls7RwxUfB3zEUuCprWmtKauhwO6cbVlI0KkxqcSXno2DUNZuy3kDzn
         aa+H2sB/1RGPEdKGc29tGwdVlvk4Cq4TbqXjQ4FD+h+/bkCoZp66qt3fsOqwKTgSscWo
         Z9HgL8wwggR93HAYoug9tNuSHzMoobT7EQUQCWKReq47uy+t/ySY9LE1SVCmpqfyvQeq
         iaQg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=SEEpP0WYkh4k0MJtvadNPgeueJmDQbdqvnqLPlyDGFU=;
        b=oPEpNvSN47VsKnl89md4gh7rYSxxQtkPJDchHavJI42P+Lo6Ozqmf7bc3w4UiGG48h
         7bzpnHfdh0umnC9cbFfwA5rFUPXtjP8ok2m5VSBo3SrUl67BmaPNGVjENTFtGWvRmg4V
         eNbt+/x4PWmKIR+KHSJ0c+Lfhcq3Fjs5JV4plDC89xGaHASeQgs6DHvUdukNxQU02Y4i
         fXJNKZ3cBoBi+PH7fA0gslEEnxfdi4wx1o1UVm60w+WPSMgAPy0gOqWgkV5BJA2DZCqh
         /r52yX5ZhhRCUOMDY/X9cXx7j4/G5WM0s/QWaYuQT1wHCHhl18OrGPZomxJ8RHj/QYhV
         PR7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PpC6OFyQ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=jQ1wEpk5;
       spf=pass (google.com: domain of prvs=9010ac11df=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=9010ac11df=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id f1si144852pgm.373.2019.04.17.16.03.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 16:03:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=9010ac11df=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=PpC6OFyQ;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=jQ1wEpk5;
       spf=pass (google.com: domain of prvs=9010ac11df=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=9010ac11df=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109331.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x3HN2pbu019237;
	Wed, 17 Apr 2019 16:02:52 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=SEEpP0WYkh4k0MJtvadNPgeueJmDQbdqvnqLPlyDGFU=;
 b=PpC6OFyQiBX9sljmGjjzIUOq0UfpSVKwjkoWC9n+bmJMPQRuQ8++UbQ5+vvpEfJCcdsx
 c6ZquAPFfwWx3pnuc2VUWq97Fu4TxnnwyE68wb8rUnAGS3ZTcRNdGAROKk3CRBeAxA/h
 VIo5oTwQNkQbiy9uctB3YoHNzsOpJUdgNAk= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2rx7w1h8s6-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 17 Apr 2019 16:02:52 -0700
Received: from prn-hub03.TheFacebook.com (2620:10d:c081:35::127) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Wed, 17 Apr 2019 16:02:47 -0700
Received: from NAM05-CO1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.27) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Wed, 17 Apr 2019 16:02:47 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=SEEpP0WYkh4k0MJtvadNPgeueJmDQbdqvnqLPlyDGFU=;
 b=jQ1wEpk5xsG3yV5Bm/6oGqTSl2QT0MFXX20QZuAWMj8DuPVp9Z97rgBMhaR//ZbW0PLJcX5fD5/PZF3v0vIlTzbfwM2nes539PW3xCxWTIQaFPhDSWrXdtTNcKZgIlyiHidibbqr84YRl6PcdV+QtZwfK73/egolH/czk6nqx/g=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3190.namprd15.prod.outlook.com (20.179.56.92) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1813.11; Wed, 17 Apr 2019 23:02:25 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d1a1:d74:852:a21e%5]) with mapi id 15.20.1792.021; Wed, 17 Apr 2019
 23:02:25 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Roman Gushchin <guroan@gmail.com>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Kernel Team <Kernel-team@fb.com>,
        "Matthew
 Wilcox" <willy@infradead.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "Vlastimil Babka" <vbabka@suse.cz>
Subject: Re: [PATCH v4 1/2] mm: refactor __vunmap() to avoid duplicated call
 to find_vm_area()
Thread-Topic: [PATCH v4 1/2] mm: refactor __vunmap() to avoid duplicated call
 to find_vm_area()
Thread-Index: AQHU9VVf0J9odzgRMk2KdtJT9GHQdKZA5rSAgAAR2wA=
Date: Wed, 17 Apr 2019 23:02:25 +0000
Message-ID: <20190417230219.GA5538@tower.DHCP.thefacebook.com>
References: <20190417194002.12369-1-guro@fb.com>
 <20190417194002.12369-2-guro@fb.com>
 <20190417145827.8b1c83bf22de8ba514f157e3@linux-foundation.org>
In-Reply-To: <20190417145827.8b1c83bf22de8ba514f157e3@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR12CA0031.namprd12.prod.outlook.com
 (2603:10b6:301:2::17) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::1:7270]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 356c02f2-6f66-4a70-7791-08d6c388c1b1
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600141)(711020)(4605104)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7193020);SRVR:BYAPR15MB3190;
x-ms-traffictypediagnostic: BYAPR15MB3190:
x-microsoft-antispam-prvs: <BYAPR15MB3190FF362FBA5B9062AA9356BE250@BYAPR15MB3190.namprd15.prod.outlook.com>
x-forefront-prvs: 0010D93EFE
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(376002)(346002)(396003)(136003)(39860400002)(366004)(199004)(189003)(25786009)(6916009)(71190400001)(71200400001)(476003)(6486002)(5660300002)(46003)(54906003)(11346002)(8676002)(486006)(97736004)(478600001)(86362001)(1076003)(6436002)(316002)(53546011)(6506007)(256004)(6512007)(6246003)(6116002)(14444005)(446003)(186003)(386003)(81156014)(81166006)(53936002)(8936002)(102836004)(7736002)(229853002)(4326008)(52116002)(2906002)(68736007)(33656002)(9686003)(76176011)(305945005)(99286004)(14454004)(37363001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3190;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: M72ARGDIpm80FoZXz9ldgVyLzaT3sBSixZt4G4J7xGTf6Zc+oHddh56PLAwmYH4wA9ernKV6zwD9zknni5VWbYbghWGU9rowWyvWOChJZa9Pg3Y5GiohB3h1m+mjA5cngTfA+FY2ujsYiTuz76vGZHHEMTLpoEEjiSPSi0nfyoj4BSShbqPx4EiURnf/9Gi1yMe7CuhU8QJjVXNFemly/Et68nZ893/wiPSlf5P368RyssoO6DzNJHv/1Z7HjzNcebwZ8VN6h5hCSwuAsdr9nLlymH8vsytYPq4TxHJ1vXRbexp80e6gZ2L81CGHNEwtOh6JTqLRMm79ztisenn7qZbVD59yVeGisTh7imw9PdBnKKwuV/DEUuDtghPfJDUSku+VTSTyjWSVDZFuJmRZbPELEkz24TfhFOsvQTxbk0M=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <2B6F40F0B437D94AA8B7732ED7F6698B@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 356c02f2-6f66-4a70-7791-08d6c388c1b1
X-MS-Exchange-CrossTenant-originalarrivaltime: 17 Apr 2019 23:02:25.5428
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3190
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-04-17_11:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 17, 2019 at 02:58:27PM -0700, Andrew Morton wrote:
> On Wed, 17 Apr 2019 12:40:01 -0700 Roman Gushchin <guroan@gmail.com> wrot=
e:
>=20
> > __vunmap() calls find_vm_area() twice without an obvious reason:
> > first directly to get the area pointer, second indirectly by calling
> > remove_vm_area(), which is again searching for the area.
> >=20
> > To remove this redundancy, let's split remove_vm_area() into
> > __remove_vm_area(struct vmap_area *), which performs the actual area
> > removal, and remove_vm_area(const void *addr) wrapper, which can
> > be used everywhere, where it has been used before.
> >=20
> > On my test setup, I've got 5-10% speed up on vfree()'ing 1000000
> > of 4-pages vmalloc blocks.
> >=20
> > Perf report before:
> >   22.64%  cat      [kernel.vmlinux]  [k] free_pcppages_bulk
> >   10.30%  cat      [kernel.vmlinux]  [k] __vunmap
> >    9.80%  cat      [kernel.vmlinux]  [k] find_vmap_area
> >    8.11%  cat      [kernel.vmlinux]  [k] vunmap_page_range
> >    4.20%  cat      [kernel.vmlinux]  [k] __slab_free
> >    3.56%  cat      [kernel.vmlinux]  [k] __list_del_entry_valid
> >    3.46%  cat      [kernel.vmlinux]  [k] smp_call_function_many
> >    3.33%  cat      [kernel.vmlinux]  [k] kfree
> >    3.32%  cat      [kernel.vmlinux]  [k] free_unref_page
> >=20
> > Perf report after:
> >   23.01%  cat      [kernel.kallsyms]  [k] free_pcppages_bulk
> >    9.46%  cat      [kernel.kallsyms]  [k] __vunmap
> >    9.15%  cat      [kernel.kallsyms]  [k] vunmap_page_range
> >    6.17%  cat      [kernel.kallsyms]  [k] __slab_free
> >    5.61%  cat      [kernel.kallsyms]  [k] kfree
> >    4.86%  cat      [kernel.kallsyms]  [k] bad_range
> >    4.67%  cat      [kernel.kallsyms]  [k] free_unref_page_commit
> >    4.24%  cat      [kernel.kallsyms]  [k] __list_del_entry_valid
> >    3.68%  cat      [kernel.kallsyms]  [k] free_unref_page
> >    3.65%  cat      [kernel.kallsyms]  [k] __list_add_valid
> >    3.19%  cat      [kernel.kallsyms]  [k] __purge_vmap_area_lazy
> >    3.10%  cat      [kernel.kallsyms]  [k] find_vmap_area
> >    3.05%  cat      [kernel.kallsyms]  [k] rcu_cblist_dequeue
> >=20
> > ...
> >
> > --- a/mm/vmalloc.c
> > +++ b/mm/vmalloc.c
> > @@ -2068,6 +2068,24 @@ struct vm_struct *find_vm_area(const void *addr)
> >  	return NULL;
> >  }
> > =20
> > +static struct vm_struct *__remove_vm_area(struct vmap_area *va)
> > +{
> > +	struct vm_struct *vm =3D va->vm;
> > +
> > +	might_sleep();
>=20
> Where might __remove_vm_area() sleep?
>=20
> From a quick scan I'm only seeing vfree(), and that has the
> might_sleep_if(!in_interrupt()).
>=20
> So perhaps we can remove this...

Agree. Here is the patch.

Thank you!

--

From 4adf58e4d3ffe45a542156ca0bce3dc9f6679939 Mon Sep 17 00:00:00 2001
From: Roman Gushchin <guro@fb.com>
Date: Wed, 17 Apr 2019 15:55:49 -0700
Subject: [PATCH] mm: remove might_sleep() in __remove_vm_area()

__remove_vm_area() has a redundant might_sleep() call, which isn't
really required, because the only place it can sleep is vfree()
and it already contains might_sleep_if(!in_interrupt()).

Suggested-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Roman Gushchin <guro@fb.com>
---
 mm/vmalloc.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 69a5673c4cd3..4a91acce4b5f 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -2079,8 +2079,6 @@ static struct vm_struct *__remove_vm_area(struct vmap=
_area *va)
 {
 	struct vm_struct *vm =3D va->vm;
=20
-	might_sleep();
-
 	spin_lock(&vmap_area_lock);
 	va->vm =3D NULL;
 	va->flags &=3D ~VM_VM_AREA;
--=20
2.20.1

