Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id EAC568E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 16:59:37 -0500 (EST)
Received: by mail-qk1-f199.google.com with SMTP id 92so17346782qkx.19
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 13:59:37 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e35si8318410qve.41.2018.12.12.13.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 13:59:37 -0800 (PST)
Date: Wed, 12 Dec 2018 16:59:31 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181212215931.GG5037@redhat.com>
References: <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20181212214641.GB29416@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Thu, Dec 13, 2018 at 08:46:41AM +1100, Dave Chinner wrote:
> On Wed, Dec 12, 2018 at 10:03:20AM -0500, Jerome Glisse wrote:
> > On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
> > > On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
> > > So this approach doesn't look like a win to me over using counter in struct
> > > page and I'd rather try looking into squeezing HMM public page usage of
> > > struct page so that we can fit that gup counter there as well. I know that
> > > it may be easier said than done...
> > 
> > So i want back to the drawing board and first i would like to ascertain
> > that we all agree on what the objectives are:
> > 
> >     [O1] Avoid write back from a page still being written by either a
> >          device or some direct I/O or any other existing user of GUP.
> >          This would avoid possible file system corruption.
> > 
> >     [O2] Avoid crash when set_page_dirty() is call on a page that is
> >          considered clean by core mm (buffer head have been remove and
> >          with some file system this turns into an ugly mess).
> 
> I think that's wrong. This isn't an "avoid a crash" case, this is a
> "prevent data and/or filesystem corruption" case. The primary goal
> we have here is removing our exposure to potential corruption, which
> has the secondary effect of avoiding the crash/panics that currently
> occur as a result of inconsistent page/filesystem state.

This is O1 avoid corruption is O1

> 
> i.e. The goal is to have ->page_mkwrite() called on the clean page
> /before/ the file-backed page is marked dirty, and hence we don't
> expose ourselves to potential corruption or crashes that are a
> result of inappropriately calling set_page_dirty() on clean
> file-backed pages.

Yes and this would be handle by put_user_page ie:

put_user_page(struct page *page, bool dirty)
{
    if (!PageAnon(page)) {
        if (dirty) {
            // Do the whole dance ie page_mkwrite and all before
            // calling set_page_dirty()
        }
        ...
    }
    ...
}

> 
> > For [O1] and [O2] i believe a solution with mapcount would work. So
> > no new struct, no fake vma, nothing like that. In GUP for file back
> > pages we increment both refcount and mapcount (we also need a special
> > put_user_page to decrement mapcount when GUP user are done with the
> > page).
> 
> I don't see how a mapcount can prevent anyone from calling
> set_page_dirty() inappropriately.

See above.

> 
> > Now for [O1] the write back have to call page_mkclean() to go through
> > all reverse mapping of the page and map read only. This means that
> > we can count the number of real mapping and see if the mapcount is
> > bigger than that. If mapcount is bigger than page is pin and we need
> > to use a bounce page to do the writeback.
> 
> Doesn't work. Generally filesystems have already mapped the page
> into bios before they call clear_page_dirty_for_io(), so it's too
> late for the filesystem to bounce the page at that point.
> 
> > For [O2] i believe we can handle that case in the put_user_page()
> > function to properly dirty the page without causing filesystem
> > freak out.
> 
> I'm pretty sure you can't call ->page_mkwrite() from
> put_user_page(), so I don't think this is workable at all.

Hu why ? i can not think of any reason whike you could not. User of
GUP have their put_user_page in tearing down code and i do not see
why it would be an issue there. Even for direct I/O i can not think
of anything that would block us from doing that. So this put_user_page
is not call while holding any other mm of fs locks.

Do you have some rough idea of what the issue would be ?

Cheers,
J�r�me
