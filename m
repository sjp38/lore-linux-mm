Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 454066B05FD
	for <linux-mm@kvack.org>; Thu, 10 May 2018 08:30:45 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id r63-v6so1084745pfl.12
        for <linux-mm@kvack.org>; Thu, 10 May 2018 05:30:45 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3-v6si729402plh.224.2018.05.10.05.30.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 May 2018 05:30:43 -0700 (PDT)
Date: Thu, 10 May 2018 14:30:39 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm: allow deferred page init for vmemmap only
Message-ID: <20180510123039.GF5325@dhcp22.suse.cz>
References: <20180510115356.31164-1-pasha.tatashin@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180510115356.31164-1-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: steven.sistare@oracle.com, daniel.m.jordan@oracle.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, tglx@linutronix.de, linux-mm@kvack.org, mgorman@techsingularity.net, mingo@kernel.org, peterz@infradead.org, rostedt@goodmis.org, fengguang.wu@intel.com, dennisszhou@gmail.com

On Thu 10-05-18 07:53:56, Pavel Tatashin wrote:
[...]
> Here is a sample path, where translation is required, that occurs before
> mm_init():
> 
> start_kernel()
>  trap_init()
>   setup_cpu_entry_areas()
>    setup_cpu_entry_area(cpu)
>     get_cpu_gdt_paddr(cpu)
>      per_cpu_ptr_to_phys(addr)
>       pcpu_addr_to_page(addr)
>        virt_to_page(addr)
>         pfn_to_page(__pa(addr) >> PAGE_SHIFT)

Thanks that helped me to see the problem. On the other hand isn't this a
bit of an overkill? AFAICS this affects only NEED_PER_CPU_KM which is !SMP
and DEFERRED_STRUCT_PAGE_INIT makes only very limited sense on UP,
right?

Or do we have more such places?
-- 
Michal Hocko
SUSE Labs
