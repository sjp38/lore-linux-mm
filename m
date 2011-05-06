Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9E1A96B0024
	for <linux-mm@kvack.org>; Fri,  6 May 2011 14:26:49 -0400 (EDT)
Date: Fri, 6 May 2011 20:26:43 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH]mm/compation.c: checking page in lru twice
Message-ID: <20110506182643.GH6330@random.random>
References: <1304681575.15473.4.camel@figo-desktop>
 <20110506130955.GF4941@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110506130955.GF4941@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: "Figo.zhang" <figo1802@gmail.com>, lkml <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, kamezawa.hiroyu@jp.fujisu.com, minchan.kim@gmail.com, Andrew Morton <akpm@osdl.org>

On Fri, May 06, 2011 at 02:09:55PM +0100, Mel Gorman wrote:
> On Fri, May 06, 2011 at 07:32:46PM +0800, Figo.zhang wrote:
> > 
> > in isolate_migratepages() have check page in LRU twice, the next one
> > at _isolate_lru_page(). 
> > 
> > Signed-off-by: Figo.zhang <figo1802@gmail.com> 
> 
> Not checking for PageLRU means that PageTransHuge() gets called
> for each page. While the scanner is active and the lock released,
> a transparent hugepage can be created and potentially we test
> PageTransHuge() on a tail page. This will trigger a BUG if
> CONFIG_DEBUG_VM is set.

Agreed. The compound_order also would become unsafe even if it was
initially an head page (if it's a compound page not in lru). And
compound_trans_order isn't a solution either because we need to be
head for it to be safe like you said, better not having to use
compound_trans_order.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
