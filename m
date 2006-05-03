From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: [patch 00/14] remap_file_pages protection support
Date: Wed, 3 May 2006 03:20:48 +0200
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au> <1146590207.5202.17.camel@localhost.localdomain>
In-Reply-To: <1146590207.5202.17.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200605030320.50055.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@osdl.org>, linux-kernel <linux-kernel@vger.kernel.org>, Linux Memory Management <linux-mm@kvack.org>, Ulrich Drepper <drepper@redhat.com>, Val Henson <val.henson@intel.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 02 May 2006 19:16, Lee Schermerhorn wrote:
> On Tue, 2006-05-02 at 13:45 +1000, Nick Piggin wrote:
> > blaisorblade@yahoo.it wrote:

> > I think I would rather this all just folded under VM_NONLINEAR rather
> > than having this extra MANYPROTS thing, no? (you're already doing that in
> > one direction).

> One way I've seen this done on other systems

I'm curious, which ones?

> is to use something like a 
> prio tree [e.g., see the shared policy support for shmem] for sub-vma
> protection ranges.
Which sub-vma ranges? The ones created with mprotect?

I'm curious about what is the difference between this sub-tree and the main 
tree... you have some point, but I miss which one :-) Actually when doing a 
lookup in the main tree the extra nodes in the subtree are not searched, so 
you get an advantage.

One possible point is that a VMA maps to one mmap() call (with splits from 
mremap(),mprotect(),partial munmap()s), and then they use sub-VMAs instead of 
VMA splits.

> Most vmas [I'm guessing here] will have only the 
> original protections or will be reprotected in toto.

> So, one need only 
> allocate/populate the protection tree when sub-vma protections are
> requested.   Then, one can test protections via the vma, perhaps with
> access/check macros to hide the existence of the protection tree.  Of
> course, adding a tree-like structure could introduce locking
> complications/overhead in some paths where we'd rather not [just
> guessing again].  Might be more overhead than just mucking with the ptes
> [for UML], but would keep the ptes in sync with the vma's view of
> "protectedness".
>
> Lee

Ok, there are two different situations, I'm globally unconvinced until I 
understand the usefulness of a different sub-tree.

a) UML. The answer is _no_ to all guesses, since we must implement page tables 
of a guest virtual machine via mmap() or remap_file_pages. And they're as 
fragmented as they get (we get one-page-wide VMAs currently).

b) the proposed glibc usage. The original Ulrich's request (which I cut down 
because of problems with objrmap) was to have one mapping per DSO, including 
code,data and guard page. So you have three protections in one VMA.

However, this is doable via this remap_file_pages, adding something for 
handling private VMAs (handling movement of the anonymous memory you get on 
writes); but it's slow on swapout, since it stops using objrmap. So I've not 
thought to do it.
-- 
Inform me of my mistakes, so I can keep imitating Homer Simpson's "Doh!".
Paolo Giarrusso, aka Blaisorblade (Skype ID "PaoloGiarrusso", ICQ 215621894)
http://www.user-mode-linux.org/~blaisorblade
Chiacchiera con i tuoi amici in tempo reale! 
 http://it.yahoo.com/mail_it/foot/*http://it.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
