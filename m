Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 57F268E0161
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 21:02:37 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id p24so501319qtl.2
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 18:02:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k5si254039qvb.200.2018.12.12.18.02.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 18:02:35 -0800 (PST)
Date: Wed, 12 Dec 2018 21:02:29 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181213020229.GN5037@redhat.com>
References: <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181212215931.GG5037@redhat.com>
 <20181213005119.GD29416@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181213005119.GD29416@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Dec 13, 2018 at 11:51:19AM +1100, Dave Chinner wrote:
> On Wed, Dec 12, 2018 at 04:59:31PM -0500, Jerome Glisse wrote:
> > On Thu, Dec 13, 2018 at 08:46:41AM +1100, Dave Chinner wrote:
> > > On Wed, Dec 12, 2018 at 10:03:20AM -0500, Jerome Glisse wrote:
> > > > On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
> > > > > On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
> > > > > So this approach doesn't look like a win to me over using counter in struct
> > > > > page and I'd rather try looking into squeezing HMM public page usage of
> > > > > struct page so that we can fit that gup counter there as well. I know that
> > > > > it may be easier said than done...
> > > > 
> > > > So i want back to the drawing board and first i would like to ascertain
> > > > that we all agree on what the objectives are:
> > > > 
> > > >     [O1] Avoid write back from a page still being written by either a
> > > >          device or some direct I/O or any other existing user of GUP.
> 
> IOWs, you need to mark pages being written to by a GUP as
> PageWriteback, so all attempts to write the page will block on
> wait_on_page_writeback() before trying to write the dirty page.

No you don't and you can't for the simple reasons is that the GUP
of some device driver can last days, weeks, months, years ... so
it is not something you want to do. Here is what happens today:
    - user space submit directio read from a file and writing to
      virtual address and the problematic case is when that virtual
      address is actualy a mmap of a file itself
    - kernel do GUP on the virtual address, if the page has write
      permission in the CPU page table mapping then the page
      refcount is incremented and the page is return to directio
      kernel code that do memcpy

      It means that the page already went through page_mkwrite so
      all is fine from fs point of view.

      If page does not have write permission then a page fault is
      triggered and page_mkwrite will happen and prep the page
      accordingly

In the above scheme a page write back might happens after we looked
up the page from the CPU page table and before directio finish with
memcpy so that the page content during the write back might not be
stable. This is a small window for things to go bad and i do not
think we know if anybody ever experience a bug because of that.

For other GUP users the flow is the same except that device driver
that keep the page around and do continuous dma to it might last
days, weeks, months, years ... so for those the race window is big
enough for bad things to happen. Jan have report of such bugs.

So what i am proposing to fix the above is have page_mkclean return
a is_pin boolean if page is pin than the fs code use a bounce page
to do the write back giving a stable bounce page. More over fs will
need to keep around all buffer_head, blocks, ... ie whatever is
associated with that file offset so that any latter set_page_dirty
would not freak out and would not need to reallocate blocks or do
anything heavy weight.

We have a separate discussion on what to do about truncate and other
fs event that inherently invalidate portion of file so i do not
want to complexify present discussion with those but we also have
that in mind.

Do you see any fundamental issues with that ? It abides by all
existing fs standard AFAICT (you have a page_mkwrite and we ask
fs to keep the result of that around).


> > > >          This would avoid possible file system corruption.
> 
> This isn't a filesystem corruption vector. At worst, it could cause
> torn data writes due to updating the page while it is under IO. We
> have a name for this: "stable pages". This is designed to prevent
> updates to pages via mmap writes from causing corruption of things
> like MD RAID due to modification of the data during RAID parity
> calculations. Hence we have wait_for_stable_page() calls in all
> ->page_mkwrite implementations so that new mmap writes block until
> writeback IO is complete on the devices that require stable pages
> to prevent corruption.
> 
> IOWs, we already deal with this "delay new modification while
> writeback is in progress" problem in the mmap/filesystem world and
> have infrastructure to handle it. And the ->page_mkwrite code
> already deals with it.

Does the above answer that too ?

> 
> > > > 
> > > >     [O2] Avoid crash when set_page_dirty() is call on a page that is
> > > >          considered clean by core mm (buffer head have been remove and
> > > >          with some file system this turns into an ugly mess).
> > > 
> > > I think that's wrong. This isn't an "avoid a crash" case, this is a
> > > "prevent data and/or filesystem corruption" case. The primary goal
> > > we have here is removing our exposure to potential corruption, which
> > > has the secondary effect of avoiding the crash/panics that currently
> > > occur as a result of inconsistent page/filesystem state.
> > 
> > This is O1 avoid corruption is O1
> 
> It's "avoid a specific instance of data corruption", not a general
> mechanism for avoiding data/filesystem corruption.
> 
> Calling set_page_dirty() on a file backed page which has not been
> correctly prepared can cause data corruption, filesystem coruption
> and shutdowns, etc because we have dirty data over a region that is
> not correctly mapped. Yes, it can also cause a crash (because we
> really, really suck at validation and error handling in generic code
> paths), but there's so, so much more that can go wrong than crash
> the kernel when we do stupid shit like this.

I believe i answer in the above explaination.

> 
> > > i.e. The goal is to have ->page_mkwrite() called on the clean page
> > > /before/ the file-backed page is marked dirty, and hence we don't
> > > expose ourselves to potential corruption or crashes that are a
> > > result of inappropriately calling set_page_dirty() on clean
> > > file-backed pages.
> > 
> > Yes and this would be handle by put_user_page ie:
> 
> No, put_user_page() is too late - it's after the DMA has completed,
> but we have to ensure the file has backing store allocated and the
> pages are in the correct state /before/ the DMA is done.
> 
> Think ENOSPC - that has to be handled before we do the DMA, not
> after. Before the DMA it is a recoverable error, after the DMA it is
> data loss/corruption failure.

Yes agree and i hope that the above explaination properly explains
that it would become legal to do set_page_dirty in put_user_page
thanks to page_mkclean telling fs code not to recycle anything
after write back finish.


> > put_user_page(struct page *page, bool dirty)
> > {
> >     if (!PageAnon(page)) {
> >         if (dirty) {
> >             // Do the whole dance ie page_mkwrite and all before
> >             // calling set_page_dirty()
> >         }
> >         ...
> >     }
> >     ...
> > }
> 
> Essentially, doing this would require a whole new "dirty a page"
> infrastructure because it is in the IO path, not the page fault
> path.
> 
> And, for hardware that does it's own page faults for DMA, this whole
> post-DMA page setup is broken because the pages will have already
> gone through ->page_mkwrite() and be set up correctly already.

Does the above properly explain that you would not need a new
set_page_dirty ?

> 
> > > > For [O2] i believe we can handle that case in the put_user_page()
> > > > function to properly dirty the page without causing filesystem
> > > > freak out.
> > > 
> > > I'm pretty sure you can't call ->page_mkwrite() from
> > > put_user_page(), so I don't think this is workable at all.
> > 
> > Hu why ? i can not think of any reason whike you could not. User of
> 
> It's not a fault path, you can't safely lock pages, you can't take
> fault-path only locks in the IO path (mmap_sem inversion problems),
> etc.
> 
> /me has a nagging feeling this was all explained in a previous
> discussions of this patchset...

Did i explain properly my idea this time ? In the scheme i am proposing
it abides by all fs rules that i am aware of at least. I hope i did not
forget any.

Cheers,
J�r�me
