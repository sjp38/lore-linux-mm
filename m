Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CF0066B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 19:30:18 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id x2-v6so14171153plv.0
        for <linux-mm@kvack.org>; Thu, 31 May 2018 16:30:18 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o70-v6sor13530653pfi.118.2018.05.31.16.30.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 31 May 2018 16:30:17 -0700 (PDT)
Date: Thu, 31 May 2018 16:30:08 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: fix kswap excessive pressure after wrong condition
 transfer
In-Reply-To: <CABA=pqc8tuLGc4OTGymj5wN3ypisMM60mgOLpy2OXxmfteoJFg@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1805311552390.13499@eggly.anvils>
References: <20180531193420.26087-1-ikalvachev@gmail.com> <CAHH2K0afVpVyMw+_J48pg9ngj9oovBEPBFd3kfCcCfyV7xxF0w@mail.gmail.com> <CABA=pqc8tuLGc4OTGymj5wN3ypisMM60mgOLpy2OXxmfteoJFg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ivan Kalvachev <ikalvachev@gmail.com>
Cc: Greg Thelen <gthelen@google.com>, David Rientjes <rientjes@google.com>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>

On Fri, 1 Jun 2018, Ivan Kalvachev wrote:
> On 5/31/18, Greg Thelen <gthelen@google.com> wrote:
> > On Thu, May 31, 2018 at 12:34 PM Ivan Kalvachev <ikalvachev@gmail.com>
> > wrote:
> >>
> >> Fixes commit 69d763fc6d3aee787a3e8c8c35092b4f4960fa5d
> >> (mm: pin address_space before dereferencing it while isolating an LRU
> >> page)
> >>
> >> working code:
> >>
> >>     mapping = page_mapping(page);
> >>     if (mapping && !mapping->a_ops->migratepage)
> >>         return ret;
> >>
> >> buggy code:
> >>
> >>     if (!trylock_page(page))
> >>         return ret;
> >>
> >>     mapping = page_mapping(page);
> >>     migrate_dirty = mapping && mapping->a_ops->migratepage;
> >>     unlock_page(page);
> >>     if (!migrate_dirty)
> >>         return ret;
> >>
> >> The problem is that !(a && b) = (!a || !b) while the old code was (a &&
> >> !b).
> >> The commit message of the buggy commit explains the need for
> >> locking/unlocking
> >> around the check but does not give any reason for the change of the
> >> condition.
> >> It seems to be an unintended change.
> >>
> >> The result of that change is noticeable under swap pressure.
> >> Big memory consumers like browsers would have a lot of pages swapped out,
> >> even pages that are been used actively, causing the process to repeatedly
> >> block for second or longer. At the same time there would be gigabytes of
> >> unused free memory (sometimes half of the total RAM).
> >> The buffers/cache would also be at minimum size.
> >>
> >> Fixes: 69d763fc6d3a ("mm: pin address_space before dereferencing it while
> >> isolating an LRU page")
> >> Signed-off-by: Ivan Kalvachev <ikalvachev@gmail.com>
> >> ---
> >>  mm/vmscan.c | 4 ++--
> >>  1 file changed, 2 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/mm/vmscan.c b/mm/vmscan.c
> >> index 9b697323a88c..83df26078d13 100644
> >> --- a/mm/vmscan.c
> >> +++ b/mm/vmscan.c
> >> @@ -1418,9 +1418,9 @@ int __isolate_lru_page(struct page *page,
> >> isolate_mode_t mode)
> >>                                 return ret;
> >>
> >>                         mapping = page_mapping(page);
> >> -                       migrate_dirty = mapping &&
> >> mapping->a_ops->migratepage;
> >> +                       migrate_dirty = mapping &&
> >> !mapping->a_ops->migratepage;
> >>                         unlock_page(page);
> >> -                       if (!migrate_dirty)
> >> +                       if (migrate_dirty)
> >>                                 return ret;
> >>                 }
> >>         }
> >> --
> >> 2.17.1
> >
> > This looks like yesterday's https://lkml.org/lkml/2018/5/30/1158
> >
> 
> Yes, it seems to be the same problem.
> It also have better technical description.

Well, your paragraph above on "Big memory consumers" gives a much
better user viewpoint, and a more urgent case for the patch to go in,
to stable if it does not make 4.17.0.

But I am surprised: the change is in a block of code only used in
one of the modes of compaction (not in  reclaim itself), and I thought
it was a mode which gives up quite easily, rather than visibly blocking. 

So I wonder if there's another issue to be improved here,
and the mistreatment of the ex-swap pages just exposed it somehow.
Cc'ing Vlastimil and David in case it triggers any insight from them.

> 
> Such let down.
> It took me so much time to bisect the issue...

Thank you for all your work on it, odd how we found it at the same
time: I was just porting Mel's patch into another tree, had to make
a change near there, and suddenly noticed that the test was wrong.

Hugh

> 
> Well, I hope that the fix will get into 4.17 release in time.
