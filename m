Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 7CF9E6B005A
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 03:00:15 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n6H70DwP005641
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 17 Jul 2009 16:00:13 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 2473445DE56
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 16:00:13 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id F2C2545DE53
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 16:00:12 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id C3F321DB803F
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 16:00:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 67283E08006
	for <linux-mm@kvack.org>; Fri, 17 Jul 2009 16:00:12 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] add isolate pages vmstat
In-Reply-To: <alpine.DEB.1.10.0907161024120.32382@gentwo.org>
References: <20090716095344.9D10.A69D9226@jp.fujitsu.com> <alpine.DEB.1.10.0907161024120.32382@gentwo.org>
Message-Id: <20090717085821.A900.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 17 Jul 2009 16:00:11 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

> > @@ -740,6 +744,13 @@ int migrate_pages(struct list_head *from
> >  	struct page *page2;
> >  	int swapwrite = current->flags & PF_SWAPWRITE;
> >  	int rc;
> > +	int flags;
> > +
> > +	local_irq_save(flags);
> > +	list_for_each_entry(page, from, lru)
> > +		__inc_zone_page_state(page, NR_ISOLATED_ANON +
> > +				      !!page_is_file_cache(page));
> > +	local_irq_restore(flags);
> >
> 
> Why do a separate pass over all the migrates pages? Can you add the
> _inc_xx  somewhere after the page was isolated from the lru by calling
> try_to_unmap()?

calling try_to_unmap()? the pages are isolated before calling migrate_pages().
migrate_pages() have multiple caller. then I put this __inc_xx into top of
migrate_pages().



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
