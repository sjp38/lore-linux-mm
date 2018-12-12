Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5EE0E8E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 12:02:28 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id 92so16515931qkx.19
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:02:28 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p8si7079618qki.221.2018.12.12.09.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 09:02:27 -0800 (PST)
Date: Wed, 12 Dec 2018 12:02:20 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181212170220.GA5037@redhat.com>
References: <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com>
 <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Dec 12, 2018 at 08:27:35AM -0800, Dan Williams wrote:
> On Wed, Dec 12, 2018 at 7:03 AM Jerome Glisse <jglisse@redhat.com> wrote:
> >
> > On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
> > > On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
> > > > Another crazy idea, why not treating GUP as another mapping of the page
> > > > and caller of GUP would have to provide either a fake anon_vma struct or
> > > > a fake vma struct (or both for PRIVATE mapping of a file where you can
> > > > have a mix of both private and file page thus only if it is a read only
> > > > GUP) that would get added to the list of existing mapping.
> > > >
> > > > So the flow would be:
> > > >     somefunction_thatuse_gup()
> > > >     {
> > > >         ...
> > > >         GUP(_fast)(vma, ..., fake_anon, fake_vma);
> > > >         ...
> > > >     }
> > > >
> > > >     GUP(vma, ..., fake_anon, fake_vma)
> > > >     {
> > > >         if (vma->flags == ANON) {
> > > >             // Add the fake anon vma to the anon vma chain as a child
> > > >             // of current vma
> > > >         } else {
> > > >             // Add the fake vma to the mapping tree
> > > >         }
> > > >
> > > >         // The existing GUP except that now it inc mapcount and not
> > > >         // refcount
> > > >         GUP_old(..., &nanonymous, &nfiles);
> > > >
> > > >         atomic_add(&fake_anon->refcount, nanonymous);
> > > >         atomic_add(&fake_vma->refcount, nfiles);
> > > >
> > > >         return nanonymous + nfiles;
> > > >     }
> > >
> > > Thanks for your idea! This is actually something like I was suggesting back
> > > at LSF/MM in Deer Valley. There were two downsides to this I remember
> > > people pointing out:
> > >
> > > 1) This cannot really work with __get_user_pages_fast(). You're not allowed
> > > to get necessary locks to insert new entry into the VMA tree in that
> > > context. So essentially we'd loose get_user_pages_fast() functionality.
> > >
> > > 2) The overhead e.g. for direct IO may be noticeable. You need to allocate
> > > the fake tracking VMA, get VMA interval tree lock, insert into the tree.
> > > Then on IO completion you need to queue work to unpin the pages again as you
> > > cannot remove the fake VMA directly from interrupt context where the IO is
> > > completed.
> > >
> > > You are right that the cost could be amortized if gup() is called for
> > > multiple consecutive pages however for small IOs there's no help...
> > >
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
> >
> >     [O3] DAX and the device block problems, ie with DAX the page map in
> >          userspace is the same as the block (persistent memory) and no
> >          filesystem nor block device understand page as block or pinned
> >          block.
> >
> > For [O3] i don't think any pin count would help in anyway. I believe
> > that the current long term GUP API that does not allow GUP of DAX is
> > the only sane solution for now.
> 
> No, that's not a sane solution, it's an emergency hack.

Then how do you want to solve it ? Knowing pin count does not help
you, at least i do not see how that would help and if it does then
my solution allow you to know pin count it is the difference between
real mapping and mapcount value.


> > The real fix would be to teach file-
> > system about DAX/pinned block so that a pinned block is not reuse
> > by filesystem.
> 
> We already have taught filesystems about pinned dax pages, see
> dax_layout_busy_page(). As much as possible I want to eliminate the
> concept of "dax pages" as a special case that gets sprinkled
> throughout the mm.
> 
> > For [O1] and [O2] i believe a solution with mapcount would work. So
> > no new struct, no fake vma, nothing like that. In GUP for file back
> > pages
> 
> With get_user_pages_fast() we don't know that we have a file-backed
> page, because we don't have a vma.

You do not need a vma to know that we have PageAnon() for that so my
solution is just about adding to core GUP page table walker:

    if (!PageAnon(page))
        atomic_inc(&page->mapcount);


Then in put_user_page() you add the opposite. In page_mkclean() you
count the number of real mapping and voil� ... you got an answer for
[O1]. You could use the same count real mapping to get the pin count
in other place that cares about it but i fails to see why the actual
pin count value would matter to any one.

Cheers,
J�r�me
