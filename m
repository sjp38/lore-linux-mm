Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 88BC76B0098
	for <linux-mm@kvack.org>; Mon, 25 Jan 2010 16:10:45 -0500 (EST)
Date: Mon, 25 Jan 2010 15:10:33 -0600
From: Jack Steiner <steiner@sgi.com>
Subject: Re: [PATCH] - Fix unmap_vma() bug related to mmu_notifiers
Message-ID: <20100125211033.GA24272@sgi.com>
References: <20100125174556.GA23003@sgi.com> <20100125190052.GF5756@random.random>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100125190052.GF5756@random.random>
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>, Robin Holt <holt@sgi.com>, cl@linux-foundation.org
Cc: mingo@elte.hu, tglx@linutronix.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Jan 25, 2010 at 08:00:52PM +0100, Andrea Arcangeli wrote:
> On Mon, Jan 25, 2010 at 11:45:56AM -0600, Jack Steiner wrote:
> > unmap_vmas() can fail to correctly flush the TLB if a
> > callout to mmu_notifier_invalidate_range_start() sleeps.
> 
> Not sure I understand: the callbacks invoked by
> mmu_notifier_invalidate_range_start can't sleep, or rcu locking inside
> mmu notifier will break too (first thing that should be replaced with
> srcu if they were allowed to sleep).
> 
> In short there's no schedule that could be added because of those
> callbacks so if this code isn't ok and schedules and screw on the
> mmu_gather tlb it's probably not mmu notifier related.

Hmmmm. I was under the impression that the range callbacks _were_ allowed to
sleep. That was certainly in the original patches posted by christoph. I was
not aware that it had changed.

I'll let Robin provide details but the way mmu_notifiers are used by
xpmem, I believe sleeping is essential. The 'start" callout sends messages to
another OS instances to teardown cross-SSI mappings. That is difficult
to do w/o a sleep.

We'll dig deeper tomorrow & see what we can do....

--- jack

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
