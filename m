Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 58B45C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:39:12 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F23D52083E
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 00:39:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="DkavMxf0";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="ZdxpNN3G"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F23D52083E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 82F9C8E0003; Wed, 13 Feb 2019 19:39:11 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7DE7D8E0001; Wed, 13 Feb 2019 19:39:11 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6CC688E0003; Wed, 13 Feb 2019 19:39:11 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 462948E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 19:39:11 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id v125so223994itc.4
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 16:39:11 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=qpP/KdIfG5pR/CDzkwzAnm+87KAsnZ9tqo05PWflvEg=;
        b=Vh1XYSFpTMs7MUoJ2D/1k1ZnHGN8qeFXXNdGddy0otGQ68Xmsx0s8ZsZkqvlM/hQvy
         2r8tHSW2Gc0V3zS2V1oyrGHE4VkIsCR3Ds2FtMHFCtizwXYSlsE7zmDL4kyXZn5WVY36
         wkJXuTUI5Qy+q789tQnmfSJrICfo/iV5pUhlcVYZpXo5ycv6fpwCoNvEofJN5eeoTq2O
         l9dCi/O3qEVrU8it5RQYe0KKNIWM0/XnHISUwKifaRqQ5iEYvFmnLZheRraPp/4YAWPY
         vlo4Mu/qaADW9IybFI/Hp1U/SUoaRUd0CbpR/4XchY8uWFjz14x91UlR6luc1FLoyu93
         jvLg==
X-Gm-Message-State: AHQUAuYhZzJKw+bahpw6SBEWC7YkowRh4XUhm+BKWhik62idGALnijub
	kiDUBAK6id/lbgkddwn0Ymt33q2GKDhsBvZk1YAumk8f2sfn4+4SuOWj0wsUZkXtQaEc6dVIMwE
	OExRGINjhChp6F6WEbGm3DaRI97GXcNjSiljIcnq4td8TnQ0vo7tujhV39D4msl4ogQ==
X-Received: by 2002:a02:1e08:: with SMTP id m8mr628181jad.120.1550104750991;
        Wed, 13 Feb 2019 16:39:10 -0800 (PST)
X-Google-Smtp-Source: AHgI3IatR2VnV1sJzebIT9B9Rp2adZ5JLT+FgX4KaWbe4CQitxQj3nvAXSqbcHNjBeGD7uYMtnQ0
X-Received: by 2002:a02:1e08:: with SMTP id m8mr628168jad.120.1550104750313;
        Wed, 13 Feb 2019 16:39:10 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550104750; cv=none;
        d=google.com; s=arc-20160816;
        b=qleSwZ3Ag+E4OIO/nnTrGHHPuE9AYUa7KNdHOUwqaBt0ZcnNXT1/r+RvM3ZRnGW33f
         /xlQd/6S6r/iNGK3NvemNA2rHyFOy0MzHWGD1WuMaG9HP6/L/JNyekrUaVH/v/wCUJGl
         Y57S0WT2RRU91hU5F9PniPlF6WcFi5nULCb5Ais/2HZmxXzNQE5XyBfdkcmFkE8C1AQP
         Y86OYyZku1NyMFu5u6qU8elPiGSxQOeuhX7JRzKLcTRJKJEbsazIixkv5OIszbU67jAT
         86xQw4YPDPlsLoFL4Sx/APD0l4vgs65WPgK7YLy0HSOsqvnpOYrFNH9/Bwo0V61qZ1mP
         7fVw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=qpP/KdIfG5pR/CDzkwzAnm+87KAsnZ9tqo05PWflvEg=;
        b=OsEGrAcaAhHQ/icPOqHc4mWW9NOk4aOdDFjqBz5/w3DJbyGAMm8cXbPNoC8yeUeayV
         fmXXyPAyk5y8CScrDfI/rz9M4f3diG+CZi9POLvaV12Ch4qIBf9awy+nGQe+yNybXwru
         caHgIjqhdcFJAhdCpVqtnxipP1kn44koDMBOFzRsPjg8p4gjTqwxU5xKj8jfFTnDoAU8
         RcMlWr7VBGlh1NUWx2nIk/8zxy/KTLDaUz/sZzOcp+iax1oLbZ/Hdzyh7kWmK4hQtlAY
         mAmIcoiy7T9GsFgoVYZTj+eNBsOnhuiSH30RLctgctOTGHu0oiRM67pIRm1BJHyzPrYY
         DC4A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DkavMxf0;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=ZdxpNN3G;
       spf=pass (google.com: domain of prvs=7948bcd4ca=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=7948bcd4ca=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id n22si461274ioj.149.2019.02.13.16.39.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Feb 2019 16:39:10 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=7948bcd4ca=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=DkavMxf0;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=ZdxpNN3G;
       spf=pass (google.com: domain of prvs=7948bcd4ca=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=7948bcd4ca=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0148461.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1E0cTQa023597;
	Wed, 13 Feb 2019 16:38:58 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=qpP/KdIfG5pR/CDzkwzAnm+87KAsnZ9tqo05PWflvEg=;
 b=DkavMxf0kZppCaWxnTpN5zcFKOIfBZW1QPWsSYkMey7bWVEdjRpNmnZV9dVd1Txyvpmb
 bFj40okVGCBgAGILIt4E18JFc5c/R7HGrxrres05kDu/3vLN1l7FFO+DRL1hiejSMpKr
 e+XrC79aWESu5Ilj80nOz37oh1V1AhGPg1w= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qmu950hgp-2
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Wed, 13 Feb 2019 16:38:58 -0800
Received: from frc-hub03.TheFacebook.com (2620:10d:c021:18::173) by
 frc-hub05.TheFacebook.com (2620:10d:c021:18::175) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Wed, 13 Feb 2019 16:38:57 -0800
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.73) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Wed, 13 Feb 2019 16:38:56 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=qpP/KdIfG5pR/CDzkwzAnm+87KAsnZ9tqo05PWflvEg=;
 b=ZdxpNN3GsmKxLRw0sptndovhTm+BAS65W5HuMiLWFmFwVnx+Wmi/Kvtz1Sog2OzjlmyWvTwmPnmBtmRZVDMUQcJrrW7sUbbE6MnNBUgs/zEfIOJ8gxkiXravpANdtuZRcsOMGL2PfZohtbr+xyvuL3f82RqbKK9iyRLhwPs59as=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2999.namprd15.prod.outlook.com (20.178.238.12) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1622.16; Thu, 14 Feb 2019 00:38:55 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1601.016; Thu, 14 Feb 2019
 00:38:55 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guroan@gmail.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Matthew Wilcox
	<willy@infradead.org>,
        Kernel Team <Kernel-team@fb.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2 0/3] vmalloc enhancements
Thread-Topic: [PATCH v2 0/3] vmalloc enhancements
Thread-Index: AQHUwvxltqRw0KKPyU2GUxvyv29fa6XcgNAAgAAd04CAAdazgA==
Date: Thu, 14 Feb 2019 00:38:54 +0000
Message-ID: <20190214003848.GA4898@tower.DHCP.thefacebook.com>
References: <20190212175648.28738-1-guro@fb.com>
 <20190212184724.GA18339@cmpxchg.org>
 <20190212123409.7ed5c34d68466dbd8b7013a3@linux-foundation.org>
In-Reply-To: <20190212123409.7ed5c34d68466dbd8b7013a3@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR03CA0035.namprd03.prod.outlook.com
 (2603:10b6:a02:a8::48) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::4:3cbc]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 2cb6e3fb-4158-41dd-050c-08d69214cc5f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(5600110)(711020)(4605077)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2999;
x-ms-traffictypediagnostic: BYAPR15MB2999:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2999;20:rO6Dxg0qdO8gQr2Gq3Ln8nIwUMI4+WQHDqw8knVYAguldUdlQtwoFa+Gu+aDe+w7EW8Q4UQUvJeFoP/M1hTzOXzFQ7vzc7pWIis/VnVSO7dVEyRMI1Go2uQAffMmZBFv3DeklPzhP6bvOYnjy0s4MuK1EgzoHYzlftuOfPYM8qs=
x-microsoft-antispam-prvs: <BYAPR15MB299958CD052FE2ECEE943D0ABE670@BYAPR15MB2999.namprd15.prod.outlook.com>
x-forefront-prvs: 09480768F8
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(346002)(376002)(136003)(39860400002)(199004)(189003)(81156014)(33896004)(4326008)(8936002)(52116002)(97736004)(386003)(25786009)(6506007)(86362001)(99286004)(6346003)(478600001)(316002)(6246003)(105586002)(14454004)(8676002)(81166006)(54906003)(102836004)(106356001)(1076003)(186003)(6116002)(476003)(33656002)(6436002)(486006)(6486002)(71190400001)(229853002)(14444005)(256004)(9686003)(6512007)(6916009)(53936002)(2906002)(305945005)(46003)(76176011)(7736002)(68736007)(446003)(11346002)(71200400001);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2999;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Nd+XzQ8ZsmJLCTQc8haj9C9LMD1gxU8AS+ofvS7zxYQXz792E9Vs2I9cG+0ImxR45JT6A1itbCRM8qwNQxCsJrwTadWbX+y1TfIixeo2huleQAxRjGmnB441JF6lPPskK9V+Rf0fgUYFeKyiAwY88vUoDBT6l9ioKNb2WCbfakVGsr/eHtLPnRoR/8Vs/4+fJywdkZLX4VmL2CDQkLjYyHNrriCdc4o0mWSzjeEpcBovi45HEBPXDX+PSim7+8WFkZwcDsPnQHZEfxyOp/1uizMGxYxHgaZCKcGVl3X156iYtP48QpW3f2+as1YLu+X9dDlBB6SIau1QLg7JG3AW17ZzuFEjxwDN7R4UgsBLJ/YRwAFQoWaNNwBTzOGshp6kk+RXZs7MGEe193U8Y/y/7Ecw0eMABotEEsr8U7b76Rc=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <66C5D4B9A861674B9DDDAE2FA011711A@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 2cb6e3fb-4158-41dd-050c-08d69214cc5f
X-MS-Exchange-CrossTenant-originalarrivaltime: 14 Feb 2019 00:38:54.1421
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2999
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

On Tue, Feb 12, 2019 at 12:34:09PM -0800, Andrew Morton wrote:
> On Tue, 12 Feb 2019 13:47:24 -0500 Johannes Weiner <hannes@cmpxchg.org> w=
rote:
>=20
> > On Tue, Feb 12, 2019 at 09:56:45AM -0800, Roman Gushchin wrote:
> > > The patchset contains few changes to the vmalloc code, which are
> > > leading to some performance gains and code simplification.
> > >=20
> > > Also, it exports a number of pages, used by vmalloc(),
> > > in /proc/meminfo.
> > >=20
> > > Patch (1) removes some redundancy on __vunmap().
> > > Patch (2) separates memory allocation and data initialization
> > >   in alloc_vmap_area()
> > > Patch (3) adds vmalloc counter to /proc/meminfo.
> > >=20
> > > v2->v1:
> > >   - rebased on top of current mm tree
> > >   - switch from atomic to percpu vmalloc page counter
> >=20
> > I don't understand what prompted this change to percpu counters.
> >=20
> > All writers already write vmap_area_lock and vmap_area_list, so it's
> > not really saving much. The for_each_possible_cpu() for /proc/meminfo
> > on the other hand is troublesome.
>=20
> percpu_counters would fit here.  They have probably-unneeded locking
> but I expect that will be acceptable.
>=20
> And they address the issues with for_each_possible_cpu() avoidance, CPU
> hotplug and transient negative values.

Using existing vmap_area_lock (as Johannes suggested) is also problematic,
due to different life-cycles of vma_areas and vmalloc pages. A special flag
will be required to decrease the counter during the lazy deletion of
vmap_areas. Allocation path will require passing a bool flag through too ma=
ny
nested functions. Also it will be semi-accurate, which is probably tolerabl=
e.
So, it's doable, but doesn't look nice to me.

So, using a simple per-cpu counter still seems to best option.
Transient negative value is a valid concern, but easily fixable.
Are there any other? What's the problem with for_each_possible_cpu()?
Reading /proc/meminfo is not that hot, no?

Thanks!

