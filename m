Date: Thu, 29 Aug 2002 22:10:53 -0700 (PDT)
From: Linus Torvalds <torvalds@transmeta.com>
Subject: Re: weirdness with ->mm vs ->active_mm handling
In-Reply-To: <20020829193413.H17288@redhat.com>
Message-ID: <Pine.LNX.4.44.0208292206130.1336-100000@home.transmeta.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin LaHaise <bcrl@redhat.com>
Cc: linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Aug 2002, Benjamin LaHaise wrote:
> 
> In trying to track down a bug, I found routines like generic_file_read 
> getting called with current->mm == NULL.  This seems to be a valid state 
> for lazy tlb tasks, but the code throughout the kernel doesn't seem to 
> assume that.

Hmm.. Have you actually ever seen this?

When tsk->mm is NULL, you should never EVER get a page fault, except for 
the one special case of the vmalloc'ed area (which is tested for in 
do_page_fault() before we even _look_ at "tsk->mm").

In fact, do_page_fault() very much checks

	if (in_atomic() || !mm)
		goto no_context;  

which says that a page fault when in a lazy TLB context should always
cause a trap, killing the thing (or, if the access has a fixup, calling
the fixup - although I don't think that should happen in any normal code)

In other words: I think your patch is "functionally correct", in that it
should work fine, but on the other hand having a NULL tsk->mm and trying
to do any user-level access is _so_ wrong that I'd much rather take a NULL
pointer fault than try to do something "sane" about it.

		Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
