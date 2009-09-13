Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 990986B004F
	for <linux-mm@kvack.org>; Sun, 13 Sep 2009 19:05:11 -0400 (EDT)
Received: by ywh28 with SMTP id 28so3869502ywh.15
        for <linux-mm@kvack.org>; Sun, 13 Sep 2009 16:05:12 -0700 (PDT)
Date: Mon, 14 Sep 2009 08:05:01 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH 4/8] mm: FOLL_DUMP replace FOLL_ANON
Message-Id: <20090914080501.bfe32d4b.minchan.kim@barrios-desktop>
In-Reply-To: <Pine.LNX.4.64.0909131636540.22865@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
	<Pine.LNX.4.64.0909072233240.15430@sister.anvils>
	<28c262360909090916w12d700b3w7fa8a970f3aba3af@mail.gmail.com>
	<Pine.LNX.4.64.0909131636540.22865@sister.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Jeff Chua <jeff.chua.linux@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi, Hugh.

On Sun, 13 Sep 2009 16:46:12 +0100 (BST)
Hugh Dickins <hugh.dickins@tiscali.co.uk> wrote:

> On Thu, 10 Sep 2009, Minchan Kim wrote:
> > > A  A  A  A /*
> > > A  A  A  A  * When core dumping an enormous anonymous area that nobody
> > > - A  A  A  A * has touched so far, we don't want to allocate page tables.
> > > + A  A  A  A * has touched so far, we don't want to allocate unnecessary pages or
> > > + A  A  A  A * page tables. A Return error instead of NULL to skip handle_mm_fault,
> > > + A  A  A  A * then get_dump_page() will return NULL to leave a hole in the dump.
> > > + A  A  A  A * But we can only make this optimization where a hole would surely
> > > + A  A  A  A * be zero-filled if handle_mm_fault() actually did handle it.
> > > A  A  A  A  */
> > > - A  A  A  if (flags & FOLL_ANON) {
> > > - A  A  A  A  A  A  A  page = ZERO_PAGE(0);
> > > - A  A  A  A  A  A  A  if (flags & FOLL_GET)
> > > - A  A  A  A  A  A  A  A  A  A  A  get_page(page);
> > > - A  A  A  A  A  A  A  BUG_ON(flags & FOLL_WRITE);
> > > - A  A  A  }
> > > + A  A  A  if ((flags & FOLL_DUMP) &&
> > > + A  A  A  A  A  (!vma->vm_ops || !vma->vm_ops->fault))
> > 
> > How about adding comment about zero page use?
> 
> What kind of comment did you have in mind?
> We used to use ZERO_PAGE there, but with this patch we're not using it.
> I thought the comment above describes what we're doing well enough.
> 
> I may have kept too quiet about ZERO_PAGEs, knowing that a later patch
> was going to change the story; but I don't see what needs saying here.

I meant following as line. 

> > > + A  A  A  if ((flags & FOLL_DUMP) &&
> > > + A  A  A  A  A  (!vma->vm_ops || !vma->vm_ops->fault))

Why do we care about anonymous vma and FOLL_DUMP?
Yeah, comment above mentioned page tables. 
But i think someone who first look at can't think it easily. 

If you think the comment is enough, I don't mind it. 

> Hugh


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
