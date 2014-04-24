Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f41.google.com (mail-pb0-f41.google.com [209.85.160.41])
	by kanga.kvack.org (Postfix) with ESMTP id 96C466B0035
	for <linux-mm@kvack.org>; Wed, 23 Apr 2014 23:10:02 -0400 (EDT)
Received: by mail-pb0-f41.google.com with SMTP id rr13so1467646pbb.0
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 20:10:02 -0700 (PDT)
Received: from mail-pd0-x230.google.com (mail-pd0-x230.google.com [2607:f8b0:400e:c02::230])
        by mx.google.com with ESMTPS id ud10si1747186pbc.503.2014.04.23.20.10.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 23 Apr 2014 20:10:01 -0700 (PDT)
Received: by mail-pd0-f176.google.com with SMTP id r10so1443811pdi.21
        for <linux-mm@kvack.org>; Wed, 23 Apr 2014 20:10:01 -0700 (PDT)
Date: Wed, 23 Apr 2014 20:08:46 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] mm: rmap: don't try to add an unevictable page to lru
 list
In-Reply-To: <CAA_GA1fj=OXeK44NYPt205TqB8OKxOeevOpDorMoytZJebXA=Q@mail.gmail.com>
Message-ID: <alpine.LSU.2.11.1404231957060.975@eggly.anvils>
References: <1396235259-2394-1-git-send-email-bob.liu@oracle.com> <alpine.LSU.2.11.1404042358030.12542@eggly.anvils> <CAA_GA1fj=OXeK44NYPt205TqB8OKxOeevOpDorMoytZJebXA=Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Bob Liu <lliubbo@gmail.com>, Mel Gorman <mgorman@suse.de>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Bob Liu <bob.liu@oracle.com>

On Tue, 8 Apr 2014, Bob Liu wrote:
> On Sat, Apr 5, 2014 at 5:04 PM, Hugh Dickins <hughd@google.com> wrote:
> > On Mon, 31 Mar 2014, Bob Liu wrote:
> >
> >> VM_BUG_ON_PAGE(PageActive(page) && PageUnevictable(page), page) in
> >> lru_cache_add() was triggered during migrate_misplaced_transhuge_page.
> >>...
> >> From vmscan.c:
> >>  * Reasons page might not be evictable:
> >>  * (1) page's mapping marked unevictable
> >>  * (2) page is part of an mlocked VMA
> >>
> >> But page_add_new_anon_rmap() only checks reason (2), we may hit this
> >> VM_BUG_ON_PAGE() if PageUnevictable(old_page) was originally set by reason (1).
> >
> > But (1) always reports evictable on an anon page, doesn't it?
> >
> >>
> >> Reported-by: Sasha Levin <sasha.levin@oracle.com>
> >> Signed-off-by: Bob Liu <bob.liu@oracle.com>
> >
> > I can't quite assert NAK, but I suspect this is not the proper fix.
...
> >
> > (Yet now I'm wavering again: if down_write mmap_sem is needed to
> > munlock() the vma, and migrate_misplaced_transhuge_page() is only
> > migrating a singly-mapped THP under down_read mmap_sem, how could
> > VM_LOCKED have changed during the migration?  I've lost sight of
> 
> I think you are right, I'll do more investigation about why this BUG
> was triggered.

Andrew, if Bob agrees, please drop

mm-rmap-dont-try-to-add-an-unevictable-page-to-lru-list.patch

from mmotm now.  We have not heard any such report yet on 3.15-rc,
and neither Bob nor I have yet come up with a convincing explanation
for how it came about.  It's tempting to suppose it was a side-effect
of something temporarily wrong on a 3.14-next, and now okay; but we'll
learn more quickly whether that's so if mmotm stops working around it.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
