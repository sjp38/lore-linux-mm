Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id A631D6B028B
	for <linux-mm@kvack.org>; Tue, 15 May 2018 08:55:46 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id n17-v6so218635wmc.8
        for <linux-mm@kvack.org>; Tue, 15 May 2018 05:55:46 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k55-v6si298086edd.138.2018.05.15.05.55.44
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 05:55:44 -0700 (PDT)
Date: Tue, 15 May 2018 14:55:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: allow deferred page init for vmemmap only
Message-ID: <20180515125541.GH12670@dhcp22.suse.cz>
References: <20180510115356.31164-1-pasha.tatashin@oracle.com>
 <20180510123039.GF5325@dhcp22.suse.cz>
 <CAGM2reZbYR96_uv-SB=5eL6tt0OSq9yXhtA-B2TGHbRQtfGU6g@mail.gmail.com>
 <20180515091036.GC12670@dhcp22.suse.cz>
 <CAGM2reaQusBA-nmQ5xqH4u-EVxgJCnaHAZs=1AXFOpNWTh7VbQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAGM2reaQusBA-nmQ5xqH4u-EVxgJCnaHAZs=1AXFOpNWTh7VbQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, tglx@linutronix.de, Linux Memory Management List <linux-mm@kvack.org>, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, Steven Rostedt <rostedt@goodmis.org>, Fengguang Wu <fengguang.wu@intel.com>, Dennis Zhou <dennisszhou@gmail.com>

On Tue 15-05-18 08:17:27, Pavel Tatashin wrote:
> Hi Michal,
> 
> Thank you for your reply, my comments below:
> 
> > You are now disabling a potentially useful feature to SPARSEMEM users
> > without having any evidence that they do suffer from the issue which is
> > kinda sad. Especially when the only known offender is a UP pcp allocator
> > implementation.
> 
> True, but what is the use case for having SPARSEMEM without virtual mapping
> and deferred struct page init together. Is it a common case to have
> multiple gigabyte of memory and currently NUMA config to benefit from
> deferred page init and yet not having a memory for virtual mapping of
> struct pages? Or am I missing some common case here?

Well, I strongly suspect that this is more a momentum, then a real
reason to stick with SPARSEMEM_MANUAL. I would really love to reduce the
number of memory models we have. Getting rid of SPARSEMEM would be a
good start as VMEMMAP should be much better.
 
> > I will not insist of course but it seems like your fix doesn't really
> > prevent virt_to_page or other direct page access either.
> 
> I am not sure what do you mean, I do not prevent virt_to_page, but that is
> OK for SPARSEMEM_VMEMMAP case, because we do not need to access "struct
> page" for this operation, as translation is in page table. Yes, we do not
> prohibit other struct page accesses before mm_init(), but we now have a
> feature that checks for uninitialized struct page access, and if those will
> happen, we will learn about them.

This will always be a maze as the early boot tends to be. Sad but true.
That is why I am not really convinced we should use a large hammer and
disallow deferred page initialization just because UP implementation of
pcp does something too early. We should instead rule that one odd case.
Your patch simply doesn't rule a large class of potential issues. It
just rules out a potentially useful feature for an odd case. See my
point?
-- 
Michal Hocko
SUSE Labs
