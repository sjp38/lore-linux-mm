Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 855126B0030
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 03:30:32 -0400 (EDT)
Received: by ywa17 with SMTP id 17so4457493ywa.14
        for <linux-mm@kvack.org>; Fri, 28 Oct 2011 00:30:30 -0700 (PDT)
Date: Fri, 28 Oct 2011 16:30:26 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 5/5]thp: split huge page if head page is isolated
Message-ID: <20111028073026.GB6268@barrios-laptop.redhat.com>
References: <1319511580.22361.141.camel@sli10-conroe>
 <20111027233407.GC29407@barrios-laptop.redhat.com>
 <1319778715.22361.155.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1319778715.22361.155.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "aarcange@redhat.com" <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Fri, Oct 28, 2011 at 01:11:55PM +0800, Shaohua Li wrote:
> On Fri, 2011-10-28 at 07:34 +0800, Minchan Kim wrote:
> > On Tue, Oct 25, 2011 at 10:59:40AM +0800, Shaohua Li wrote:
> > > With current logic, if page reclaim finds a huge page, it will just reclaim
> > > the head page and leave tail pages reclaimed later. Let's take an example,
> > > lru list has page A and B, page A is huge page:
> > > 1. page A is isolated
> > > 2. page B is isolated
> > > 3. shrink_page_list() adds page A to swap page cache. so page A is split.
> > > page A+1, page A+2, ... are added to lru list.
> > > 4. shrink_page_list() adds page B to swap page cache.
> > > 5. page A and B is written out and reclaimed.
> > > 6. page A+1, A+2 ... is isolated and reclaimed later.
> > > So the reclaim order is A, B, ...(maybe other pages), A+1, A+2 ...
> > 
> > I don't see your code yet but have a question.
> > You mitigate this problem by 4/5 which could add subpages into lru tail
> > so subpages would reclaim next interation of reclaim.
> > 
> > What do we need 5/5?
> > Do I miss something?
> Both patches are required. without this patch, current page reclaim will
> only reclaim the first page of a huge page, because the hugepage isn't
> split yet. The hugepage is split when the first page is being written to
> swap, which is too later and page reclaim might already isolated a lot
> of pages.

When split happens, subpages would be located in tail of LRU by your 4/5.
(Assume tail of LRU is old age).
In addtion, isolation happens 32 page chunk so the subpages would be isolated
and reclaimed in next iteration. I think 32 pages are not too many.

What do you think about it?
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
