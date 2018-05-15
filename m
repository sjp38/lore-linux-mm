Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61BD26B0281
	for <linux-mm@kvack.org>; Tue, 15 May 2018 08:18:09 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id q16-v6so1233233pls.15
        for <linux-mm@kvack.org>; Tue, 15 May 2018 05:18:09 -0700 (PDT)
Received: from aserp2130.oracle.com (aserp2130.oracle.com. [141.146.126.79])
        by mx.google.com with ESMTPS id o7-v6si9478591pgc.381.2018.05.15.05.18.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 May 2018 05:18:05 -0700 (PDT)
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
	by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w4FCG2q6065464
	for <linux-mm@kvack.org>; Tue, 15 May 2018 12:18:04 GMT
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
	by aserp2130.oracle.com with ESMTP id 2hxpvcpq5h-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 15 May 2018 12:18:04 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w4FCI320013996
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Tue, 15 May 2018 12:18:03 GMT
Received: from abhmp0012.oracle.com (abhmp0012.oracle.com [141.146.116.18])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w4FCI3nZ014440
	for <linux-mm@kvack.org>; Tue, 15 May 2018 12:18:03 GMT
Received: by mail-ot0-f170.google.com with SMTP id g7-v6so18169350otj.11
        for <linux-mm@kvack.org>; Tue, 15 May 2018 05:18:03 -0700 (PDT)
MIME-Version: 1.0
References: <20180510115356.31164-1-pasha.tatashin@oracle.com>
 <20180510123039.GF5325@dhcp22.suse.cz> <CAGM2reZbYR96_uv-SB=5eL6tt0OSq9yXhtA-B2TGHbRQtfGU6g@mail.gmail.com>
 <20180515091036.GC12670@dhcp22.suse.cz>
In-Reply-To: <20180515091036.GC12670@dhcp22.suse.cz>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Tue, 15 May 2018 08:17:27 -0400
Message-ID: <CAGM2reaQusBA-nmQ5xqH4u-EVxgJCnaHAZs=1AXFOpNWTh7VbQ@mail.gmail.com>
Subject: Re: [PATCH v2] mm: allow deferred page init for vmemmap only
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Steven Rostedt <rostedt@goodmis.org>, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

Hi Michal,

Thank you for your reply, my comments below:

> You are now disabling a potentially useful feature to SPARSEMEM users
> without having any evidence that they do suffer from the issue which is
> kinda sad. Especially when the only known offender is a UP pcp allocator
> implementation.

True, but what is the use case for having SPARSEMEM without virtual mapping
and deferred struct page init together. Is it a common case to have
multiple gigabyte of memory and currently NUMA config to benefit from
deferred page init and yet not having a memory for virtual mapping of
struct pages? Or am I missing some common case here?

> I will not insist of course but it seems like your fix doesn't really
> prevent virt_to_page or other direct page access either.

I am not sure what do you mean, I do not prevent virt_to_page, but that is
OK for SPARSEMEM_VMEMMAP case, because we do not need to access "struct
page" for this operation, as translation is in page table. Yes, we do not
prohibit other struct page accesses before mm_init(), but we now have a
feature that checks for uninitialized struct page access, and if those will
happen, we will learn about them.

Thank you,
Pavel
