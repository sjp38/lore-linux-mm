Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 455016B01EF
	for <linux-mm@kvack.org>; Wed, 14 Apr 2010 06:06:42 -0400 (EDT)
Subject: Re: [PATCH] mm: disallow direct reclaim page writeback
From: Andi Kleen <andi@firstfloor.org>
References: <1271117878-19274-1-git-send-email-david@fromorbit.com>
	<20100413095815.GU25756@csn.ul.ie> <20100413111902.GY2493@dastard>
	<20100413193428.GI25756@csn.ul.ie> <20100413202021.GZ13327@think>
Date: Wed, 14 Apr 2010 12:06:36 +0200
In-Reply-To: <20100413202021.GZ13327@think> (Chris Mason's message of "Tue, 13 Apr 2010 16:20:21 -0400")
Message-ID: <877hoa9wlv.fsf@basil.nowhere.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
To: Chris Mason <chris.mason@oracle.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Dave Chinner <david@fromorbit.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Chris Mason <chris.mason@oracle.com> writes:
>
> Huh, 912 bytes...for select, really?  From poll.h:
>
> /* ~832 bytes of stack space used max in sys_select/sys_poll before allocating
>    additional memory. */
> #define MAX_STACK_ALLOC 832
> #define FRONTEND_STACK_ALLOC    256
> #define SELECT_STACK_ALLOC      FRONTEND_STACK_ALLOC
> #define POLL_STACK_ALLOC        FRONTEND_STACK_ALLOC
> #define WQUEUES_STACK_ALLOC     (MAX_STACK_ALLOC - FRONTEND_STACK_ALLOC)
> #define N_INLINE_POLL_ENTRIES   (WQUEUES_STACK_ALLOC / sizeof(struct poll_table_entry))
>
> So, select is intentionally trying to use that much stack.  It should be using
> GFP_NOFS if it really wants to suck down that much stack...

There are lots of other call chains which use multiple KB bytes by itself,
so why not give select() that measly 832 bytes?

You think only file systems are allowed to use stack? :)

Basically if you cannot tolerate 1K (or more likely more) of stack
used before your fs is called you're toast in lots of other situations
anyways.

> kernel had some sort of way to dynamically allocate ram, it could try
> that too.

It does this for large inputs, but the whole point of the stack fast
path is to avoid it for common cases when a small number of fds is
only needed.

It's significantly slower to go to any external allocator.

-Andi
-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
