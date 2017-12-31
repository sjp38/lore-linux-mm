Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 55A546B0038
	for <linux-mm@kvack.org>; Sun, 31 Dec 2017 04:07:16 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id r8so8186186pgp.7
        for <linux-mm@kvack.org>; Sun, 31 Dec 2017 01:07:16 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 8si31078737pfj.82.2017.12.31.01.07.14
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 31 Dec 2017 01:07:15 -0800 (PST)
Date: Sun, 31 Dec 2017 10:07:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm: unclutter THP migration
Message-ID: <20171231090710.GA18691@dhcp22.suse.cz>
References: <20171207143401.GK20234@dhcp22.suse.cz>
 <20171208161559.27313-1-mhocko@kernel.org>
 <20171208161559.27313-4-mhocko@kernel.org>
 <AEE005DE-5103-4BCC-BAAB-9E126173AB62@cs.rutgers.edu>
 <20171229113627.GB27077@dhcp22.suse.cz>
 <044496C5-5ACD-4845-A7A3-BD920BF9233B@cs.rutgers.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <044496C5-5ACD-4845-A7A3-BD920BF9233B@cs.rutgers.edu>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@cs.rutgers.edu>
Cc: linux-mm@kvack.org, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Andrea Reale <ar@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>

On Fri 29-12-17 10:45:46, Zi Yan wrote:
> On 29 Dec 2017, at 6:36, Michal Hocko wrote:
> 
> > On Tue 26-12-17 21:19:35, Zi Yan wrote:
[...]
> >> And it seems a little bit strange to only re-migrate the head page, then come back to all tail
> >> pages after migrating the rest of pages in the list a??froma??. Is it better to split the THP into
> >> a list other than a??froma?? and insert the list after a??pagea??, then retry from the split a??pagea???
> >> Thus, we attempt to migrate all sub pages of the THP after it is split.
> >
> > Why does this matter?
> 
> Functionally, it does not matter.
> 
> This behavior is just less intuitive and a little different from current one,
> which implicitly preserves its original order of the not-migrated pages
> in the a??froma?? list, although no one relies on this implicit behavior now.
>
> 
> Adding one line comment about this difference would be good for code maintenance. :)

OK, I will not argue. I still do not see _why_ we need it but I've added
the following.

diff --git a/mm/migrate.c b/mm/migrate.c
index 21b3381a2871..0ac5185d3949 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1395,6 +1395,11 @@ int migrate_pages(struct list_head *from, new_page_t get_new_page,
 				 * allocation could've failed so we should
 				 * retry on the same page with the THP split
 				 * to base pages.
+				 *
+				 * Head page is retried immediatelly and tail
+				 * pages are added to the tail of the list so
+				 * we encounter them after the rest of the list
+				 * is processed.
 				 */
 				if (PageTransHuge(page)) {
 					lock_page(page);

Does that this reflect what you mean?
 
> Reviewed-by: Zi Yan <zi.yan@cs.rutgers.edu>

Thx!

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
