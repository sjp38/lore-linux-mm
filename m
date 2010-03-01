Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id DD1286B0047
	for <linux-mm@kvack.org>; Mon,  1 Mar 2010 07:14:30 -0500 (EST)
Date: Mon, 1 Mar 2010 12:14:10 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch 25/36] _GFP_NO_KSWAPD
Message-ID: <20100301121410.GD3852@csn.ul.ie>
References: <20100221141009.581909647@redhat.com> <20100221141756.772875923@redhat.com> <4B82C487.9020407@redhat.com> <20100222180009.GM11504@random.random> <4B82C6D2.8010201@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <4B82C6D2.8010201@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Avi Kivity <avi@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>
List-ID: <linux-mm.kvack.org>

On Mon, Feb 22, 2010 at 08:02:58PM +0200, Avi Kivity wrote:
> On 02/22/2010 08:00 PM, Andrea Arcangeli wrote:
>> On Mon, Feb 22, 2010 at 12:53:11PM -0500, Rik van Riel wrote:
>>    
>>> Once Mel's defragmentation code is in, we can kick off
>>> that code instead when a hugepage allocation fails.
>>>      
>> That will be cool yes!! Then maybe we can turn on defrag by
>> default... (maybe because it'd still slowdown the allocation time)
>>
>> I think at least for khugepaged invoking memory compaction code by
>> default is going to be good idea. And then I wonder if it makes sense
>> to allow the user to disable defrag in khugepaged, if yes then it'd
>> require a new sysfs file in the khugepaged directory.
>>    
>
> If we detect hugepage pressure, we can run compaction in a separate  
> thread, so we can have low latency allocations.
>

It'd require something like "kcompactd" and a definition of hugepage pressure
but yeah, it's feasible. I think it should be on the relatively long-finger
until such point as there is clear data on how long processes stall on
compaction that could be resolved with a separate thread. I suspect what will
happen in practice is that there will be pairings of (compaction,reclaim)
during promotion where reclaim is periodically required to dump unused
page cache before compaction can progress. If that prediction is accurate,
would not help because it would be kicked awake, see that enough memory is
not free and then go to sleep. kswapd could take on a dual role where it
decides whether to reclaim or compact but it's harder to predict what the
performance impact would be.

I'm not against the idea, but I wouldn't rush to implement it sooner than
it's needed either.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
