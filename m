Date: Tue, 29 Jan 2008 14:55:56 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 2/6] mmu_notifier: Callbacks to invalidate address ranges
In-Reply-To: <20080129223503.GY7233@v2.random>
Message-ID: <Pine.LNX.4.64.0801291440170.27327@schroedinger.engr.sgi.com>
References: <20080128202840.974253868@sgi.com> <20080128202923.849058104@sgi.com>
 <20080129162004.GL7233@v2.random> <20080129182831.GS7233@v2.random>
 <Pine.LNX.4.64.0801291219030.25629@schroedinger.engr.sgi.com>
 <20080129213604.GW7233@v2.random> <Pine.LNX.4.64.0801291343530.26824@schroedinger.engr.sgi.com>
 <20080129223503.GY7233@v2.random>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@qumranet.com>
Cc: Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, Nick Piggin <npiggin@suse.de>, kvm-devel@lists.sourceforge.net, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com, Hugh Dickins <hugh@veritas.com>
List-ID: <linux-mm.kvack.org>

On Tue, 29 Jan 2008, Andrea Arcangeli wrote:

> But now I think there may be an issue with a third thread that may
> show unsafe the removal of invalidate_page from ptep_clear_flush.
> 
> A third thread writing to a page through the linux-pte and the guest
> VM writing to the same page through the sptes, will be writing on the
> same physical page concurrently and using an userspace spinlock w/o
> ever entering the kernel. With your patch that invalidate_range after
> dropping the PT lock, the third thread may start writing on the new
> page, when the guest is still writing to the old page through the
> sptes. While this couldn't happen with my patch.

A user space spinlock plays into this??? That is irrelevant to the kernel. 
And we are discussing "your" placement of the invalidate_range not mine.

This is the scenario that I described before. You just need two threads.
One thread is in do_wp_page and the other is writing through the spte. 
We are in do_wp_page. Meaning the page is not writable. The writer will 
have to take fault which will properly serialize access. It a bug if the 
spte would allow write.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
