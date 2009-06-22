Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6ECC96B005A
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 12:02:40 -0400 (EDT)
Subject: Re: BUG: Bad page state [was: Strange oopses in 2.6.30]
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20090622091626.GA3981@csn.ul.ie>
References: <1245506908.6327.36.camel@localhost>
	 <4A3CFFEC.1000805@gmail.com> <20090622113652.21E7.A69D9226@jp.fujitsu.com>
	 <20090622091626.GA3981@csn.ul.ie>
Content-Type: text/plain
Date: Mon, 22 Jun 2009 12:02:33 -0400
Message-Id: <1245686553.7799.102.camel@lts-notebook>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Jiri Slaby <jirislaby@gmail.com>, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Mon, 2009-06-22 at 10:16 +0100, Mel Gorman wrote:
> On Mon, Jun 22, 2009 at 11:39:53AM +0900, KOSAKI Motohiro wrote:
> > (cc to Mel and some reviewer)

[added Rik so that he can get multiple copies, too. :)]

> > 
> > > Flags are:
> > > 0000000000400000 -- __PG_MLOCKED
> > > 800000000050000c -- my page flags
> > >         3650000c -- Maxim's page flags
> > > 0000000000693ce1 -- my PAGE_FLAGS_CHECK_AT_FREE
> > 
> > I guess commit da456f14d (page allocator: do not disable interrupts in
> > free_page_mlock()) is a bit wrong.
> > 
> > current code is:
> > -------------------------------------------------------------
> > static void free_hot_cold_page(struct page *page, int cold)
> > {
> > (snip)
> >         int clearMlocked = PageMlocked(page);
> > (snip)
> >         if (free_pages_check(page))
> >                 return;
> > (snip)
> >         local_irq_save(flags);
> >         if (unlikely(clearMlocked))
> >                 free_page_mlock(page);
> > -------------------------------------------------------------
> > 
> > Oh well, we remove PG_Mlocked *after* free_pages_check().
> > Then, it makes false-positive warning.
> > 
> > Sorry, my review was also wrong. I think reverting this patch is better ;)
> > 
> 
> I think a revert is way overkill. The intention of the patch is sound -
> reducing the number of times interrupts are disabled. Having pages
> with the PG_locked bit is now somewhat of an expected situation. I'd
> prefer to go with either
> 
> 1. Unconditionally clearing the bit with TestClearPageLocked as the
>    patch already posted does
> 2. Removing PG_locked from the free_pages_check()
> 3. Unlocking the pages as we go when an mlocked VMA is being torn town

Mel,

#3 SHOULD be happening in all cases.  The free_page_mlocked() function
counts when this is not happening.  We tried to fix all cases that we
encountered before this feature was submitted, but left the vm_stat
there to report if more PG_mlocked leaks were introduced.  We also,
inadvertently, left PG_mlocked in the flags to check at free.  We didn't
hit this before your patch because free_page_mlock() did a test&clear on
the PG_mlocked before checking the flags.  Since you moved the call, and
used PageMlocked() instead of TestClearPageMlocked(), any PG_locked page
will cause the bug.

So, we have another PG_mlocked flag leaking to free.  I don't think this
is terribly serious in itself, and probably not deserving of a BUG_ON.
It probably doesn't deserve a vm_stat, either, I guess.  However, it
could indicate a more serious logic error and should be examined. So it
would be nice to retain some indication that it's happening.

> The patch that addresses 1 seemed ok to me. What do you think?
> 

Your alternative #2 sounds less expensive that test&clear.

Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
