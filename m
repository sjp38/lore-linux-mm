Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id D57138E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 01:18:54 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id s14so11828642pfk.16
        for <linux-mm@kvack.org>; Mon, 10 Dec 2018 22:18:54 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id j39si11727267plb.272.2018.12.10.22.18.52
        for <linux-mm@kvack.org>;
        Mon, 10 Dec 2018 22:18:53 -0800 (PST)
Date: Tue, 11 Dec 2018 17:18:47 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181211061847.GG2398@dastard>
References: <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <CAPcyv4hwtMA+4qc6500ucn5vf6fRrNdfyMHru_Jhzx86=1Wwww@mail.gmail.com>
 <20181208163353.GA2952@redhat.com>
 <20181208164825.GA26154@infradead.org>
 <CAPcyv4hP1XrheKTrapANmrg10xz6dpG7cj=qEG8La9L34bCKDQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hP1XrheKTrapANmrg10xz6dpG7cj=qEG8La9L34bCKDQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, Jan Kara <jack@suse.cz>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Sat, Dec 08, 2018 at 10:09:26AM -0800, Dan Williams wrote:
> On Sat, Dec 8, 2018 at 8:48 AM Christoph Hellwig <hch@infradead.org> wrote:
> >
> > On Sat, Dec 08, 2018 at 11:33:53AM -0500, Jerome Glisse wrote:
> > > Patchset to use HMM inside nouveau have already been posted, some
> > > of the bits have already made upstream and more are line up for
> > > next merge window.
> >
> > Even with that it is a relative fringe feature compared to making
> > something like get_user_pages() that is literally used every to actually
> > work properly.
> >
> > So I think we need to kick out HMM here and just find another place for
> > it to store data.
> >
> > And just to make clear that I'm not picking just on this - the same is
> > true to a just a little smaller extent for the pgmap..
> 
> Fair enough, I cringed as I took a full pointer for that use case, I'm
> happy to look at ways of consolidating or dropping that usage.
> 
> Another fix that may put pressure 'struct page' is resolving the
> untenable situation of dax being incompatible with reflink, i.e.
> reflink currently requires page-cache pages. Dave has talked about
> silently establishing page-cache entries when a dax-page is cow'd for
> reflink,

I think you've got it the wrong way around there :)

Think of a set of files with the following physical block mappings:

index		0  1  2  3  4  5
inode W		A  B  C  D  E  F
inode X		B  C  D  E  F  A
inode Y		C  D  E  F  A  B
inode Z		D  E  F  A  B  C

Basically, each block has 4 references (one from each file), and
each reference to a block is from a diffent file offset. Now, with
DAX, each inode wants to put the same struct page into their own
address space mapping tree but have different page indexes.

i.e. for block A, inode W wants page->index = 0, X wants 5, Y wants
4 and Z wants 3.

This is not possible with a single struct page and where the
problem with DAX, struct pages and physically shared data lies.

This is where the page cache is currently required - each mapping
gets it's own copy of the shared block in volatile RAM, but when
sharing is broken (by COW) we can toss the volatile copy and go back
to using DAX for the newly allocated, single owner {block, struct
page} tuple that replaces the shared page.

> but I wonder if we could go the other way and introduce the
> mechanism of a page belonging to multiple mappings simultaneously and
> managed by the filesystem.

That's pretty much what I suggested at LSFMM. We do lookups for
shared extent mappings through the filesystem buffer cache (which is
indexed by physical location) and hold the primary struct page in
the filesystem buffer cache. We then hand out dynamically allocated
struct pages back to the caller that point to the same physical page
and place them in each inode's address space. When a write fault
occurs, we allocate a new block, grab the physical struct page, copy
the data across, and release the dynamically allocated read-only
struct page and reference to the primary struct page held in the
filesytem buffer cache.

It's essentially the same model "cached page per inode address
space" as using volatile RAM copies via the page cache, except
the struct pages point back to the same physical location rather
than having their own temporary, volatile copy of the data.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
