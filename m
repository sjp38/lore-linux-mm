Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id A5A786B00E9
	for <linux-mm@kvack.org>; Mon, 24 Jan 2011 20:44:58 -0500 (EST)
Date: Mon, 24 Jan 2011 17:44:55 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RESEND PATCH] mm: Use spin_lock_irqsave in
 __set_page_dirty_nobuffers
Message-Id: <20110124174455.8994d8cf.akpm@linux-foundation.org>
In-Reply-To: <4D3E27B3.5050707@oracle.com>
References: <1294726534-16438-1-git-send-email-andy.grover@oracle.com>
	<20110121001804.413b3f6d.akpm@linux-foundation.org>
	<4D39DDA6.1080604@oracle.com>
	<20110121120945.8d0e1010.akpm@linux-foundation.org>
	<4D3E27B3.5050707@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andy Grover <andy.grover@oracle.com>
Cc: linux-mm@kvack.org, rds-devel@oss.oracle.com
List-ID: <linux-mm.kvack.org>

On Mon, 24 Jan 2011 17:30:27 -0800 Andy Grover <andy.grover@oracle.com> wrote:

> > Running lock_page() against multiple pages is problematic because it
> > introduces a risk of ab/ba deadlocks against another thread which is
> > also locking multiple pages.  Possible solutions are a) take some
> > higher-level mutex so that only one thread will ever be running the
> > lock_page()s at a time or b) lock all the pages in ascending
> > paeg_to_pfn() order.  Both of these are a PITA.
> 
> Another problem may be that lock/unlock_page() doesn't nest.

Not against the same page, no.  It's functionally the same as
mutex_lock/unlock, only lockdep doesn't know about lock_page().

> We need to 
> be able to handle multiple ops to the same page. So, sounds like we also 
> need to keep track of all pages we lock/dirty and make sure they aren't 
> unlocked as long as we have references against them?

It sounds like it.  Also need to address the ab/ba issue with multiple
lock_page()s in a single thread.

I don't *think* there's any other site in the kernel which locks
multiple pages like this.  Adopting the convention of "lock them in
ascending pfn order" will be OK, I think.

> I just want to fully understand what's needed, before writing at least 2 
> PITA's worth of extra code :)
> 
> > Some thought is needed regarding anonymous pages and swapcache pages.
> 
> I think the common case for us is IO into anon pages.

lock_page() will presumably keep the swapcache manipulations happy. 
We'd also need to think about the implications of pte-dirtiness and
maybe rmap walks when dealing with non-cpu-initiated dirtyings.  "do
what fs/direct-io.c does" would be a good starting point.

Actually, fs/direct-io.c gets away without locking the pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
