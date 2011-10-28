Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id D417D6B002F
	for <linux-mm@kvack.org>; Fri, 28 Oct 2011 03:21:35 -0400 (EDT)
Received: by ggnh4 with SMTP id h4so4436811ggn.14
        for <linux-mm@kvack.org>; Fri, 28 Oct 2011 00:21:33 -0700 (PDT)
Date: Fri, 28 Oct 2011 16:21:25 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [patch 4/5]thp: correct order in lru list for split huge page
Message-ID: <20111028072102.GA6268@barrios-laptop.redhat.com>
References: <1319511577.22361.140.camel@sli10-conroe>
 <20111027231928.GB29407@barrios-laptop.redhat.com>
 <1319778538.22361.152.camel@sli10-conroe>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1319778538.22361.152.camel@sli10-conroe>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shaohua.li@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "aarcange@redhat.com" <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, mel <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Fri, Oct 28, 2011 at 01:08:58PM +0800, Shaohua Li wrote:
> On Fri, 2011-10-28 at 07:19 +0800, Minchan Kim wrote:
> > On Tue, Oct 25, 2011 at 10:59:37AM +0800, Shaohua Li wrote:
> > > If a huge page is split, all the subpages should live in lru list adjacently
> > > because they should be taken as a whole.
> > > In page split, with current code:
> > > a. if huge page is in lru list, the order is: page, page+HPAGE_PMD_NR-1,
> > > page + HPAGE_PMD_NR-2, ..., page + 1(in lru page reclaim order)
> > > b. otherwise, the order is: page, ..other pages.., page + 1, page + 2, ...(in
> > > lru page reclaim order). page + 1 ... page + HPAGE_PMD_NR - 1 are in the lru
> > > reclaim tail.
> > > 
> > > In case a, the order is wrong. In case b, page is isolated (to be reclaimed),
> > > but other tail pages will not soon.
> > > 
> > > With below patch:
> > > in case a, the order is: page, page + 1, ... page + HPAGE_PMD_NR-1(in lru page
> > > reclaim order).
> > > in case b, the order is: page + 1, ... page + HPAGE_PMD_NR-1 (in lru page reclaim
> > > order). The tail pages are in the lru reclaim head.
> > > 
> > > Signed-off-by: Shaohua Li <shaohua.li@intel.com>
> > 
> > In case of a, it doesn't matter ordering of subpages.
> > As a huge page, age of sub pages are same.
> It does matter. Hugepage is split first and then reclaim. if page, page
> +HPAGE_PMD_NR-1 is reclaimed, you can't get an order-1 page. but if
> page, page+1 is reclaimed, you can.

Right you are. I didn't catch up it.
It would be better to add it in description.
It's most important part in this patch.

Thanks.

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
