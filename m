Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 91BFD6B002B
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 13:05:29 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH] pagemap: fix wrong KPF_THP on slab pages
Date: Tue, 25 Sep 2012 13:05:15 -0400
Message-Id: <1348592715-31006-1-git-send-email-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <CAHGf_=rbyk1UFGwyQ0BSN3qM_K+5J3Q-Aj=xjNDZFrTrZ6a3dw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Wu Fengguang <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi.kleen@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Sep 25, 2012 at 11:59:51AM -0400, KOSAKI Motohiro wrote:
> On Tue, Sep 25, 2012 at 9:56 AM, Naoya Horiguchi
> <n-horiguchi@ah.jp.nec.com> wrote:
> > KPF_THP can be set on non-huge compound pages like slab pages, because
> > PageTransCompound only sees PG_head and PG_tail. Obviously this is a bug
> > and breaks user space applications which look for thp via /proc/kpageflags.
> > Currently thp is constructed only on anonymous pages, so this patch makes
> > KPF_THP be set when both of PageAnon and PageTransCompound are true.
> 
> Indeed. Please add some comment too.

Sure. I send revised one.

Thanks,
Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Mon, 24 Sep 2012 16:28:30 -0400
Subject: [PATCH v2] pagemap: fix wrong KPF_THP on slab pages

KPF_THP can be set on non-huge compound pages like slab pages, because
PageTransCompound only sees PG_head and PG_tail. Obviously this is a bug
and breaks user space applications which look for thp via /proc/kpageflags.
Currently thp is constructed only on anonymous pages, so this patch makes
KPF_THP be set when both of PageAnon and PageTransCompound are true.

Changelog in v2:
  - add a comment in code

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 fs/proc/page.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/proc/page.c b/fs/proc/page.c
index 7fcd0d6..f7cd2f6c 100644
--- a/fs/proc/page.c
+++ b/fs/proc/page.c
@@ -115,7 +115,12 @@ u64 stable_page_flags(struct page *page)
 		u |= 1 << KPF_COMPOUND_TAIL;
 	if (PageHuge(page))
 		u |= 1 << KPF_HUGE;
-	else if (PageTransCompound(page))
+	/*
+	 * Since THP is relevant only for anonymous pages so far, we check it
+	 * explicitly with PageAnon. Otherwise thp is confounded with non-huge
+	 * compound pages like slab pages.
+	 */
+	else if (PageTransCompound(page) && PageAnon(page))
 		u |= 1 << KPF_THP;
 
 	/*
-- 
1.7.11.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
