In-reply-to: <Pine.LNX.4.64.0703281550300.11726@blonde.wat.veritas.com>
	(message from Hugh Dickins on Wed, 28 Mar 2007 15:51:25 +0100 (BST))
Subject: Re: [PATCH 2/4] holepunch: fix shmem_truncate_range punch locking
References: <Pine.LNX.4.64.0703281543230.11119@blonde.wat.veritas.com> <Pine.LNX.4.64.0703281550300.11726@blonde.wat.veritas.com>
Message-Id: <E1HWsrY-0000zQ-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Thu, 29 Mar 2007 13:32:16 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: hugh@veritas.com
Cc: akpm@linux-foundation.org, mszeredi@suse.cz, pbadari@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

> Miklos Szeredi observes that during truncation of shmem page directories,
> info->lock is released to improve latency (after lowering i_size and
> next_index to exclude races); but this is quite wrong for holepunching,
> which receives no such protection from i_size or next_index, and is left
> vulnerable to races with shmem_unuse, shmem_getpage and shmem_writepage.
> 
> Hold info->lock throughout when holepunching?  No, any user could prevent
> rescheduling for far too long.  Instead take info->lock just when needed:
> in shmem_free_swp when removing the swap entries, and whenever removing
> a directory page from the level above.  But so long as we remove before
> scanning, we can safely skip taking the lock at the lower levels, except
> at misaligned start and end of the hole.

ACK, but I think this has become way too complex, and none of us will
understand it in a month or so :(

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
