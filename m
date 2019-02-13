Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 37740C43381
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:00:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BB410222A4
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 22:00:24 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="m2wSsZof";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="iKNVCGoF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BB410222A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3506F8E0002; Wed, 13 Feb 2019 17:00:24 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2FD7A8E0001; Wed, 13 Feb 2019 17:00:24 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1A06B8E0002; Wed, 13 Feb 2019 17:00:24 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id CC90B8E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 17:00:23 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id y1so2687616pgo.0
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:00:23 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=qHKCPOrJcNRd8N1tcJ6b89jpPL5eDAmkwvFiz9F1dOI=;
        b=CrlAMu/TOteU4KQeamt5WjSJc+PCe15eEeOJnmZf6hvkoD7VDFpDjxzsOTIkDwsOog
         NxO1IgE/+S0AFH6Qeu/0KLxiQ6spRvkSP2BGJ3+QMGKjLNowLdbGRgHDMS2/4Q5nOhfz
         umbZH/xVyfsFVWkJDW2Xfgiu2K50rJaUvGfTMHpEwNq8pm79RzDMmTdZnYv8PrYFfVPd
         TzonpI2tOfxgcO7SXcqdrwOnsFK4x0E3zzQK4zRke7FeHaDig18R6ZQ2djvhJ4t+tssp
         rsFqd6c1wxzZI4dIJqRAc72rWaXAXrYfKceAUFGp4gpfn1a/cmq6Mu55ViJev51SWieo
         R5Iw==
X-Gm-Message-State: AHQUAubKuncslQL7eXtfN9vxPcCUw3NTKlKYU/oHC7WvY33yH8V/CNjd
	EbO9lAQsKZhrB2gpEozWZsKKRYsVEjWf29m+sOcYxaRUtEJULnxVeCpbYn757kBiCoVi0sp0ePq
	BSmt3KaC09FGai+FIZcAKlPJdAKD3jLHocJDcHi5xg2o8t0q9kW8tpuczJjGAL64qzQ==
X-Received: by 2002:a17:902:bb0b:: with SMTP id l11mr381212pls.127.1550095223314;
        Wed, 13 Feb 2019 14:00:23 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYaYVsN+9QcXoHRN56vz/2JbOPt9wgMEMdFeb/HBtB0hNuVz0TmFBLBrGCGEtulMJJzPbju
X-Received: by 2002:a17:902:bb0b:: with SMTP id l11mr381143pls.127.1550095222573;
        Wed, 13 Feb 2019 14:00:22 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550095222; cv=none;
        d=google.com; s=arc-20160816;
        b=KKD3B2Cpg8XgX5/rn9pQmf11+tuAhOrTZ7AG/wEkgDy9gfqavHnfcrieKqif2/KKsa
         wxdxNR27ZJRHBVDdwJuNnu4PvVXF7211GFxz3b6WzTMrlaWfAzmf9h51Mr91CrpkUVk/
         /l7kWc+PvDus5gAoibCh+HuCYUwf8v8+gAF1Kd2i/Aev3TBsD/qv++AaiKYvcX/LWiYp
         YEYdvqCx8oC0js/ZGZ58DE5xCwrK1ILIv7yo5xniSr7htBQUebm/+2lyhsRWsO8DBYHc
         8KrHQNzAdDWSz/hXYmj0vnPkUyGYwo7/26DUu5+ZhU/bze1nEMZJCUECoQnXnjoiXjY6
         QcCQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature:dkim-signature;
        bh=qHKCPOrJcNRd8N1tcJ6b89jpPL5eDAmkwvFiz9F1dOI=;
        b=x5Gtn1Ypw1hRMz5z604g55sXEOGJ0OyQ25Hl1edGv4axrknppwQnAQ4Ar1Jh3QXIPz
         67ij0rYsfhu+mDaWp6OTHP3IA5fqEyqk7NWVpIRvehLG1dV4zDytLGqEiyh4H5vUOO5L
         l1WLkzngWmJvPcySKNgBe5FIlaXna3crDzQmkm0fHjsIABh6AeOMBOFhrKFURpSYgdmb
         +KBNdHsSPbFOHJS1EB2/x+KwbxzUrARXfmOcOZUW37eZtMc/S8l+ii6ZTdMVDcBuzozj
         FYh353BnMEOv37bRyeC5jvJAtWa8VP/Ef1cePiyK9ewL+/RX19+XJXxs7/7JX8pfEZ+R
         PCNg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=m2wSsZof;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=iKNVCGoF;
       spf=pass (google.com: domain of prvs=794782e062=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=794782e062=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id g132si510478pfb.23.2019.02.13.14.00.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 14:00:22 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=794782e062=songliubraving@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=m2wSsZof;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=iKNVCGoF;
       spf=pass (google.com: domain of prvs=794782e062=songliubraving@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=794782e062=songliubraving@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109333.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1DLsmAG009371;
	Wed, 13 Feb 2019 14:00:22 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : content-type : content-id :
 content-transfer-encoding : mime-version; s=facebook;
 bh=qHKCPOrJcNRd8N1tcJ6b89jpPL5eDAmkwvFiz9F1dOI=;
 b=m2wSsZof89XUOoDKH8NHUG1k1onKRWQw2iA0OnITKzgdBAn5CKGLURQOUwiQdpfN0rhD
 M/GiltFJ3ikdFNMISnS1Env/PNl/fYTuD5T3+vgVtk2ESYaxNpr010jYpc7Jv+FqrgIL
 5jvNSaQgx89A8ms71HleV2bXUDsWIXpZjSM= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qms4armmc-5
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 13 Feb 2019 14:00:21 -0800
Received: from frc-hub03.TheFacebook.com (2620:10d:c021:18::173) by
 frc-hub05.TheFacebook.com (2620:10d:c021:18::175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Wed, 13 Feb 2019 14:00:12 -0800
Received: from NAM04-CO1-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.73) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Wed, 13 Feb 2019 14:00:12 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qHKCPOrJcNRd8N1tcJ6b89jpPL5eDAmkwvFiz9F1dOI=;
 b=iKNVCGoFcMdVi9wGiN3Y1KErfSJRowBtBBLyDw+sL0NRAHlsYgr8/tP3Y5cPgCRKi+fZQSofmciHyph83cOe6M0jEjhUJFUUM4wzCqMDn8G6lAoZP28Pl0c43PJxYzcy1QIkupf4uZr4dN9Sjta3fT6VbJFupgjoeJPyVN8s75A=
Received: from MWHPR15MB1165.namprd15.prod.outlook.com (10.175.2.19) by
 MWHPR15MB1439.namprd15.prod.outlook.com (10.173.234.141) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.17; Wed, 13 Feb 2019 22:00:10 +0000
Received: from MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::ec0e:4a05:81f8:7df9]) by MWHPR15MB1165.namprd15.prod.outlook.com
 ([fe80::ec0e:4a05:81f8:7df9%4]) with mapi id 15.20.1601.023; Wed, 13 Feb 2019
 22:00:10 +0000
From: Song Liu <songliubraving@fb.com>
To: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        linux-kernel
	<linux-kernel@vger.kernel.org>,
        linux-raid <linux-raid@vger.kernel.org>,
        "bpf@vger.kernel.org" <bpf@vger.kernel.org>,
        "linux-fsdevel@vger.kernel.org"
	<linux-fsdevel@vger.kernel.org>
CC: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: [LSF/MM TOPIC] (again) THP for file systems 
Thread-Topic: [LSF/MM TOPIC] (again) THP for file systems 
Thread-Index: AQHUw+d98PJr/f1RW0yrtlybflg8VA==
Date: Wed, 13 Feb 2019 22:00:10 +0000
Message-ID: <77A00946-D70D-469D-963D-4C4EA20AE4FA@fb.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-mailer: Apple Mail (2.3445.102.3)
x-originating-ip: [2620:10d:c090:180::1:f80f]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 57ec5233-de4e-4423-2a70-08d691fe9fac
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:MWHPR15MB1439;
x-ms-traffictypediagnostic: MWHPR15MB1439:
x-ms-exchange-purlcount: 3
x-microsoft-exchange-diagnostics: 1;MWHPR15MB1439;20:hy1n5M+KXnbfYRHZrH+M4PwwePhRQeMxosaf5HpofpptO/oxnWZTFruJH6u813Z6z7Me8LBxvs9bL2+Z6MDEElIJ24TNn/RzQ9qoq8vjoSu08cOtPcmS26VptXLLRcY9HgZ0rK4+E5eL7hmTgyuv1+qvftFemjD7xs5GPQnxCZQ=
x-microsoft-antispam-prvs: <MWHPR15MB14394E936E88F4AD94D3E27CB3660@MWHPR15MB1439.namprd15.prod.outlook.com>
x-forefront-prvs: 094700CA91
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(396003)(376002)(136003)(366004)(39860400002)(346002)(189003)(199004)(2501003)(81166006)(478600001)(6116002)(33656002)(4743002)(966005)(99286004)(57306001)(53936002)(81156014)(8676002)(105586002)(6436002)(7736002)(4326008)(110136005)(106356001)(6486002)(316002)(6306002)(8936002)(83716004)(71200400001)(71190400001)(6512007)(68736007)(102836004)(97736004)(46003)(36756003)(2906002)(2616005)(82746002)(6506007)(305945005)(50226002)(486006)(256004)(25786009)(86362001)(186003)(14454004)(2201001)(476003);DIR:OUT;SFP:1102;SCL:1;SRVR:MWHPR15MB1439;H:MWHPR15MB1165.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;MX:1;A:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: j5JNJSuf3Ta1uW0DAHUEjrTXHZFFekoxIpEMCDEtvdG0invqqin5/4j0fE7vhEmRO4IpuhOF7bTKfm8dwzWSy723uKR3t0Zeo79wA2Y0+hnY/w+XvBFDbisXzWdKogKmbNPU/j79AsFnB4sxNe+dogNYM6cjig5sp4W1UMjS4j5svs/c2O6vlDM8vUzXpp8iyYNLXAWWwSRse6q0A38UxWqwHWfPqYLkr0nWZQ47fDNppnG0/h3ltmmKTg/86J4c8c7qtvQmV9wSUU16dWzD5iR3qMgn5XBfajpqxKCqsLJ4Z6IBx9kUXdA9RPfe1v4/OpipklPCUbGG+dXCLCWnPscdHXRBWlb2LI6uJQPQUI3XNnTTCV61cAFw8ApYb/oeuy91FbYPOkHbPWrX8E6RpGjnYcij/RZ9vWUN9yl05UE=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <D311F68F799EF74789524BC7643BD169@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 57ec5233-de4e-4423-2a70-08d691fe9fac
X-MS-Exchange-CrossTenant-originalarrivaltime: 13 Feb 2019 22:00:10.3502
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: MWHPR15MB1439
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-13_12:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I would like to attend the LSF/MM Summit 2019. I'm interested in topics abo=
ut
BPF, mdraid, and MM. I am a designated reviewer of BPF. I am also helping J=
ens
organize mdraid patches.

I would like to discuss remaining work to bring THP to (non-tmpfs) file sys=
tems.
This topic has been discussed multiple times in previous LSF/MM summits [1]=
[2].
However, there hasn't been much progress since late 2017 (the latest work I=
 can
find is by Kirill A. Shutemov [3]).

We (Facebook) uses THP in many services. We see significant savings by putt=
ing
hot-text on THP. To achieve this with state-of-the-art Linux Kernel, we hav=
e to
either: trick the Kernel to believe certain region is anonymous pages; or p=
ut
the executable in tmpfs. In our case, the tmpfs solution is too expensive.
Therefore, we use a hack to trick the Kernel. This hack breaks other useful
features, e.g. perf symbols and uprobes. Instead of introducing more hacks =
to
use these broken features, it is better to enable THP for file systems.
Therefore, we would like discuss (for one more time) what is needed to brin=
g
THP to file systems like ext4, xfs, btrfs, etc. Once we are aligned on the
direction, we are more than happy to commit time and resource to make it ha=
ppen.

Since this topic is my main focus of this year's summit, I would like an in=
vite
to the MM track.

Thanks,
Song

[1] https://lwn.net/Articles/686690/
[2] https://lwn.net/Articles/718102/
[3] https://kernel.googlesource.com/pub/scm/linux/kernel/git/kas/linux/+/hu=
geext4/wip=

