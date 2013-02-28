Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx107.postini.com [74.125.245.107])
	by kanga.kvack.org (Postfix) with SMTP id A34626B0002
	for <linux-mm@kvack.org>; Thu, 28 Feb 2013 16:25:51 -0500 (EST)
Date: Thu, 28 Feb 2013 13:25:49 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH RESEND] mm: trace filemap add and del
Message-Id: <20130228132549.b0bf04f7.akpm@linux-foundation.org>
In-Reply-To: <1362084420-3840-1-git-send-email-robert.jarzmik@free.fr>
References: <1362084420-3840-1-git-send-email-robert.jarzmik@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Robert Jarzmik <robert.jarzmik@free.fr>
Cc: linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Hugh Dickins <hughd@google.com>, Steven Rostedt <rostedt@goodmis.org>, Frederic Weisbecker <fweisbec@gmail.com>, Ingo Molnar <mingo@redhat.com>

On Thu, 28 Feb 2013 21:47:00 +0100
Robert Jarzmik <robert.jarzmik@free.fr> wrote:

> Use the events API to trace filemap loading and unloading of file pieces
> into the page cache.
> 
> This patch aims at tracing the eviction reload cycle of executable and
> shared libraries pages in a memory constrained environment.
> 
> The typical usage is to spot a specific device and inode (for example
> /lib/libc.so) to see the eviction cycles, and find out if frequently used
> code is rather spread across many pages (bad) or coallesced (good).
> 
> ...
>
>  		if (likely(!error)) {
>  			mapping->nrpages++;
>  			__inc_zone_page_state(page, NR_FILE_PAGES);
> +			trace_mm_filemap_add_to_page_cache(page);
>  			spin_unlock_irq(&mapping->tree_lock);
>  		} else {
>  			page->mapping = NULL;

I don't see a need to do this under the spinlock.  The page is locked
so nobody else will be fiddling with it.  There would be a tiny
scalability gain from moving the tracepoint outside the locked region.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
