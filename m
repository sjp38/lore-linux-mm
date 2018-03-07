Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D4E336B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 13:01:40 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id o10so3036140iod.21
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 10:01:40 -0800 (PST)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id c18si9864019itd.48.2018.03.07.10.01.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 10:01:38 -0800 (PST)
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
	by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w27HucqW100711
	for <linux-mm@kvack.org>; Wed, 7 Mar 2018 18:01:37 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by aserp2120.oracle.com with ESMTP id 2gjkk5gfcu-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 07 Mar 2018 18:01:37 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w27I1YCU010772
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Wed, 7 Mar 2018 18:01:34 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
	by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w27I1YL5013785
	for <linux-mm@kvack.org>; Wed, 7 Mar 2018 18:01:34 GMT
Received: by mail-ot0-f174.google.com with SMTP id t2so2889426otj.4
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 10:01:34 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <33e3a3ff-0318-1a07-3c57-6be638046c87@suse.cz>
References: <20180306224004.25150-1-pasha.tatashin@oracle.com> <33e3a3ff-0318-1a07-3c57-6be638046c87@suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Wed, 7 Mar 2018 13:01:32 -0500
Message-ID: <CAOAebxty1EfEvd++BJq3zBOy81+LFV-WF=ERtoqprbsWZpm3HA@mail.gmail.com>
Subject: Re: [PATCH v2] mm: might_sleep warning
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Steve Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, m.mizuma@jp.fujitsu.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, baiyaowei@cmss.chinamobile.com, Wei Yang <richard.weiyang@gmail.com>, Paul Burton <paul.burton@mips.com>, Miles Chen <miles.chen@mediatek.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>

> Hi,
>
> I've noticed that this function first disables the on-demand
> initialization, and then runs the kthreads. Doesn't that leave a window
> where allocations can fail? The chances are probably small, but I think
> it would be better to avoid it completely, rare failures suck.
>
> Fixing that probably means rethinking the whole synchronization more
> dramatically though :/
>
> Vlastimil

Hi Vlastimil,

You are right, there is a window, it is short, and probably not
possible to reproduce, as it happens before user threads are started,
and after init calls done by smp_init() are finished. The only way it
can happen, as far as I can see, is if some device fires an interrupt,
and interrupt handler decides to allocate a large chunk of memory. The
small allocations will succeed, as zone grow function growth more than
strictly requested, and also there are zones without deferred pages.

I will, however, think some more how to solve this problem to be future proof.

Thank you,
Pavel

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
