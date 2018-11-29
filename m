Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 678756B5378
	for <linux-mm@kvack.org>; Thu, 29 Nov 2018 11:18:51 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id s50so1324190edd.11
        for <linux-mm@kvack.org>; Thu, 29 Nov 2018 08:18:51 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x32si1158277edc.425.2018.11.29.08.18.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 29 Nov 2018 08:18:50 -0800 (PST)
Date: Thu, 29 Nov 2018 17:18:47 +0100
From: Michal Hocko <mhocko@suse.com>
Subject: Re: [PATCH] mm, show_mem: drop pgdat_resize_lock in show_mem()
Message-ID: <20181129161847.GU6923@dhcp22.suse.cz>
References: <20181128210815.2134-1-richard.weiyang@gmail.com>
 <20181129081703.GN6923@dhcp22.suse.cz>
 <20181129150449.desiutez735agyau@master>
 <20181129154922.GT6923@dhcp22.suse.cz>
 <20181129160524.ewjn2x7spyloitu4@master>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181129160524.ewjn2x7spyloitu4@master>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wei Yang <richard.weiyang@gmail.com>
Cc: akpm@linux-foundation.org, jweiner@fb.com, linux-mm@kvack.org

On Thu 29-11-18 16:05:24, Wei Yang wrote:
> On Thu, Nov 29, 2018 at 04:49:22PM +0100, Michal Hocko wrote:
[...]
> >It is only called from __remove_pages and that one calls cond_resched so
> >obviosly not.
> >
> 
> Forgive my poor background knowledge, I went throught the code, but not
> found where call cond_resched.
> 
>   __remove_pages()
>     release_mem_region_adjustable()
>     clear_zone_contiguous()
>     __remove_section()
>       unregister_memory_section()
>       __remove_zone()
>       sparse_remove_one_section()
>     set_zone_contiguous()
> 
> Would you mind giving me a hint?

This is the code as of 4.20-rc2

	for (i = 0; i < sections_to_remove; i++) {
		unsigned long pfn = phys_start_pfn + i*PAGES_PER_SECTION;

		cond_resched();
		ret = __remove_section(zone, __pfn_to_section(pfn), map_offset,
				altmap);
		map_offset = 0;
		if (ret)
			break;
	}

Maybe things have changed in the meantime but in general the code is
sleepable (e.g. release_mem_region_adjustable does GFP_KERNEL
allocation) and that rules out IRQ context.
-- 
Michal Hocko
SUSE Labs
