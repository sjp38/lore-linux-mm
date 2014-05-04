Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0347E6B0036
	for <linux-mm@kvack.org>; Sun,  4 May 2014 16:39:01 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so8309177pad.1
        for <linux-mm@kvack.org>; Sun, 04 May 2014 13:39:01 -0700 (PDT)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id qd9si6376045pac.228.2014.05.04.13.39.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 04 May 2014 13:39:01 -0700 (PDT)
Received: by mail-pa0-f44.google.com with SMTP id ld10so3136467pab.3
        for <linux-mm@kvack.org>; Sun, 04 May 2014 13:39:00 -0700 (PDT)
Date: Sun, 4 May 2014 13:37:47 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [3.15rc1] BUG at mm/filemap.c:202!
In-Reply-To: <CAFLxGvxPV9+BgP=CVEp4kLbedOYBEui9uYddNTDix=ENrrusoQ@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1405041311130.3230@eggly.anvils>
References: <20140415190936.GA24654@redhat.com> <alpine.LSU.2.11.1404161239320.6778@eggly.anvils> <CAFLxGvxZxWf6nzJ5cXM--b02axz9u8UL_MTUyo3WgLPvbpCFAg@mail.gmail.com> <CAFLxGvxPV9+BgP=CVEp4kLbedOYBEui9uYddNTDix=ENrrusoQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Richard Weinberger <richard.weinberger@gmail.com>
Cc: Dave Jones <davej@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Sasha Levin <sasha.levin@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Sat, 3 May 2014, Richard Weinberger wrote:
> On Thu, May 1, 2014 at 6:20 PM, Richard Weinberger
> <richard.weinberger@gmail.com> wrote:
> > On Wed, Apr 16, 2014 at 10:40 PM, Hugh Dickins <hughd@google.com> wrote:
> >>
> >> Help!
> >
> > Using a trinity as of today I'm able to trigger this bug on UML within seconds.
> > If you want me to test patch, I can help.
> >
> > I'm also observing one strange fact, I can trigger this on any kernel version.
> > So far I've managed UML to crash on 3.0 to 3.15-rc...
> 
> After digging deeper into UML's mmu and tlb code I've found issues and
> fixed them.
> 
> But I'm still facing this issue. Although triggering the BUG_ON() is
> not so easy as before
> I can trigger "BUG: Bad rss-counter ..." very easily.
> Now the interesting fact, with my UML mmu and flb fixes applied it
> happens only on kernels >= 3.14.
> If it helps I can try to bisect it.

Thanks a lot for trying, but from other mail it looks like your
bisection got blown off course ;(

I expect for the moment you'll want to concentrate on getting UML's
TLB flushing back on track with 3.15-rc.

Once you have that sorted out, I wouldn't be surprised if the same
changes turn out to fix your "Bad rss-counter"s on 3.14 also.

If not, and if you do still have time to bisect back between 3.13 and
3.14 to find where things went wrong, it will be a bit tedious in that
you would probably have to apply

887843961c4b "mm: fix bad rss-counter if remap_file_pages raced migration"
7e09e738afd2 "mm: fix swapops.h:131 bug if remap_file_pages raced migration"

at each stage, to avoid those now-known bugs which trinity became rather
good at triggering.  Perhaps other fixes needed, those the two I remember.

Please don't worry if you don't have time for this, that's understandable.

Or is UML so contrary that one of those commits actually brings on the
problem for you?

As to the BUG_ON(page_mapped(page)), I still have nothing to suggest.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
