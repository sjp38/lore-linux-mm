Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 7CC346B0005
	for <linux-mm@kvack.org>; Mon, 25 Feb 2013 11:58:14 -0500 (EST)
Date: Mon, 25 Feb 2013 11:57:56 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1361811476-la4ql3y2-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAJd=RBDvqFYUgy+d=DJTBZoaafXoDP+QodAh2CzV2XpDMjaw7Q@mail.gmail.com>
References: <1361475708-25991-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1361475708-25991-9-git-send-email-n-horiguchi@ah.jp.nec.com>
 <CAJd=RBDvqFYUgy+d=DJTBZoaafXoDP+QodAh2CzV2XpDMjaw7Q@mail.gmail.com>
Subject: Re: [PATCH 8/9] memory-hotplug: enable memory hotplug to handle
 hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <dhillf@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>

Hi Hillf,

On Sat, Feb 23, 2013 at 03:05:30PM +0800, Hillf Danton wrote:
> Hello Naoya
> 
> [add Michal in cc list]
> 
> On Fri, Feb 22, 2013 at 3:41 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> >
> > +/* Returns true for head pages of in-use hugepages, otherwise returns false. */
> > +int is_hugepage_movable(struct page *hpage)
> s/int/bool/  can we?

Yes, we can. I'll do this.

> > +{
> > +       struct page *page;
> > +       struct page *tmp;
> > +       struct hstate *h = page_hstate(hpage);
> Make sense to compute hstate for a tail page?

No need to do this here.
It's better to put it after PageTail check.

> > +       int ret = 0;
> > +
> > +       VM_BUG_ON(!PageHuge(hpage));
> > +       if (PageTail(hpage))
> > +               return 0;
> VM_BUG_ON(!PageHuge(hpage) || PageTail(hpage)), can we?

I think that firing BUG_ON() for tail pages is overkill.
Pfn range over which scan_movable_pages() runs could start
at the pfn inside the hugepage when we try to hot-remove
the memory block used by 1GB hugepage. In that case,
is_hugepage_movable() can be called for tail pages as a
normal behavior.

But anyway, I'll add the comment for this corner case.

> > +       spin_lock(&hugetlb_lock);
> > +       list_for_each_entry_safe(page, tmp, &h->hugepage_activelist, lru)
> s/_safe//  can we?

OK.

> > +               if (page == hpage)
> > +                       ret = 1;
> Can we bail out with ret set to be true?

Yes, inserting break is good for performance.

> > +       spin_unlock(&hugetlb_lock);
> > +       return ret;
> > +}

Thank you!
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
