Return-Path: <SRS0=4tVm=QS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F083C169C4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:46:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1DD27218A4
	for <linux-mm@archiver.kernel.org>; Mon, 11 Feb 2019 20:46:45 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="klj86b6F";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="cAr/Xx3R"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1DD27218A4
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A97808E015C; Mon, 11 Feb 2019 15:46:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A1C718E0155; Mon, 11 Feb 2019 15:46:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 8E3908E015C; Mon, 11 Feb 2019 15:46:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-it1-f198.google.com (mail-it1-f198.google.com [209.85.166.198])
	by kanga.kvack.org (Postfix) with ESMTP id 662AC8E0155
	for <linux-mm@kvack.org>; Mon, 11 Feb 2019 15:46:44 -0500 (EST)
Received: by mail-it1-f198.google.com with SMTP id x82so365043ita.9
        for <linux-mm@kvack.org>; Mon, 11 Feb 2019 12:46:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=BuMjeOhW9I7vhltsqSqqmmFrJdwHdM2pUfoNeG1/vsQ=;
        b=I9kaBAznb6bAHQDituFO3TpDM0ageWPh9KD9dG4I19g3qouo+d/aX34jRTTccb2hLo
         oAnGhgTYWLEW5iBUddIDtEZMG9wHRT6LdUQKwuxGWFe58/EcaWRmCqPk0sTB5J6U7VNN
         jnUne7HNj6O+i+rqQwsGVTwvsRTZf2JbwTx7Y7gIia6re2JXylIoy4Hnf3rBgsMNIbjG
         cfxStD+1tgzDe2dzQ/gbTWwUGJeU27LuvgpEXuM9gKRzvMoLmsC2P6vfktB6Zz2P3846
         QwBi2SQ4QYMTGAmLtgsBdQnrAfrXh8h0AM4tye9nX/OvtiB3vzXZfojEEg9crIjsJFlu
         tPyg==
X-Gm-Message-State: AHQUAub+d6TYcZjURrA0EJsGuvhwokHifrvpQu47iMqTC84nONznVEHb
	JarNTwz7OTFKcZ/+iy6eRLIBvcb85I1tD//jKaN6XYeouQ+pooKtdUUwD/3AOTxuASpeN/mIE4K
	f9igXFO8X/u7ZlPrEJkJwF8hKAxfygtT0uThiaWKuARfQR0vWC0smK3kbm8FFVavJeg==
X-Received: by 2002:a6b:7f08:: with SMTP id l8mr53650ioq.283.1549918004139;
        Mon, 11 Feb 2019 12:46:44 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbjWoNiUUMreCnluEUBgtLHbLRbij5rFiKrXpRGq+ap/CeQFQ2I5ebKuAzpjvXOU/gT8M01
X-Received: by 2002:a6b:7f08:: with SMTP id l8mr53618ioq.283.1549918003546;
        Mon, 11 Feb 2019 12:46:43 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549918003; cv=none;
        d=google.com; s=arc-20160816;
        b=jPBvzpHGp2PYcOUi7IVND2BI6fdcOTNPjQCQsD8xJaUrLM5fdUdgMnwYZqmNTeQyp5
         u6aDdYk0bqZG3sozL9faRU3dPleR0IRCtXXNR+jy9B7JdgCamUfM8VEjbmbb72UohBhl
         kWsw2e9AJ1mpxZz/yfNKTru4jqjUo0GOZJX6SMESoI0UOjbrbKzg3ZH5DALUI6OcJvN1
         dA45N2TCydC/gtebA3sUDSrmH/LczGq2DtTaw5Aqo5stV/4wd2Z5JNwvXxyqGazIyOTZ
         pfeVY2EyQijaheDIWp4xtg2RJrdn5AgK+m1A891Eao53I+wMtxcNH0RZTam1vhIg7ea8
         ccdQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=BuMjeOhW9I7vhltsqSqqmmFrJdwHdM2pUfoNeG1/vsQ=;
        b=CLH950aMgMP2PeQdg+SBfQTAaajIQel+Q68H3GX/SByGxXQcTam/uEeoqM7P1bJ3dY
         xaeoS7Vz7iyL3473735LAvh3oVBk6QHqZeer8DYqEwUcYRb1UgflKmUUqDaNW7Or4sMt
         NlHRTu/KcfmCH/GQPkAhnssFgL6Xu1NZMRpBkdDiJbhFMWRy9M+7awc5peMs1sScTbi7
         ZbvdRjAnURzO/yR+zdRki32Ul1HN55bg2LR1MXS/jDMJWbhImFoXLCDAncUaLOZUJFaF
         LRNQL+Icj4M8xLtVdUK2ZEoLyOzyTdWW0RgxLayM0HfD5glU/N1PwV1nNKbhwNQ++wc6
         XNdg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=klj86b6F;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b="cAr/Xx3R";
       spf=pass (google.com: domain of prvs=79451623ea=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79451623ea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id r1si1429427jaj.65.2019.02.11.12.46.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Feb 2019 12:46:43 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=79451623ea=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=klj86b6F;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b="cAr/Xx3R";
       spf=pass (google.com: domain of prvs=79451623ea=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=79451623ea=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044010.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1BKf5tb010313;
	Mon, 11 Feb 2019 12:46:33 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=BuMjeOhW9I7vhltsqSqqmmFrJdwHdM2pUfoNeG1/vsQ=;
 b=klj86b6FOVzV0SXv+bwuUP2rJgNHl99oG6QYuk2g6R0Bba4KAnHYBXRtybN2J4GJpQmp
 UiZbtgn0eFfLRHZ12KEkHn9zFjG2byQXmB0usycgJRCJtL3G58m75OcLfxW57NBaMKel
 c5QmCB4UPNOgXQLF85k5pS4qp0rqqVwLqw4= 
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qkcxe0sga-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Mon, 11 Feb 2019 12:46:32 -0800
Received: from prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) by
 prn-hub01.TheFacebook.com (2620:10d:c081:35::125) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 11 Feb 2019 12:46:31 -0800
Received: from prn-hub04.TheFacebook.com (2620:10d:c081:35::128) by
 prn-mbx06.TheFacebook.com (2620:10d:c081:6::20) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Mon, 11 Feb 2019 12:46:31 -0800
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.28) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Mon, 11 Feb 2019 12:46:31 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=BuMjeOhW9I7vhltsqSqqmmFrJdwHdM2pUfoNeG1/vsQ=;
 b=cAr/Xx3RHlwKsJMApzthdajS4TOMIHioq0+sATRMhmFLLcCqvOm5KmmpbpSFX/kVbNxc7xWYvarx+XwvtI/c3P96R6BSRL5TDAD58xN4Q2oag8mzW7AnF5Q6eAC8eS7AYGfHNVOezAz+dRhUdnUIFWWHSIXJPe0gdir49YfkycU=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2440.namprd15.prod.outlook.com (52.135.198.156) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1601.21; Mon, 11 Feb 2019 20:46:29 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1601.016; Mon, 11 Feb 2019
 20:46:29 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrew Morton <akpm@linux-foundation.org>
CC: Johannes Weiner <hannes@cmpxchg.org>, Roman Gushchin <guroan@gmail.com>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        Matthew Wilcox
	<willy@infradead.org>, Michal Hocko <mhocko@suse.com>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Kernel Team
	<Kernel-team@fb.com>
Subject: Re: [PATCH 0/3] vmalloc enhancements
Thread-Topic: [PATCH 0/3] vmalloc enhancements
Thread-Index: AQHUl8GbJG6pa3bRZ0aPB1+8uVFsNKXbSswAgAAC54CAABiAAA==
Date: Mon, 11 Feb 2019 20:46:29 +0000
Message-ID: <20190211204623.GA18847@tower.DHCP.thefacebook.com>
References: <20181219173751.28056-1-guro@fb.com>
 <20190211190822.GA14443@cmpxchg.org>
 <20190211111845.fcc4210d35020a721149da74@linux-foundation.org>
In-Reply-To: <20190211111845.fcc4210d35020a721149da74@linux-foundation.org>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR11CA0104.namprd11.prod.outlook.com
 (2603:10b6:a03:f4::45) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::7:797b]
x-ms-publictraffictype: Email
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2440;20:rDkEfT33l86XCNLmfnorEqpc+5jcMHoqjoNpNk6ZSshv5PnX5es75uYVSwCdjrr0Akcsqaj6MMYZ8CwDJqUVeSlTRqQJ86RIHaQb6jrzuvviP19pKAXzwnpYVHf+Bab7/gicjIXRftFmR7FQpqCUMJkeSy0cSqOy9UTv5zHBnmw=
x-ms-office365-filtering-correlation-id: 8766f4cf-7dc1-4765-5f64-08d69061ff32
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600110)(711020)(4605077)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2440;
x-ms-traffictypediagnostic: BYAPR15MB2440:
x-microsoft-antispam-prvs: <BYAPR15MB2440051A90A0F7E8AC688927BE640@BYAPR15MB2440.namprd15.prod.outlook.com>
x-forefront-prvs: 0945B0CC72
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(346002)(136003)(376002)(366004)(39860400002)(396003)(199004)(189003)(478600001)(46003)(186003)(76176011)(33896004)(7736002)(386003)(6506007)(33656002)(68736007)(305945005)(102836004)(52116002)(99286004)(6916009)(2906002)(97736004)(8676002)(14454004)(81156014)(4744005)(54906003)(316002)(8936002)(81166006)(6116002)(9686003)(86362001)(256004)(106356001)(6512007)(229853002)(4326008)(53936002)(25786009)(476003)(486006)(6486002)(11346002)(446003)(6436002)(6246003)(105586002)(71200400001)(71190400001)(1076003);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2440;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: Ww2QuaAfCktfBi0jjkIPiNR3JEnGo5s67OsJ7o6g/C10FPfNXNL+owXEk2tNexv9u+ZQSE5FYK8SlQN7EE2ya1J+yBUyMkdIXtleQEqKu2snNGd/pJj5vxwceNJnU2jlF17V5RPW7Em6HFrlr+AUF0XTOSXe6C6FQzEuoUwtYKkwSFqA16yPjhDdjNpW0quGMObl6EsEXau0xdDRzFuJ5hXCconlx/ONtibbMPtD6jkgRAZGD7xt8M3ebRXi1Y0EdRdbQiMktjSUIXLQsvV35rddC5FPpEn35ExUKF47wYm6nyba4PVBG8al1xyg20TbeqWH3kQJtZ9LBxbrQk/yY2mwUhqfdQasyp00Q99pnvUPVIl08xp8g31dW2He58QhANP8IgaGsmt7x4wV/Dk7GMNYH/WnyG5diYrkm3hIT3U=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <9B7C900295FD9E4585C35C52C1E03DAC@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 8766f4cf-7dc1-4765-5f64-08d69061ff32
X-MS-Exchange-CrossTenant-originalarrivaltime: 11 Feb 2019 20:46:28.2789
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2440
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-11_14:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Feb 11, 2019 at 11:18:45AM -0800, Andrew Morton wrote:
> On Mon, 11 Feb 2019 14:08:22 -0500 Johannes Weiner <hannes@cmpxchg.org> w=
rote:
>=20
> > On Wed, Dec 19, 2018 at 09:37:48AM -0800, Roman Gushchin wrote:
> > > The patchset contains few changes to the vmalloc code, which are
> > > leading to some performance gains and code simplification.
> > >=20
> > > Also, it exports a number of pages, used by vmalloc(),
> > > in /proc/meminfo.
> >
> > These slipped through the cracks. +CC Andrew directly.
> > Andrew, if it's not too late yet, could you consider them for 5.1?
> >=20
>=20
> There's been some activity in vmalloc.c lately and these have
> bitrotted.  They'll need a redo, please.
>=20

Will do. Thanks!

