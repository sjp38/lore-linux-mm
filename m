Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5735D6B0005
	for <linux-mm@kvack.org>; Thu, 19 May 2016 13:23:57 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 203so169287496pfy.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 10:23:57 -0700 (PDT)
Received: from mail-pa0-x230.google.com (mail-pa0-x230.google.com. [2607:f8b0:400e:c03::230])
        by mx.google.com with ESMTPS id a62si21252382pfc.166.2016.05.19.10.23.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 10:23:56 -0700 (PDT)
Received: by mail-pa0-x230.google.com with SMTP id qo8so31164634pab.1
        for <linux-mm@kvack.org>; Thu, 19 May 2016 10:23:56 -0700 (PDT)
Date: Thu, 19 May 2016 10:23:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: compact: fix zoneindex in compact
In-Reply-To: <573DADF7.4000109@suse.cz>
Message-ID: <alpine.LSU.2.11.1605191020470.12425@eggly.anvils>
References: <1463659121-84124-1-git-send-email-puck.chen@hisilicon.com> <573DAD84.7020403@suse.cz> <573DADF7.4000109@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Chen Feng <puck.chen@hisilicon.com>, mhocko@suse.com, kirill.shutemov@linux.intel.com, hannes@cmpxchg.org, tj@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, suzhuangluan@hisilicon.com, dan.zhao@hisilicon.com, qijiwen@hisilicon.com, xuyiping@hisilicon.com, oliver.fu@hisilicon.com, puck.chen@foxmail.com

On Thu, 19 May 2016, Vlastimil Babka wrote:
> On 05/19/2016 02:11 PM, Vlastimil Babka wrote:
> > On 05/19/2016 01:58 PM, Chen Feng wrote:
> >> While testing the kcompactd in my platform 3G MEM only DMA ZONE.
> >> I found the kcompactd never wakeup. It seems the zoneindex
> >> has already minus 1 before. So the traverse here should be <=.
> > 
> > Ouch, thanks!
> > 
> >> Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
> > 
> > Fixes: 0f87baf4f7fb ("mm: wake kcompactd before kswapd's short sleep")
> 
> Bah, not that one.
> 
> Fixes: accf62422b3a ("mm, kswapd: replace kswapd compaction with waking
> up kcompactd")
> 
> > Cc: stable@vger.kernel.org
> > Acked-by: Vlastimil Babka <vbabka@suse.cz>
> > 
> >> ---
> >>  mm/compaction.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >>
> >> diff --git a/mm/compaction.c b/mm/compaction.c
> >> index 8fa2540..e5122d9 100644
> >> --- a/mm/compaction.c
> >> +++ b/mm/compaction.c
> >> @@ -1742,7 +1742,7 @@ static bool kcompactd_node_suitable(pg_data_t *pgdat)
> >>  	struct zone *zone;
> >>  	enum zone_type classzone_idx = pgdat->kcompactd_classzone_idx;
> >>  
> >> -	for (zoneid = 0; zoneid < classzone_idx; zoneid++) {
> >> +	for (zoneid = 0; zoneid <= classzone_idx; zoneid++) {
> >>  		zone = &pgdat->node_zones[zoneid];
> >>  
> >>  		if (!populated_zone(zone))

Ignorant question: kcompactd_do_work() just below has a similar loop:
should that one be saying "zoneid <= cc.classzone_idx" too?

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
