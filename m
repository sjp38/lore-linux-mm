Date: Thu, 18 Nov 1999 19:57:58 -0800 (PST)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: [patch] zoned-2.3.28-K4
In-Reply-To: <Pine.LNX.4.10.9911172042220.5725-100000@chiara.csoma.elte.hu>
Message-ID: <Pine.LNX.4.10.9911181946030.4569-100000@penguin.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@chiara.csoma.elte.hu>
Cc: MM mailing list <linux-mm@kvack.org>, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

[ Ok, back from comdex, looking through my horrible backlog of email.. ]

On Wed, 17 Nov 1999, Ingo Molnar wrote:
> 
> the latest patchset is at:
> 
> 	http://www.redhat.com/~mingo/zoned-2.3.28-K4

Ugh. I don't like some of this:

 - the "task->refcount" thing is just silly, considering that any
   architecture that uses pages for task allocation would have been better
   off just using the memory management refcount like we used to.

   Why not do this by just doing a per-architecture "get_task_struct()"
   and "put_task_struct()", to go with the already existing "alloc" and
   "free" functionality?

   Thus, on the 99% of all machines where the page allocator already does
   the work for us, we'd just have

		#define get_task_struct(tsk) \
			atomic_inc(&mem_map[MAP_NR(tsk)].count)
		#define put_task_struct(tsk) \
			free_task_struct(tsk)

   which is just obviously right and cleans up the need to have that silly
   refcount. Then ARM can just have a refcount in its own definition of
   get_task_struct() and friends in task->thread.refcount..

 - I don't see the reason for renaming page_address() to page_vaddr()?

 - "flush_cache_all()" etc in "pgalloc.h"? Senseless. I can see pgalloc.h
   containing the page table allocation routines. But why did you move the
   other stuff there? Looks like a cut-and-paste bug to me. Why a new
   header file at all?

Would you mind explaining or re-doing?

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
