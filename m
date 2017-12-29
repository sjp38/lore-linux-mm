Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3C66B0069
	for <linux-mm@kvack.org>; Fri, 29 Dec 2017 06:36:29 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id p4so7621358wrf.4
        for <linux-mm@kvack.org>; Fri, 29 Dec 2017 03:36:29 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k184si16051783wmd.221.2017.12.29.03.36.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Dec 2017 03:36:28 -0800 (PST)
Date: Fri, 29 Dec 2017 12:36:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm: unclutter THP migration
Message-ID: <20171229113627.GB27077@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-4-mhocko@kernel.org>
 <AEE005DE-5103-4BCC-BAAB-9E126173AB62@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AEE005DE-5103-4BCC-BAAB-9E126173AB62@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Tue 26-12-17 21:19:35, Zi Yan wrote:
> On 8 Dec 2017, at 11:15, Michal Hocko wrote:
[...]
> > @@ -1394,6 +1390,21 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
> >
> >  			switch(rc) {
> >  			case -ENOMEM:
> > +				/*
> > +				 * THP migration might be unsupported or the
> > +				 * allocation could've failed so we should
> > +				 * retry on the same page with the THP split
> > +				 * to base pages.
> > +				 */
> > +				if (PageTransHuge(page)) {
> > +					lock_page(page);
> > +					rc = split_huge_page_to_list(page, from);
> > +					unlock_page(page);
> > +					if (!rc) {
> > +						list_safe_reset_next(page, page2, lru);
> > +						goto retry;
> > +					}
> > +				}
> 
> The hunk splits the THP and adds all tail pages at the end of the list a??froma??.
> Why do we need a??list_safe_reset_next(page, page2, lru);a?? here, when page2 is not changed here?

Because we need to handle the case when the page2 was the last on the
list.
 
> And it seems a little bit strange to only re-migrate the head page, then come back to all tail
> pages after migrating the rest of pages in the list a??froma??. Is it better to split the THP into
> a list other than a??froma?? and insert the list after a??pagea??, then retry from the split a??pagea???
> Thus, we attempt to migrate all sub pages of the THP after it is split.

Why does this matter?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
