Date: Thu, 23 Jun 2005 21:50:11 -0700
From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch][rfc] 5/5: core remove PageReserved
Message-Id: <20050623215011.0b1e6ef2.akpm@osdl.org>
In-Reply-To: <20050623095153.GB3334@holomorphy.com>
References: <42BA5F37.6070405@yahoo.com.au>
	<42BA5F5C.3080101@yahoo.com.au>
	<42BA5F7B.30904@yahoo.com.au>
	<42BA5FA8.7080905@yahoo.com.au>
	<42BA5FC8.9020501@yahoo.com.au>
	<42BA5FE8.2060207@yahoo.com.au>
	<20050623095153.GB3334@holomorphy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: William Lee Irwin III <wli@holomorphy.com>
Cc: nickpiggin@yahoo.com.au, linux-kernel@vger.kernel.org, linux-mm@kvack.org, hugh@veritas.com, pbadari@us.ibm.com, linux-scsi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

William Lee Irwin III <wli@holomorphy.com> wrote:
>
>  On Thu, Jun 23, 2005 at 05:08:24PM +1000, Nick Piggin wrote:
>  > Index: linux-2.6/drivers/scsi/sg.c
>  > ===================================================================
>  > --- linux-2.6.orig/drivers/scsi/sg.c
>  > +++ linux-2.6/drivers/scsi/sg.c
>  > @@ -1887,9 +1887,10 @@ st_unmap_user_pages(struct scatterlist *
>  >  	int i;
>  >  
>  >  	for (i=0; i < nr_pages; i++) {
>  > -		if (dirtied && !PageReserved(sgl[i].page))
>  > +		if (dirtied)
>  >  			SetPageDirty(sgl[i].page);
>  >  		/* unlock_page(sgl[i].page); */
>  > +		/* FIXME: XXX don't dirty/unmap VM_RESERVED regions? */
>  >  		/* FIXME: cache flush missing for rw==READ
>  >  		 * FIXME: call the correct reference counting function
>  >  		 */
> 
>  An answer should be devised for this. My numerous SCSI CD-ROM devices
>  (I have 5 across several different machines of several different arches)
>  are rather unlikely to be happy with /* FIXME: XXX ... as an answer.
> 
> 
>  On Thu, Jun 23, 2005 at 05:08:24PM +1000, Nick Piggin wrote:
>  > Index: linux-2.6/drivers/scsi/st.c
>  > ===================================================================
>  > --- linux-2.6.orig/drivers/scsi/st.c
>  > +++ linux-2.6/drivers/scsi/st.c
>  > @@ -4435,8 +4435,9 @@ static int sgl_unmap_user_pages(struct s
>  >  	int i;
>  >  
>  >  	for (i=0; i < nr_pages; i++) {
>  > -		if (dirtied && !PageReserved(sgl[i].page))
>  > +		if (dirtied)
>  >  			SetPageDirty(sgl[i].page);
>  > +		/* FIXME: XXX don't dirty/unmap VM_RESERVED regions? */
>  >  		/* FIXME: cache flush missing for rw==READ
>  >  		 * FIXME: call the correct reference counting function
>  >  		 */
> 
>  Mutatis mutandis for my SCSI tape drive.

This scsi code is already rather wrong.  There isn't much point in just
setting PG_dirty and leaving the page marked as clean in the radix tree. 
As it is we'll lose data if the user reads it into a MAP_SHARED memory
buffer.

set_page_dirty_lock() should be used here.  That can sleep.

<looks>

The above two functions are called under write_lock_irqsave() (at least)
and might be called from irq context (dunno).  So we cannot use
set_page_dirty_lock() and we don't have a ref on the page's inode.  We
could use set_page_dirty() and be racy against page reclaim.

But to get all this correct (and it's very incorrect now) we'd need to punt
the page dirtying up to process context, along the lines of
bio_check_pages_dirty().

Or, if st_unmap_user_pages() and sgl_unmap_user_pages() are not called from
irq context then we should arrange for them to be called without locks held
and use set_page_dirty_lock().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
