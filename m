Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id BF5076B002D
	for <linux-mm@kvack.org>; Thu, 27 Oct 2011 19:19:38 -0400 (EDT)
Received: by wwf5 with SMTP id 5so4220767wwf.26
        for <linux-mm@kvack.org>; Thu, 27 Oct 2011 16:19:35 -0700 (PDT)
Date: Fri, 28 Oct 2011 08:19:28 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 4/5]thp: correct order in lru list for split huge page
Message-ID: <20111027231928.GB29407@barrios-laptop.redhat.com>
References: <1319511577.22361.140.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1319511577.22361.140.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, aarcange@redhat.com, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Tue, Oct 25, 2011 at 10:59:37AM +0800, Shaohua Li wrote:
> If a huge page is split, all the subpages should live in lru list adjacently
> because they should be taken as a whole.
> In page split, with current code:
> a. if huge page is in lru list, the order is: page, page+HPAGE_PMD_NR-1,
> page + HPAGE_PMD_NR-2, ..., page + 1(in lru page reclaim order)
> b. otherwise, the order is: page, ..other pages.., page + 1, page + 2, ...(in
> lru page reclaim order). page + 1 ... page + HPAGE_PMD_NR - 1 are in the lru
> reclaim tail.
> 
> In case a, the order is wrong. In case b, page is isolated (to be reclaimed),
> but other tail pages will not soon.
> 
> With below patch:
> in case a, the order is: page, page + 1, ... page + HPAGE_PMD_NR-1(in lru page
> reclaim order).
> in case b, the order is: page + 1, ... page + HPAGE_PMD_NR-1 (in lru page reclaim
> order). The tail pages are in the lru reclaim head.
> 
> Signed-off-by: Shaohua Li <shaohua.li@intel.com>

In case of a, it doesn't matter ordering of subpages.
As a huge page, age of sub pages are same.

In case of b, what a page is located in tail and other subpages are located in head
isn't critical problem.

Having said that, it's more consistent and simple patch.
So I like that. Nice catch, Shaohua!

Reviewed-by: Minchan Kim <minchan.kim@gmail.com>
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
