Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DBDA76B0085
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 14:54:28 -0500 (EST)
Date: Wed, 3 Feb 2010 13:54:27 -0600
From: Robin Holt <holt@sgi.com>
Subject: Re: [RFP-V2 0/3] Make mmu_notifier_invalidate_range_start able to
 sleep.
Message-ID: <20100203195427.GE6616@sgi.com>
References: <20100202142130.GI6616@sgi.com>
 <20100202145911.GM4135@random.random>
 <20100202152142.GQ6653@sgi.com>
 <20100202160146.GO4135@random.random>
 <20100202163930.GR6653@sgi.com>
 <20100202165224.GP4135@random.random>
 <20100202165903.GN6616@sgi.com>
 <20100202201718.GQ4135@random.random>
 <20100203004833.GS6653@sgi.com>
 <20100203171413.GB5959@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100203171413.GB5959@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Robin Holt <holt@sgi.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Jack Steiner <steiner@sgi.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Feb 03, 2010 at 06:14:13PM +0100, Andrea Arcangeli wrote:
> On Tue, Feb 02, 2010 at 06:48:33PM -0600, Robin Holt wrote:
> > In the _invalidate_page case, it is called by the kernel from sites where
> > the kernel is relying upon the reference count to eliminate the page from
> > use while maintaining the page's data as clean and ready to be released.
> > If the page is marked as dirty, etc. then the kernel will "do the right
> > thing" with the page to maintain data consistency.
> >
> > The _invalidate_range_start/end pairs are used in places where the
> > caller's address space is being modified.  If we allow the attachers
> > to continue to use the old pages from the old mapping even for a short
> > time after the process has started to use the new pages, there would be
> > silent data corruption.
> 
> Just to show how fragile your assumption is, your code is already
> generating mm corruption in fork and in ksm... the set_pte_at_notify
> invalidate_page has to run immediately and be effective immediately
> despite being called with the PT lock hold.

Actually, we don't generate corruption, but that is a little more complex.

At fork time, the invalidate range happens to clear all of the segment's
page table.

When XPMEM goes to refill the entry, we always call
get_user_pages(,write=1,).  That will result in a page callout, but
we have no entry in the segment's page table so the callout is safely
ignored.  When the processes pte gets established, it has already broken
COW so we are back to a safe state.

Robin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
