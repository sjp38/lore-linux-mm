Date: Fri, 25 May 2007 16:43:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Patch] memory unplug v3 [2/4] migration by kernel
Message-Id: <20070525164309.8175d241.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0705231855000.11495@skynet.skynet.ie>
References: <20070522155824.563f5873.kamezawa.hiroyu@jp.fujitsu.com>
	<20070522160437.6607f445.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0705221143450.29456@schroedinger.engr.sgi.com>
	<Pine.LNX.4.64.0705231855000.11495@skynet.skynet.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: clameter@sgi.com, linux-mm@kvack.org, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

On Wed, 23 May 2007 20:14:39 +0100 (IST)
Mel Gorman <mel@csn.ul.ie> wrote:

> I put together a memory compaction prototype today[*] to check because 
> it's been put off long enough. However, memory compaction works whether I 
> called migrate_pages() or migrate_pages_nocontext() even when regularly 
> compacting under load. That said, calling migrate_pages() is probably 
> racing like mad and I am not getting nailed for it as the test machine is 
> small with one CPU and the stress load is kernel compiles instead of 
> processes with mapped data. I'm basing compaction on top of a slightly 
> modified version of this patch and will revisit it later.
> 
thank you for test :)

We (I and Goto-san) saw !page_mapped(page) case in try_to_unmap() under heavy
memory pressure,....swapping.
So, at least, 
==
+	if (page_mapped(page))
+		try_to_unmap(page, 1);
==
This change is necessary.

About anon_vma, see comments in page_remove_rmap().

> Incidentally, the results of the compaction at rest are;
> 
> Freelists before compaction
> Node    0, zone   Normal, type    Unmovable    302     55     26     20     12      6      2      0      0      0      0
> Node    0, zone   Normal, type  Reclaimable   3165    734    218     28      3      0      0      0      0      0      0
> Node    0, zone   Normal, type      Movable   4986   2222   1980   1553    752    238     26      2      0      0      0
> Node    0, zone   Normal, type      Reserve      5      3      0      0      1      1      0      0      1      1      0
> 
> Freelists after compaction
> Node    0, zone   Normal, type    Unmovable    278     32     14     12     10      5      4      2      0      0      0
> Node    0, zone   Normal, type  Reclaimable   3184    743    226     32      3      0      0      0      0      0      0
> Node    0, zone   Normal, type      Movable    862    676    599    421    238     94     17      6      4      3     31
> Node    0, zone   Normal, type      Reserve      1      1      1      1      1      1      1      1      1      1      0
> 
> So it's doing something and the machine hasn't killed itself in the face. 
> Aside, the page migration framework is ridiculously easy to work with - 
> kudos to all who worked on it.
> 

I'll write this patch as one independent from memory unplug, AMAP.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
