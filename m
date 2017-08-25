Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5B59744088B
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 20:20:06 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 83so3754104pgb.1
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 17:20:06 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id o84si741384pfi.421.2017.08.24.17.20.04
        for <linux-mm@kvack.org>;
        Thu, 24 Aug 2017 17:20:05 -0700 (PDT)
Date: Fri, 25 Aug 2017 09:20:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
Message-ID: <20170825002031.GD29701@js1304-P5Q-DELUXE>
References: <1503553546-27450-1-git-send-email-iamjoonsoo.kim@lge.com>
 <e919c65e-bc2f-6b3b-41fc-3589590a84ac@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e919c65e-bc2f-6b3b-41fc-3589590a84ac@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Aug 24, 2017 at 11:41:58AM +0200, Vlastimil Babka wrote:
> On 08/24/2017 07:45 AM, js1304@gmail.com wrote:
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > Freepage on ZONE_HIGHMEM doesn't work for kernel memory so it's not that
> > important to reserve. When ZONE_MOVABLE is used, this problem would
> > theorectically cause to decrease usable memory for GFP_HIGHUSER_MOVABLE
> > allocation request which is mainly used for page cache and anon page
> > allocation. So, fix it.
> > 
> > And, defining sysctl_lowmem_reserve_ratio array by MAX_NR_ZONES - 1 size
> > makes code complex. For example, if there is highmem system, following
> > reserve ratio is activated for *NORMAL ZONE* which would be easyily
> > misleading people.
> > 
> >  #ifdef CONFIG_HIGHMEM
> >  32
> >  #endif
> > 
> > This patch also fix this situation by defining sysctl_lowmem_reserve_ratio
> > array by MAX_NR_ZONES and place "#ifdef" to right place.
> > 
> > Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> Looks like I did that almost year ago, so definitely had to refresh my
> memory now :)
> 
> Anyway now I looked more thoroughly and noticed that this change leaks
> into the reported sysctl. On a 64bit system with ZONE_MOVABLE:
> 
> before the patch:
> vm.lowmem_reserve_ratio = 256   256     32
> 
> after the patch:
> vm.lowmem_reserve_ratio = 256   256     32      2147483647
> 
> So if we indeed remove HIGHMEM from protection (c.f. Michal's mail), we
> should do that differently than with the INT_MAX trick, IMHO.

Hmm, this is already pointed by Minchan and I have answered that.

lkml.kernel.org/r/<20170421013243.GA13966@js1304-desktop>

If you have a better idea, please let me know.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
