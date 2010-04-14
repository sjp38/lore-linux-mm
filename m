Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6822E6B01E3
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 08:15:20 -0400 (EDT)
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
From: Andi Kleen <andi@firstfloor.org>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com>
	<20100413095815.GU25756@csn.ul.ie> <20100413111902.GY2493@dastard>
	<20100413193428.GI25756@csn.ul.ie> <20100413202021.GZ13327@think>
	<877hoa9wlv.fsf@basil.nowhere.org> <20100414112015.GO13327@think>
Date: Wed, 14 Apr 2010 14:15:16 +0200
In-Reply-To: <20100414112015.GO13327@think> (Chris Mason's message of "Wed, 14 Apr 2010 07:20:15 -0400")
Message-ID: <8739yy9qnf.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Chris Mason <chris.mason@oracle.com> writes:
>> 
>> Basically if you cannot tolerate 1K (or more likely more) of stack
>> used before your fs is called you're toast in lots of other situations
>> anyways.
>
> Well, on a 4K stack kernel, 832 bytes is a very large percentage for
> just one function.

To be honest I think 4K stack simply has to go. I tend to call
it "russian roulette" mode. 

It was just a old workaround for a very old buggy VM that couldn't free 8K
pages and the VM is a lot better at that now. And the general trend is
to more complex code everywhere, so 4K stacks become more and more hazardous.

It was a bad idea back then and is still a bad idea, getting
worse and worse with each MLOC being added to the kernel each year.

We don't have any good ways to verify that obscure paths through
the more and more subsystems won't exceed it (in fact I'm pretty
sure there are plenty of problems in exotic configurations)

And even if you can make a specific load work there's basically
no safety net.

The only part of the 4K stack code that's good is the separate
interrupt stack, but that one should be just combined with a sane 8K 
process stack.

But yes on a 4K kernel you probably don't want to do any direct reclaim. 
Maybe for GFP_NOFS everywhere except user allocations when it's set? 
Or simply drop it?

> But they don't realize their function can dive down into ecryptfs then
> the filesystem then maybe loop and then perhaps raid6 on top of a
> network block device.

Those stackings need to use separate threads anyways. A lot of them
do in fact. Block avoided this problem by iterating instead of
recursing.  Those that still recurse on the same stack simply
need to be fixed.

> Yeah, but since the call chain does eventually go into the allocator,
> this function needs to be more stack friendly.

For common fast paths it doesn't go into the allocator.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
