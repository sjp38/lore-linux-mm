Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 115618E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 10:13:24 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id t13so2457594otk.4
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 07:13:24 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j8si2603517otc.164.2018.12.14.07.13.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Dec 2018 07:13:22 -0800 (PST)
Date: Fri, 14 Dec 2018 10:13:15 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181214151314.GA3645@redhat.com>
References: <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181212215931.GG5037@redhat.com>
 <20181213005119.GD29416@dastard>
 <20181213020229.GN5037@redhat.com>
 <20181214060012.GA10644@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181214060012.GA10644@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Dec 14, 2018 at 05:00:12PM +1100, Dave Chinner wrote:
> On Wed, Dec 12, 2018 at 09:02:29PM -0500, Jerome Glisse wrote:
> > On Thu, Dec 13, 2018 at 11:51:19AM +1100, Dave Chinner wrote:
> > > On Wed, Dec 12, 2018 at 04:59:31PM -0500, Jerome Glisse wrote:
> > > > On Thu, Dec 13, 2018 at 08:46:41AM +1100, Dave Chinner wrote:
> > > > > On Wed, Dec 12, 2018 at 10:03:20AM -0500, Jerome Glisse wrote:
> > > > > > On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
> > > > > > > On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
> > > > > > > So this approach doesn't look like a win to me over using counter in struct
> > > > > > > page and I'd rather try looking into squeezing HMM public page usage of
> > > > > > > struct page so that we can fit that gup counter there as well. I know that
> > > > > > > it may be easier said than done...
> > > > > > 
> > > > > > So i want back to the drawing board and first i would like to ascertain
> > > > > > that we all agree on what the objectives are:
> > > > > > 
> > > > > >     [O1] Avoid write back from a page still being written by either a
> > > > > >          device or some direct I/O or any other existing user of GUP.
> > > 
> > > IOWs, you need to mark pages being written to by a GUP as
> > > PageWriteback, so all attempts to write the page will block on
> > > wait_on_page_writeback() before trying to write the dirty page.
> > 
> > No you don't and you can't for the simple reasons is that the GUP
> > of some device driver can last days, weeks, months, years ... so
> > it is not something you want to do. Here is what happens today:
> >     - user space submit directio read from a file and writing to
> >       virtual address and the problematic case is when that virtual
> >       address is actualy a mmap of a file itself
> >     - kernel do GUP on the virtual address, if the page has write
> >       permission in the CPU page table mapping then the page
> >       refcount is incremented and the page is return to directio
> >       kernel code that do memcpy
> > 
> >       It means that the page already went through page_mkwrite so
> >       all is fine from fs point of view.
> >       If page does not have write permission then a page fault is
> >       triggered and page_mkwrite will happen and prep the page
> >       accordingly
> 
> Yes, the short term GUP references do the right thing. They aren't
> the issue - the problem is the long term GUP references that dirty
> clean pages without first having called ->page_mkwrite.
> 
> > In the above scheme a page write back might happens after we looked
> > up the page from the CPU page table and before directio finish with
> > memcpy so that the page content during the write back might not be
> > stable. This is a small window for things to go bad and i do not
> > think we know if anybody ever experience a bug because of that.
> > 
> > For other GUP users the flow is the same except that device driver
> > that keep the page around and do continuous dma to it might last
> > days, weeks, months, years ... so for those the race window is big
> > enough for bad things to happen. Jan have report of such bugs.
> 
> i.e. this case.
> 
> GUP faults the page, gets marked dirty, time passes, page
> writeback occurs, it's now mapped clean, time passes, another RDMA
> hits those pages, it calls set_page_dirty() again and things go
> boom.
> 
> Basically, you are saying that the problem here is that writeback
> of a dirty page occurred while there was an active GUP, and that
> you want us to ....
> 
> > So what i am proposing to fix the above is have page_mkclean return
> > a is_pin boolean if page is pin than the fs code use a bounce page
> > to do the write back giving a stable bounce page. More over fs will
> > need to keep around all buffer_head, blocks, ... ie whatever is
> > associated with that file offset so that any latter set_page_dirty
> > would not freak out and would not need to reallocate blocks or do
> > anything heavy weight.
> 
> .... keep the dirty page pinned and never written back until the GUP
> is released.

I am sorry if i am so hard to understand but this is not what i
have in mind. WHat i have in mind is the write back will use a
bounce page so that the page content is stable and dma can keep
happening to the GUPed page while write back make progress. But
the end of write back callback should not free buffer_head or
blocks or anything that was done by the first page_mkwrite so
that another set_page_dirty can happens at anytime after without
the fs code freaking out.


> Which, quite frankly, is insanity.  The whole point of
> ->page_mkwrite() is that we can clean file backed mapped pages at
> any point in time and have the next write access correctly mark it
> dirty again so it can be written back.
> 
> This is *absolutely necessary* for data integrity (i.e. fsync,
> sync(), etc) as well as filesystem management operations (e.g.
> filesystem freeze) to work correctly and not lose data if the system
> crashes or generate corrupt snapshots for backup or migration
> purposes.

Is keeping the result of the first page_mkwrite not doable ? Or
at least avoiding freeing blocks and such so that we can have a
latter lighter page_mkwrite_light that can be call by put_user_page

The thing is we can not stop the DMA on some device and thus we
can not force device do redo a GUP after a write back. Note that
if you said that device must do that and you will not accept any-
thing that do not do that, i am fine with that, this was what i
advocated for in the first place, but it means that a certain
number of device driver will have to regress from user point of
view ie they will not be able to support GUP anymore.

> 
> > We have a separate discussion on what to do about truncate and other
> > fs event that inherently invalidate portion of file so i do not
> > want to complexify present discussion with those but we also have
> > that in mind.
> > 
> > Do you see any fundamental issues with that ? It abides by all
> > existing fs standard AFAICT (you have a page_mkwrite and we ask
> > fs to keep the result of that around).
> 
> The fundamental issue is that ->page_mkwrite must be called on every
> write access to a clean file backed page, not just the first one.
> How long the GUP reference lasts is irrelevant, if the page is clean
> and you need to dirty it, you must call ->page_mkwrite before it is
> marked writeable and dirtied. Every. Time.

I am fine with that then it is just a matter of telling device that
do not abide by mmu notifier that they can not use GUP anymore which
means that it will regress from user point of view. But i am ok with
that.

> 
> > > Think ENOSPC - that has to be handled before we do the DMA, not
> > > after. Before the DMA it is a recoverable error, after the DMA it is
> > > data loss/corruption failure.
> > 
> > Yes agree and i hope that the above explaination properly explains
> > that it would become legal to do set_page_dirty in put_user_page
> > thanks to page_mkclean telling fs code not to recycle anything
> > after write back finish.
> 
> No, page_mkclean doesn't help at all. Every time the page is dirtied
> it may require block allocation (think COW filesystems) and so
> ENOSPC (and block allocation) must be done /before/ the page is
> dirtied. YOU can't just keep re-dirtying the same page and assuming
> that the filesystem will just work with that - that's essentially
> what the current code does with long term GUP references, and that's
> why it's so broken.
> 
> /me is getting tired of explaining the same thing over and over
> again.

Sorry you feel that way, thank you for bearing with me. Like i said
i am fine with telling GUP user that do not abibe by mmu notifier
and thus that keep writing to page after write back that they need
to stop even if it means breaking existing userspace.

Cheers,
J�r�me
