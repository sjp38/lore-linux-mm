Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 16D858E0018
	for <linux-mm@kvack.org>; Mon, 10 Dec 2018 13:44:46 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id a199so10850812qkb.23
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 10:44:46 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 41sor14377324qtw.64.2018.12.10.10.44.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 10 Dec 2018 10:44:43 -0800 (PST)
Date: Mon, 10 Dec 2018 13:44:39 -0500
From: Josef Bacik <josef@toxicpanda.com>
Subject: Re: [PATCH 3/4] filemap: drop the mmap_sem for all blocking
 operations
Message-ID: <20181210184438.va7mdwjgwndgri4s@macbook-pro-91.dhcp.thefacebook.com>
References: <20181130195812.19536-1-josef@toxicpanda.com>
 <20181130195812.19536-4-josef@toxicpanda.com>
 <20181207110138.GE13008@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181207110138.GE13008@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: Josef Bacik <josef@toxicpanda.com>, kernel-team@fb.com, hannes@cmpxchg.org, linux-kernel@vger.kernel.org, tj@kernel.org, david@fromorbit.com, akpm@linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, riel@redhat.com

On Fri, Dec 07, 2018 at 12:01:38PM +0100, Jan Kara wrote:
> On Fri 30-11-18 14:58:11, Josef Bacik wrote:
> > Currently we only drop the mmap_sem if there is contention on the page
> > lock.  The idea is that we issue readahead and then go to lock the page
> > while it is under IO and we want to not hold the mmap_sem during the IO.
> > 
> > The problem with this is the assumption that the readahead does
> > anything.  In the case that the box is under extreme memory or IO
> > pressure we may end up not reading anything at all for readahead, which
> > means we will end up reading in the page under the mmap_sem.
> > 
> > Instead rework filemap fault path to drop the mmap sem at any point that
> > we may do IO or block for an extended period of time.  This includes
> > while issuing readahead, locking the page, or needing to call ->readpage
> > because readahead did not occur.  Then once we have a fully uptodate
> > page we can return with VM_FAULT_RETRY and come back again to find our
> > nicely in-cache page that was gotten outside of the mmap_sem.
> > 
> > Signed-off-by: Josef Bacik <josef@toxicpanda.com>
> > ---
> >  mm/filemap.c | 113 ++++++++++++++++++++++++++++++++++++++++++++++++-----------
> >  1 file changed, 93 insertions(+), 20 deletions(-)
> > 
> > diff --git a/mm/filemap.c b/mm/filemap.c
> > index f068712c2525..5e76b24b2a0f 100644
> > --- a/mm/filemap.c
> > +++ b/mm/filemap.c
> > @@ -2304,28 +2304,44 @@ EXPORT_SYMBOL(generic_file_read_iter);
> >  
> >  #ifdef CONFIG_MMU
> >  #define MMAP_LOTSAMISS  (100)
> > +static struct file *maybe_unlock_mmap_for_io(struct file *fpin,
> > +					     struct vm_area_struct *vma,
> > +					     int flags)
> > +{
> > +	if (fpin)
> > +		return fpin;
> > +	if ((flags & (FAULT_FLAG_ALLOW_RETRY | FAULT_FLAG_RETRY_NOWAIT)) ==
> > +	    FAULT_FLAG_ALLOW_RETRY) {
> > +		fpin = get_file(vma->vm_file);
> > +		up_read(&vma->vm_mm->mmap_sem);
> > +	}
> > +	return fpin;
> > +}
> >  
> >  /*
> >   * Synchronous readahead happens when we don't even find
> >   * a page in the page cache at all.
> >   */
> > -static void do_sync_mmap_readahead(struct vm_area_struct *vma,
> > -				   struct file_ra_state *ra,
> > -				   struct file *file,
> > -				   pgoff_t offset)
> > +static struct file *do_sync_mmap_readahead(struct vm_area_struct *vma,
> > +					   struct file_ra_state *ra,
> > +					   struct file *file,
> > +					   pgoff_t offset,
> > +					   int flags)
> >  {
> 
> IMO it would be nicer to pass vmf here at this point. Everything this
> function needs is there and the number of arguments is already quite big.
> But I don't insist.
> 
> >  /*
> >   * Asynchronous readahead happens when we find the page and PG_readahead,
> >   * so we want to possibly extend the readahead further..
> >   */
> > -static void do_async_mmap_readahead(struct vm_area_struct *vma,
> > -				    struct file_ra_state *ra,
> > -				    struct file *file,
> > -				    struct page *page,
> > -				    pgoff_t offset)
> > +static struct file *do_async_mmap_readahead(struct vm_area_struct *vma,
> > +					    struct file_ra_state *ra,
> > +					    struct file *file,
> > +					    struct page *page,
> > +					    pgoff_t offset, int flags)
> >  {
> 
> The same here (except for 'page' which needs to be kept).
> 
> > @@ -2433,9 +2458,32 @@ vm_fault_t filemap_fault(struct vm_fault *vmf)
> >  			return vmf_error(-ENOMEM);
> >  	}
> >  
> > -	if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
> > -		put_page(page);
> > -		return ret | VM_FAULT_RETRY;
> > +	/*
> > +	 * We are open-coding lock_page_or_retry here because we want to do the
> > +	 * readpage if necessary while the mmap_sem is dropped.  If there
> > +	 * happens to be a lock on the page but it wasn't being faulted in we'd
> > +	 * come back around without ALLOW_RETRY set and then have to do the IO
> > +	 * under the mmap_sem, which would be a bummer.
> > +	 */
> 
> Hum, lock_page_or_retry() has two callers and you've just killed one. I
> think it would be better to modify the function to suit both callers rather
> than opencoding? Maybe something like lock_page_maybe_drop_mmap() which
> would unconditionally acquire the lock and return whether it has dropped
> mmap sem or not? Callers can then decide what to do.
> 

I tried this, but it ends up being convoluted, since swap doesn't have a file to
pin we have to add extra cases for that, and then change the return value to
indicate wether we locked the page _and_ dropped the mmap sem, or just locked
the page, etc.  It didn't seem the extra complication, so I just broke the open
coding out into its own helper.

> BTW I'm not sure this complication is really worth it. The "drop mmap_sem
> for IO" is never going to be 100% thing if nothing else because only one
> retry is allowed in do_user_addr_fault(). So the second time we get to
> filemap_fault(), we will not have FAULT_FLAG_ALLOW_RETRY set and thus do
> blocking locking. So I think your code needs to catch common cases you
> observe in practice but not those super-rare corner cases...

I had counters in all of these paths because I was sure some things weren't
getting hit at all, but it turns out each of these cases gets hit with
surprisingly high regularity.  The lock_page_or_retry() case in particular gets
hit a lot with multi-threaded applications that got paged out because of heavy
memory pressure.  By no means is it as high as just the normal readpage or
readahead cases, but it's not 0, so I'd rather have the extra helper here to
make sure we're never getting screwed.  Thanks,

Josef
