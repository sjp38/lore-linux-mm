Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 134856B002B
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 00:02:59 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] pagemap: fix wrong KPF_THP on slab pages
Date: Wed, 26 Sep 2012 00:02:34 -0400
Message-Id: <1348632154-31508-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120926024754.GA12716@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 26, 2012 at 10:47:54AM +0800, Fengguang Wu wrote:
> On Tue, Sep 25, 2012 at 10:06:08PM -0400, Naoya Horiguchi wrote:
> > On Tue, Sep 25, 2012 at 05:20:48PM -0700, David Rientjes wrote:
> > > On Tue, 25 Sep 2012, Naoya Horiguchi wrote:
> > > 
> > > > KPF_THP can be set on non-huge compound pages like slab pages, because
> > > > PageTransCompound only sees PG_head and PG_tail. Obviously this is a bug
> > > > and breaks user space applications which look for thp via /proc/kpageflags.
> > > > Currently thp is constructed only on anonymous pages, so this patch makes
> > > > KPF_THP be set when both of PageAnon and PageTransCompound are true.
> > > > 
> > > > Changelog in v2:
> > > >   - add a comment in code
> > > > 
> > > > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > > 
> > > Wouldn't PageTransCompound(page) && !PageHuge(page) && !PageSlab(page) be 
> > > better for a future extension of thp support?
> > 
> > Yes, this saves us an additional change when thp starts handling pagecaches.
> > Andrew, can you replace the previous version in -mm tree with new one below?
> > 
> > Thanks,
> > Naoya
> > ---
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Date: Tue, 25 Sep 2012 21:30:25 -0400
> > Subject: [PATCH v3] kpageflags: fix wrong KPF_THP on slab pages
> > 
> > KPF_THP can be set on non-huge compound pages like slab pages, because
> > PageTransCompound only sees PG_head and PG_tail. Obviously this is a bug
> 
> s/sees/checks/
> 
> > and breaks user space applications which look for thp via /proc/kpageflags.
> > This patch rules out setting KPF_THP wrongly by additional PageSlab check.
> > 
> > Changelog in v3:
> >   - check PageSlab instead of PageAnon
> >   - fix patch subject
> > 
> > Changelog in v2:
> >   - add a comment in code
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
> >  fs/proc/page.c | 7 ++++++-
> >  1 file changed, 6 insertions(+), 1 deletion(-)
> > 
> > diff --git a/fs/proc/page.c b/fs/proc/page.c
> > index 7fcd0d6..e36d1f3 100644
> > --- a/fs/proc/page.c
> > +++ b/fs/proc/page.c
> > @@ -115,7 +115,12 @@ u64 stable_page_flags(struct page *page)
> >  		u |= 1 << KPF_COMPOUND_TAIL;
> >  	if (PageHuge(page))
> >  		u |= 1 << KPF_HUGE;
> > -	else if (PageTransCompound(page))
> > +	/*
> > +	 * PageTransCompound can be true for slab pages because it just sees
> 
> s/sees/checks/
> 
> > +	 * PG_head/PG_head, so we need to check PageSlab to make sure the given
> 
> PG_head/PG_head should be PG_head/PG_tail.

Ah, sorry for my carelessness.

> > +	 * page is a thp, not a non-huge compound page.
> > +	 */
> > +	else if (PageTransCompound(page) && !PageSlab(page))
> >  		u |= 1 << KPF_THP;
> 
> Good catch!
> 
> Will this report THP for the various drivers that do __GFP_COMP
> page allocations?

I'm afraid it will. I think of checking PageLRU as an alternative,
but it needs compound_head() to report tail pages correctly.
In this context, pages are not pinned or locked, so it's unsafe to
use compound_head() because it can return a dangling pointer.
Maybe it's a thp's/hugetlbfs's (not kpageflags specific) problem,
so going forward with compound_head() expecting that it will be
fixed in the future work can be an option.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
