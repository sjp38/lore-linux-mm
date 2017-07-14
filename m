Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id B355F4408E5
	for <linux-mm@kvack.org>; Thu, 13 Jul 2017 21:55:16 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u5so77787064pgq.14
        for <linux-mm@kvack.org>; Thu, 13 Jul 2017 18:55:16 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id p14si5661574pli.440.2017.07.13.18.55.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Jul 2017 18:55:15 -0700 (PDT)
Date: Thu, 13 Jul 2017 18:55:15 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: asynchronous readahead prefetcher operation
Message-ID: <20170714015515.GC4469@bombadil.infradead.org>
References: <CAE=wTWYU8F5KDrC9VSxrtckVZ2xmvxy8owxCkZUcY4KXEiz0Og@mail.gmail.com>
 <20170713163437.GA4469@bombadil.infradead.org>
 <CAE=wTWZqwxJqb5v_BBpt97J2YxOGsQd86Nv6E5v6=GJetyE=KQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAE=wTWZqwxJqb5v_BBpt97J2YxOGsQd86Nv6E5v6=GJetyE=KQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vasilis Dimitsas <vdimitsas@gmail.com>
Cc: linux-mm@kvack.org

On Thu, Jul 13, 2017 at 11:36:22PM +0300, Vasilis Dimitsas wrote:
> Hello Matthew,
> 
> Thank you for your response. Since at user level I am using the pread()
> function, in kernel level, unless I am making a mistake, the
> do_generic_file_read() is being called. Inside this, the find_get_page() is
> called and if the page is not in the page cache then
> page_cache_sync_readahead() is called or page_cache_async_readahead() if
> the page is marked with the PG_readahead flag. So, I would like to find in
> which exact part of the code can someone understand that the I/O is not
> waited for.

As I said, the I/O is never waited for by either of these functions.
The _sync_readahead vs _async_readahead calls just use a slightly
different algorithm for choosing which pages to bring in.  In the case
of do_generic_file_read(), if the I/O has not finished by the time the
call returns, then the page will not be marked Uptodate, so we follow
this path:

                if (!PageUptodate(page)) {
                        error = wait_on_page_locked_killable(page);

and that is where we wait for the I/O to complete, no matter whether the
I/O was triggered by the sync or async calls.

> Thank you again,
> 
> Vasilis
> 
> On Thu, Jul 13, 2017 at 7:34 PM, Matthew Wilcox <willy@infradead.org> wrote:
> 
> > On Wed, Jul 12, 2017 at 11:31:21PM +0300, Vasilis Dimitsas wrote:
> > > I am currently working on a project which is related to the operation of
> > > the linux readahead prefetcher. As a result, I am trying to understand
> > its
> > > operation. Having read thoroughly the relevant part in the kernel code, I
> > > realize, from the comments, that part of the prefetching occurs
> > > asynchronously. The problem is that I can not verify this from the code.
> > >
> > > Even if you call page_cache_sync_readahead() or
> > > page_cache_async_readahead(), then both will end up in ra_submit(), in
> > > which, the operation is common for both cases.
> > >
> > > So, please could you tell me at which point does the operation of
> > > prefetching occurs asynchronously?
> >
> > The prefetching operation always occurs asynchronously; the
> > I/O is submitted and then both page_cache_sync_readahead() and
> > page_cache_async_readahead() return to the caller.  They use slightly
> > different algorithms, which is why they're different functions, but the
> > I/O is not waited for.  It's up to the caller to do that.
> >
> > I imagine you're looking at filemap_fault(), and it happens like this:
> >
> >         page = find_get_page(mapping, offset);
> > (returns NULL because there's no page in the cache)
> >                 do_sync_mmap_readahead(vmf->vma, ra, file, offset);
> > (will create pages and put them in the page cache, taking PageLock on each
> > page)
> >                 page = find_get_page(mapping, offset);
> > (finds the page that was just created)
> >         if (!lock_page_or_retry(page, vmf->vma->vm_mm, vmf->flags)) {
> > (will attempt to lock the page ... if it's locked and the fault lets us
> > retry,
> > fails so we can handle retries at the higher level.  If it's locked and the
> > fault says we can't retry, then sleeps until unlocked.  If/once it's
> > unlocked,
> > will return success)
> >
> > When the I/O completes, the page will be unlocked, usually by calling
> > page_endio().
> >

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
