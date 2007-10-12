Date: Fri, 12 Oct 2007 01:38:12 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: msync(2) bug(?), returns AOP_WRITEPAGE_ACTIVATE to userland
In-Reply-To: <cfa94dc20710111512j9b6c038qf89c516ecd605411@mail.gmail.com>
Message-ID: <Pine.LNX.4.64.0710120129080.16588@blonde.wat.veritas.com>
References: <200710071920.l97JKJX5018871@agora.fsl.cs.sunysb.edu>
 <20071011144740.136b31a8.akpm@linux-foundation.org>
 <cfa94dc20710111512j9b6c038qf89c516ecd605411@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ryan Finnie <ryan@finnie.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Erez Zadok <ezk@cs.sunysb.edu>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, cjwatson@ubuntu.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 11 Oct 2007, Ryan Finnie wrote:
> On 10/11/07, Andrew Morton <akpm@linux-foundation.org> wrote:
> > shit.  That's a nasty bug.  Really userspace should be testing for -1, but
> > the msync() library function should only ever return 0 or -1.
> >
> > Does this fix it?
> >
> > --- a/mm/page-writeback.c~a
> > +++ a/mm/page-writeback.c
> > @@ -850,8 +850,10 @@ retry:
> >
> >                         ret = (*writepage)(page, wbc, data);
> >
> > -                       if (unlikely(ret == AOP_WRITEPAGE_ACTIVATE))
> > +                       if (unlikely(ret == AOP_WRITEPAGE_ACTIVATE)) {
> >                                 unlock_page(page);
> > +                               ret = 0;
> > +                       }
> >                         if (ret || (--(wbc->nr_to_write) <= 0))
> >                                 done = 1;
> >                         if (wbc->nonblocking && bdi_write_congested(bdi)) {
> > _
> >
> 
> Pekka Enberg replied with an identical patch a few days ago, but for
> some reason the same condition flows up to msync as -1 EIO instead of
> AOP_WRITEPAGE_ACTIVATE with that patch applied.  The last part of the
> thread is below.  Thanks.

Each time I sit down to follow what's going on with writepage and
unionfs and msync, I get distracted: I really haven't researched
this properly.

But I keep suspecting that the answer might be the patch below (which
rather follows what drivers/block/rd.c is doing).  I'm especially
worried that, rather than just AOP_WRITEPAGE_ACTIVATE being returned
to userspace, bad enough in itself, you might be liable to hit that
BUG_ON(page_mapped(page)).  shmem_writepage does not expect to be
called by anyone outside mm/vmscan.c, but unionfs can now get to it?

Please let us know if this patch does fix it:
then I'll try harder to work out what goes on.

Thanks,
Hugh

--- 2.6.23/mm/shmem.c	2007-10-09 21:31:38.000000000 +0100
+++ linux/mm/shmem.c	2007-10-12 01:25:46.000000000 +0100
@@ -916,6 +916,11 @@ static int shmem_writepage(struct page *
 	struct inode *inode;
 
 	BUG_ON(!PageLocked(page));
+	if (!wbc->for_reclaim) {
+		set_page_dirty(page);
+		unlock_page(page);
+		return 0;
+	}
 	BUG_ON(page_mapped(page));
 
 	mapping = page->mapping;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
