Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id F3E27900001
	for <linux-mm@kvack.org>; Sun,  1 May 2011 09:19:48 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 56ADA3EE0AE
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:19:46 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 40C4B45DE55
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:19:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 2789E45DD74
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:19:46 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1902E1DB803A
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:19:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id D4DE01DB802C
	for <linux-mm@kvack.org>; Sun,  1 May 2011 22:19:45 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [RFC 5/8] compaction: remove active list counting
In-Reply-To: <BANLkTi=bMm+iyO23+16FxK__V1-aM50zWQ@mail.gmail.com>
References: <20110428105027.GT4658@suse.de> <BANLkTi=bMm+iyO23+16FxK__V1-aM50zWQ@mail.gmail.com>
Message-Id: <20110501222117.75E8.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Sun,  1 May 2011 22:19:45 +0900 (JST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Christoph Lameter <cl@linux.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>

> On Thu, Apr 28, 2011 at 7:50 PM, Mel Gorman <mgorman@suse.de> wrote:
> > On Wed, Apr 27, 2011 at 01:25:22AM +0900, Minchan Kim wrote:
> >> acct_isolated of compaction uses page_lru_base_type which returns only
> >> base type of LRU list so it never returns LRU_ACTIVE_ANON or LRU_ACTIVE_FILE.
> >> So it's pointless to add lru[LRU_ACTIVE_[ANON|FILE]] to get sum.
> >>
> >> Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> >> Cc: Mel Gorman <mgorman@suse.de>
> >> Cc: Rik van Riel <riel@redhat.com>
> >> Cc: Andrea Arcangeli <aarcange@redhat.com>
> >> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> >
> > hmm, isolate_migratepages() is doing a linear scan of PFNs and is
> > calling __isolate_lru_page(..ISOLATE_BOTH..). Using page_lru_base_type
> > happens to work because we're only interested in the number of isolated
> > pages and your patch still covers that. Using page_lru might be more
> > accurate in terms of accountancy but does not seem necessary.
> 
> True.
> 
> >
> > Adding a comment explaining why we account for it as inactive and why
> > that's ok would be nice although I admit this is something I should have
> > done when acct_isolated() was introduced.
> 
> When Kame pointed out comment, I wanted to avoid unnecessary comment
> so decided changing it with page_lru although it adds overhead a
> little bit. But Hannes, you and maybe Kame don't want it. I don't mind
> adding comment.
> Okay. fix it in next version.

Or

	unsigned int count[2];

        list_for_each_entry(page, &cc->migratepages, lru) {
                count[page_is_file_cache(page)]++;
        }

is also clear to me.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
