Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CFEDB6B0397
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 12:25:05 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id k22so6904289wrk.5
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 09:25:05 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 205si23319321wme.109.2017.04.06.09.25.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 09:25:04 -0700 (PDT)
Date: Thu, 6 Apr 2017 17:24:57 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/6] mm: make movable onlining suck less
Message-ID: <20170406162457.6ewfmyekidogvfth@suse.de>
References: <20170330115454.32154-1-mhocko@kernel.org>
 <20170406130846.GL5497@dhcp22.suse.cz>
 <20170406152449.zmghwdb4y6hxn4pm@arbab-laptop>
 <20170406154127.GQ5497@dhcp22.suse.cz>
 <20170406154653.yv4i2k2r7hjq6mke@arbab-laptop>
 <20170406162154.GR5497@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170406162154.GR5497@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Reza Arbab <arbab@linux.vnet.ibm.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Yasuaki Ishimatsu <yasu.isimatu@gmail.com>, Tang Chen <tangchen@cn.fujitsu.com>, qiuxishi@huawei.com, Kani Toshimitsu <toshi.kani@hpe.com>, slaoub@gmail.com, Joonsoo Kim <js1304@gmail.com>, Andi Kleen <ak@linux.intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, David Rientjes <rientjes@google.com>, Daniel Kiper <daniel.kiper@oracle.com>, Igor Mammedov <imammedo@redhat.com>, Vitaly Kuznetsov <vkuznets@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Chris Metcalf <cmetcalf@mellanox.com>, Dan Williams <dan.j.williams@gmail.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>

On Thu, Apr 06, 2017 at 06:21:55PM +0200, Michal Hocko wrote:
> On Thu 06-04-17 10:46:53, Reza Arbab wrote:
> > On Thu, Apr 06, 2017 at 05:41:28PM +0200, Michal Hocko wrote:
> > >On Thu 06-04-17 10:24:49, Reza Arbab wrote:
> > >>On Thu, Apr 06, 2017 at 03:08:46PM +0200, Michal Hocko wrote:
> > >>>OK, so after recent change mostly driven by testing from Reza Arbab
> > >>>(thanks again) I believe I am getting to a working state finally. All I
> > >>>currently have is
> > >>>in git://git.kernel.org/pub/scm/linux/kernel/git/mhocko/mm.git tree
> > >>>attempts/rewrite-mem_hotplug-WIP branch. I will highly appreciate more
> > >>>testing of course and if there are no new issues found I will repost the
> > >>>series for the review.
> > >>
> > >>Looking good! I can do my add/remove/repeat test and things seem fine.
> > >>
> > >>One thing--starting on the second iteration, I am seeing the WARN in
> > >>free_area_init_node();
> > >>
> > >>add_memory
> > >> add_memory_resource
> > >>   hotadd_new_pgdat
> > >>     free_area_init_node
> > >>	WARN_ON(pgdat->nr_zones || pgdat->kswapd_classzone_idx);
> > >
> > >Have you tested with my attempts/rewrite-mem_hotplug-WIP mentioned
> > >elsewhere? Because I suspect that "mm: get rid of zone_is_initialized"
> > >might cause this.
> > 
> > This was my first time using your git branch instead of applying the patches
> > from this thread to v4.11-rc5 myself.
> 
> OK, so this looks like another thing to resolve. I have seen this
> warning as well but I didn't consider it relevant because I had to tweak
> the code make the node go offline (removed check_and_unmap_cpu_on_node
> from try_offline_node) so I thought it was a fallout from there. 
> 
> But let's have a look. hotadd_new_pgdat does for an existing pgdat
> 		/* Reset the nr_zones, order and classzone_idx before reuse */
> 		pgdat->nr_zones = 0;
> 		pgdat->kswapd_order = 0;
> 		pgdat->kswapd_classzone_idx = MAX_NR_ZONES;
> 
> so free_area_init_node absolutely has to hit this warning. This is not
> in the Linus tree because it is still in Andrew's mmotm coming from
> http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-vmscan-prevent-kswapd-sleeping-prematurely-due-to-mismatched-classzone_idx.patch
> 
> So yay, finally that doesn't come from me. Mel, I guess that either
> hotadd_new_pgdat should keep its kswapd_classzone_idx = 0 or the warning
> should be updated.
> 

Almost certainly the case that the warning should be updated.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
