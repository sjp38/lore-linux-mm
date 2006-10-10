Date: Tue, 10 Oct 2006 19:06:32 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: ptrace and pfn mappings
In-Reply-To: <20061010123128.GA23775@infradead.org>
Message-ID: <Pine.LNX.4.64.0610101827130.14815@blonde.wat.veritas.com>
References: <20061009140354.13840.71273.sendpatchset@linux.site>
 <20061009140447.13840.20975.sendpatchset@linux.site>
 <1160427785.7752.19.camel@localhost.localdomain> <452AEC8B.2070008@yahoo.com.au>
 <1160442987.32237.34.camel@localhost.localdomain> <20061010123128.GA23775@infradead.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Jes Sorensen <jes@sgi.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Tue, 10 Oct 2006, Christoph Hellwig wrote:
> On Tue, Oct 10, 2006 at 11:16:27AM +1000, Benjamin Herrenschmidt wrote:
> > 
> > The "easy" way out I can see, but it may have all sort of bad side
> > effects I haven't thought about at this point, is to switch the mm in
> > access_process_vm (at least if it's hitting such a VMA).
> 
> Switching the mm is definitly no acceptable.  Too many things could
> break when violating the existing assumptions.

I disagree.  Ben's switch-mm approach deserves deeper examination than
that.  It's both simple and powerful.  And it's already done by AIO's
use_mm - the big differences being, of course, that the kthread has
no original mm of its own, and it's limited in what it gets up to.

What would be the actual problems with ptrace temporarily adopting
another's mm?  What are our existing assumptions?

We do already have the minor issue that expand_stack uses the wrong
task's rlimits (there was a patch for that, perhaps Nick's fault
struct would help make it less intrusive to fix - I was put off
it by having to pass an additional arg down so many levels).

> I think the best idea is to add a new ->access method to the vm_operations
> that's called by access_process_vm() when it exists and VM_IO or VM_PFNMAP
> are set.   ->access would take the required object locks and copy out the
> data manually.  This should work both for spufs and drm.

I find Ben's idea more appealing; but agree it _may_ prove unworkable.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
