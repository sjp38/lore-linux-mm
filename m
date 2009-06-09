Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 445186B005C
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 04:25:41 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n598t5Kl011553
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 9 Jun 2009 17:55:07 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6488145DE60
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:55:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D36245DE7A
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:55:05 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E11321DB803E
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:55:04 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E9E161DB8037
	for <linux-mm@kvack.org>; Tue,  9 Jun 2009 17:55:03 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] Properly account for the number of page cache pages zone_reclaim() can reclaim
In-Reply-To: <20090609082728.GF18380@csn.ul.ie>
References: <20090609022549.GB6740@localhost> <20090609082728.GF18380@csn.ul.ie>
Message-Id: <20090609175211.DD85.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue,  9 Jun 2009 17:55:03 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: kosaki.motohiro@jp.fujitsu.com, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, "Zhang, Yanmin" <yanmin.zhang@intel.com>, "linuxram@us.ibm.com" <linuxram@us.ibm.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> > > The ideal would be that the number of tmpfs pages would also be known
> > > and account for like NR_FILE_MAPPED as swap is required to discard them.
> > > A means of working this out quickly was not obvious but a comment is added
> > > noting the problem.
> > 
> > I'd rather prefer it be accounted separately than to muck up NR_FILE_MAPPED :)
> > 
> 
> Maybe I used a poor choice of words. What I meant was that the ideal would
> be we had a separate count for tmpfs pages. As tmpfs pages and mapped pages
> both have to be unmapped and potentially, they are "like" each other with
> respect to the zone_reclaim_mode and how it behaves. We would end up
> with something like
> 
> 	pagecache_reclaimable -= zone_page_state(zone, NR_FILE_MAPPED);
> 	pagecache_reclaimable -= zone_page_state(zone, NR_FILE_TMPFS);

Please see shmem_writepage(). tmpfs writeout make swapcache, We also
need to concern swapcache.

note: swapcache also increase NR_FILE_PAGES, see add_to_swap_cache.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
