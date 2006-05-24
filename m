Date: Wed, 24 May 2006 15:57:34 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: remove VM_LOCKED before remap_pfn_range and drop VM_SHM
In-Reply-To: <Pine.LNX.4.64.0605231524370.11985@schroedinger.engr.sgi.com>
Message-ID: <Pine.LNX.4.64.0605241539590.12355@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605230917390.9731@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605231937410.14985@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605231223360.10836@schroedinger.engr.sgi.com>
 <Pine.LNX.4.64.0605232131560.19019@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0605231524370.11985@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, David Howells <dhowells@redhat.com>, Rohit Seth <rohitseth@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 May 2006, Christoph Lameter wrote:
> 
> Remove VM_LOCKED before remap_pfn range from device drivers and get rid of 
> VM_SHM.

Okay, that is rather a nice cleanup.  I've held off from doing it,
and have discouraged one or two others from doing it, because there's
a number of other things to be checked thereabouts (witness the way
vfc_dev.c is or'ing flags it has no business to change: but you've
rightly preserved that existing behaviour for now, however bad it may
be); and there's VM_RESERVED (or most of its or'ings) to be removed too.

But what you have looks nice, and no way does it prevent further
cleanup later; though I've not wanted to bother maintainers repeatedly.

Of course, you don't need this patch in order to proceed with migrating
VM_LOCKED areas, because this patch is no more than a cleanup of
irrelevance.  Well, somewhat worse than irrelevance: when a driver
unilaterally sets VM_LOCKED on a vma, then mm->locked_vm goes wild
when the vma is unmapped: doesn't matter at exit, but bad if before.

> remap_pfn_range() already sets VM_IO. There is no need to set VM_SHM since
> it does nothing. VM_LOCKED is of no use since the remap_pfn_range does
> not place pages on the LRU. The pages are therefore never subject to
> swap anyways. Remove all the vm_flags settings before calling
> remap_pfn_range.
> 
> After removing all the vm_flag settings no use of VM_SHM is left.
> Drop it.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>

Acked-by: Hugh Dickins <hugh@veritas.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
