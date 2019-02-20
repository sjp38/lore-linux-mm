Return-Path: <SRS0=8949=Q3=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C6064C43381
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:31:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 710E42147A
	for <linux-mm@archiver.kernel.org>; Wed, 20 Feb 2019 05:31:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="C01coSkU";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="YL5eGtR5"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 710E42147A
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 0F0C18E000B; Wed, 20 Feb 2019 00:31:52 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 09FE88E0007; Wed, 20 Feb 2019 00:31:52 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED06D8E000B; Wed, 20 Feb 2019 00:31:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id BCE7A8E0007
	for <linux-mm@kvack.org>; Wed, 20 Feb 2019 00:31:51 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id b40so6523109qte.1
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 21:31:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=2xJZ/YKKSXbrpB9nIObxvJGHP/f0BJ+7rmocOG9ikCw=;
        b=Ie3k3yoxY+8qOc2k/Zbo2H0NhUvqtOic48ul4amn1QMzdZYZ0oI7UcrCkockPjEmn5
         tj0z4PtIzzGBsD51L7A4Lbujy1LxEegEJJpMCTH/X9kaIOzOzOuTxqY4f7WulPTIz/vW
         pn4vPdw72bXE8IyFK+TVqLVe572O4Gx19SqmuurS9QtfuULZjTbt6Ealf34N+VaJDOvS
         s9WYRHgPHkJEIif9MufXc7vGpEjU6YqGcGuAQ3d7VCfgBXwzSl4jeXH2FBQlqwOnGZX6
         zu/d9vEqH3Z2XfS79YP2/EyKmomYZfxlDTxtIkbE7PWWvhkWKDkjCDJUZItEYtx8IE4l
         hLPg==
X-Gm-Message-State: AHQUAuZ8Cje5Lnn6gGSLrkAk9yaNZ68dolNAv/91OT/tD/XBZeYgGssx
	xtTccuB1GZraezP+pZmPCRpy5JB2xji6CLy1kcdQ7Qh2fPyLzCkcdFB359pIQQ1iSJlVQvVfr/1
	dWfVcSWvyLVYOFePAGm5RZH5XB240OFAG/o5RGlBloZ0qNgmnKnujExO+BhcnEoURVQ==
X-Received: by 2002:a37:96c4:: with SMTP id y187mr22406033qkd.149.1550640711468;
        Tue, 19 Feb 2019 21:31:51 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaEmpiive/aUigM+fCMJWm0PKnmeVFUwxi25UqF5sxbYTLaQ+mA5G+I3w0KsAVZ50zNXXsY
X-Received: by 2002:a37:96c4:: with SMTP id y187mr22406000qkd.149.1550640710659;
        Tue, 19 Feb 2019 21:31:50 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550640710; cv=none;
        d=google.com; s=arc-20160816;
        b=RTDCMRZ23J64hMiBN+2yv0p6TQ6t+Ejuc+7XUIh9ZP6LxikehH73XcNFtB6Ngc6CEF
         U6JB+Uxn8joAy3kXHPdiLlNtpaXn7yI1oB4bF/NsPGo1NAGGzksnhJ174//mUcwbdn62
         o0HC5188EQwDtK9eR/w34MphrUO9lrEVjcceG4OZCWioDM9lYMPFf5VpO2mNyEYqD19+
         A45R2IzMHomdIucILXLZMlqm65dVtII7XOVERALSLMpnU7KwTFfGVpXeURA1zURfyrX3
         wra2tQrw4xAAQTrVQHjT1+UhoOwH3looMQ0G9yZWQnGYL8klVDoqIsWtBo8zxJYMFdbP
         6erw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=2xJZ/YKKSXbrpB9nIObxvJGHP/f0BJ+7rmocOG9ikCw=;
        b=o9bIj/WmAJzbv6Ca3IwJqWCaySRnWJIWyJjqBvE2BMnhh+NQpJSuSxi0eFcQppkrf3
         6wdUd4d5eMXatD3uxZkpzfYNDkVoXTjyLpu0sYGaGmQKj19Olt8HtDAJ24lS0Y/7L2Rc
         7zWkSqR7EmN22ZGXy+HP6UkSEOU+5CQysa+41IPRgzLgBgS16CdopK+e1UfiImPdEbtv
         QxLceZic2OeT/yfNIHEMXVVyVhEV8PMzT4If06sq7mBWwrIBCbiRplKkqv731bntYnMQ
         HgbGh7/dNyXmfBoNMYO5zNna96FUAWuPOX0bF+9GfW+/le3M+SP5azBiI7M3+5+rksAY
         XFfw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=C01coSkU;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=YL5eGtR5;
       spf=pass (google.com: domain of prvs=795499e935=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=795499e935=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id s17si4239724qve.22.2019.02.19.21.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 19 Feb 2019 21:31:50 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=795499e935=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=C01coSkU;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=YL5eGtR5;
       spf=pass (google.com: domain of prvs=795499e935=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=795499e935=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148460.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1K5VXFG019982;
	Tue, 19 Feb 2019 21:31:35 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=2xJZ/YKKSXbrpB9nIObxvJGHP/f0BJ+7rmocOG9ikCw=;
 b=C01coSkU3mWXO6Lft1lajjHOkzb6MphJb7sVPfKen0j4t529qW5PZow+YX7V6WeSXSOT
 +LGvVZt+ls8LmFrXADiYk1/hSPRajJHzXJTE4MaeVsBhVNNEHhhO6g/ViE8J75i8doYu
 db1GiDDQGZWLZEy0DRzHAPfvjUjHRLE5r/o= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qrx0grdhs-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Tue, 19 Feb 2019 21:31:34 -0800
Received: from frc-mbx01.TheFacebook.com (2620:10d:c0a1:f82::25) by
 frc-hub05.TheFacebook.com (2620:10d:c021:18::175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Tue, 19 Feb 2019 21:31:03 -0800
Received: from frc-hub02.TheFacebook.com (2620:10d:c021:18::172) by
 frc-mbx01.TheFacebook.com (2620:10d:c0a1:f82::25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Tue, 19 Feb 2019 21:31:03 -0800
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.72) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Tue, 19 Feb 2019 21:31:03 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=2xJZ/YKKSXbrpB9nIObxvJGHP/f0BJ+7rmocOG9ikCw=;
 b=YL5eGtR5uL9NqoZa8XAFTZDu2V0NEtKyRfC761NT7YKZXZnCKAAqbm6vCalsEKuIod4FYjfbbvFR9whYLHybziQOB7xqaIknxXYSBiuaGpwrBgQPVQ3pJIM3a3jGccUEMbJjuTnS4YXjO29D47XetwV3YjMpfdEKv2LVmTg9n1c=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB3382.namprd15.prod.outlook.com (20.179.59.15) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Wed, 20 Feb 2019 05:31:01 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1601.016; Wed, 20 Feb 2019
 05:31:01 +0000
From: Roman Gushchin <guro@fb.com>
To: Dave Chinner <dchinner@redhat.com>
CC: Rik van Riel <riel@surriel.com>,
        "lsf-pc@lists.linux-foundation.org"
	<lsf-pc@lists.linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "mhocko@kernel.org" <mhocko@kernel.org>,
        "guroan@gmail.com" <guroan@gmail.com>,
        Kernel Team <Kernel-team@fb.com>,
        "hannes@cmpxchg.org" <hannes@cmpxchg.org>
Subject: Re: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Topic: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Index: AQHUx+p7YU4wmFXyC0Kxxb6WvO6kKqXmXyYAgAEC0wCAAGNEgIAALJyAgAApMACAABAIgA==
Date: Wed, 20 Feb 2019 05:31:01 +0000
Message-ID: <20190220053052.GA13267@castle.DHCP.thefacebook.com>
References: <20190219003140.GA5660@castle.DHCP.thefacebook.com>
 <20190219020448.GY31397@rh>
 <7f66dd5242ab4d305f43d85de1a8e514fc47c492.camel@surriel.com>
 <20190219232627.GZ31397@rh>
 <9446a6a8a6d60cf5727d348d34969ba1e67e1c58.camel@surriel.com>
 <20190220043332.GA31397@rh>
In-Reply-To: <20190220043332.GA31397@rh>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: MWHPR19CA0095.namprd19.prod.outlook.com
 (2603:10b6:320:1f::33) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:69b7]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 375f7409-a942-42ac-d302-08d696f4994b
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB3382;
x-ms-traffictypediagnostic: BYAPR15MB3382:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB3382;20:coqyegDqGb0SdDYrAhL9EoDK0BJ1TAv8VlgSZaCdHxacZT4Kf62Mh/ga3XDz6eYuVxDwxMly/WrDgaTcw0UWGV3bZSrbvxStzalvMfa/7YjxLo44TdFasNWDKzACOiXjuWsUYm8uxTKXmqjVQ168TL6fIGD4RyEoL9JLEaSpP9U=
x-microsoft-antispam-prvs: <BYAPR15MB3382461B92B7E201F3A5DF15BE7D0@BYAPR15MB3382.namprd15.prod.outlook.com>
x-forefront-prvs: 0954EE4910
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(979002)(136003)(346002)(39860400002)(376002)(366004)(396003)(189003)(199004)(186003)(46003)(25786009)(68736007)(6506007)(476003)(486006)(14454004)(71190400001)(478600001)(71200400001)(6116002)(11346002)(93886005)(86362001)(446003)(8676002)(386003)(81166006)(5660300002)(81156014)(102836004)(105586002)(106356001)(1076003)(33656002)(6436002)(14444005)(2906002)(305945005)(6486002)(9686003)(256004)(6512007)(97736004)(7736002)(6246003)(54906003)(53936002)(52116002)(229853002)(99286004)(33896004)(316002)(76176011)(8936002)(4326008)(6916009)(969003)(989001)(999001)(1009001)(1019001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB3382;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: fhcJl0hxIjHarWsLVdY6RP00mNanGTIUyrhY3dTdheVoM3FRu4y7PnzLGS46bNSiF8ptSruRbSZmcPkslA1SOWrONVv1ikzsFy+ylVR8wDXmXAD9abO0J9id/nuuSN+57oJOnSe2vmHHIocnLYT2sSm8iMMUIBE+67vHPnqW70jfQGffc+37lW0BGUSltN/7MOZPb87f9qtXisyzlvKc43xiaaY23rCHopPIzxtPTImv9QlAb7pzUsY6qvFx5GJB3ZUv6+ZMB0HewwD3c16C5HwCMfS/v/D86OVNmloRgbbj4KSBmkRKQbe7VokB+gWids4HfVqKUSH1chMShB9cOcbUgLLi0oOccoiySbGDxK/iU9HpmVdoGz10cuKPVCP1KXxCuXl0iJmfc4CBSb344VYLC9Myp1iatoGCna0c3hs=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <469A818F5B365942A73522A54FE28095@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 375f7409-a942-42ac-d302-08d696f4994b
X-MS-Exchange-CrossTenant-originalarrivaltime: 20 Feb 2019 05:31:00.0028
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB3382
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-20_05:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 20, 2019 at 03:33:32PM +1100, Dave Chinner wrote:
> On Tue, Feb 19, 2019 at 09:06:07PM -0500, Rik van Riel wrote:
> > On Wed, 2019-02-20 at 10:26 +1100, Dave Chinner wrote:
> > > On Tue, Feb 19, 2019 at 12:31:10PM -0500, Rik van Riel wrote:
> > > > On Tue, 2019-02-19 at 13:04 +1100, Dave Chinner wrote:
> > > > > On Tue, Feb 19, 2019 at 12:31:45AM +0000, Roman Gushchin wrote:
> > > > > > Sorry, resending with the fixed to/cc list. Please, ignore the
> > > > > > first letter.
> > > > >=20
> > > > > Please resend again with linux-fsdevel on the cc list, because
> > > > > this
> > > > > isn't a MM topic given the regressions from the shrinker patches
> > > > > have all been on the filesystem side of the shrinkers....
> > > >=20
> > > > It looks like there are two separate things going on here.
> > > >=20
> > > > The first are an MM issues, one of potentially leaking memory
> > > > by not scanning slabs with few items on them,
> > >=20
> > > We don't leak memory. Slabs with very few freeable items on them
> > > just don't get scanned when there is only light memory pressure.
> > > That's /by design/ and it is behaviour we've tried hard over many
> > > years to preserve. Once memory pressure ramps up, they'll be
> > > scanned just like all the other slabs.
> >=20
> > That may have been fine before cgroups, but when
> > a system can have (tens of) thousands of slab
> > caches, we DO want to scan slab caches with few
> > freeable items in them.
> >=20
> > The threshold for "few items" is 4096, not some
> > actually tiny number. That can add up to a lot
> > of memory if a system has hundreds of cgroups.
>=20
> That doesn't sound right. The threshold is supposed to be low single
> digits based on the amount of pressure on the page cache, and it's
> accumulated by deferral until the batch threshold (128) is exceeded.
>=20
> Ohhhhh. The penny just dropped - this whole sorry saga has be
> triggered because people are chasing a regression nobody has
> recognised as a regression because they don't actually understand
> how the shrinker algorithms are /supposed/ to work.
>=20
> And I'm betting that it's been caused by some other recent FB
> shrinker change.....
>=20
> Yup, there it is:
>=20
> commit 9092c71bb724dba2ecba849eae69e5c9d39bd3d2
> Author: Josef Bacik <jbacik@fb.com>
> Date:   Wed Jan 31 16:16:26 2018 -0800
>=20
>     mm: use sc->priority for slab shrink targets
>=20
> ....
>     We don't need to know exactly how many pages each shrinker represents=
,
>     it's objects are all the information we need.  Making this change all=
ows
>     us to place an appropriate amount of pressure on the shrinker pools f=
or
>     their relative size.
> ....
>=20
> -       delta =3D (4 * nr_scanned) / shrinker->seeks;
> -       delta *=3D freeable;
> -       do_div(delta, nr_eligible + 1);
> +       delta =3D freeable >> priority;
> +       delta *=3D 4;
> +       do_div(delta, shrinker->seeks);
>=20
>=20
> So, prior to this change:
>=20
> 	delta ~=3D (4 * nr_scanned * freeable) / nr_eligible
>=20
> IOWs, the ratio of nr_scanned:nr_eligible determined the resolution
> of scan, and that meant delta could (and did!) have values in the
> single digit range.
>=20
> The current code introduced by the above patch does:
>=20
> 	delta ~=3D (freeable >> priority) * 4
>=20
> Which, as you state, has a threshold of freeable > 4096 to trigger
> scanning under low memory pressure.
>=20
> So, that's the original regression that people are trying to fix
> (root cause analysis FTW).  It was introduced in 4.16-rc1. The
> attempts to fix this regression (i.e. the lack of low free object
> shrinker scanning) were introduced into 4.18-rc1, which caused even
> worse regressions and lead us directly to this point.
>=20
> Ok, now I see where the real problem people are chasing is, I'll go
> write a patch to fix it.

Sounds good, I'll check if it can prevent the memcg leak.
If it will work, we're fine.

>=20
> > Roman's patch, which reclaimed small slabs extra
> > aggressively, introduced issues, but reclaiming
> > small slabs at the same pressure/object as large
> > slabs seems like the desired behavior.
>=20
> It's still broken. Both of your patches do the wrong thing because
> they don't address the resolution and accumulation regression and
> instead add another layer of heuristics over the top of the delta
> calculation to hide the lack of resolution.
>=20
> > > That's a cgroup referencing and teardown problem, not a memory
> > > reclaim algorithm problem. To treat it as a memory reclaim problem
> > > smears memcg internal implementation bogosities all over the
> > > independent reclaim infrastructure. It violates the concepts of
> > > isolation, modularity, independence, abstraction layering, etc.
> >=20
> > You are overlooking the fact that an inode loaded
> > into memory by one cgroup (which is getting torn
> > down) may be in active use by processes in other
> > cgroups.
>=20
> No I am not. I am fully aware of this problem (have been since memcg
> day one because of the list_lru tracking issues Glauba and I had to
> sort out when we first realised shared inodes could occur). Sharing
> inodes across cgroups also causes "complexity" in things like cgroup
> writeback control (which cgroup dirty list tracks and does writeback
> of shared inodes?) and so on. Shared inodes across cgroups are
> considered the exception rather than the rule, and they are treated
> in many places with algorithms that assert "this is rare, if it's
> common we're going to be in trouble"....

No, even if sharing inodes can be advertised as a bad practice and
may lead to some sub-optimal results, it shouldn't trigger obvious
kernel issues like memory leaks. Otherwise it becomes a security concern.

Also, in practice, it's common to have a main workload and a couple
of supplementary processes (e.g. monitoring) in sibling cgroups,
which are sharing some inodes (e.g. logs).

Thanks!

