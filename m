Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C03576B0253
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 09:34:05 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id a141so3476214wma.8
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 06:34:05 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g62si3635261wmg.258.2017.12.07.06.34.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 06:34:04 -0800 (PST)
Date: Thu, 7 Dec 2017 15:34:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm: unclutter THP migration
Message-ID: <20171207143401.GK20234@dhcp22.suse.cz>
References: <20171207124815.12075-1-mhocko@kernel.org>
 <5A294BE7.4010904@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5A294BE7.4010904@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Thu 07-12-17 22:10:47, Zi Yan wrote:
> Hi Michal,
> 
> Thanks for sending this out.
> 
> Michal Hocko wrote:
> > From: Michal Hocko <mhocko@suse.com>
> > 
> > THP migration is hacked into the generic migration with rather
> > surprising semantic. The migration allocation callback is supposed to
> > check whether the THP can be migrated at once and if that is not the
> > case then it allocates a simple page to migrate. unmap_and_move then
> > fixes that up by spliting the THP into small pages while moving the
> > head page to the newly allocated order-0 page. Remaning pages are moved
> > to the LRU list by split_huge_page. The same happens if the THP
> > allocation fails. This is really ugly and error prone [1].
> > 
> > I also believe that split_huge_page to the LRU lists is inherently
> > wrong because all tail pages are not migrated. Some callers will just
> 
> I agree with you that we should try to migrate all tail pages if the THP
> needs to be split. But this might not be compatible with "getting
> migration results" in unmap_and_move(), since a caller of
> migrate_pages() may want to know the status of each page in the
> migration list via int **result in get_new_page() (e.g.
> new_page_node()). The caller has no idea whether a THP in its migration
> list will be split or not, thus, storing migration results might be
> quite tricky if tail pages are added into the migration list.

Ouch. I wasn't aware of this "beauty". I will try to wrap my head around
this code and think about what to do about it. Thanks for point me to
it.

> We need to consider this when we clean up migrate_pages().
> 
[...]
> > diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> > index a2246cf670ba..ec9503e5f2c2 100644
> > --- a/include/linux/migrate.h
> > +++ b/include/linux/migrate.h
> > @@ -43,9 +43,11 @@ static inline struct page *new_page_nodemask(struct page *page,
> >  		return alloc_huge_page_nodemask(page_hstate(compound_head(page)),
> >  				preferred_nid, nodemask);
> >  
> > -	if (thp_migration_supported() && PageTransHuge(page)) {
> > -		order = HPAGE_PMD_ORDER;
> > +	if (PageTransHuge(page)) {
> > +		if (!thp_migration_supported())
> > +			return NULL;
> We may not need these two lines, since if thp_migration_supported() is
> false, unmap_and_move() returns -ENOMEM in your code below, which has
> the same result of returning NULL here.

yes, this is a left over after rebase. Originally I used to have
thp_migration_supported in allocation callbacks but then moved it to
unmap_and_move to reduce the code duplication and also it makes much
more sense to have this up in the migration layer. I've fixed this up in
my local copy now.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
