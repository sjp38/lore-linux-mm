Return-Path: <SRS0=YQJ0=QZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,MENTIONS_GIT_HOSTING,SPF_PASS autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BBA13C43381
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 23:53:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 696AE20818
	for <linux-mm@archiver.kernel.org>; Mon, 18 Feb 2019 23:53:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="leXW7QPF";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="Lp9NYYn4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 696AE20818
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id ED6158E0003; Mon, 18 Feb 2019 18:53:29 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E86088E0002; Mon, 18 Feb 2019 18:53:29 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D4FE58E0003; Mon, 18 Feb 2019 18:53:29 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7CFCA8E0002
	for <linux-mm@kvack.org>; Mon, 18 Feb 2019 18:53:29 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id i55so7773927ede.14
        for <linux-mm@kvack.org>; Mon, 18 Feb 2019 15:53:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:accept-language
         :content-language:content-id:content-transfer-encoding:mime-version;
        bh=AJ2JEp5mMQmR+JmfKISdADxbdgMii//y1avntJrQmqo=;
        b=l727QgMpZSgsPeygvApfJTRvSZ338iCvPSA8pY8HK16tFRvLUgNXRHzEdpShCV0ycy
         K72LxR2g9VyqEKxrvpWWLmNMRs2mI5lp31ShaqO2UFQt9OtyWN5QKwrStJl6T9DgU0JB
         Cs3HUw9I7mH1BrkYDio+PphMw5HT3gOKPbeUvR0x/sQOSBjB9JgyoNQx0IeOcUv92ndA
         E6s1flCwoaCyjZh64+cFurvwyYJh4j8L+IVQTZGWNQq7Go+JalD3m6z83fteFV0AZeHF
         axsaNIyVIwEZrtSI4Sy8QzEqnpla5IVJr2I7ohcNTofjQSSSRPW8KJEOMSa11tVcQuuJ
         kzfA==
X-Gm-Message-State: AHQUAuYi+IJG5iOEgKQYRGbrdGbvXiImYcVEmaa85O1JxHBt341Zehus
	sA8+lvQVqRuKTr6snYllcvoidIa4aZ/gQCu3BwJAmBtN+yf36WDyhr8MUrWNTViIWPSrfp9tbIv
	o9LkPu5FpSApO6e/+vpV1HcMNHEfvzJEhaaE12ayT2ZdKTTh5sf7cN9gRnjbHjEUDcA==
X-Received: by 2002:a50:9012:: with SMTP id b18mr15485478eda.30.1550534008841;
        Mon, 18 Feb 2019 15:53:28 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaXeZ2CViI4sUoQyr/0f2SRdCV9fFZ50qS/VCeFol/xZBsQcEbucAT7bxAqHIG/kwAqR84q
X-Received: by 2002:a50:9012:: with SMTP id b18mr15485439eda.30.1550534007808;
        Mon, 18 Feb 2019 15:53:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550534007; cv=none;
        d=google.com; s=arc-20160816;
        b=wMCsQj6yf/xPlT/X+Ylv0jcoDv8oDYTWAHSXlt2FI+ump1wRbT6rlcddYuYDmn9+fO
         5W2yGH0DEiGz18M9n4epsUFj6pA5qd9ohvS3DUekfuGc8H02nuFskbDkrZjp/cAvMv/H
         RgSPu0NsKNaQv6oNWe58Z2DpGDI+V9jVHuLPVchwmJlRS+v8jQa9yxu/0pAnBCBLiJeW
         zUgF77YlVhcGW84l6oY3+sx++znbFDPnDae0DtHHCruP6DmO+H01tSlPG8Mm0SgQvxQG
         UGIcaHCxHLugAjgSMJNMbW7RvB6Sq5cuiE7RSN1yrdFSkJ7LjJj4MDfN/sSjdzQ80tiz
         /RoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:message-id:date:thread-index:thread-topic:subject
         :cc:to:from:dkim-signature:dkim-signature;
        bh=AJ2JEp5mMQmR+JmfKISdADxbdgMii//y1avntJrQmqo=;
        b=tk1JOmH6Hxh+k7X/TSz9lpZttez7MKTgG2DDgXHrNCHWOcrxpqScsxt7V+wX6kq+GF
         F224uyripwIoAS8OPJn10EqJJ93rlO92p4q6RNcFcbONOAIB51ke9DKNaWPCmupxodTI
         YjFon6MNwLHMVYzM9pu43/wRYJ+pITVFi4AWFo3eHb4anU1qnyGbAZnozsrOhFrFEkJ7
         iJcwc4DHw+HRldMzirwx7dU8DYV9khQGZyGRHy7coJPYXKNFP4Nn+muj+k418+RXzcuW
         DUyoXN5+XzHDYJuABijvu/DQTHSTNulGb+nsRh26ddMtjUEcLPHeDnF9vwe7+7T5diK/
         sChw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=leXW7QPF;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Lp9NYYn4;
       spf=pass (google.com: domain of prvs=79522c9478=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=79522c9478=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id g11si1193704ejd.263.2019.02.18.15.53.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Feb 2019 15:53:27 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79522c9478=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=leXW7QPF;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=Lp9NYYn4;
       spf=pass (google.com: domain of prvs=79522c9478=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=79522c9478=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0109332.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1INnH69009659;
	Mon, 18 Feb 2019 15:53:23 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : content-type : content-id :
 content-transfer-encoding : mime-version; s=facebook;
 bh=AJ2JEp5mMQmR+JmfKISdADxbdgMii//y1avntJrQmqo=;
 b=leXW7QPFRs0yJxbAg0H6CgEwAu6XvuSBFQ71IFDiHcoAe3U7GrXCa1oVb+AvUp2Ciokj
 jkOvw4v9vt7q2/5MOudbhHVU++Ddbf5cufzsrM1hhaLGO67NzCWn4jjT/uPukHBN4SBC
 lanqhF+2w1ePumQPWXGGcGQWr7NwqHPDHgE= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qr2n1gm49-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 18 Feb 2019 15:53:23 -0800
Received: from frc-mbx04.TheFacebook.com (192.168.155.19) by
 frc-hub06.TheFacebook.com (192.168.177.76) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 18 Feb 2019 15:53:22 -0800
Received: from frc-hub01.TheFacebook.com (192.168.177.71) by
 frc-mbx04.TheFacebook.com (192.168.155.19) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 18 Feb 2019 15:53:22 -0800
Received: from NAM05-DM3-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.71) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Mon, 18 Feb 2019 15:53:22 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=AJ2JEp5mMQmR+JmfKISdADxbdgMii//y1avntJrQmqo=;
 b=Lp9NYYn4hxMefL3p0Ntekqlu5OiozgEr29pLArjJsnvEsFpiRApBviHYSR1CnDR3BAQPdNtEGrvT4LUbmUgBnLBHVLtwe3pg1ZR+4ymId2LymKBwE+KLl6iOYCfji5kUGiI04/BKfFJhfrKYmFaCvtMQ2OKSws00zYw0mheUUIw=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2248.namprd15.prod.outlook.com (52.135.197.13) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.19; Mon, 18 Feb 2019 23:53:20 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1601.016; Mon, 18 Feb 2019
 23:53:20 +0000
From: Roman Gushchin <guro@fb.com>
To: "sf-pc@lists.linux-foundation.org" <sf-pc@lists.linux-foundation.org>
CC: "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "mhocko@kernel.org"
	<mhocko@kernel.org>,
        "riel@surriel.com" <riel@surriel.com>,
        "dchinner@redhat.com" <dchinner@redhat.com>,
        "dairinin@gmail.com"
	<dairinin@gmail.com>,
        "akpm@linux-foundation.org" <akpm@linux-foundation.org>
Subject: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Topic: [LSF/MM TOPIC] dying memory cgroups and slab reclaim issues
Thread-Index: AQHUx+Ug0Vif721JokW7CkHnc9CIQA==
Date: Mon, 18 Feb 2019 23:53:20 +0000
Message-ID: <20190218235313.GA4627@castle.DHCP.thefacebook.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR02CA0005.namprd02.prod.outlook.com
 (2603:10b6:a02:ee::18) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:fce0]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: b1c934af-09ef-4bd1-dde4-08d695fc4254
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2248;
x-ms-traffictypediagnostic: BYAPR15MB2248:
x-ms-exchange-purlcount: 4
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2248;20:QSmR05DlAvN3+UbNf5nx7VXZtqBjk6ZMZruQiYrc8YVlOwRWs7/GhrmviyYg9MAdzbfeiKUnNfovaPA80rLd2sOkgBjU1RBQ20/4WYt04KfZm++fFOz5+NUp9ESskoXXQyAuUVzTQIOxZUZtcZJxCEv5OZ9kbmZj6479RUY5gX4=
x-microsoft-antispam-prvs: <BYAPR15MB2248CA46AE365D4AC9938F72BE630@BYAPR15MB2248.namprd15.prod.outlook.com>
x-forefront-prvs: 09525C61DB
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(136003)(396003)(376002)(366004)(39860400002)(199004)(189003)(476003)(102836004)(2501003)(478600001)(256004)(14444005)(25786009)(71200400001)(71190400001)(33656002)(14454004)(316002)(6116002)(99286004)(86362001)(54906003)(53936002)(2906002)(33896004)(52116002)(68736007)(97736004)(6486002)(305945005)(1076003)(186003)(4326008)(106356001)(105586002)(486006)(5660300002)(6436002)(7736002)(966005)(81166006)(81156014)(8936002)(8676002)(6512007)(46003)(6306002)(9686003)(5640700003)(6506007)(386003)(2351001)(6916009);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2248;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: XKc8eFBRCj/L+W3F1y12gF47HU7T15g1noHxu0ipnwCxPJi+uycnJTfRQ2qFv5jBvq+HP8ZAz72t0C9Vc7Fw4MXSy9OLD7seJ4BadCdQfM4w1syAIvwZjKyG2rGw+7Of90Gq1V6FhA4SeRbjDr88/XMxgDGRF6lBYpbImanonWULWuxSKc0jhAeRZbbmHc4Rz9qPSrjYo9JGKB2x0nsqk8Ea07In9GBFSc1Ua5aJJ2dVeriMNTQzcymdC0xq2jhNiAWJVTFC0AQYxr/zYeDFBFH0UxQHnNUcRogzQ/9GMZnC5FPVSZg7bo436SE++RJCjthuGHwNKaHrmlVI9evKJmF6c4xokdVYUbpyPX6aHlDFORVq/tPuhbNwuuckqIXKg3fOsykfW/BGAfOHs8I5FT1JbZNXwFVClV6vhnM7FAw=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <A89C773429D55C46AFE5B7B7419BC934@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: b1c934af-09ef-4bd1-dde4-08d695fc4254
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 Feb 2019 23:53:19.1845
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2248
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-18_17:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Recent reverts of memcg leak fixes [1, 2] reintroduced the problem
with accumulating of dying memory cgroups. This is a serious problem:
on most of our machines we've seen thousands on dying cgroups, and
the corresponding memory footprint was measured in hundreds of megabytes.
The problem was also independently discovered by other companies.

The fixes were reverted due to xfs regression investigated by Dave Chinner.
Simultaneously we've seen a very small (0.18%) cpu regression on some hosts=
,
which caused Rik van Riel to propose a patch [3], which aimed to fix the
regression. The idea is to accumulate small memory pressure and apply it
periodically, so that we don't overscan small shrinker lists. According
to Jan Kara's data [4], Rik's patch partially fixed the regression,
but not entirely.

The path forward isn't entirely clear now, and the status quo isn't accepta=
ble
sue to memcg leak bug. Dave and Michal's position is to focus on dying memo=
ry
cgroup case and apply some artificial memory pressure on corresponding slab=
s
(probably, during cgroup deletion process). This approach can theoretically
be less harmful for the subtle scanning balance, and not cause any regressi=
ons.

In my opinion, it's not necessarily true. Slab objects can be shared betwee=
n
cgroups, and often can't be reclaimed on cgroup removal without an impact o=
n the
rest of the system. Applying constant artificial memory pressure precisely =
only
on objects accounted to dying cgroups is challenging and will likely
cause a quite significant overhead. Also, by "forgetting" of some slab obje=
cts
under light or even moderate memory pressure, we're wasting memory, which c=
an be
used for something useful. Dying cgroups are just making this problem more
obvious because of their size.

So, using "natural" memory pressure in a way, that all slabs objects are sc=
anned
periodically, seems to me as the best solution. The devil is in details, an=
d how
to do it without causing any regressions, is an open question now.

Also, completely re-parenting slabs to parent cgroup (not only shrinker lis=
ts)
is a potential option to consider.

It will be nice to discuss the problem on LSF/MM, agree on general path and
make a potential list of benchmarks, which can be used to prove the solutio=
n.

[1] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3Da9a238e83fbb0df31c3b9b67003f8f9d1d1b6c96
[2] https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/comm=
it/?id=3D69056ee6a8a3d576ed31e38b3b14c70d6c74edcc
[3] https://lkml.org/lkml/2019/1/28/1865
[4] https://lkml.org/lkml/2019/2/8/336

