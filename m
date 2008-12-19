Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4A66B0044
	for <linux-mm@kvack.org>; Fri, 19 Dec 2008 02:51:25 -0500 (EST)
Date: Fri, 19 Dec 2008 08:53:28 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [rfc][patch] unlock_page speedup
Message-ID: <20081219075328.GD26419@wotan.suse.de>
References: <20081219072909.GC26419@wotan.suse.de> <20081218233549.cb451bc8.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20081218233549.cb451bc8.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Memory Management List <linux-mm@kvack.org>, linux-fsdevel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 18, 2008 at 11:35:49PM -0800, Andrew Morton wrote:
> On Fri, 19 Dec 2008 08:29:09 +0100 Nick Piggin <npiggin@suse.de> wrote:
> 
> > Introduce a new page flag, PG_waiters
> 
> Leaving how many?

Don't know... I thought the page-flags.h obfuscation project was
supposed to make that clearer to work out. There are what, 21 flags
used now. If everything is coded properly, then the memory model
should automatically kick its metadata out of page flags if it gets
too big. But most likely it will just blow up. Probably we want
at least a few flags for memory model on 32-bit for smaller systems
(big NUMA 32-bit systems probably don't matter much anymore).


>  fs-cache wants to take two more.

fs-cache is getting merged? Wow, I've wanted to review that. When?
Aside from artificial benchmarks (which are obviously going to be
good), does anybody actually deploy it? What do their before/afters
look like I wonder?

 
> How's about we actually work this out, then make PG_waiters the
> highest-numbered free one?
> 
> 	PG_free1,
> 	PG_free2,
> 	...
> 	PG_waiters
> };
> 
> (or even something really sensitive, like PG_lru)
> 
> So that
> 
> a) we can see how many are left in a robust fashion and
> 
> b) we find out whether PG_waiters (PG_lru?) gets scribbled on by architectures
>    which borrow upper bits from page.flags for other nefarious purposes.

I think if we can just get the memory-model people involved, they
can assure us their code automatically scales to any value of __NR_PAGEFLAGS,
and suggest a reasonable number of flags we should leave for 32-bit systems.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
