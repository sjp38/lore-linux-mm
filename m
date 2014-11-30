Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id A61F46B0069
	for <linux-mm@kvack.org>; Sun, 30 Nov 2014 18:56:35 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id et14so9882368pad.17
        for <linux-mm@kvack.org>; Sun, 30 Nov 2014 15:56:35 -0800 (PST)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id sr2si26338608pab.139.2014.11.30.15.56.32
        for <linux-mm@kvack.org>;
        Sun, 30 Nov 2014 15:56:34 -0800 (PST)
Date: Mon, 1 Dec 2014 08:56:52 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v17 1/7] mm: support madvise(MADV_FREE)
Message-ID: <20141130235652.GA10333@bbox>
References: <1413799924-17946-1-git-send-email-minchan@kernel.org>
 <1413799924-17946-2-git-send-email-minchan@kernel.org>
 <20141127144725.GB19157@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <20141127144725.GB19157@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Michael Kerrisk <mtk.manpages@gmail.com>, linux-api@vger.kernel.org, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Jason Evans <je@fb.com>, zhangyanfei@cn.fujitsu.com, "Kirill A. Shutemov" <kirill@shutemov.name>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hello Michal,

On Thu, Nov 27, 2014 at 03:47:25PM +0100, Michal Hocko wrote:
> [Late but I didn't get to this soone - I hope this is still up-to-date
> version]
> 
> On Mon 20-10-14 19:11:58, Minchan Kim wrote:
> > Linux doesn't have an ability to free pages lazy while other OS
> > already have been supported that named by madvise(MADV_FREE).
> > 
> > The gain is clear that kernel can discard freed pages rather than
> > swapping out or OOM if memory pressure happens.
> > 
> > Without memory pressure, freed pages would be reused by userspace
> > without another additional overhead(ex, page fault + allocation
> > + zeroing).
> > 
> > How to work is following as.
> > 
> > When madvise syscall is called, VM clears dirty bit of ptes of
> > the range. If memory pressure happens, VM checks dirty bit of
> > page table and if it found still "clean", it means it's a
> > "lazyfree pages" so VM could discard the page instead of swapping out.
> > Once there was store operation for the page before VM peek a page
> > to reclaim, dirty bit is set so VM can swap out the page instead of
> > discarding.
> 
> Is there any patch for madvise man page? I guess the semantic will be
> same/similar to FreeBSD:
> http://www.freebsd.org/cgi/man.cgi?query=madvise&sektion=2

I postponed because I didn't know when we release the feature into mainline
but I should write down in man page ("MADV_FREE since Linux x.x.x").
However, early posting is not harmful.

Here it goes.
Most of content was copied from FreeBSD man page.
