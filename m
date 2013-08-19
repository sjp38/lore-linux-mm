Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id BB8F96B0032
	for <linux-mm@kvack.org>; Mon, 19 Aug 2013 14:29:08 -0400 (EDT)
Date: Mon, 19 Aug 2013 14:28:58 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1376936938-d6j957y5-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130819065450.GC28591@elgon.mountain>
References: <20130819065450.GC28591@elgon.mountain>
Subject: [PATCH][mmotm] mbind: add BUG_ON(!vma) in new_vma_page() (was Re: mm:
 mbind: add hugepage migration code to mbind())
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>

Hi Dan,
(Cc:ed MM maintainers/developers.)

Thanks for reporting.

On Mon, Aug 19, 2013 at 09:54:50AM +0300, Dan Carpenter wrote:
> Hello Naoya Horiguchi,
> 
> This is a semi-automatic email about new static checker warnings.
> 
> The patch 4c5bbbd24ae1: "mm: mbind: add hugepage migration code to 
> mbind()" from Aug 16, 2013, leads to the following Smatch complaint:
> 
> mm/mempolicy.c:1199 new_vma_page()
> 	 error: we previously assumed 'vma' could be null (see line 1191)
> 
> mm/mempolicy.c
>   1190	
>   1191		while (vma) {
>                        ^^^
> Old check.
> 
>   1192			address = page_address_in_vma(page, vma);
>   1193			if (address != -EFAULT)
>   1194				break;
>   1195			vma = vma->vm_next;
>   1196		}
>   1197	
>   1198		if (PageHuge(page))
>   1199			return alloc_huge_page_noerr(vma, address, 1);
>                                                      ^^^
> 
> New dereference inside the call to alloc_huge_page_noerr()
> 
>   1200		/*
>   1201		 * if !vma, alloc_page_vma() will use task or system default policy

I think that making alloc_huge_page_noerr() return NULL for !vma is one
possible solution. But current code looks strange to me in anther way,
and I don't think that considering vma==NULL case is meaningful.

When migrate_pages() is called from do_mbind(), pages in the pagelist are
collected via check_range(). And the collected pages certainly belong to
some vma. So it seems to me that something wrong should happen in !vma case.
So my suggestion is to add BUG_ON(!vma) after the while loop with comments.

Thanks,
Naoya Horiguchi
------------------------------------------------------------------------
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Mon, 19 Aug 2013 13:23:34 -0400
Subject: [PATCH][mmotm] mbind: add BUG_ON(!vma) in new_vma_page()

new_vma_page() is called only by page migration called from do_mbind(),
where pages to be migrated are queued into a pagelist by queue_pages_range().
queue_pages_range() confirms that a queued page belongs to some vma,
so !vma case is not supposed to be happen.
This patch adds BUG_ON() to catch this unexpected case.

Dependency:
  "mempolicy: rename check_*range to queue_pages_*range"
  in git//git.cmpxchg.org/linux-mmotm master

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/mempolicy.c | 8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index dca5225..43a70dc 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1187,12 +1187,14 @@ static struct page *new_vma_page(struct page *page, unsigned long private, int *
 			break;
 		vma = vma->vm_next;
 	}
+	/*
+	 * queue_pages_range() confirms that @page belongs to some vma,
+	 * so vma shouldn't be NULL.
+	 */
+	BUG_ON(!vma);
 
 	if (PageHuge(page))
 		return alloc_huge_page_noerr(vma, address, 1);
-	/*
-	 * if !vma, alloc_page_vma() will use task or system default policy
-	 */
 	return alloc_page_vma(GFP_HIGHUSER_MOVABLE, vma, address);
 }
 #else
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
