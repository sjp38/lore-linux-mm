Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id EA7846B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 22:06:24 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so218665pad.16
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 19:06:24 -0700 (PDT)
Message-ID: <525DF466.6030308@redhat.com>
Date: Tue, 15 Oct 2013 22:05:26 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [patch 0/8] mm: thrash detection-based file cache sizing v5
References: <1381441622-26215-1-git-send-email-hannes@cmpxchg.org> <20131011003930.GC4446@dastard> <20131014214250.GG856@cmpxchg.org> <20131015014123.GQ4446@dastard> <20131015174128.GH856@cmpxchg.org> <20131015234147.GA4446@dastard>
In-Reply-To: <20131015234147.GA4446@dastard>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Andrea Arcangeli <aarcange@redhat.com>, Greg Thelen <gthelen@google.com>, Christoph Hellwig <hch@infradead.org>, Hugh Dickins <hughd@google.com>, Jan Kara <jack@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Roman Gushchin <klamm@yandex-team.ru>, Ozgun Erdogan <ozgun@citusdata.com>, Metin Doslu <metin@citusdata.com>, Vlastimil Babka <vbabka@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org

On 10/15/2013 07:41 PM, Dave Chinner wrote:
> On Tue, Oct 15, 2013 at 01:41:28PM -0400, Johannes Weiner wrote:

>> I'm not forgetting about them, I just track them very coarsely by
>> linking up address spaces and then lazily enforce their upper limit
>> when memory is tight by using the shrinker callback.  The assumption
>> was that actually scanning them is such a rare event that we trade the
>> rare computational costs for smaller memory consumption most of the
>> time.
> 
> Sure, I understand the tradeoff that you made. But there's nothing
> worse than a system that slows down unpredictably because of some
> magic threshold in some subsystem has been crossed and
> computationally expensive operations kick in.

The shadow shrinker should remove the radix nodes with
the oldest shadow entries first, so true LRU should actually
work for the radix tree nodes.

Actually, since we only care about the age of the youngest
shadow entry in each radix tree node, FIFO will be the same
as LRU for that list.

That means the shrinker can always just take the radix tree
nodes off the end.

>> But it
>> looks like tracking radix tree nodes with a list and backpointers to
>> the mapping object for the lock etc. will be a major pain in the ass.
> 
> Perhaps so - it may not work out when we get down to the fine
> details...

I suspect that a combination of lifetime rules (inode cannot
disappear until all the radix tree nodes) and using RCU free
for the radix tree nodes, and the inodes might do the trick.

That would mean that, while holding the rcu read lock, the
back pointer from a radix tree node to the inode will always
point to valid memory.

That allows the shrinker to lock the inode, and verify that
the inode is still valid, before it attempts to rcu free the
radix tree node with shadow entries.

It also means that locking only needs to be in the inode,
and on the LRU list for shadow radix tree nodes.

Does that sound sane?

Am I overlooking something?

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
