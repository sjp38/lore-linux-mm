Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 815186B00E8
	for <linux-mm@kvack.org>; Fri, 21 Jan 2011 15:09:48 -0500 (EST)
Date: Fri, 21 Jan 2011 12:09:45 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH] mm: Use spin_lock_irqsave in
 __set_page_dirty_nobuffers
Message-Id: <20110121120945.8d0e1010.akpm@linux-foundation.org>
In-Reply-To: <4D39DDA6.1080604@oracle.com>
References: <1294726534-16438-1-git-send-email-andy.grover@oracle.com>
	<20110121001804.413b3f6d.akpm@linux-foundation.org>
	<4D39DDA6.1080604@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andy Grover <andy.grover@oracle.com>
Cc: linux-mm@kvack.org, rds-devel@oss.oracle.com
List-ID: <linux-mm.kvack.org>

On Fri, 21 Jan 2011 11:25:26 -0800
Andy Grover <andy.grover@oracle.com> wrote:

> On 01/21/2011 12:18 AM, Andrew Morton wrote:
> > On Mon, 10 Jan 2011 22:15:34 -0800 Andy Grover<andy.grover@oracle.com>  wrote:
> >
> >> RDS is calling set_page_dirty from interrupt context,
> >
> > yikes.  Whatever possessed you to try that?
> 
> When doing an RDMA read into pinned pages, we get notified the operation 
> is complete in a tasklet, and would like to mark the pages dirty and 
> unpin in the same context.
> 
> The issue was __set_page_dirty_buffers (via calling set_page_dirty) was 
> unconditionally re-enabling irqs as a side-effect because it was using 
> *_irq instead of *_irqsave/restore.

Your patch patched __set_page_dirty_nobuffers()?

> How would you recommend we proceed? My understanding was calling 
> set_page_dirty prior to issuing the operation isn't an option since it 
> might get cleaned too early.

The page should be locked, for reasons explained over
set_page_dirty_lock() (which was a strange place to document this).

What you could perhaps do is to lock_page() all the pages and run
set_page_dirty() on them *before* setting up the IO operation, then run
unlock_page() from interrupt context.

I assume that all these pages are mapped into userspace processes?  If
so, they're fully uptodate and we're OK.  If they're plain old
pagecache pages then we could have partially uptodate pages and things
get messier.

Running lock_page() against multiple pages is problematic because it
introduces a risk of ab/ba deadlocks against another thread which is
also locking multiple pages.  Possible solutions are a) take some
higher-level mutex so that only one thread will ever be running the
lock_page()s at a time or b) lock all the pages in ascending
paeg_to_pfn() order.  Both of these are a PITA.

A slow-and-safe solution to all this would be to punt the operation to
a process-context helper thread and run

	lock_page(page);
	if (page->mapping)	/* truncate? */
		set_page_dirty(page);
	unlock_page(page);

against each page.

Some thought is needed regarding anonymous pages and swapcache pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
