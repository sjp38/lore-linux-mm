Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id E3A006B0003
	for <linux-mm@kvack.org>; Mon,  5 Nov 2018 09:23:13 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id n68so21208377qkn.8
        for <linux-mm@kvack.org>; Mon, 05 Nov 2018 06:23:13 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 42si503565qvd.29.2018.11.05.06.23.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Nov 2018 06:23:12 -0800 (PST)
Date: Mon, 5 Nov 2018 22:23:08 +0800
From: Baoquan He <bhe@redhat.com>
Subject: Re: [PATCH] mm, memory_hotplug: teach has_unmovable_pages about of
 LRU migrateable pages
Message-ID: <20181105142308.GJ27491@MiWiFi-R3L-srv>
References: <20181101091055.GA15166@MiWiFi-R3L-srv>
 <20181102155528.20358-1-mhocko@kernel.org>
 <20181105002009.GF27491@MiWiFi-R3L-srv>
 <20181105091407.GB4361@dhcp22.suse.cz>
 <20181105092851.GD4361@dhcp22.suse.cz>
 <20181105102520.GB22011@MiWiFi-R3L-srv>
 <20181105123837.GH4361@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181105123837.GH4361@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Stable tree <stable@vger.kernel.org>

On 11/05/18 at 01:38pm, Michal Hocko wrote:
> On Mon 05-11-18 18:25:20, Baoquan He wrote:
> > Hi Michal,
> > 
> > On 11/05/18 at 10:28am, Michal Hocko wrote:
> > > 
> > > Or something like this. Ugly as hell, no question about that. I also
> > > have to think about this some more to convince myself this will not
> > > result in an endless loop under some situations.
> > 
> > It failed. Paste the log and patch diff here, please help check if I made
> > any mistake on manual code change. The log is at bottom.
> 
> The retry patch is obviously still racy, it just makes the race window
> slightly smaller and I hoped it would catch most of those races but this
> is obviously not the case.
> 
> I was thinking about your MIGRATE_MOVABLE check some more and I still do
> not like it much, we just change migrate type at many places and I have
> hard time to actually see this is always safe wrt. to what we need here.
> 
> We should be able to restore the zone type check though. The
> primary problem fixed by 15c30bc09085 ("mm, memory_hotplug: make
> has_unmovable_pages more robust") was that early allocations made it to
> the zone_movable range. If we add the check _after_ the PageReserved()
> check then we should be able to rule all bootmem allocation out.
> 
> So what about the following (on top of the previous patch which makes
> sense on its own I believe).

Yes, I think this looks very reasonable and should be robust.

Have tested it, hot removing 4 hotpluggable nodes continusously
succeeds, and then hot adding them back, still works well.

So please feel free to add my Tested-by or Acked-by.

Tested-by: Baoquan He <bhe@redhat.com>
or
Acked-by: Baoquan He <bhe@redhat.com>

Thanks, Michal.
> 
> 
> From d7ffd1342529c892f1de8999c3a5609211599c9d Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Mon, 5 Nov 2018 13:28:51 +0100
> Subject: [PATCH] mm, memory_hotplug: check zone_movable in has_unmovable_pages
> 
> Page state checks are racy. Under a heavy memory workload (e.g. stress
> -m 200 -t 2h) it is quite easy to hit a race window when the page is
> allocated but its state is not fully populated yet. A debugging patch to
> dump the struct page state shows
> : [  476.575516] has_unmovable_pages: pfn:0x10dfec00, found:0x1, count:0x0
> : [  476.582103] page:ffffea0437fb0000 count:1 mapcount:1 mapping:ffff880e05239841 index:0x7f26e5000 compound_mapcount: 1
> : [  476.592645] flags: 0x5fffffc0090034(uptodate|lru|active|head|swapbacked)
> 
> Note that the state has been checked for both PageLRU and PageSwapBacked
> already. Closing this race completely would require some sort of retry
> logic. This can be tricky and error prone (think of potential endless
> or long taking loops).
> 
> Workaround this problem for movable zones at least. Such a zone should
> only contain movable pages. 15c30bc09085 ("mm, memory_hotplug: make
> has_unmovable_pages more robust") has told us that this is not strictly
> true though. Bootmem pages should be marked reserved though so we can
> move the original check after the PageReserved check. Pages from other
> zones are still prone to races but we even do not pretend that memory
> hotremove works for those so pre-mature failure doesn't hurt that much.
> 
> Reported-by: Baoquan He <bhe@redhat.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/page_alloc.c | 8 ++++++++
>  1 file changed, 8 insertions(+)
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 48ceda313332..5b64c5bc6ea0 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -7788,6 +7788,14 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
>  		if (PageReserved(page))
>  			goto unmovable;
>  
> +		/*
> +		 * If the zone is movable and we have ruled out all reserved
> +		 * pages then it should be reasonably safe to assume the rest
> +		 * is movable.
> +		 */
> +		if (zone_idx(zone) == ZONE_MOVABLE)
> +			continue;
> +
>  		/*
>  		 * Hugepages are not in LRU lists, but they're movable.
>  		 * We need not scan over tail pages bacause we don't
> -- 
> 2.19.1
> 
> -- 
> Michal Hocko
> SUSE Labs
