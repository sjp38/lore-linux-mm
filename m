Date: Tue, 26 Nov 2002 20:00:23 +0100
From: Ingo Oeser <ingo.oeser@informatik.tu-chemnitz.de>
Subject: Generalising page walking even more
Message-ID: <20021126200023.Q659@nightmaster.csn.tu-chemnitz.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@digeo.com
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Andrew,
hi linux-mm readers,

Gerd Knorr pointed me to another common used function, which
might need generalisation.

mm/memory.c:vmalloc_to_page() is also some kind of page walker,
but is usally called in a loop, which is really inefficient and
causes a lot of preemption enable/disable calls.

My plan is to put some generalisation into mm/page_walk.c
allowing also to walk a vmalloc range and collect pages or sgls
from there.

Routines for fixing up after DMA transfers are also nice to have.
My idea is a function like this for pages and sgls.

/* If we wrote into the page, we must tell that the VM system.
 * @numdirty is the number of pages dirtied. It may be zero.
 */
void fixup_sgl_usage(struct gup_add_sgls *gup, unsigned int numdirty) {
        unsigned int i=0;

        BUG_ON(gup->count < numdirty);
        WARN_ON(!(gup->pw.vm_flags & (VM_WRITE|VM_MAYWRITE)));

        for (; i < numdirty; i++) {
                set_page_dirty(gup->sgl[i].page);
                page_cache_release(gup->sgl[i].page);
        }

        for (; i < gup->count; i++) {
                page_cache_release(gup->sgl[i].page);
        }
}

This is to assist driver writers and to remove more vm knowledge
from the drivers, since driver writers are usually no VM gurus.

What do you think?

Regards

Ingo Oeser
-- 
Science is what we can tell a computer. Art is everything else. --- D.E.Knuth
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
