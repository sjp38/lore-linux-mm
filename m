Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C84816B005D
	for <linux-mm@kvack.org>; Tue,  7 Jul 2009 12:48:36 -0400 (EDT)
Date: Tue, 7 Jul 2009 09:50:19 -0700 (PDT)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [RFC][PATCH 3/4] get_user_pages READ fault handling special
 cases
In-Reply-To: <20090707165950.7a84145a.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.LFD.2.01.0907070931340.3210@localhost.localdomain>
References: <20090707165101.8c14b5ac.kamezawa.hiroyu@jp.fujitsu.com> <20090707165950.7a84145a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, npiggin@suse.de, "hugh.dickins@tiscali.co.uk" <hugh.dickins@tiscali.co.uk>, avi@redhat.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>



On Tue, 7 Jul 2009, KAMEZAWA Hiroyuki wrote:
>
> Now, get_user_pages(READ) can return ZERO_PAGE but it creates some trouble.
> This patch is a workaround for each callers.
>  - mlock() ....ignore ZERO_PAGE if found. This happens only when mlock against
> 		read-only mapping finds zero pages.
>  - futex() ....if ZERO PAGE is found....BUG ?(but possible...)
>  - lookup_node() .... no good idea..this is the same behavior to 2.6.23 age.

Gaah. None of these special cases seem at all valid.

I _like_ ZERO_PAGE(), but I always liked it mainly with the whole 
"PAGE_RESERVED" flag.

And I think that if we resurrect zero-page, then we should do it with the 
modern equivalent of PAGE_RESERVED, namely the "pte_special()" bit. 
Anybody who walks page tables had better already handle special PTE 
entries (or we could trivially extend them - in case they currently just 
look at the vm_flags and decide that the range can have no special pages).

So I'd suggest instead:

 - always mark the zero page with PTE_SPECIAL. This avoids the constant 
   page count updates - that's what PTE_SPECIAL means, after all.

   The page count updates was what killed ZERO_PAGE. It's wonderful for 
   cache behaviour _other_ than the ping-pong of having to modify the 
   "struct page".

 - for architectures that don't have the PTE_SPECIAL bit in the page 
   tables, we don't do the magic zero page at all.

 - for architectures that have virtual caches and cannot handle a single 
   zero page well (eg the mess we had with MIPS and muliple zero-pages), 
   also simply don't do it, at least not initially.

 - for the rest, depend on pte_special().

 - pass down the fault flags to "vm_normal_page()", and let one of the 
   bits in there say "I want the zero-page". That way "get_user_pages()" 
   can just treat the zero page as a normal page (it's read-only, of 
   course, but we check the page tables, so that's ok). We'd increment the 
   page count there, but nowhere else (we _need_ to increment the zero 
   page count there, since it will be decremented at free time, and we've 
   lost the page table entry that says that the "struct page *" is 
   special).

With something like the above, there really shouldn't be a lot of 
special-case code. None of these games with mlock etc. Nothing should 
_ever_ need to test "is_zero_page()", because the only thing that does so 
is vm_normal_page() - and if that one returns the "struct page *", then 
it's going to be considered a normal page, nothing special.

That's how the _original_ ZERO_PAGE worked. It had pretty much no special 
case logic. It was basically treated as an IO page from an allocation 
standpoint, thanks to the PG_Reserved bit, but other than that nobody 
really cared.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
