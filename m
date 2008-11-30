Date: Sun, 30 Nov 2008 11:27:53 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC] another crazy idea to get rid of mmap_sem in faults
In-Reply-To: <1227886959.4454.4421.camel@twins>
Message-ID: <alpine.LFD.2.00.0811301123320.24125@nehalem.linux-foundation.org>
References: <1227886959.4454.4421.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, hugh <hugh@veritas.com>, Paul E McKenney <paulmck@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@elte.hu>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>



On Fri, 28 Nov 2008, Peter Zijlstra wrote:
> 
> While pondering the page_fault retry stuff, I came up with the following
> idea.

I don't know if your idea is any good, but this part of your patch is 
utter crap:

	-       if (!down_read_trylock(&mm->mmap_sem)) {
	-               if ((error_code & PF_USER) == 0 &&
	-                   !search_exception_tables(regs->ip))
	-                       goto bad_area_nosemaphore;
	-               down_read(&mm->mmap_sem);
	-       }
	-
	+       down_read(&mm->mmap_sem);

because the reason we do a down_read_trylock() is not because of any lock 
order issue or anything like that, but really really fundamental: we want 
to be able to print an oops, instead of deadlocking, if we take a page 
fault in kernel code while holding/waiting-for the mmap_sem for writing.

... and I don't even see the reason why you did tht change anyway, since 
it seems to be totally independent of all the other locking changes.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
