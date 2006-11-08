Date: Tue, 7 Nov 2006 18:08:44 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Page allocator: Single Zone optimizations
In-Reply-To: <20061108092957.d9f7fc74.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <Pine.LNX.4.64.0611071801160.7749@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.64.0610271225320.9346@schroedinger.engr.sgi.com>
 <454A2CE5.6080003@shadowen.org> <Pine.LNX.4.64.0611021004270.8098@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022053490.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021345140.9877@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611022153491.27544@skynet.skynet.ie>
 <Pine.LNX.4.64.0611021442210.10447@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611030900480.9787@skynet.skynet.ie>
 <Pine.LNX.4.64.0611030952530.14741@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611031825420.25219@skynet.skynet.ie>
 <Pine.LNX.4.64.0611031124340.15242@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611032101190.25219@skynet.skynet.ie>
 <Pine.LNX.4.64.0611031329480.16397@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611071629040.11212@skynet.skynet.ie>
 <Pine.LNX.4.64.0611070947100.3791@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0611071756050.11212@skynet.skynet.ie>
 <20061108092957.d9f7fc74.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Mel Gorman <mel@csn.ul.ie>, apw@shadowen.org, akpm@osdl.org, nickpiggin@yahoo.com.au, linux-mm@kvack.org, a.p.zijlstra@chello.nl
List-ID: <linux-mm.kvack.org>

On Wed, 8 Nov 2006, KAMEZAWA Hiroyuki wrote:

> In these days, I've struggled with crashdump from a user to investigate the reason
> of oom-kill. At last, the reason was most of 2G bytes ZONE_DMA pages were
> mlocked(). Sigh....
> I wonder we can use migration of MOVABLE pages for zone balancing in future.
> (maybe complicated but...)

If we run out of ZONE_DMA memory in the page allocator then scan through 
the LRU of ZONE_DMA for pages, call isolate_lru_page() for each page that 
you find worthy of moving (all mlocked pages f.e.) and when you have 
collected a sufficient quantity call migrate_pages() to get all that are 
movable out of ZONE_DMA. 

Note though that any writeback of the migrated pages to devices that 
require pages <2G will then allocate a bounce buffer for the page.

Seems that you found another reason why it would be useful to get 
rid of ZONE_DMA entirely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
