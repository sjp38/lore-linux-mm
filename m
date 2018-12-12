Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 41AE58E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 16:46:48 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id e89so16340697pfb.17
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 13:46:48 -0800 (PST)
Received: from ipmail01.adl2.internode.on.net (ipmail01.adl2.internode.on.net. [150.101.137.133])
        by mx.google.com with ESMTP id j20si14682181pgg.162.2018.12.12.13.46.46
        for <linux-mm@kvack.org>;
        Wed, 12 Dec 2018 13:46:47 -0800 (PST)
Date: Thu, 13 Dec 2018 08:46:41 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181212214641.GB29416@dastard>
References: <3c91d335-921c-4704-d159-2975ff3a5f20@nvidia.com>
 <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181212150319.GA3432@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, Dan Williams <dan.j.williams@intel.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, mike.marciniszyn@intel.com, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Dec 12, 2018 at 10:03:20AM -0500, Jerome Glisse wrote:
> On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
> > On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
> > So this approach doesn't look like a win to me over using counter in struct
> > page and I'd rather try looking into squeezing HMM public page usage of
> > struct page so that we can fit that gup counter there as well. I know that
> > it may be easier said than done...
> 
> So i want back to the drawing board and first i would like to ascertain
> that we all agree on what the objectives are:
> 
>     [O1] Avoid write back from a page still being written by either a
>          device or some direct I/O or any other existing user of GUP.
>          This would avoid possible file system corruption.
> 
>     [O2] Avoid crash when set_page_dirty() is call on a page that is
>          considered clean by core mm (buffer head have been remove and
>          with some file system this turns into an ugly mess).

I think that's wrong. This isn't an "avoid a crash" case, this is a
"prevent data and/or filesystem corruption" case. The primary goal
we have here is removing our exposure to potential corruption, which
has the secondary effect of avoiding the crash/panics that currently
occur as a result of inconsistent page/filesystem state.

i.e. The goal is to have ->page_mkwrite() called on the clean page
/before/ the file-backed page is marked dirty, and hence we don't
expose ourselves to potential corruption or crashes that are a
result of inappropriately calling set_page_dirty() on clean
file-backed pages.

> For [O1] and [O2] i believe a solution with mapcount would work. So
> no new struct, no fake vma, nothing like that. In GUP for file back
> pages we increment both refcount and mapcount (we also need a special
> put_user_page to decrement mapcount when GUP user are done with the
> page).

I don't see how a mapcount can prevent anyone from calling
set_page_dirty() inappropriately.

> Now for [O1] the write back have to call page_mkclean() to go through
> all reverse mapping of the page and map read only. This means that
> we can count the number of real mapping and see if the mapcount is
> bigger than that. If mapcount is bigger than page is pin and we need
> to use a bounce page to do the writeback.

Doesn't work. Generally filesystems have already mapped the page
into bios before they call clear_page_dirty_for_io(), so it's too
late for the filesystem to bounce the page at that point.

> For [O2] i believe we can handle that case in the put_user_page()
> function to properly dirty the page without causing filesystem
> freak out.

I'm pretty sure you can't call ->page_mkwrite() from
put_user_page(), so I don't think this is workable at all.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
