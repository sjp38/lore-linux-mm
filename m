Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 596BE6B0085
	for <linux-mm@kvack.org>; Sat, 30 May 2009 02:29:56 -0400 (EDT)
Date: Sat, 30 May 2009 08:37:10 +0200
From: Andi Kleen <andi@firstfloor.org>
Subject: More thoughts about hwpoison and pageflags compression
Message-ID: <20090530063710.GI1065@one.firstfloor.org>
References: <200905291135.124267638@firstfloor.org> <20090529225202.0c61a4b3@lxorguk.ukuu.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090529225202.0c61a4b3@lxorguk.ukuu.org.uk>
Sender: owner-linux-mm@kvack.org
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Andi Kleen <andi@firstfloor.org>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, fengguang.wu@intel.com
List-ID: <linux-mm.kvack.org>


I thought a bit more about Alan's proposal of page flags compression
for poisoned pages. I actually found more problems with it :-)
(in addition to the points I wrote up in my earlier email on the topic)

Just wanted to write them up:

First some basics about hwpoison. 

- HwPoisioning can come in at any time and at any state of the page. 
- There can be multiple hwpoison events coming in for the same page in a short time window.
This can happen for example when the hardware detects errors on different cache lines of a page, 
which can happen in some DIMM breakage scenarios.
The HwPoison bit serves as a synchronization point for this, it's essentially a lock
for the hwpoison code (although no spinlock)
- HwPoison is high level code should only use portable primitives.

Alan proposed to use reserved|writeback to express hwpoisioning instead
of an own bit.

- Now the first problem is that we don't have a portable primitive to set
multiple bits atomically. cmpxchg() can be only used in architecture specific
code. So it wouldn't be atomic in its locking function.

That means that all multiple bit variants are problematic, or at least
would need a new global atomic primitive.

- Then you can actually have a page in writeback and poisoned. That is
we can't stop writeback (we might at some point in the future), so the order
the code works right now is:

set page poisoned
bail out if was already poisioned
do some other stuff
lock the page
wait for page writeback
	(which just polls on the bit to clear)

Now the obvious problem is of course, if we used writeback|reserved, how
would it it do the poison locking while the the page is still in writeback?
The encoding would not be unique.

If we don't do that we would risk multiple memory_failures() on the same
page, which has various issues.

So at least writeback|reserved doesn't work.

- Could we in theory find another weird bit combination that's truly impossible today
?
Probably, but it would be very hard to verify that this can truly never happen.

- Then I don't like it due to the fragility against other software bugs. Unless someone 
blasts 0xffs over the struct page (in which case treating it poisoned is probably a 
good thing anyways) then a separate bit is fairly robust against software bugs. 
Right now "impossible combinations" are used as a indication that something is wrong u
with the page, to catch broken software.

If we gave meaning to previously impossible combinations then this robustness
would be less. So a separate bit is generally more robust and doesn't take
this away from the other code.

So using a separate bit is a sensible choice imho.

Hope this helps,

-Andi


-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
