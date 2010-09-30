Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 92ECB6B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 22:27:09 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o8U2R5v5009975
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Thu, 30 Sep 2010 11:27:06 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8EE6A45DE4E
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 11:27:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 51F5E45DE4F
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 11:27:05 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 297ED1DB8043
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 11:27:05 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id C7E531DB804E
	for <linux-mm@kvack.org>; Thu, 30 Sep 2010 11:27:04 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [patch]vmscan: protect exectuable page from inactive list scan
In-Reply-To: <1285805052.1773.9.camel@shli-laptop>
References: <20100929101704.GB2618@cmpxchg.org> <1285805052.1773.9.camel@shli-laptop>
Message-Id: <20100930112408.2A94.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Date: Thu, 30 Sep 2010 11:27:04 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Shaohua Li <shaohua.li@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

> On Wed, 2010-09-29 at 18:17 +0800, Johannes Weiner wrote:
> > On Wed, Sep 29, 2010 at 10:57:40AM +0800, Shaohua Li wrote:
> > > With commit 645747462435, pte referenced file page isn't activated in inactive
> > > list scan. For VM_EXEC page, if it can't get a chance to active list, the
> > > executable page protect loses its effect. We protect such page in inactive scan
> > > here, now such page will be guaranteed cached in a full scan of active and
> > > inactive list, which restores previous behavior.
> > 
> > This change was in the back of my head since the used-once detection
> > was merged but there were never any regressions reported that would
> > indicate a requirement for it.
> The executable page protect is to improve responsibility. I would expect
> it's hard for user to report such regression. 

Seems strange. 8cab4754d24a0f was introduced for fixing real world problem.
So, I wonder why current people can't feel the same lag if it is.


> > Does this patch fix a problem you observed?
> No, I haven't done test where Fengguang does in commit 8cab4754d24a0f.

But, I am usually not against a number. If you will finished to test them I'm happy :)


> 
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -608,8 +608,15 @@ static enum page_references page_check_references(struct page *page,
> > >  		 * quickly recovered.
> > >  		 */
> > >  		SetPageReferenced(page);
> > > -
> > > -		if (referenced_page)
> > > +		/*
> > > +		 * Identify pte referenced and file-backed pages and give them
> > > +		 * one trip around the active list. So that executable code get
> > > +		 * better chances to stay in memory under moderate memory
> > > +		 * pressure. JVM can create lots of anon VM_EXEC pages, so we
> > > +		 * ignore them here.
> > 
> > PTE-referenced PageAnon() pages are activated unconditionally a few
> > lines further up, so the page_is_file_cache() check filters only shmem
> > pages.  I doubt this was your intention...?
> This is intented. the executable page protect is just to protect
> executable file pages. please see 8cab4754d24a0f.

8cab4754d24a0f was using !PageAnon() but your one are using page_is_file_cache.
8cab4754d24a0f doesn't tell us the reason of the change, no?



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
