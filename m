Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 4ABA26B00B7
	for <linux-mm@kvack.org>; Tue, 26 Mar 2013 00:33:46 -0400 (EDT)
Date: Tue, 26 Mar 2013 00:33:35 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1364272415-zvaphow7-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130325105701.GS2154@dhcp22.suse.cz>
References: <1363983835-20184-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1363983835-20184-3-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130325105701.GS2154@dhcp22.suse.cz>
Subject: Re: [PATCH 02/10] migrate: make core migration code aware of hugepage
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org

On Mon, Mar 25, 2013 at 11:57:01AM +0100, Michal Hocko wrote:
> On Fri 22-03-13 16:23:47, Naoya Horiguchi wrote:
...
> > diff --git v3.9-rc3.orig/mm/hugetlb.c v3.9-rc3/mm/hugetlb.c
> > index 98a478e..a787c44 100644
> > --- v3.9-rc3.orig/mm/hugetlb.c
> > +++ v3.9-rc3/mm/hugetlb.c
> > @@ -48,7 +48,8 @@ static unsigned long __initdata default_hstate_max_huge_pages;
> >  static unsigned long __initdata default_hstate_size;
> >
> >  /*
> > - * Protects updates to hugepage_freelists, nr_huge_pages, and free_huge_pages
> > + * Protects updates to hugepage_freelists, hugepage_activelist, nr_huge_pages,
> > + * free_huge_pages, and surplus_huge_pages.
> >   */
>
> Could you get this out into a separate patch and add lockdep assertions
> to functions which do not lock it directly but they rely on it so that
> the locking is more clear?
> e.g. dequeue_huge_page_node, update_and_free_page, try_to_free_low, ...

OK, I'll try it.

> It would a nice cleanup and a lead for future when somebody tries to
> make the locking a bit saner.
>
...
> > @@ -1056,6 +1064,20 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> >  	return rc;
> >  }
> >
> > +int migrate_movable_pages(struct list_head *from, new_page_t get_new_page,
> > +			unsigned long private,
> > +			enum migrate_mode mode, int reason)
> > +{
> > +	int err = 0;
> > +
> > +	if (!list_empty(from)) {
> > +		err = migrate_pages(from, get_new_page, private, mode, reason);
> > +		if (err)
> > +			putback_movable_pages(from);
> > +	}
> > +	return err;
> > +}
> > +
>
> There doesn't seem to be any caller for this function. Please move it to
> the patch which uses it.

I would do like that if there's only one user of this function, but I thought
that it's better to separate this part as changes of common code
because this function is commonly used by multiple users which are added by
multiple patches later in this series.

I mean doing like

  Patch 1: core change
  Patch 2: user A (depend on patch 1)
  Patch 3: user B (depend on patch 1)
  Patch 4: user C (depend on patch 1)

is a bit cleaner and easier in bisecting than doing like

  Patch 1: core change + user A
  Patch 2: user B (depend on patch 1)
  Patch 3: user C (depend on patch 1)

. I'm not sure which is standard or well-accepted way.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
