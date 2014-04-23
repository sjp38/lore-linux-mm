Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f46.google.com (mail-pb0-f46.google.com [209.85.160.46])
	by kanga.kvack.org (Postfix) with ESMTP id E51D16B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 14:13:10 -0400 (EDT)
Received: by mail-pb0-f46.google.com with SMTP id rq2so1028806pbb.33
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 11:13:10 -0700 (PDT)
Received: from mail-pb0-x235.google.com (mail-pb0-x235.google.com [2607:f8b0:400e:c01::235])
        by mx.google.com with ESMTPS id px1si1059081pbb.499.2014.04.23.11.13.08
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 11:13:08 -0700 (PDT)
Received: by mail-pb0-f53.google.com with SMTP id rp16so1027319pbb.40
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 11:13:08 -0700 (PDT)
Date: Wed, 23 Apr 2014 11:11:53 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: 3.15rc2 hanging processes on exit.
In-Reply-To: <CA+55aFziPHmSP5yjxDP6h_hRY-H2VgWZKsqC7w8+B9d9wXqn6Q@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1404231057470.2678@eggly.anvils>
References: <20140422180308.GA19038@redhat.com> <CA+55aFxjADAB80AV6qK-b4QPzP7fgog_EyH-7dSpWVgzpZmL8Q@mail.gmail.com> <alpine.LSU.2.11.1404221303060.6220@eggly.anvils> <20140423144901.GA24220@redhat.com>
 <CA+55aFziPHmSP5yjxDP6h_hRY-H2VgWZKsqC7w8+B9d9wXqn6Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Dave Jones <davej@redhat.com>, Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>

On Wed, 23 Apr 2014, Linus Torvalds wrote:
> On Wed, Apr 23, 2014 at 7:49 AM, Dave Jones <davej@redhat.com> wrote:
> >
> > So for reasons I can't figure out, I've not been able to hit it on 3.14

Thanks for trying.  Not the reassuring answer that I was hoping for,
so I'd better give it a little more thought, to see if we have some
reason in 3.15-rc why it should now appear.  Not worth spending too
much effort on, though: Linus's fix looked good whatever.

> > The only 'interesting' thing I've hit in overnight testing is this, which
> > I'm not sure if I've also seen in my .15rc testing, but it doesn't look
> > familiar to me.  (Though the vm oopses I've seen the last few months
> > are starting to all blur together in my memory)
> >
> >
> > kernel BUG at mm/mlock.c:82!
> 
> That's
> 
>   mlock_vma_page:
>     BUG_ON(!PageLocked(page));
> 
> which is odd, because:
> 
> > Call Trace:
> >  [<ffffffffbe196612>] try_to_unmap_nonlinear+0x2a2/0x530
> >  [<ffffffffbe1972a7>] rmap_walk+0x157/0x320
> >  [<ffffffffbe1976e3>] try_to_unmap+0x93/0xf0
> >  [<ffffffffbe1bb8f6>] migrate_pages+0x3b6/0x7b0
> 
> All the calls to "try_to_unmap()" in mm/migrate.c are preceded by the pattern
> 
>         if (!trylock_page(page)) {
>                  ....
>                 lock_page(page);
>         }

Yes, that's true of the mm/migrate.c end, but the nonlinear
try_to_unmap_cluster() (Being unable to point directly to the desired
page) does this thing of unmapping a cluster of (likely unrelated) pages,
in the hope that if it keeps getting called repeatedly, it will sooner or
later have unmapped everything required.

> 
> where there are just a few "goto out" style cases for the "ok, we're
> not going to wait for this page lock" in there.
> 
> Very odd.  Does anybody see anything I missed?

Easily explained (correct me if I'm wrong): Dave is reporting this from
his testing of 3.14, but Linus is looking at his 3.15-rc git tree, which
now contains

commit 57e68e9cd65b4b8eb4045a1e0d0746458502554c
Author: Vlastimil Babka <vbabka@suse.cz>
Date:   Mon Apr 7 15:37:50 2014 -0700
    mm: try_to_unmap_cluster() should lock_page() before mlocking

precisely to fix this (long-standing but long-unnoticed) issue,
which Sasha reported a couple of months ago.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
