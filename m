Return-Path: <SRS0=DsBj=RA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIMWL_WL_MED,
	DKIM_SIGNED,DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,
	MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C4C1C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 04:03:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACEF12084D
	for <linux-mm@archiver.kernel.org>; Mon, 25 Feb 2019 04:03:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=fb.com header.i=@fb.com header.b="np9MPOvo";
	dkim=pass (1024-bit key) header.d=fb.onmicrosoft.com header.i=@fb.onmicrosoft.com header.b="HykAhdwb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACEF12084D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=fb.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 484078E016C; Sun, 24 Feb 2019 23:03:34 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 435498E016A; Sun, 24 Feb 2019 23:03:34 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 323B48E016C; Sun, 24 Feb 2019 23:03:34 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0707D8E016A
	for <linux-mm@kvack.org>; Sun, 24 Feb 2019 23:03:34 -0500 (EST)
Received: by mail-yb1-f200.google.com with SMTP id t128so6073420ybf.11
        for <linux-mm@kvack.org>; Sun, 24 Feb 2019 20:03:33 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:dkim-signature:from:to:cc:subject
         :thread-topic:thread-index:date:message-id:references:in-reply-to
         :accept-language:content-language:content-id
         :content-transfer-encoding:mime-version;
        bh=9VXJhSq638uSY01btt4oIi9Ht1j0U/kKJbU9l37MQP8=;
        b=MGWLJ5jkkJfy5uTw/iDtXZ1daDRQpa0qfWchdFalW0677nqbn2kEJ7H5djbsHe1h1p
         hI0KktJNiItvBfNZpb8V7RHc/nhHqsJmlsdn3WAC/P51sCT6g6TbaVTcyqniG28u4JLG
         RtRfklopBoGkYKUSn5DPJR1kqIFA4g7+Se4MeBavsiCrXj3A5vgEvsVU7FNBaenCtXK/
         TW+qTpZRC6ARRzYN4zr7SC+LCoyWK8JNzLBUupHWV05E2Ecc9xWtt/E6mmRBVkAAs5Wy
         ser6MaZkUcETpg/gDu5ZB1CCMkWky8jbLpCUyQhcR571CB0NbHVfWaJEqAPRRQYkGpOC
         DScA==
X-Gm-Message-State: AHQUAuaJsXTuF8TQ8pvqn2BAZm25et4/abcG8k1ekxd4YXj6GvuoCsOy
	npxwolv6Q096WnN+54fCnbbsG+MCszUzUG5uVQyj45WN65jJD0tPUwafUnpaLkCEBDOWZT1wMFo
	0O2ot9Zc8+kSs7KZZ8SeGN64zgf8dhJd/CdmYe6YC16B35EFJU58gPd1TPz1dewl5ww==
X-Received: by 2002:a81:5252:: with SMTP id g79mr12197371ywb.420.1551067413667;
        Sun, 24 Feb 2019 20:03:33 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ibrty1Pnyl6dpe1Fn6kGV3VXMpXvW0Mox92/+R7xJ5bj5deuG6Ik85uhkPs4YCu62GfFq0W
X-Received: by 2002:a81:5252:: with SMTP id g79mr12197335ywb.420.1551067412814;
        Sun, 24 Feb 2019 20:03:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551067412; cv=none;
        d=google.com; s=arc-20160816;
        b=quLuvQVqcMqgPqyN/P71N8A7tuI7dE1k9upZqytG97Q/fxLXfak3Xd/j24BxsF8KfY
         QkAYDW7ASw1YcLFno4uk+Xeu27/ZtYkhL8nqOaiEhZ4sjPr4vPDkFDhbScYt3nyxDjag
         5svgKXxI744e6fllt4h5R9XlHimYu1m3SOEo/P/p5cDkO7FZbc5robEb+PuLibZ0A9qH
         xlc0JzY9KncbJ0m4ho/GsxWk81+dB6uWdq2ex0Df43m/ut0auTFxubD95rFGlxiTyGl0
         laD/6lPamLo0jOq+GwQaLrRt/4GDWxTSsRJ9CJCERgEMJvtu2vhQNcO096Va7mK+v8WS
         3Umg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:content-transfer-encoding:content-id:content-language
         :accept-language:in-reply-to:references:message-id:date:thread-index
         :thread-topic:subject:cc:to:from:dkim-signature:dkim-signature;
        bh=9VXJhSq638uSY01btt4oIi9Ht1j0U/kKJbU9l37MQP8=;
        b=mmuLc0Woe3cVsR0VJUnkQS6ERykNwmsMGx5tiCRnz7cZ7zwx4qTp8h95Uz/90+NpMU
         HQCM0/Gr0Yc0taPv2pYqHOGdNr/GY4YxKZj/lOsANvlVs+0A6qVQeXkkqmjdFRihfoUB
         OL/dTGT1bTGa+eAqX0SUNYHanWfkQl7+ilgxGcaVysiUlQZHCtWICChnoW9tHqInONkE
         9BPk+Wmd3ubkK7YE/vpOxUNennWl77uQg0H4k6tR4nQFp1MOOBUVC6XWIUJuHsi+vWvO
         VGYeXFZtWchPK8a77d1rZ1THvUxs11DWKUjl9PKg3oo0gKXxm1QyuNI58KRXIRXpc718
         Yihg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=np9MPOvo;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=HykAhdwb;
       spf=pass (google.com: domain of prvs=7959fd5ab7=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=7959fd5ab7=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id u203si4479571ybb.171.2019.02.24.20.03.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 24 Feb 2019 20:03:32 -0800 (PST)
Received-SPF: pass (google.com: domain of prvs=7959fd5ab7=guro@fb.com designates 67.231.145.42 as permitted sender) client-ip=67.231.145.42;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@fb.com header.s=facebook header.b=np9MPOvo;
       dkim=pass header.i=@fb.onmicrosoft.com header.s=selector1-fb-com header.b=HykAhdwb;
       spf=pass (google.com: domain of prvs=7959fd5ab7=guro@fb.com designates 67.231.145.42 as permitted sender) smtp.mailfrom="prvs=7959fd5ab7=guro@fb.com";
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=fb.com
Received: from pps.filterd (m0044008.ppops.net [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.16.0.27/8.16.0.27) with SMTP id x1P3reIR023590;
	Sun, 24 Feb 2019 20:03:24 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.com; h=from : to : cc : subject
 : date : message-id : references : in-reply-to : content-type : content-id
 : content-transfer-encoding : mime-version; s=facebook;
 bh=9VXJhSq638uSY01btt4oIi9Ht1j0U/kKJbU9l37MQP8=;
 b=np9MPOvoQyG/AJGmofvkwiM5gawrGD0XuZ4KR8oeM6gQXWOUZya5YWlu8o9IMcrZX1JT
 OIJHWf0dVnK8ANfV7ql7SPEnlmyr7Vcg5BrnctV1hw1ZuxwlEzU5EynHSDzQUS2pMEGw
 5+45J9DDK4xukIINKTqTp0lzUmjUn63pAKU= 
Received: from maileast.thefacebook.com ([199.201.65.23])
	by mx0a-00082601.pphosted.com with ESMTP id 2qv1n7rvj5-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT);
	Sun, 24 Feb 2019 20:03:24 -0800
Received: from frc-hub05.TheFacebook.com (2620:10d:c021:18::175) by
 frc-hub06.TheFacebook.com (2620:10d:c021:18::176) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id
 15.1.1531.3; Sun, 24 Feb 2019 20:03:22 -0800
Received: from NAM01-BY2-obe.outbound.protection.outlook.com (192.168.183.28)
 by o365-in.thefacebook.com (192.168.177.75) with Microsoft SMTP Server
 (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384) id 15.1.1531.3
 via Frontend Transport; Sun, 24 Feb 2019 20:03:22 -0800
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fb.onmicrosoft.com;
 s=selector1-fb-com;
 h=From:Date:Subject:Message-ID:Content-Type:MIME-Version:X-MS-Exchange-SenderADCheck;
 bh=9VXJhSq638uSY01btt4oIi9Ht1j0U/kKJbU9l37MQP8=;
 b=HykAhdwbmtZW4BHsne4dZjXEy6PxlTSsCGWIecUiWo/C1E9VwzT9NIVI1fozuJ1eOItVvgmWTyIYtI9DzBldR2db5UIfZ230Q3tN3dpPkQifsamLMBk6pBLtSOgi5L+kkv9LKU/2rAYoe/i+m4txxQCUOW+ozpYAFn60aMQ2MHQ=
Received: from BYAPR15MB2631.namprd15.prod.outlook.com (20.179.156.24) by
 BYAPR15MB2981.namprd15.prod.outlook.com (20.178.237.206) with Microsoft SMTP
 Server (version=TLS1_2, cipher=TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384) id
 15.20.1643.14; Mon, 25 Feb 2019 04:03:02 +0000
Received: from BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92]) by BYAPR15MB2631.namprd15.prod.outlook.com
 ([fe80::ecc7:1a8c:289f:df92%3]) with mapi id 15.20.1643.019; Mon, 25 Feb 2019
 04:03:02 +0000
From: Roman Gushchin <guro@fb.com>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
CC: Andrew Morton <akpm@linux-foundation.org>,
        "linux-mm@kvack.org"
	<linux-mm@kvack.org>,
        "linux-kernel@vger.kernel.org"
	<linux-kernel@vger.kernel.org>,
        Johannes Weiner <hannes@cmpxchg.org>,
        "Michal
 Hocko" <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>,
        Rik van Riel
	<riel@surriel.com>,
        Mel Gorman <mgorman@techsingularity.net>,
        Shakeel Butt
	<shakeelb@google.com>
Subject: Re: [PATCH RFC] mm/vmscan: try to protect active working set of
 cgroup from reclaim.
Thread-Topic: [PATCH RFC] mm/vmscan: try to protect active working set of
 cgroup from reclaim.
Thread-Index: AQHUythGXfYU+8xM1EWrupNuYl99T6Xv6EsA
Date: Mon, 25 Feb 2019 04:03:02 +0000
Message-ID: <20190225040255.GA31684@castle.DHCP.thefacebook.com>
References: <20190222175825.18657-1-aryabinin@virtuozzo.com>
In-Reply-To: <20190222175825.18657-1-aryabinin@virtuozzo.com>
Accept-Language: en-US
Content-Language: en-US
X-MS-Has-Attach: 
X-MS-TNEF-Correlator: 
x-clientproxiedby: CO1PR15CA0113.namprd15.prod.outlook.com
 (2603:10b6:101:21::33) To BYAPR15MB2631.namprd15.prod.outlook.com
 (2603:10b6:a03:152::24)
x-ms-exchange-messagesentrepresentingtype: 1
x-originating-ip: [2620:10d:c090:180::1:48a8]
x-ms-publictraffictype: Email
x-ms-office365-filtering-correlation-id: 747cab16-d65c-408a-d269-08d69ad6232f
x-microsoft-antispam: BCL:0;PCL:0;RULEID:(2390118)(7020095)(4652040)(8989299)(4534185)(4627221)(201703031133081)(201702281549075)(8990200)(5600127)(711020)(4605104)(2017052603328)(7153060)(7193020);SRVR:BYAPR15MB2981;
x-ms-traffictypediagnostic: BYAPR15MB2981:
x-microsoft-exchange-diagnostics: 1;BYAPR15MB2981;20:cyW9EMFGVr2b9hSimsQRdBf1alZ46+mrTr+EdveVeIjoBKIJFX5gOUWAyXsqpKHqIJa9aH6fCsUlCSaVqzDnhvMb+ouoUVDswUOTSzjmn9l3tTR0izk7xG6tnU5Q8unVVyuuq340IpShTxGOlpNDZCDNfH0snC8XT8RmhjJHXZs=
x-microsoft-antispam-prvs: <BYAPR15MB2981FB98010419B1728664C3BE7A0@BYAPR15MB2981.namprd15.prod.outlook.com>
x-forefront-prvs: 095972DF2F
x-forefront-antispam-report: SFV:NSPM;SFS:(10019020)(366004)(396003)(136003)(346002)(376002)(39860400002)(199004)(189003)(54906003)(6486002)(476003)(102836004)(97736004)(446003)(25786009)(316002)(6436002)(486006)(8676002)(6346003)(68736007)(478600001)(6116002)(14444005)(11346002)(33656002)(6506007)(386003)(6246003)(14454004)(256004)(105586002)(6916009)(71190400001)(2906002)(106356001)(71200400001)(46003)(7416002)(99286004)(229853002)(305945005)(76176011)(1076003)(7736002)(81166006)(86362001)(8936002)(5660300002)(4326008)(186003)(53936002)(6512007)(9686003)(81156014)(52116002);DIR:OUT;SFP:1102;SCL:1;SRVR:BYAPR15MB2981;H:BYAPR15MB2631.namprd15.prod.outlook.com;FPR:;SPF:None;LANG:en;PTR:InfoNoRecords;A:1;MX:1;
received-spf: None (protection.outlook.com: fb.com does not designate
 permitted sender hosts)
x-ms-exchange-senderadcheck: 1
x-microsoft-antispam-message-info: 2YhvqzFLlJ1YPRaSxBh6b1SOmZAMLl/jZJSd6NtQuayeT96j7fpSQWpYKgSsYUyCoT4B1Wl3AIigVs/0+Gl2WwRxVXKeNEGe8h43OUqqj1BtUW3nebuontb2gcVmgCF20cn8eNK+10phCfSfgu35bTh8carfj0J4F7PrLS90p2U05UdFkTNWVvwjrV5f0OCFVSwvMvhMcBH7BZQrkr6MySYy+jeV3i9k3y1ZKbMxJoWsMnqHW4L/ssHJoFt0JXQhBLuWR0uHHTiseEddcxihQ4jbdqYPYQe35W0mfVwDWvzqFDMBI+CPhRAxSQxTMqRP63iSFH1FXc7RFheN3CXCVb8crB/e/0Qo6edjefG9L5VojVUB0Tkgp/7YdBwge9e+VaaKlod4DU6pcFNOFyn11DsJbxefdlREXzNDqxLLy8E=
Content-Type: text/plain; charset="us-ascii"
Content-ID: <4241B12B98BA0240BC935A05E777030C@namprd15.prod.outlook.com>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
X-MS-Exchange-CrossTenant-Network-Message-Id: 747cab16-d65c-408a-d269-08d69ad6232f
X-MS-Exchange-CrossTenant-originalarrivaltime: 25 Feb 2019 04:03:01.5123
 (UTC)
X-MS-Exchange-CrossTenant-fromentityheader: Hosted
X-MS-Exchange-CrossTenant-mailboxtype: HOSTED
X-MS-Exchange-CrossTenant-id: 8ae927fe-1255-47a7-a2af-5f3a069daaa2
X-MS-Exchange-Transport-CrossTenantHeadersStamped: BYAPR15MB2981
X-OriginatorOrg: fb.com
X-Proofpoint-Virus-Version: vendor=fsecure engine=2.50.10434:,, definitions=2019-02-25_02:,,
 signatures=0
X-Proofpoint-Spam-Reason: safe
X-FB-Internal: Safe
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Feb 22, 2019 at 08:58:25PM +0300, Andrey Ryabinin wrote:
> In a presence of more than 1 memory cgroup in the system our reclaim
> logic is just suck. When we hit memory limit (global or a limit on
> cgroup with subgroups) we reclaim some memory from all cgroups.
> This is sucks because, the cgroup that allocates more often always wins.
> E.g. job that allocates a lot of clean rarely used page cache will push
> out of memory other jobs with active relatively small all in memory
> working set.
>=20
> To prevent such situations we have memcg controls like low/max, etc which
> are supposed to protect jobs or limit them so they to not hurt others.
> But memory cgroups are very hard to configure right because it requires
> precise knowledge of the workload which may vary during the execution.
> E.g. setting memory limit means that job won't be able to use all memory
> in the system for page cache even if the rest the system is idle.
> Basically our current scheme requires to configure every single cgroup
> in the system.
>=20
> I think we can do better. The idea proposed by this patch is to reclaim
> only inactive pages and only from cgroups that have big
> (!inactive_is_low()) inactive list. And go back to shrinking active lists
> only if all inactive lists are low.

Hi Andrey!

It's definitely an interesting idea! However, let me bring some concerns:
1) What's considered active and inactive depends on memory pressure inside
a cgroup. Actually active pages in one cgroup (e.g. just deleted) can be co=
lder
than inactive pages in an other (e.g. a memory-hungry cgroup with a tight
memory.max).

Also a workload inside a cgroup can to some extend control what's going
to the active LRU. So it opens a way to get more memory unfairly by
artificially promoting more pages to the active LRU. So a cgroup
can get an unfair advantage over other cgroups.

Generally speaking, now we have a way to measure the memory pressure
inside a cgroup. So, in theory, it should be possible to balance
scanning effort based on memory pressure.

Thanks!

