Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id DB3AE6B005D
	for <linux-mm@kvack.org>; Wed, 26 Sep 2012 10:43:00 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] pagemap: fix wrong KPF_THP on slab pages
Date: Wed, 26 Sep 2012 10:42:43 -0400
Message-Id: <1348670563-7755-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20120926073841.GA26028@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Sep 26, 2012 at 03:38:41PM +0800, Fengguang Wu wrote:
> On Wed, Sep 26, 2012 at 02:06:08AM -0400, Naoya Horiguchi wrote:
> > On Wed, Sep 26, 2012 at 12:02:34AM -0400, Naoya Horiguchi wrote:
> > ...
> > > > > +	 * page is a thp, not a non-huge compound page.
> > > > > +	 */
> > > > > +	else if (PageTransCompound(page) && !PageSlab(page))
> > > > >  		u |= 1 << KPF_THP;
> > > > 
> > > > Good catch!
> > > > 
> > > > Will this report THP for the various drivers that do __GFP_COMP
> > > > page allocations?
> > > 
> > > I'm afraid it will. I think of checking PageLRU as an alternative,
> > > but it needs compound_head() to report tail pages correctly.
> > > In this context, pages are not pinned or locked, so it's unsafe to
> > > use compound_head() because it can return a dangling pointer.
> > > Maybe it's a thp's/hugetlbfs's (not kpageflags specific) problem,
> > > so going forward with compound_head() expecting that it will be
> > > fixed in the future work can be an option.
> > 
> > It seems that compound_trans_head() solves this problem, so I'll
> > simply use it.
> 
> Naoya, in fact I didn't quite catch your concerns. Why not just test
> 
>         PageTransCompound(page) && PageLRU(page)

If we simply check PageLRU, tail pages in thp only show KPF_COMPOUND_TAIL
and we can't distinguish them from tail pages in non-huge compound pages.

Moreover this behavior is not consistent with that of hugetlbfs tail
pages where tail pages also have KPF_HUGE and are distinct from non-huge
compound pages. I show the output of page-types:

  offset  len     flags
  ...
  2d400   1       ___U_lA____Ma_bH______t____________ (thp head)
  2d401   1ff     ________________T__________________ (thp tail) # no KPF_THP
  ...
  77000   1       ___U_______Ma__H_G_________________ (hugetlbfs head)
  77001   1ff     ________________TG_________________ (hugetlbfs tail)
  ...
  11fb50  1       _______________H___________________ (compound head)
  11fb51  3       ________________T__________________ (compound tail)
  ...
  11fb58  1       _______S_______H___________________ (slab head)
  11fb59  7       ________________T__________________ (slab tail)

    H: KPF_COMPOUND_HEAD   T: KPF_COMPOUND_TAIL
    G: KPF_HUGE            t: KPF_THP

So I think it's better to set KPF_THP on thp tail pages.
  
> The whole page flag report thing is inherently racy and it's fine to
> report wrong values due to races. The "__GFP_COMP reported as THP",
> however, should be avoided because it will make consistent wrong
> reporting of page flags.

Yes, I agree with this point.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
