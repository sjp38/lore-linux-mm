Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 06B3B82F64
	for <linux-mm@kvack.org>; Thu,  5 Nov 2015 04:26:28 -0500 (EST)
Received: by wmnn186 with SMTP id n186so8528530wmn.1
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 01:26:27 -0800 (PST)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id 69si8096624wmn.54.2015.11.05.01.26.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Nov 2015 01:26:26 -0800 (PST)
Received: by wmll128 with SMTP id l128so7815227wml.0
        for <linux-mm@kvack.org>; Thu, 05 Nov 2015 01:26:26 -0800 (PST)
Date: Thu, 5 Nov 2015 11:26:22 +0200
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/4] thp: fix split vs. unmap race
Message-ID: <20151105092622.GD7614@node.shutemov.name>
References: <052401d116e0$c3ac0110$4b040330$@alibaba-inc.com>
 <052701d116e2$0437a2b0$0ca6e810$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <052701d116e2$0437a2b0$0ca6e810$@alibaba-inc.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, 'Minchan Kim' <minchan@kernel.org>

On Wed, Nov 04, 2015 at 05:20:15PM +0800, Hillf Danton wrote:
> > @@ -1135,20 +1135,12 @@ void do_page_add_anon_rmap(struct page *page,
> >  	bool compound = flags & RMAP_COMPOUND;
> >  	bool first;
> > 
> > -	if (PageTransCompound(page)) {
> > +	if (compound) {
> > +		atomic_t *mapcount;
> >  		VM_BUG_ON_PAGE(!PageLocked(page), page);
> > -		if (compound) {
> > -			atomic_t *mapcount;
> > -
> > -			VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> > -			mapcount = compound_mapcount_ptr(page);
> > -			first = atomic_inc_and_test(mapcount);
> > -		} else {
> > -			/* Anon THP always mapped first with PMD */
> > -			first = 0;
> > -			VM_BUG_ON_PAGE(!page_mapcount(page), page);
> > -			atomic_inc(&page->_mapcount);
> > -		}
> > +		VM_BUG_ON_PAGE(!PageTransHuge(page), page);
> > +		mapcount = compound_mapcount_ptr(page);
> > +		first = atomic_inc_and_test(mapcount);
> >  	} else {
> >  		VM_BUG_ON_PAGE(compound, page);
> 
> Then this debug info is no longer needed.
> >  		first = atomic_inc_and_test(&page->_mapcount);

Right.

diff --git a/mm/rmap.c b/mm/rmap.c
index 0837487d3737..a9550b1f74cd 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -1186,7 +1186,6 @@ void do_page_add_anon_rmap(struct page *page,
 		mapcount = compound_mapcount_ptr(page);
 		first = atomic_inc_and_test(mapcount);
 	} else {
-		VM_BUG_ON_PAGE(compound, page);
 		first = atomic_inc_and_test(&page->_mapcount);
 	}
 
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
