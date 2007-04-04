Date: Wed, 04 Apr 2007 13:11:11 -0700 (PDT)
Message-Id: <20070404.131111.62667528.davem@davemloft.net>
Subject: Re: [rfc] no ZERO_PAGE?
From: David Miller <davem@davemloft.net>
In-Reply-To: <Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
References: <20070330024048.GG19407@wotan.suse.de>
	<20070404033726.GE18507@wotan.suse.de>
	<Pine.LNX.4.64.0704040830500.6730@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 4 Apr 2007 08:35:30 -0700 (PDT)
Return-Path: <owner-linux-mm@kvack.org>
To: torvalds@linux-foundation.org
Cc: npiggin@suse.de, hugh@veritas.com, akpm@linux-foundation.org, linux-mm@kvack.org, tee@sgi.com, holt@sgi.com, andrea@suse.de, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> Anyway, I'm not against this, but I can see somebody actually *wanting* 
> the ZERO page in some cases. I've used the fact for TLB testing, for 
> example, by just doing a big malloc(), and knowing that the kernel will 
> re-use the ZERO_PAGE so that I don't get any cache effects (well, at least 
> not any *physical* cache effects. Virtually indexed cached will still show 
> effects of it, of course, but I haven't cared).
> 
> That's an example of an app that actually cares about the page allocation 
> (or, in this case, the lack there-of). Not an important one, but maybe 
> there are important ones that care?

If we're going to consider this seriously, there is a case I know of.
Look at flush_dcache_page()'s test for ZERO_PAGE() on sparc64, there
is an instructive comment:

	/* Do not bother with the expensive D-cache flush if it
	 * is merely the zero page.  The 'bigcore' testcase in GDB
	 * causes this case to run millions of times.
	 */
	if (page == ZERO_PAGE(0))
		return;

basically what the GDB test case does it mmap() an enormous anonymous
area, not touch it, then dump core.

As I understand the patch being considered to remove ZERO_PAGE(), this
kind of core dump will cause a lot of pages to be allocated, probably
eating up a lot of system time as well as memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
