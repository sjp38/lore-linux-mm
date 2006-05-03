From: Blaisorblade <blaisorblade@yahoo.it>
Subject: Re: [patch 00/14] remap_file_pages protection support
Date: Wed, 3 May 2006 02:44:58 +0200
References: <20060430172953.409399000@zion.home.lan> <4456D5ED.2040202@yahoo.com.au>
In-Reply-To: <4456D5ED.2040202@yahoo.com.au>
MIME-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Message-Id: <200605030245.01457.blaisorblade@yahoo.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org, Linux Memory Management <linux-mm@kvack.org>, Ulrich Drepper <drepper@redhat.com>, Val Henson <val.henson@intel.com>
List-ID: <linux-mm.kvack.org>

On Tuesday 02 May 2006 05:45, Nick Piggin wrote:
> blaisorblade@yahoo.it wrote:
> > The first idea is to use this for UML - it must create a lot of single
> > page mappings, and managing them through separate VMAs is slow.

> I think I would rather this all just folded under VM_NONLINEAR rather than
> having this extra MANYPROTS thing, no? (you're already doing that in one
> direction).

That step is _temporary_ if the extra usages are accepted.

Also, I reported (changelog of patch 03/14) a definite API bug you get if you 
don't distinguish VM_MANYPROTS from VM_NONLINEAR. I'm pasting it here because 
that changelog is rather long:

"In fact, without this flag, we'd have indeed a regression with
remap_file_pages VS mprotect, on uniform nonlinear VMAs.

mprotect alters the VMA prots and walks each present PTE, ignoring installed
ones, even when pte_file() is on; their saved prots will be restored on 
faults,
ignoring VMA ones and losing the mprotect() on them. So, in do_file_page(), we
must restore anyway VMA prots when the VMA is uniform, as we used to do before
this trail of patches."

> > Additional note: this idea, with some further refinements (which I'll
> > code after this chunk is accepted), will allow to reduce the number of
> > used VMAs for most userspace programs - in particular, it will allow to
> > avoid creating one VMA for one guard pages (which has PROT_NONE) -
> > forcing PROT_NONE on that page will be enough.

> I think that's silly. Your VM_MANYPROTS|VM_NONLINEAR vmas will cause more
> overhead in faulting and reclaim.

I know that problem. In fact for that we want VM_MANYPROTS without 
VM_NONLINEAR.

> It loooks like it would take an hour or two just to code up a patch which
> puts a VM_GUARDPAGES flag into the vma, and tells the free area allocator
> to skip vm_start-1 .. vm_end+1
we must refine which pages to skip (the example I saw has only one guard page, 
if I'm not mistaken) but 
> . What kind of troubles has prevented 
> something simple and easy like that from going in?

Fairly better idea... It's just the fact that the original proposal was wider, 
and that we looked to the problem in the wrong way (+ we wanted anyway to 
have the present work merged, so that wasn't a problem).

Ulrich wanted to have code+data(+guard on 64-bit) into the same VMA, but I 
left the code+data VMA joining away, to think more with it, since currently 
it's too slow on swapout.

The other part is avoiding guard VMAs for thread stacks, and that could be 
accomplished too by your proposal. Iff this work is held out, however.
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
