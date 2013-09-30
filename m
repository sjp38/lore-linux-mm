Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id 1E86B6B0032
	for <linux-mm@kvack.org>; Mon, 30 Sep 2013 11:01:42 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id un15so5710546pbc.15
        for <linux-mm@kvack.org>; Mon, 30 Sep 2013 08:01:41 -0700 (PDT)
Date: Mon, 30 Sep 2013 11:01:03 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1380553263-lqp3ggll-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130928172602.GA6191@pd.tnic>
References: <1376025702-14818-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1376025702-14818-5-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130928172602.GA6191@pd.tnic>
Subject: Re: [PATCH 4/9] migrate: add hugepage migration code to move_pages()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Hillf Danton <dhillf@gmail.com>, Michal Hocko <mhocko@suse.cz>, Rik van Riel <riel@redhat.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Sat, Sep 28, 2013 at 07:26:02PM +0200, Borislav Petkov wrote:
> On Fri, Aug 09, 2013 at 01:21:37AM -0400, Naoya Horiguchi wrote:
> > This patch extends move_pages() to handle vma with VM_HUGETLB set.
> > We will be able to migrate hugepage with move_pages(2) after
> > applying the enablement patch which comes later in this series.
> > 
> > We avoid getting refcount on tail pages of hugepage, because unlike thp,
> > hugepage is not split and we need not care about races with splitting.
> > 
> > And migration of larger (1GB for x86_64) hugepage are not enabled.
> > 
> > ChangeLog v4:
> >  - use get_page instead of get_page_foll
> >  - add comment in follow_page_mask
> > 
> > ChangeLog v3:
> >  - revert introducing migrate_movable_pages
> >  - follow_page_mask(FOLL_GET) returns NULL for tail pages
> >  - use isolate_huge_page
> > 
> > ChangeLog v2:
> >  - updated description and renamed patch title
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > Acked-by: Andi Kleen <ak@linux.intel.com>
> > Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> > ---
> >  mm/memory.c  | 17 +++++++++++++++--
> >  mm/migrate.c | 13 +++++++++++--
> >  2 files changed, 26 insertions(+), 4 deletions(-)
> 
> ...
> 
> > diff --git v3.11-rc3.orig/mm/migrate.c v3.11-rc3/mm/migrate.c
> > index 3ec47d3..d313737 100644
> > --- v3.11-rc3.orig/mm/migrate.c
> > +++ v3.11-rc3/mm/migrate.c
> > @@ -1092,7 +1092,11 @@ static struct page *new_page_node(struct page *p, unsigned long private,
> >  
> >  	*result = &pm->status;
> >  
> > -	return alloc_pages_exact_node(pm->node,
> > +	if (PageHuge(p))
> > +		return alloc_huge_page_node(page_hstate(compound_head(p)),
> > +					pm->node);
> > +	else
> > +		return alloc_pages_exact_node(pm->node,
> >  				GFP_HIGHUSER_MOVABLE | GFP_THISNODE, 0);
> >  }
> >  
> > @@ -1152,6 +1156,11 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
> >  				!migrate_all)
> >  			goto put_and_set;
> >  
> > +		if (PageHuge(page)) {
> > +			isolate_huge_page(page, &pagelist);
> > +			goto put_and_set;
> > +		}
> 
> This gives
> 
> In file included from mm/migrate.c:35:0:
> mm/migrate.c: In function ‘do_move_page_to_node_array’:
> include/linux/hugetlb.h:140:33: warning: statement with no effect [-Wunused-value]
>  #define isolate_huge_page(p, l) false
>                                  ^
> mm/migrate.c:1170:4: note: in expansion of macro ‘isolate_huge_page’
>     isolate_huge_page(page, &pagelist);
> 
> on a
> 
> # CONFIG_HUGETLBFS is not set
> 
> .config.

Thanks for reporting. The patch should fix this.

Naoya Horiguchi
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Mon, 30 Sep 2013 10:22:26 -0400
Subject: [PATCH] mm/migrate.c: take returned value of isolate_huge_page()

Introduces a cosmetic substitution of the returned value of isolate_huge_page()
to suppress a build warning when !CONFIG_HUGETLBFS. No behavioral change.

Reported-by: Borislav Petkov <bp@alien8.de>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/migrate.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/migrate.c b/mm/migrate.c
index 4cd63c2..4a26042 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1168,7 +1168,7 @@ static int do_move_page_to_node_array(struct mm_struct *mm,
 			goto put_and_set;
 
 		if (PageHuge(page)) {
-			isolate_huge_page(page, &pagelist);
+			err = isolate_huge_page(page, &pagelist);
 			goto put_and_set;
 		}
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
