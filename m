Return-Path: <SRS0=dvGr=TS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-4.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9889DC04AB4
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 01:00:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FA8820848
	for <linux-mm@archiver.kernel.org>; Sat, 18 May 2019 00:59:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="bL0Fp2IG";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="EQBUwSht"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FA8820848
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D6146B0003; Fri, 17 May 2019 20:59:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6879A6B0005; Fri, 17 May 2019 20:59:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 527566B0006; Fri, 17 May 2019 20:59:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F5F66B0003
	for <linux-mm@kvack.org>; Fri, 17 May 2019 20:59:59 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id p190so7277662qke.10
        for <linux-mm@kvack.org>; Fri, 17 May 2019 17:59:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=7qKsPldQKiOqJbT53B5lYvQu0Xny2wWC1bg1lwvSMV8=;
        b=sAjhrEreBFALoBmaw+A0A028a+p6WEeOdbFzHKV5fBnDkensAVJtdWy6u9rWyR8hik
         zsn7n3UgrG+PaXhzM1+yhjwW6wBo8BhXvACpYgwh2EDu/8NVGorN/qt3S8XUAXMlHPb0
         h3sWuTPWICcsv3MVg1kl8DA8qOqk8evWJ+hBKfsuUphtdq7QkfUay+uTYcbcJpu6Z96k
         aGzf02+zB4aTOEUzfEOWD/mOQhF9V7AJk4FkD33vFJ3Udfkz6pnjuCYp0qYEVS5hFamk
         A7jtPikRGuRUYucu1NGiwxGdfQYrn8z7XJjxZqofQwwzi1h//UrMNrUMKPTbTYz1xGs9
         NF5A==
X-Gm-Message-State: APjAAAWrRUHcNJJtEk6E5OZC/UBkYbPABONtO8LPHYTEDyyaXYnDr2Ft
	i+21UPhcpy5N/hXReZMKTRCyLb9y9/jAL5g/YPSQAinjtuoh0CMYPWGfnxF/MKsWiJId0cKbpJe
	IIEOzRsXoXTixnVucBe6bk39R7AIEnD4AZDt8mX/Y6yUr8MseKA7biHJ4XUlpQ5KnWw==
X-Received: by 2002:ac8:1671:: with SMTP id x46mr28992325qtk.240.1558141198861;
        Fri, 17 May 2019 17:59:58 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxt4kU/2C+qnIHxEcmERROnyn9RkdMtnL5OMf78LfVhOcCVpY6Wiyi31J3LuD0XQAKYx+fn
X-Received: by 2002:ac8:1671:: with SMTP id x46mr28992253qtk.240.1558141197833;
        Fri, 17 May 2019 17:59:57 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558141197; cv=none;
        d=google.com; s=arc-20160816;
        b=IAdB5gbzc/V3SsOfms8awir3mzv7aC98HqgTIVANh88DQ2abqfwh0gUtX3IvdBUtQJ
         DSss4nqPtOdDRDZJUOb7Ss03qElBA0YL2HGC/fWZ7bs4jOUtreQFDGKZ4vCTVFlkEQnF
         cU1rU4aSZ1lx8RfZc229L3riliuuKDZbpwK2RoQPvKCm5Xw+KUrb4fxZFyHN/pQkt0Ow
         zPVKMAamFrsZ2ri0MKwWoddyCDnsG3C/ulwZfqw9lE3v/bfaj7s5Th22+N+qFdzodX04
         SHRXmCM6pEJHnF+09B7YpY2xHaxhHhdEBaT8zAntYtQgEetWRaa9glXrQV32+85bbx5R
         1BwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=7qKsPldQKiOqJbT53B5lYvQu0Xny2wWC1bg1lwvSMV8=;
        b=l6UhPuRUfmP5OBlygBuFcO7IgxAED/jdp5xLFyBeWlQInSoT0EhEnAXTylu5Eoh3vT
         3Yg09jsdfFrftDftZubHrX8vd8uHJFDT2OHvuwSTaB2+baRH1iWeWUn3XauMopmc+7xr
         lPjdMwAY1K4GIHjf6Xszv37C2LyJ/0dpOZW/XwRbB/XRV+CMSV0avoUGZA62jlt+TnDh
         fgYLN0FNF9iraahjnt/CsUuzKGP1D/9HgK6/1QC7qBkMzRqEqL2Oc+QxrF02T07mpGZr
         AHdxXOH1Oi2wNpNcurcyD/7gflyRVkS7m5Yc4wZP4w/JB0WaPE9LUqegDQXtwcR4PYN8
         1vog==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bL0Fp2IG;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=EQBUwSht;
       spf=pass (google.com: domain of prvs=0041bc8e50=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0041bc8e50=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id z74si1608808qka.120.2019.05.17.17.59.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 May 2019 17:59:57 -0700 (PDT)
Received-SPF: pass (google.com: domain of prvs=0041bc8e50=guro@fb.com designates 67.231.153.30 as permitted sender) client-ip=67.231.153.30;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=bL0Fp2IG;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-onmicrosoft-com header.b=EQBUwSht;
       spf=pass (google.com: domain of prvs=0041bc8e50=guro@fb.com designates 67.231.153.30 as permitted sender) smtp.mailfrom="prvs=0041bc8e50=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0089730.ppops.net [127.0.0.1])
	by m0089730.ppops.net (8.16.0.27/8.16.0.27) with SMTP id x4I0xOOg008031;
	Fri, 17 May 2019 17:59:47 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=7qKsPldQKiOqJbT53B5lYvQu0Xny2wWC1bg1lwvSMV8=;
 b=bL0Fp2IGZVpRpN+z+SEaYK1ZNTKQ+3piBoXDKKa7LmBwXpuSFVwHr80Tu/3vHZ0TrG+l
 +5jy4zy/BuKY+EhamjEcTW6KTbin/K4JHkyPiQZrI6VCPsFggbUXjN96lINoM9+hiniC
 1Fcak6ezMO7lfzWRHtmarfH83dwaKSloEqc= 
Received: from mail.thefacebook.com (mailout.thefacebook.com [199.201.64.23])
	by m0089730.ppops.net with ESMTP id 2sj7ggg22d-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Fri, 17 May 2019 17:59:47 -0700
Received: from prn-hub01.TheFacebook.com (2620:10d:c081:35::125) by
 prn-hub06.TheFacebook.com (2620:10d:c081:35::130) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1713.5; Fri, 17 May 2019 17:59:46 -0700
Received: from NAM02-CY1-obe.outbound.protection.outlook.com (192.168.54.28)
 by o365-in.thefacebook.com (192.168.16.25) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1713.5
 via Frontend Transport; Fri, 17 May 2019 17:59:46 -0700
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-onmicrosoft-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=7qKsPldQKiOqJbT53B5lYvQu0Xny2wWC1bg1lwvSMV8=;
 b=EQBUwShtpY7RYKBOdCLPE58QQ/OmVEj7witCilVlDuuT7K4Ehy+j1Zy5zbEMfnQgNcGkNWmGpBbWylmYW+YtSHapMPxlt12Wpj9Kq/Zwj+TOSqeCyzVetBUz0jn0zVGAHkX007eYR9poZtG+isrHYIMlzWUbs6M+4HDGS/udKo0=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2805.namprd15.prod.outlook.com (20.179.158.146) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1900.18; Sat, 18 May 2019 00:59:30 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::d4f6:b485:69ee:fd9a%7]) with mapi id 15.20.1900.010; Sat, 18 May 2019
 00:59:30 +0000
From: Roman Gushchin <guro@fb.com>
To: Shakeel Butt <shakeelb@google.com>
CC: Johannes Weiner <hannes@cmpxchg.org>,
        Vladimir Davydov
	<vdavydov.dev@gmail.com>,
        Michal Hocko <mhocko@kernel.org>,
        Andrew Morton
	<akpm@linux-foundation.org>,
        Chris Down <chris@chrisdown.name>,
        "linux-mm@kvack.org" <linux-mm@kvack.org>,
        "cgroups@vger.kernel.org"
	<cgroups@vger.kernel.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>
Subject: Re: [PATCH v2] mm, memcg: introduce memory.events.local
Thread-Topic: [PATCH v2] mm, memcg: introduce memory.events.local
Thread-Index: AQHVDQ9AIsql3vtrqUugyovKoP5pDaZwD8OA
Date: Sat, 18 May 2019 00:59:30 +0000
Message-ID: <20190518005927.GB3431@tower.DHCP.thefacebook.com>
References: <20190518001818.193336-1-shakeelb@google.com>
In-Reply-To: <20190518001818.193336-1-shakeelb@google.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: BYAPR01CA0069.prod.exchangelabs.com (2603:10b6:a03:94::46)
 To BYAPR15MB2631.namprd15.prod.outlook.com (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:200::2:d7d0]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: a97bfa3b-793f-4a1c-6b53-08d6db2c1558
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600141)(711020)(4605104)(2017052603328)(7193020);SRVR:BYAPR15MB2805;
x-ms-traffictypediagnostic: BYAPR15MB2805:
x-microsoft-antispam-prvs: <BYAPR15MB280518E3FFFE3988BAEAD750BE040@BYAPR15MB2805.namprd15.prod.outlook.com>
x-ms-oob-tlc-oobclassifiers: OLM:9508;
x-forefront-prvs: 0041D46242
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(136003)(376002)(396003)(39850400004)(346002)(54534003)(199004)(189003)(81156014)(81166006)(8676002)(99286004)(73956011)(186003)(6506007)(6116002)(386003)(68736007)(25786009)(5660300002)(478600001)(229853002)(316002)(54906003)(66446008)(2906002)(64756008)(9686003)(6512007)(4326008)(66556008)(14454004)(6246003)(66946007)(86362001)(8936002)(66476007)(102836004)(486006)(6436002)(71190400001)(71200400001)(53936002)(52116002)(76176011)(7736002)(305945005)(33656002)(476003)(14444005)(256004)(1076003)(6486002)(6916009)(46003)(446003)(11346002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2805;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: LDwaK9woaUlRqTZsOGjUGOI0aw8usd5G8QK5aYNipcJqTCtEJB1FDTzyEhf4dx+LnWpeUKuXc0tSeTH1vv5LYaS54pss1F9DOKREBDEPXCd1os0ir/0sW6udIRIUJBk+qMwsgtNlyYh1QGofUNy9ZQRj0HRm6vW5/rIMQhQKP9bAEIZo3IZcey3xgMO+eNyg1Oe94hxUTT6CNESxnpwHfb6EoOeY+E1/iRyG4OXkOGek1l65FmZaBM+7I3tZagEwA1ZK5Ih8eCDeCb9tX/TQ1Adc+pUu+cXCCnF+6UfY5H2a53G6m151gkONCqHWfWXntr6+X1EstI0xtRwyprk9eQlmcdVX4kdsZg98EU7HEfm1dgj3a/i/Ek1KvbXtdXm8EBYoTzzvet5cUVPs5QuyPppovFRHnuYTueO14hxSyf0=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <F4C49EE3FF59984090F0BB32EF187949@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: a97bfa3b-793f-4a1c-6b53-08d6db2c1558
X-MS-Exchange-CrossTenant-originalarrivaltime: 18 May 2019 00:59:30.5192
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2805
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-05-17_15:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, May 17, 2019 at 05:18:18PM -0700, Shakeel Butt wrote:
> The memory controller in cgroup v2 exposes memory.events file for each
> memcg which shows the number of times events like low, high, max, oom
> and oom_kill have happened for the whole tree rooted at that memcg.
> Users can also poll or register notification to monitor the changes in
> that file. Any event at any level of the tree rooted at memcg will
> notify all the listeners along the path till root_mem_cgroup. There are
> existing users which depend on this behavior.
>=20
> However there are users which are only interested in the events
> happening at a specific level of the memcg tree and not in the events in
> the underlying tree rooted at that memcg. One such use-case is a
> centralized resource monitor which can dynamically adjust the limits of
> the jobs running on a system. The jobs can create their sub-hierarchy
> for their own sub-tasks. The centralized monitor is only interested in
> the events at the top level memcgs of the jobs as it can then act and
> adjust the limits of the jobs. Using the current memory.events for such
> centralized monitor is very inconvenient. The monitor will keep
> receiving events which it is not interested and to find if the received
> event is interesting, it has to read memory.event files of the next
> level and compare it with the top level one. So, let's introduce
> memory.events.local to the memcg which shows and notify for the events
> at the memcg level.
>=20
> Now, does memory.stat and memory.pressure need their local versions.
> IMHO no due to the no internal process contraint of the cgroup v2. The
> memory.stat file of the top level memcg of a job shows the stats and
> vmevents of the whole tree. The local stats or vmevents of the top level
> memcg will only change if there is a process running in that memcg but
> v2 does not allow that. Similarly for memory.pressure there will not be
> any process in the internal nodes and thus no chance of local pressure.
>=20
> Signed-off-by: Shakeel Butt <shakeelb@google.com>
> ---
> Changelog since v1:
> - refactor memory_events_show to share between events and events.local

Reviewed-by: Roman Gushchin <guro@fb.com>

You also need to add some stuff into cgroup v2 documentation.

Thanks!

