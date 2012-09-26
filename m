Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 4A3F26B0044
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 03:38:48 -0400 (EDT)
Date: Wed, 26 Sep 2012 15:38:41 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [PATCH] pagemap: fix wrong KPF_THP on slab pages
Message-ID: <20120926073841.GA26028@localhost>
References: <1348632154-31508-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1348639568-10648-1-git-send-email-n-horiguchi@ah.jp.nec.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1348639568-10648-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 26, 2012 at 02:06:08AM -0400, Naoya Horiguchi wrote:
> On Wed, Sep 26, 2012 at 12:02:34AM -0400, Naoya Horiguchi wrote:
> ...
> > > > +	 * page is a thp, not a non-huge compound page.
> > > > +	 */
> > > > +	else if (PageTransCompound(page) && !PageSlab(page))
> > > >  		u |= 1 << KPF_THP;
> > > 
> > > Good catch!
> > > 
> > > Will this report THP for the various drivers that do __GFP_COMP
> > > page allocations?
> > 
> > I'm afraid it will. I think of checking PageLRU as an alternative,
> > but it needs compound_head() to report tail pages correctly.
> > In this context, pages are not pinned or locked, so it's unsafe to
> > use compound_head() because it can return a dangling pointer.
> > Maybe it's a thp's/hugetlbfs's (not kpageflags specific) problem,
> > so going forward with compound_head() expecting that it will be
> > fixed in the future work can be an option.
> 
> It seems that compound_trans_head() solves this problem, so I'll
> simply use it.

Naoya, in fact I didn't quite catch your concerns. Why not just test

        PageTransCompound(page) && PageLRU(page)

The whole page flag report thing is inherently racy and it's fine to
report wrong values due to races. The "__GFP_COMP reported as THP",
however, should be avoided because it will make consistent wrong
reporting of page flags.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
