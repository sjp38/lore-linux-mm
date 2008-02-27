Date: Wed, 27 Feb 2008 14:43:41 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [patch 5/6] mmu_notifier: Support for drivers with revers maps
 (f.e. for XPmem)
In-Reply-To: <200802201055.21343.nickpiggin@yahoo.com.au>
Message-ID: <Pine.LNX.4.64.0802271440530.13186@schroedinger.engr.sgi.com>
References: <20080215064859.384203497@sgi.com> <20080215064933.376635032@sgi.com>
 <200802201055.21343.nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: akpm@linux-foundation.org, Andrea Arcangeli <andrea@qumranet.com>, Robin Holt <holt@sgi.com>, Avi Kivity <avi@qumranet.com>, Izik Eidus <izike@qumranet.com>, kvm-devel@lists.sourceforge.net, Peter Zijlstra <a.p.zijlstra@chello.nl>, general@lists.openfabrics.org, Steve Wise <swise@opengridcomputing.com>, Roland Dreier <rdreier@cisco.com>, Kanoj Sarcar <kanojsarcar@yahoo.com>, steiner@sgi.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, daniel.blueman@quadrics.com
List-ID: <linux-mm.kvack.org>

On Wed, 20 Feb 2008, Nick Piggin wrote:

> I don't know how this is supposed to solve anything. The sleeping
> problem happens I guess mostly in truncate. And all you are doing
> is putting these rmap callbacks in page_mkclean and try_to_unmap.

truncate is handled by the range invalidates. This is special code to deal 
with the unnap/clean of an individual page.

> That doesn't seem right. To start with, the new callbacks aren't
> even called in the places where invalidate_page isn't allowed to
> sleep.
> 
> The problem is unmap_mapping_range, right? And unmap_mapping_range
> must walk the rmaps with the mmap lock held, which is why it can't
> sleep. And it can't hold any mmap_sem so it cannot prevent address

Nope. unmap_mapping_range is already handled by the range callbacks.

> So in the meantime, you could have eg. a fault come in and set up a
> new page for one of the processes, and that page might even get
> exported via the same external driver. And now you have a totally
> inconsistent view.

The situation that you are imagining has already been dealt with by the 
earlier patches. This is only to allow sleeping while unmapping individual 
pages.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
