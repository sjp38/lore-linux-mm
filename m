Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 9F4C96B00E7
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 20:31:03 -0500 (EST)
Message-ID: <4D3E27B3.5050707@oracle.com>
Date: Mon, 24 Jan 2011 17:30:27 -0800
From: Andy Grover <andy.grover@oracle.com>
MIME-Version: 1.0
Subject: Re: [RESEND PATCH] mm: Use spin_lock_irqsave in __set_page_dirty_nobuffers
References: <1294726534-16438-1-git-send-email-andy.grover@oracle.com>	<20110121001804.413b3f6d.akpm@linux-foundation.org>	<4D39DDA6.1080604@oracle.com> <20110121120945.8d0e1010.akpm@linux-foundation.org>
In-Reply-To: <20110121120945.8d0e1010.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, rds-devel@oss.oracle.com
List-ID: <linux-mm.kvack.org>

On 01/21/2011 12:09 PM, Andrew Morton wrote:
> Andy Grover<andy.grover@oracle.com>  wrote:
>> When doing an RDMA read into pinned pages, we get notified the operation
>> is complete in a tasklet, and would like to mark the pages dirty and
>> unpin in the same context.

>> The issue was __set_page_dirty_buffers (via calling set_page_dirty)
>> was unconditionally re-enabling irqs as a side-effect because it
>> was using *_irq instead of *_irqsave/restore.
>
> Your patch patched __set_page_dirty_nobuffers()?

Yes, _nobuffers, sorry.

> What you could perhaps do is to lock_page() all the pages and run
> set_page_dirty() on them *before* setting up the IO operation, then run
> unlock_page() from interrupt context.
>
> I assume that all these pages are mapped into userspace processes?  If
> so, they're fully uptodate and we're OK.  If they're plain old
> pagecache pages then we could have partially uptodate pages and things
> get messier.
>
> Running lock_page() against multiple pages is problematic because it
> introduces a risk of ab/ba deadlocks against another thread which is
> also locking multiple pages.  Possible solutions are a) take some
> higher-level mutex so that only one thread will ever be running the
> lock_page()s at a time or b) lock all the pages in ascending
> paeg_to_pfn() order.  Both of these are a PITA.

Another problem may be that lock/unlock_page() doesn't nest. We need to 
be able to handle multiple ops to the same page. So, sounds like we also 
need to keep track of all pages we lock/dirty and make sure they aren't 
unlocked as long as we have references against them?

I just want to fully understand what's needed, before writing at least 2 
PITA's worth of extra code :)

> Some thought is needed regarding anonymous pages and swapcache pages.

I think the common case for us is IO into anon pages.

Regards -- Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
