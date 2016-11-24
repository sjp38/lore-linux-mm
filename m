Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id A98066B025E
	for <linux-mm@kvack.org>; Thu, 24 Nov 2016 07:12:15 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id g23so14360999wme.4
        for <linux-mm@kvack.org>; Thu, 24 Nov 2016 04:12:15 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k129si7870723wmb.68.2016.11.24.04.12.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Nov 2016 04:12:14 -0800 (PST)
Date: Thu, 24 Nov 2016 13:12:09 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: Softlockup during memory allocation
Message-ID: <20161124121209.GE20668@dhcp22.suse.cz>
References: <a73f4917-48ac-bf1e-04d9-64fb937abfc6@kyup.com>
 <CAJFSNy5_z_FA4DTPAtqBdOU+LmnfvdeVBtDhHuperv1MVU-9VA@mail.gmail.com>
 <20161121053154.GA29816@dhcp22.suse.cz>
 <ab42c7a5-49e2-4e46-be60-e0a56704a11d@kyup.com>
 <20161122143056.GB6831@dhcp22.suse.cz>
 <6c33f44b-327c-d943-73da-5935136a83c9@kyup.com>
 <20161122170239.GH6831@dhcp22.suse.cz>
 <dca0dfb4-6623-f11f-5f6e-1afac02d5ee6@kyup.com>
 <20161123074947.GE2864@dhcp22.suse.cz>
 <e0bdfd66-9e15-dee7-c311-b1785efab390@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e0bdfd66-9e15-dee7-c311-b1785efab390@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: Linux MM <linux-mm@kvack.org>

On Thu 24-11-16 13:45:03, Nikolay Borisov wrote:
[...]
> Ok, I think I know what has happened. Inspecting the data structures of
> the respective cgroup here is what the mem_cgroup_per_zone looks like:
> 
>   zoneinfo[2] =   {
>     lruvec = {{
>         lists = {
>           {
>             next = 0xffffea004f98c660,
>             prev = 0xffffea0063f6b1a0
>           },
>           {
>             next = 0xffffea0004123120,
>             prev = 0xffffea002c2e2260
>           },
>           {
>             next = 0xffff8818c37bb360,
>             prev = 0xffff8818c37bb360
>           },
>           {
>             next = 0xffff8818c37bb370,
>             prev = 0xffff8818c37bb370
>           },
>           {
>             next = 0xffff8818c37bb380,
>             prev = 0xffff8818c37bb380
>           }
>         },
>         reclaim_stat = {
>           recent_rotated = {172969085, 43319509},
>           recent_scanned = {173112994, 185446658}
>         },
>         zone = 0xffff88207fffcf00
>     }},
>     lru_size = {159722, 158714, 0, 0, 0},
>     }
> 
> So this means that there are inactive_anon and active_annon only -
> correct?

yes. at least in this particular zone.

> Since the machine doesn't have any swap this means anon memory
> has nowhere to go. If I'm interpreting the data correctly then this
> explains why reclaim makes no progress. If that's the case then I have
> the following questions:
> 
> 1. Shouldn't reclaim exit at some point rather than being stuck in
> reclaim without making further progress.

Reclaim (try_to_free_mem_cgroup_pages) has to go down all priorities
without to get out. We are not doing any pro-active checks whether there
is anything reclaimable but that alone shouldn't be such a big deal
because shrink_node_memcg should simply do nothing because
get_scan_count will find no pages to scan. So it shouldn't take much
time to realize there is nothing to reclaim and get back to try_charge
which retries few more times and eventually goes OOM. I do not see how
we could trigger rcu stalls here. There shouldn't be any long RCU
critical section on the way and preemption points on the way.

> 2. It seems rather strange that there are no (INACTIVE|ACTIVE)_FILE
> pages - is this possible?

All of them might be reclaimed already as a result of the memory
pressure in the memcg. So not all that surprising. But the fact that
you are hitting the limit means that the anonymous pages saturate your
hard limit so your memcg seems underprovisioned.

> 3. Why hasn't OOM been activated in order to free up some anonymous memory ?

It should eventually. Maybe there still were some reclaimable pages in
other zones for this memcg.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
