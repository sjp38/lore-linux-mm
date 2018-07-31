Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 79EFA6B000D
	for <linux-mm@kvack.org>; Tue, 31 Jul 2018 02:57:01 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w1-v6so10642247plq.8
        for <linux-mm@kvack.org>; Mon, 30 Jul 2018 23:57:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f8-v6sor3930545plr.96.2018.07.30.23.57.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 30 Jul 2018 23:57:00 -0700 (PDT)
Date: Tue, 31 Jul 2018 09:56:54 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: Linux 4.18-rc7
Message-ID: <20180731065654.duhzpg7yor7tckva@kshutemo-mobl1>
References: <CA+55aFxpFefwVdTGVML99PSFUqwpJXPx5LVCA3D=g2t2_QLNsA@mail.gmail.com>
 <CAMi1Hd0fJuAgP09_KkbjyGwszOXmxcPybKyBxP3U1y5JUqxxSw@mail.gmail.com>
 <20180730130134.yvn5tcmoavuxtwt5@kshutemo-mobl1>
 <CA+55aFwxwCPZs=h5wy-5PELwfBVuTETm+wuZB5cM2SDoXJi68g@mail.gmail.com>
 <alpine.LSU.2.11.1807301410470.4805@eggly.anvils>
 <CA+55aFx3qR1FW0T3na25NrwLZAvpOdUEUJa879CnaJT2ZPfhkg@mail.gmail.com>
 <alpine.LSU.2.11.1807301940460.5904@eggly.anvils>
 <CALAqxLU3cmu4g+HaB6A7=VhY-hW=d9e68EZ=_4JiwX_BigzjPQ@mail.gmail.com>
 <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMi1Hd0-2eDod4HiBifKCxY0cUUEW_A-yv7sZ7GRgL0whWQt+w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Amit Pundir <amit.pundir@linaro.org>
Cc: John Stultz <john.stultz@linaro.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, willy@infradead.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>, Oleg Nesterov <oleg@redhat.com>, aarcange@redhat.com, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm@kvack.org, lkml <linux-kernel@vger.kernel.org>, youling 257 <youling257@gmail.com>, Joel Fernandes <joelaf@google.com>, ccross@google.com

On Tue, Jul 31, 2018 at 12:10:06PM +0530, Amit Pundir wrote:
> On Tue, 31 Jul 2018 at 09:55, John Stultz <john.stultz@linaro.org> wrote:
> >
> > On Mon, Jul 30, 2018 at 8:26 PM, Hugh Dickins <hughd@google.com> wrote:
> > > On Mon, 30 Jul 2018, Linus Torvalds wrote:
> > >> On Mon, Jul 30, 2018 at 2:53 PM Hugh Dickins <hughd@google.com> wrote:
> > >> >
> > >> > I have no problem with reverting -rc7's vma_is_anonymous() series.
> > >>
> > >> I don't think we need to revert the whole series: I think the rest are
> > >> all fairly obvious cleanups, and shouldn't really have any semantic
> > >> changes.
> > >
> > > Okay.
> > >
> > >>
> > >> It's literally only that last patch in the series that then changes
> > >> that meaning of "vm_ops". And I don't really _mind_ that last step
> > >> either, but since we don't know exactly what it was that it broke, and
> > >> we're past rc7, I don't think we really have any option but the revert
> > >> it.
> > >
> > > It took me a long time to grasp what was happening, that that last
> > > patch bfd40eaff5ab was fixing. Not quite explained in the commit.
> > >
> > > I think it was that by mistakenly passing the vma_is_anonymous() test,
> > > create_huge_pmd() gave the MAP_PRIVATE kcov mapping a THP (instead of
> > > COWing pages from kcov); which the truncate then had to split, and in
> > > going to do so, again hit the mistaken vma_is_anonymous() test, BUG.
> > >
> > >>
> > >> And if we revert it, I think we need to just remove the
> > >> VM_BUG_ON_VMA() that it was supposed to fix. Because I do think that
> > >> it is quite likely that the real bug is that overzealous BUG_ON(),
> > >> since I can't see any reason why anonymous mappings should be special
> > >> there.
> > >
> > > Yes, that probably has to go: but it's not clear what state it leaves
> > > us in, with an anon THP being split by a truncate, without the expected
> > > locking; I don't remember offhand, probably a subtler bug than that BUG,
> > > which you may or may not consider an improvement.
> > >
> > > I fear that Kirill has not missed inserting a vma_set_anonymous() from
> > > somewhere that it should be, but rather that zygote is working with some
> > > special mapping which used to satisfy vma_is_anonymous(), faults supplying
> > > backing pages, but now comes out as !vma_is_anonymous(), so do_fault()
> > > finds !dummy_vm_ops.fault hence SIGBUS.
> >
> > I've been only casually following this thread (mostly just glad Amit
> > caught it and I could avoid having to bisect the issue in my own
> > Android testing), but this bit starting to shake a few old cobwebs
> > loose in my brain.
> >
> > I'm wondering if Zygote is utilizing ashmem here, and we're somehow
> > traversing ashmem purged memory, or due to some setup issue the
> > initial traverse isn't being zero-filled as expected?
> >
> > ashmem ranges are created using: shmem_file_setup() and shmem_zero_setup()
> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/staging/android/ashmem.c#n377
> >
> >
> > If we purge pages, it punches it out with:
> > vfs_fallocate(range->asma->file,
> >      FALLOC_FL_PUNCH_HOLE | FALLOC_FL_KEEP_SIZE,
> >      start, end - start);
> > here:
> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/staging/android/ashmem.c#n447
> >
> > But in ashmem_pin(), we don't do anything other then returning if we
> > purged any page in the range.
> > https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/drivers/staging/android/ashmem.c#n577
> >
> > And I believe the future assumption is the if we traverse those pages
> > they will be zero filled (if purged or even during the initial
> > traversal after mmap)
> >
> > Its been a long time, and I've not looked at the code in question but
> > it sounds from Hugh's comments above that we might instead get a
> > SIGBUS here.
> >
> > Looking more at the problematic patch..
> > Amit: Does adding something like (whitespace damaged, apologies):
> >
> > index a1a0025..1af6915 100644
> > --- a/drivers/staging/android/ashmem.c
> > +++ b/drivers/staging/android/ashmem.c
> > @@ -402,7 +402,8 @@ static int ashmem_mmap(struct file *file, struct
> > vm_area_struct *vma)
> >                         fput(asma->file);
> >                         goto out;
> >                 }
> > -       }
> > +       } else
> > +               vma_set_anonymous(vma);
> >
> >         if (vma->vm_file)
> >                 fput(vma->vm_file);
> >
> 
> This ashmem change ^^ worked too.

Okay. It makes sense.

But I'm not convinced that's a legitimate way to get an anonymous mapping.

I don't know how ashmem suppose to work. Looks like we get a shmem file
associated with the mapping, even if user asked for private mapping.

Shouldn't in this case vm_ops point to shmem_vm_ops?

Note, we have only one other case when MAP_PRIVATE on a file gets you an
anonymous mapping -- /dev/zero.

-- 
 Kirill A. Shutemov
