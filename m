Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4FFE48E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 05:58:28 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id i68-v6so899316pfb.9
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 02:58:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id t2-v6si17722984pge.64.2018.09.18.02.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Sep 2018 02:58:26 -0700 (PDT)
Date: Tue, 18 Sep 2018 11:58:22 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: [BUG] mm: direct I/O (using GUP) can write to COW anonymous pages
Message-ID: <20180918095822.GH10257@quack2.suse.cz>
References: <CAG48ez17Of=dnymzm8GAN_CNG1okMg1KTeMtBQhXGP2dyB5uJw@mail.gmail.com>
 <alpine.LSU.2.11.1809171628190.2225@eggly.anvils>
 <CAG48ez1hk5evqQpyvticPzLFOcESfo2NoWnqrLZk6N4PXwdsOw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAG48ez1hk5evqQpyvticPzLFOcESfo2NoWnqrLZk6N4PXwdsOw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: Hugh Dickins <hughd@google.com>, Dan Williams <dan.j.williams@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, sqazi@google.com, "Michael S. Tsirkin" <mst@redhat.com>, jack@suse.cz, kernel list <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Miklos Szeredi <miklos@szeredi.hu>, john.hubbard@gmail.com

On Tue 18-09-18 02:35:43, Jann Horn wrote:
> On Tue, Sep 18, 2018 at 2:05 AM Hugh Dickins <hughd@google.com> wrote:

Thanks for CC Hugh.

> > On Mon, 17 Sep 2018, Jann Horn wrote:
> >
> > > [I'm not sure who the best people to ask about this are, I hope the
> > > recipient list resembles something reasonable...]
> > >
> > > I have noticed that the dup_mmap() logic on fork() doesn't handle
> > > pages with active direct I/O properly: dup_mmap() seems to assume that
> > > making the PTE referencing a page readonly will always prevent future
> > > writes to the page, but if the kernel has acquired a direct reference
> > > to the page before (e.g. via get_user_pages_fast()), writes can still
> > > happen that way.
> > >
> > > The worst-case effect of this - as far as I can tell - is that when a
> > > multithreaded process forks while one thread is in the middle of
> > > sys_read() on a file that uses direct I/O with get_user_pages_fast(),
> > > the read data can become visible in the child while the parent's
> > > buffer stays uninitialized if the parent writes to a relevant page
> > > post-fork before either the I/O completes or the child writes to it.
> >
> > Yes: you're understandably more worried by the one seeing the other's
> > data;
> 
> Actually, I was mostly just trying to find a scenario in which the
> parent doesn't get the data it's asking for, and this is the simplest
> I could come up with. :)
> 
> I was also vaguely worried about whether some other part of the mm
> subsystem might assume that COW pages are immutable, but I haven't
> found anything like that so far, so that might've been unwarranted
> paranoia.

It's actually warranted paranoia. There are situations where filesystems
don't expect *shared file* page to be written when all pages tables are
write-protected - you can have a look at https://lwn.net/Articles/753027/
for a discussion from LSF/MM on this.  And as I've learned from Nick Piggin
people were aware of this problem over 10 years ago -
https://lkml.org/lkml/2018/7/9/217. Just nobody put enough effort into
fixing this.

> > we've tended in the past to be more worried about the one getting
> > corruption, and the other not seeing the data it asked for (and usually
> > in the context of RDMA, rather than filesystem direct I/O).
> >
> > I've added some Cc's: I might be misremembering, but I think both
> > Andrea and Konstantin have offered approaches to this in the past,
> > and I believe Salman is taking a look at it currently.
> >
> > But my own interest ended when Michael added MADV_DONTFORK: beyond
> > that, we've rated it a "Patient: It hurts when I do this. Doctor:
> > Don't do that then" - more complexity and overhead to solve, than
> > we have had appetite to get into.
> 
> Makes sense, I guess.
> 
> I wonder whether there's a concise way to express this in the fork.2
> manpage, or something like that. Maybe I'll take a stab at writing
> something. The biggest issue I see with documenting this edgecase is
> that, as an application developer, if you don't know whether some file
> might be coming from a FUSE filesystem that has opted out of using the
> disk cache, the "don't do that" essentially becomes "don't read() into
> heap buffers while fork()ing in another thread", since with FUSE,
> direct I/O can happen even if you don't open files as O_DIRECT as long
> as the filesystem requests direct I/O, and get_user_pages_fast() will
> AFAIU be used for non-page-aligned buffers, meaning that an adjacent
> heap memory access could trigger CoW page duplication. But then, FUSE
> filesystems that opt out of the disk cache are probably so rare that
> it's not a concern in practice...

So at least for shared file mappings we do need to fix this issue as it's
currently userspace triggerable Oops if you try hard enough. And with RDMA
you don't even have to try that hard. Properly dealing with private
mappings should not be that hard once the infrastructure is there I hope
but I didn't seriously look into that. I've added Miklos and John to CC as
they are interested as well. John was working on fixing this problem -
https://lkml.org/lkml/2018/7/9/158 - but I didn't hear from him for quite a
while so I'm not sure whether it died off or what's the current situation.

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
