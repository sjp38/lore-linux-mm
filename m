Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 836116B028F
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 08:41:07 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id p2so14635188pfk.13
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 05:41:07 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f4si13257562plr.760.2017.11.22.05.41.05
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Nov 2017 05:41:06 -0800 (PST)
Date: Wed, 22 Nov 2017 14:40:59 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: migrate: fix an incorrect call of
 prep_transhuge_page()
Message-ID: <20171122134059.fmyambktkel4e3zq@dhcp22.suse.cz>
References: <20171121021855.50525-1-zi.yan@sent.com>
 <20171122085416.ycrvahu2bznlx37s@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171122085416.ycrvahu2bznlx37s@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Zi Yan <zi.yan@cs.rutgers.edu>, Andrea Reale <ar@linux.vnet.ibm.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, stable@vger.kernel.org

On Wed 22-11-17 09:54:16, Michal Hocko wrote:
> On Mon 20-11-17 21:18:55, Zi Yan wrote:
[...]
> > diff --git a/include/linux/migrate.h b/include/linux/migrate.h
> > index 895ec0c4942e..a2246cf670ba 100644
> > --- a/include/linux/migrate.h
> > +++ b/include/linux/migrate.h
> > @@ -54,7 +54,7 @@ static inline struct page *new_page_nodemask(struct page *page,
> >  	new_page = __alloc_pages_nodemask(gfp_mask, order,
> >  				preferred_nid, nodemask);
> >  
> > -	if (new_page && PageTransHuge(page))
> > +	if (new_page && PageTransHuge(new_page))
> >  		prep_transhuge_page(new_page);
> 
> I would keep the two checks consistent. But that leads to a more
> interesting question. new_page_nodemask does
> 
> 	if (thp_migration_supported() && PageTransHuge(page)) {
> 		order = HPAGE_PMD_ORDER;
> 		gfp_mask |= GFP_TRANSHUGE;
> 	}

And one more question/note. Why do we need thp_migration_supported
in the first place? 9c670ea37947 ("mm: thp: introduce
CONFIG_ARCH_ENABLE_THP_MIGRATION") says
: Introduce CONFIG_ARCH_ENABLE_THP_MIGRATION to limit thp migration
: functionality to x86_64, which should be safer at the first step.

but why is unsafe to enable the feature on other arches which support
THP? Is there any plan to do the next step and remove this config
option?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
