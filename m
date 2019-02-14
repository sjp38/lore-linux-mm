Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0603DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 02:00:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9BBEE222A1
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 02:00:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="H949i6Ip";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="LgTbepYn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9BBEE222A1
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 274018E0002; Wed, 13 Feb 2019 21:00:46 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 224988E0001; Wed, 13 Feb 2019 21:00:46 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 0C67A8E0002; Wed, 13 Feb 2019 21:00:46 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id BA5908E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 21:00:45 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id p20so3093924plr.22
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 18:00:45 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=HBHJrDQfafml37jlCXLrGKZmsXpxKxFrdorDxj7aO6s=;
        b=nq6eMZEPfDEc9RyYvm6IX3DNne78Ou3hw+xHkg6itV7NdK/K8yjX5vUexpn27v88ui
         UO/4p9ckE5lfGR1InHowPpep9wC4137lVlkxtcUMVVVFX6tJSRcyxYGidas9MvvJ46Bg
         5Ywd4Tg9X0kKVNOmS4OZKVPtck+seJ8/xSuBuO2LWUkPzUyYpDpy/UrltXxKoVz4Vecx
         wL8l7sebClrW03IHlxHe2rxBd3Wefqc/ZWGySKAfWX87wpPwl/kSCB97bwU8EtbojOCl
         H3rXOofQ4Tqw4tDh1rZO7gI2vUzUdZNFKjRjXRjlyxlHHU2tln1cxhYnPFT3l9vuZmfi
         EARQ==
X-Gm-Message-State: AHQUAuZ7oaT3gnyZV6YqfmtNwFsp5rZCtH8VTbUOWtONfkXlps7fefEN
	8/Z2JzalTEv7ZQVhFQtXIo7ZALzm72RCVrPpfKfFYBgagFcq6Rmu/PibUApJFnrEQtYxWXbRbDf
	+gH1meBJlI7RgKx5SOEeYM+h2QQbIqW2hVrL0X2ET6SBFoZW2CrdHGAEUa22upcV+lw==
X-Received: by 2002:a62:b248:: with SMTP id x69mr1391008pfe.256.1550109645329;
        Wed, 13 Feb 2019 18:00:45 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYmnnD5EjMZpVqbFdF3VdfSca5zlTEsci45utGpBhQt8bZvgsCA6Gsv9Qi2PbGG/UyzzC76
X-Received: by 2002:a62:b248:: with SMTP id x69mr1390885pfe.256.1550109644053;
        Wed, 13 Feb 2019 18:00:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550109644; cv=none;
        d=google.com; s=arc-20160816;
        b=gYphag6KSCnGE0+K1zgz++cjr1nJoOrgnQF2MCs6Jqi95F9FOS7E/GSp6pUa/uPg7H
         DwLqt6NFyGnojRfg1e2GoW4F/06E7uC1FhDOIlAMOfi+h5DD1jNuuY+OiC8JwyTiko1N
         jtcFKVx1DdaabfNHMud+TlAQi4wBzQiZ4RMszNvh3hWkPq4e06HzvUf3Qv/PI043KG0v
         tgsOdwE+Wm/KZbpeZruQSlPvvpKFpExnJ7HfRPDwpOwgEzYcUy9JVMjRjcFiw9TSWh+r
         xJFRLNIjAupuu2xy7eDhMbW4vp+14Etoq40MLAerKCqQXGAr9aqsMnzQNzhbfPRGLfH0
         9+nQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=HBHJrDQfafml37jlCXLrGKZmsXpxKxFrdorDxj7aO6s=;
        b=ccccSiADBmnDcOBol7CSaO4pwxQQ1qFb5onA5yi3R0kUYtXCbtuH4YQKJHXyr3tSD1
         bEaOUPezuRpwafyjGvGVEsz1yJrcAjQswmyI7RC6ZzVXQMjXw0J6wlzz5arwstyHot5e
         lUiOLm6FgW5pqGnqgUswU7p7U+HzhIFhgvizXep8UbCioXWwvdJxLLQhCYJHwlfWxkdj
         XEq2p6UyJC0bdI8Ofty9MbtbCuTxhkKsuQMCt+n9P2HmFZrKUNl4PVZ0yH7gMQnBnb19
         FlZ3TvTSLrnlZYl99PgP6U4y0tLW4XZJ2tBaqUicUAmywBPB8k4FBmLHSh8ZsOGMaRac
         1WIQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=H949i6Ip;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=LgTbepYn;
       spf=pass (google.com: domain of prvs=79486281c3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79486281c3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id d9si967628pls.412.2019.02.13.18.00.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 18:00:44 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79486281c3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=H949i6Ip;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=LgTbepYn;
       spf=pass (google.com: domain of prvs=79486281c3=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79486281c3=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1E20Xsm005392;
	Wed, 13 Feb 2019 18:00:34 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=HBHJrDQfafml37jlCXLrGKZmsXpxKxFrdorDxj7aO6s=;
 b=H949i6Ipq5wDVyoRCFM1igaT6ivdKY0Br0xBLW9nvZUWHD6z+T/c/djcfDi56DHygoRh
 LiYsm5zPGgDFtUOxGctXOK/b4SxdToj4lyS5p4UGwCWfZx/lUbA7Pr3jMkzVIbytIaLB
 QHBpHIstoUfmktV6BBjEt5PwghHyZlJiO6E= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qmvrv0dh1-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 13 Feb 2019 18:00:34 -0800
Received: from frc-mbx07.TheFacebook.com (2620:10d:c0a1:f82::31) by
 frc-hub03.TheFacebook.com (2620:10d:c021:18::173) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Wed, 13 Feb 2019 18:00:14 -0800
Received: from frc-hub04.TheFacebook.com (2620:10d:c021:18::174) by
 frc-mbx07.TheFacebook.com (2620:10d:c0a1:f82::31) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Wed, 13 Feb 2019 18:00:14 -0800
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.74) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Wed, 13 Feb 2019 18:00:14 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=HBHJrDQfafml37jlCXLrGKZmsXpxKxFrdorDxj7aO6s=;
 b=LgTbepYnjoAFfK9SYFv3IlVuSl/DfWb7PReckeoiiOfgqvJc/OqtkzcV+bb4HddevlodcYE35+znt6vOOB/01dLR4wklIlNIh/LF9Vh6ds+2X/yVNavdN7/v2KbGrSLQrx9PvxYPDamaJLaR32fvf9ZBL+nZbY2oWw2mt0/QQMc=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.2.19) by
 MWHPR15MB1664.namprd15.prod.outlook.com (10.175.141.23) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Thu, 14 Feb 2019 01:59:56 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::ec0e:4a05:81f8:7df9]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::ec0e:4a05:81f8:7df9%4]) with mapi id 15.20.1601.023; Thu, 14 Feb 2019
 01:59:55 +0000
From: Song Liu <songliubraving@fb.com>
To: Matthew Wilcox <willy@infradead.org>
CC: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-kernel
	<linux-kernel@vger.kernel.org>,
        linux-raid <linux-raid@vger.kernel.org>,
        "bpf@vger.kernel.org" <bpf@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>,
        "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [LSF/MM TOPIC] (again) THP for file systems
Thread-Topic: [LSF/MM TOPIC] (again) THP for file systems
Thread-Index: AQHUw+d91LnZv2+dn0iH+77xUzeGLKXeaKSAgAAhgQA=
Date: Thu, 14 Feb 2019 01:59:55 +0000
Message-ID: <843818E0-C7E8-451E-A5B1-DAF0F120BD5A@fb.com>
References: <77A00946-D70D-469D-963D-4C4EA20AE4FA@fb.com>
 <20190213235959.GX12668@bombadil.infradead.org>
In-Reply-To: <20190213235959.GX12668@bombadil.infradead.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.102.3)
x-originating-ip: [2620:10d:c090:180::1:757a]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: e68b61ed-9cfc-471b-33b2-08d692201e06
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:MWHPR15MB1664;
x-ms-traffictypediagnostic: MWHPR15MB1664:
x-ms-exchange-purlcount: 2
x-microsoft-exchange-diagnostics: 1;MWHPR15MB1664;20:gGdmQOqdcoAWbkYV1ejN+RigJQAFvq/kVi8jxshKfDHqGSfCUoxBuJMv1nmxbIM3/Znc1clztdyNwDAaxxCen4FJquBFrbmnAgSt5UVf4F+RltwUWlL4BNwsot2Uoj1/fRiSX2WPbwxlNFNegJx2mapNlbaCg3FYO8Unu1/OLiU=
x-microsoft-antispam-prvs: <MWHPR15MB16645FB96114342A2A6A0AD8B3670@MWHPR15MB1664.namprd15.prod.outlook.com>
x-forefront-prvs: 09480768F8
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(39860400002)(366004)(136003)(346002)(376002)(396003)(189003)(199004)(51914003)(71190400001)(6916009)(11346002)(476003)(46003)(2616005)(446003)(6506007)(57306001)(186003)(6486002)(229853002)(71200400001)(478600001)(6116002)(6436002)(486006)(6512007)(6306002)(4326008)(14454004)(25786009)(53546011)(102836004)(68736007)(97736004)(36756003)(86362001)(6246003)(82746002)(105586002)(106356001)(256004)(316002)(81156014)(33656002)(54906003)(8676002)(50226002)(53936002)(83716004)(8936002)(966005)(99286004)(2906002)(81166006)(7736002)(305945005)(76176011);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1664;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: WxjhtRndmtAH3EsyXP3tmq2sWZzcpWgmVnPittg29ShtYm6G8KpID09JoMitXhXrQJpFF43PRZ9fgCZuS2z+AaMlaGL64SKFLURkPimiiW2uY9Cnep5R0LF/JnvWN4wat5rG/yilM1Gcn/mhtE8muJLiTeYMctR/Yt5SE/n0AZZkkUe6g8TsMc7G8BexfMLVk03tnxzQLEqpFbzg691hd2qycjWL+07o1DMtfb5oD3Bu9yJWaf/YLZQUYqgBJ0WWIOKOiRfbhYsGNtYif328PYcOFm8Xs7gh1nR6X08bNQD6Iao8Lmwn3aHjyS/8T+53v2UP9m2fBVix/C2JBfFD3gFkeLI/7ofOW1gZwiOuJ5phWSnKU04QaYYfzyWDwx6rGPQApio8kfO/Wix6wfACtKFdyp8ogbmPdofnnWbDHPU=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <050ED4B99A554F4AACE4A77BAE0F3527@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: e68b61ed-9cfc-471b-33b2-08d692201e06
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 Feb 2019 01:59:55.8664
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1664
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-14_01:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>



> On Feb 13, 2019, at 3:59 PM, Matthew Wilcox <willy@infradead.org> wrote:
>=20
> On Wed, Feb 13, 2019 at 10:00:10PM +0000, Song Liu wrote:
>> I would like to discuss remaining work to bring THP to (non-tmpfs) file =
systems.
>> This topic has been discussed multiple times in previous LSF/MM summits =
[1][2].
>> However, there hasn't been much progress since late 2017 (the latest wor=
k I can
>> find is by Kirill A. Shutemov [3]).
>=20
> ... this was literally just discussed.
>=20
> Feel free to review
> https://lore.kernel.org/lkml/20190212183454.26062-1-willy@infradead.org/
>=20
> with particular reference to the last three paragraphs of
> https://lore.kernel.org/lkml/20190208042448.GB21860@bombadil.infradead.or=
g/

Thanks for the pointers! I will read the patches and related code. =20

>=20
>> Therefore, we would like discuss (for one more time) what is needed to b=
ring
>> THP to file systems like ext4, xfs, btrfs, etc. Once we are aligned on t=
he
>> direction, we are more than happy to commit time and resource to make it=
 happen.
>=20
> I believe the direction is clear.  It needs people to do the work.
> We're critically short of reviewers.  I got precious little review of
> the original XArray work, which made Andrew nervous and delayed its
> integration.  Now I'm getting little review of the followup patches
> to lay the groundwork for filesystems to support larger page sizes.
> I have very little patience for this situation.

I don't feel I am a qualified reviewer for MM patches, yet. But I will=20
try my best to catch up.=20

Thanks again,
Song=

