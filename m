Date: Wed, 20 Aug 2008 11:02:34 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch] mm: rewrite vmap layer
Message-ID: <20080820090234.GA7018@wotan.suse.de>
References: <20080818133224.GA5258@wotan.suse.de> <48AADBDC.2000608@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <48AADBDC.2000608@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, linux-arch@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Tue, Aug 19, 2008 at 09:42:36AM -0500, Christoph Lameter wrote:
> Nick Piggin wrote:
> 
> > +static void free_unmap_vmap_area(struct vmap_area *va)
> > +{
> > +	va->flags |= VM_LAZY_FREE;
> > +	atomic_add((va->va_end - va->va_start) >> PAGE_SHIFT, &vmap_lazy_nr);
> > +	if (unlikely(atomic_read(&vmap_lazy_nr) > LAZY_MAX))
> > +		purge_vmap_area_lazy();
> > +}
> 
> Could you check here if we are in an atomic context and then simply not purge
> the vmap area? That may we may get to a vfree that can be run in an atomic
> context.

If the locks and per-cpu access is made irq safe, then yes.

 
> Or run purge_vma_area_lazy from keventd?
 
Right. But that's only needed if we want to vmap from irq context too
(otherwise we can just do the purge check at vmap time).

Is there any good reason to be able to vmap or vunmap from interrupt
time, though?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
