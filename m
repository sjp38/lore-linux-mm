Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 62EA16B002C
	for <linux-mm@kvack.org>; Mon, 19 Feb 2018 14:18:40 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id z11so6667082plo.21
        for <linux-mm@kvack.org>; Mon, 19 Feb 2018 11:18:40 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n4-v6si4933860plp.199.2018.02.19.11.18.39
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 19 Feb 2018 11:18:39 -0800 (PST)
Date: Mon, 19 Feb 2018 20:18:34 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm: Fix for PG_reserved page flag clearing
Message-ID: <20180219191834.GS21134@dhcp22.suse.cz>
References: <d77ca418-1614-6ad3-d739-161ca737b7ec@gmail.com>
 <20180219171916.GR21134@dhcp22.suse.cz>
 <cdc33597-191f-1471-ce5e-9efba1bf5fe7@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cdc33597-191f-1471-ce5e-9efba1bf5fe7@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Masayoshi Mizuma <msys.mizuma@gmail.com>
Cc: akpm@linux-foundation.org, mgorman@techsingularity.net, pasha.tatashin@oracle.com, linux-mm@kvack.org

On Mon 19-02-18 14:11:03, Masayoshi Mizuma wrote:
> Hello Michal, 
> 
> Mon, 19 Feb 2018 18:19:16 +0100 Michal Hocko wrote:
> > On Mon 19-02-18 12:06:14, Masayoshi Mizuma wrote:
> >> From: Masayoshi Mizuma <m.mizuma@jp.fujitsu.com>
> >>
> >> struct page is inizialized as zero in __init_single_page().
> >> If the page is offlined page, PG_reserved flag is set in early boot
> >> time before __init_single_page(), so we should not clear the flag.
> >>
> >> The real problem is that we can not online the offlined page
> >> through following sysfs operation because offlined page is
> >> expected PG_reserved flag is set. 
> >> It is not needed the initialization, so remove it simply.
> >>
> >>   Code:
> >>
> >>   static int online_pages_range(unsigned long start_pfn, 
> >>   ...
> >>           if (PageReserved(pfn_to_page(start_pfn))) <= HERE!!
> >>                   for (i = 0; i < nr_pages; i++) {
> >>                           page = pfn_to_page(start_pfn + i);
> >>                           (*online_page_callback)(page);
> >>                           onlined_pages++;
> >>   sysfs operation:
> >>
> >>   # echo online > /sys/devices/system/node/node2/memory12288/online
> >>   # cat /sys/devices/system/node/node2/memory12288/online 
> >>   1
> >>   # cat /sys/devices/system/node/node2/meminfo 
> >>   Node 2 MemTotal:              0 kB
> > 
> > Nack. The patch is simply wrong. We do need to zero page for the boot
> > pages. I believe the fix you are looking for is 9bb5a391f9a5 ("mm,
> > memory_hotplug: fix memmap initialization"). Or do you still see a
> > problem with this patch applied?
> 
> I have confirmed the problem is fixed by your patch 9bb5a391f9a5.
> (I had tested it in 4.15.2, so I did not notice your patch, sorry)

I have posted the backport for the 4.15 stable tree just an hour ago so
it should appear in the next stable release.

Thanks for double checking.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
