Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f200.google.com (mail-oi1-f200.google.com [209.85.167.200])
	by kanga.kvack.org (Postfix) with ESMTP id 076E18E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 12:49:51 -0500 (EST)
Received: by mail-oi1-f200.google.com with SMTP id p131so9859285oig.10
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 09:49:51 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r131sor9847266oib.14.2018.12.12.09.49.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 09:49:49 -0800 (PST)
MIME-Version: 1.0
References: <20181205011519.GV10377@bombadil.infradead.org>
 <20181205014441.GA3045@redhat.com> <59ca5c4b-fd5b-1fc6-f891-c7986d91908e@nvidia.com>
 <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com> <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com> <20181208022445.GA7024@redhat.com>
 <20181210102846.GC29289@quack2.suse.cz> <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com> <20181212170220.GA5037@redhat.com>
In-Reply-To: <20181212170220.GA5037@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 12 Dec 2018 09:49:36 -0800
Message-ID: <CAPcyv4hnQ-4DKwtrJjy9euvJvRf_sDO+1hbxuFCQv5m9qd9Drg@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>
Cc: Jan Kara <jack@suse.cz>, John Hubbard <jhubbard@nvidia.com>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Dec 12, 2018 at 9:02 AM Jerome Glisse <jglisse@redhat.com> wrote:
>
> On Wed, Dec 12, 2018 at 08:27:35AM -0800, Dan Williams wrote:
> > On Wed, Dec 12, 2018 at 7:03 AM Jerome Glisse <jglisse@redhat.com> wrot=
e:
> > >
> > > On Mon, Dec 10, 2018 at 11:28:46AM +0100, Jan Kara wrote:
> > > > On Fri 07-12-18 21:24:46, Jerome Glisse wrote:
> > > > > Another crazy idea, why not treating GUP as another mapping of th=
e page
> > > > > and caller of GUP would have to provide either a fake anon_vma st=
ruct or
> > > > > a fake vma struct (or both for PRIVATE mapping of a file where yo=
u can
> > > > > have a mix of both private and file page thus only if it is a rea=
d only
> > > > > GUP) that would get added to the list of existing mapping.
> > > > >
> > > > > So the flow would be:
> > > > >     somefunction_thatuse_gup()
> > > > >     {
> > > > >         ...
> > > > >         GUP(_fast)(vma, ..., fake_anon, fake_vma);
> > > > >         ...
> > > > >     }
> > > > >
> > > > >     GUP(vma, ..., fake_anon, fake_vma)
> > > > >     {
> > > > >         if (vma->flags =3D=3D ANON) {
> > > > >             // Add the fake anon vma to the anon vma chain as a c=
hild
> > > > >             // of current vma
> > > > >         } else {
> > > > >             // Add the fake vma to the mapping tree
> > > > >         }
> > > > >
> > > > >         // The existing GUP except that now it inc mapcount and n=
ot
> > > > >         // refcount
> > > > >         GUP_old(..., &nanonymous, &nfiles);
> > > > >
> > > > >         atomic_add(&fake_anon->refcount, nanonymous);
> > > > >         atomic_add(&fake_vma->refcount, nfiles);
> > > > >
> > > > >         return nanonymous + nfiles;
> > > > >     }
> > > >
> > > > Thanks for your idea! This is actually something like I was suggest=
ing back
> > > > at LSF/MM in Deer Valley. There were two downsides to this I rememb=
er
> > > > people pointing out:
> > > >
> > > > 1) This cannot really work with __get_user_pages_fast(). You're not=
 allowed
> > > > to get necessary locks to insert new entry into the VMA tree in tha=
t
> > > > context. So essentially we'd loose get_user_pages_fast() functional=
ity.
> > > >
> > > > 2) The overhead e.g. for direct IO may be noticeable. You need to a=
llocate
> > > > the fake tracking VMA, get VMA interval tree lock, insert into the =
tree.
> > > > Then on IO completion you need to queue work to unpin the pages aga=
in as you
> > > > cannot remove the fake VMA directly from interrupt context where th=
e IO is
> > > > completed.
> > > >
> > > > You are right that the cost could be amortized if gup() is called f=
or
> > > > multiple consecutive pages however for small IOs there's no help...
> > > >
> > > > So this approach doesn't look like a win to me over using counter i=
n struct
> > > > page and I'd rather try looking into squeezing HMM public page usag=
e of
> > > > struct page so that we can fit that gup counter there as well. I kn=
ow that
> > > > it may be easier said than done...
> > >
> > > So i want back to the drawing board and first i would like to ascerta=
in
> > > that we all agree on what the objectives are:
> > >
> > >     [O1] Avoid write back from a page still being written by either a
> > >          device or some direct I/O or any other existing user of GUP.
> > >          This would avoid possible file system corruption.
> > >
> > >     [O2] Avoid crash when set_page_dirty() is call on a page that is
> > >          considered clean by core mm (buffer head have been remove an=
d
> > >          with some file system this turns into an ugly mess).
> > >
> > >     [O3] DAX and the device block problems, ie with DAX the page map =
in
> > >          userspace is the same as the block (persistent memory) and n=
o
> > >          filesystem nor block device understand page as block or pinn=
ed
> > >          block.
> > >
> > > For [O3] i don't think any pin count would help in anyway. I believe
> > > that the current long term GUP API that does not allow GUP of DAX is
> > > the only sane solution for now.
> >
> > No, that's not a sane solution, it's an emergency hack.
>
> Then how do you want to solve it ? Knowing pin count does not help
> you, at least i do not see how that would help and if it does then
> my solution allow you to know pin count it is the difference between
> real mapping and mapcount value.

True, pin count doesn't help, and indefinite waits are intolerable, so
I think we need to make "long term" GUP revokable, but otherwise
hopefully use the put_user_page() scheme to replace the use of the pin
count for dax_layout_busy_page().

> > > The real fix would be to teach file-
> > > system about DAX/pinned block so that a pinned block is not reuse
> > > by filesystem.
> >
> > We already have taught filesystems about pinned dax pages, see
> > dax_layout_busy_page(). As much as possible I want to eliminate the
> > concept of "dax pages" as a special case that gets sprinkled
> > throughout the mm.
> >
> > > For [O1] and [O2] i believe a solution with mapcount would work. So
> > > no new struct, no fake vma, nothing like that. In GUP for file back
> > > pages
> >
> > With get_user_pages_fast() we don't know that we have a file-backed
> > page, because we don't have a vma.
>
> You do not need a vma to know that we have PageAnon() for that so my
> solution is just about adding to core GUP page table walker:
>
>     if (!PageAnon(page))
>         atomic_inc(&page->mapcount);

Ah, ok, would need to add proper mapcount manipulation for dax and
audit that nothing makes page-cache assumptions based on a non-zero
mapcount.

> Then in put_user_page() you add the opposite. In page_mkclean() you
> count the number of real mapping and voil=C3=A0 ... you got an answer for
> [O1]. You could use the same count real mapping to get the pin count
> in other place that cares about it but i fails to see why the actual
> pin count value would matter to any one.

Sounds like a could work... devil is in the details.
