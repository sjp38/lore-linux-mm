Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 311656B0012
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:22:18 -0400 (EDT)
Date: Fri, 6 May 2011 20:21:51 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH]mm/compation.c: checking page in lru twice
Message-ID: <20110506182151.GG6330@random.random>
References: <1304681575.15473.4.camel@figo-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1304681575.15473.4.camel@figo-desktop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Figo.zhang" <figo1802@gmail.com>
Cc: lkml <linux-kernel@vger.kernel.org>, mel@csn.ul.ie, "linux-mm@kvack.org" <linux-mm@kvack.org>, kamezawa.hiroyu@jp.fujisu.com, minchan.kim@gmail.com, Andrew Morton <akpm@osdl.org>

On Fri, May 06, 2011 at 07:32:46PM +0800, Figo.zhang wrote:
> 
> in isolate_migratepages() have check page in LRU twice, the next one
> at _isolate_lru_page(). 

hugetlbfs or any other compound page won't have PageLRU set and they
may go away from under us leading to compound_order not being reliable
if we remove the PageLRU check before compound_order. So we need to
verify the page is in LRU before running compound_order safely. And if
we hold the lru_lock, the page won't be isolated under us, and we know
it's not going to get splitted either.

We might use compound_trans_order but that's only reliable if run on
the head page so it's not so reliable, and so far it's only used by
memory-failure to "diminish" the risk of races in reading the compound
order, but it's not the best having to use compound_trans_order (and
memory-failure remains unsafe w.r.t to hugetlbfs being released during
hwpoisoning, so compound_trans_order might have to be improved for
it).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
