Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E91556B0047
	for <linux-mm@kvack.org>; Wed, 29 Sep 2010 20:04:18 -0400 (EDT)
Subject: Re: [patch]vmscan: protect exectuable page from inactive list scan
From: Shaohua Li <shaohua.li@intel.com>
In-Reply-To: <20100929101704.GB2618@cmpxchg.org>
References: <1285729060.27440.14.camel@sli10-conroe.sh.intel.com>
	 <20100929101704.GB2618@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 30 Sep 2010 08:04:12 +0800
Message-ID: <1285805052.1773.9.camel@shli-laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm <linux-mm@kvack.org>, "riel@redhat.com" <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Wu, Fengguang" <fengguang.wu@intel.com>
List-ID: <linux-mm.kvack.org>

On Wed, 2010-09-29 at 18:17 +0800, Johannes Weiner wrote:
> On Wed, Sep 29, 2010 at 10:57:40AM +0800, Shaohua Li wrote:
> > With commit 645747462435, pte referenced file page isn't activated in inactive
> > list scan. For VM_EXEC page, if it can't get a chance to active list, the
> > executable page protect loses its effect. We protect such page in inactive scan
> > here, now such page will be guaranteed cached in a full scan of active and
> > inactive list, which restores previous behavior.
> 
> This change was in the back of my head since the used-once detection
> was merged but there were never any regressions reported that would
> indicate a requirement for it.
The executable page protect is to improve responsibility. I would expect
it's hard for user to report such regression. 

> Does this patch fix a problem you observed?
No, I haven't done test where Fengguang does in commit 8cab4754d24a0f.

> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -608,8 +608,15 @@ static enum page_references page_check_references(struct page *page,
> >  		 * quickly recovered.
> >  		 */
> >  		SetPageReferenced(page);
> > -
> > -		if (referenced_page)
> > +		/*
> > +		 * Identify pte referenced and file-backed pages and give them
> > +		 * one trip around the active list. So that executable code get
> > +		 * better chances to stay in memory under moderate memory
> > +		 * pressure. JVM can create lots of anon VM_EXEC pages, so we
> > +		 * ignore them here.
> 
> PTE-referenced PageAnon() pages are activated unconditionally a few
> lines further up, so the page_is_file_cache() check filters only shmem
> pages.  I doubt this was your intention...?
This is intented. the executable page protect is just to protect
executable file pages. please see 8cab4754d24a0f.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
