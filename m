Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f178.google.com (mail-ea0-f178.google.com [209.85.215.178])
	by kanga.kvack.org (Postfix) with ESMTP id D14426B0031
	for <linux-mm@kvack.org>; Fri,  7 Mar 2014 01:35:09 -0500 (EST)
Received: by mail-ea0-f178.google.com with SMTP id a15so2105251eae.23
        for <linux-mm@kvack.org>; Thu, 06 Mar 2014 22:35:09 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id a43si14091829eei.142.2014.03.06.22.35.07
        for <linux-mm@kvack.org>;
        Thu, 06 Mar 2014 22:35:08 -0800 (PST)
Date: Fri, 07 Mar 2014 01:35:02 -0500
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <5319689c.437e0e0a.63ea.ffffacdcSMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <5318E5AD.9090107@oracle.com>
References: <53126861.7040107@oracle.com>
 <1393822946-26871-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5314E0CD.6070308@oracle.com>
 <5314F661.30202@oracle.com>
 <1393968743-imrxpynb@n-horiguchi@ah.jp.nec.com>
 <531657DC.4050204@oracle.com>
 <1393976967-lnmm5xcs@n-horiguchi@ah.jp.nec.com>
 <5317FA3B.8060900@oracle.com>
 <1394122113-xsq3i6vw@n-horiguchi@ah.jp.nec.com>
 <5318E5AD.9090107@oracle.com>
Subject: Re: [PATCH] mm: add pte_present() check on existing hugetlb_entry
 callbacks
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, riel@redhat.com

On Thu, Mar 06, 2014 at 04:16:29PM -0500, Sasha Levin wrote:
> On 03/06/2014 11:08 AM, Naoya Horiguchi wrote:
> > And I found my patch was totally wrong because it should check
> > !pte_present(), not pte_present().
> > I'm testing fixed one (see below), and the problem seems not to reproduce
> > in my environment at least for now.
> > But I'm not 100% sure, so I need your double checking.
> 
> Nope, I still see the problem. Same NULL deref and trace as before.

Hmm, that's unfortunate.
I tried to find out how this reproduces and the root cause, but no luck.
So I suggest to add !PageHuge check before entering isolate_huge_page(),
which certainly gets over this problem.

I think "[PATCH] mm: add pte_present() check on existing hugetlb_entry"
is correct itself although it didn't fix this race.

Thanks,
Naoya
---
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Date: Fri, 7 Mar 2014 00:59:41 -0500
Subject: [PATCH] mm/mempolicy.c: add comment in queue_pages_hugetlb()

We have a race where we try to migrate an invalid page, resulting in
hitting VM_BUG_ON_PAGE in isolate_huge_page().
queue_pages_hugetlb() is OK to fail, so let's check !PageHuge before
queuing it with some comment as a todo reminder.

Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
---
 mm/mempolicy.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 494f401bbf6c..175353eb7396 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -530,6 +530,17 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long addr,
 	if (!pte_present(entry))
 		return 0;
 	page = pte_page(entry);
+
+	/*
+	 * TODO: Trinity found that page could be a non-hugepage. This is an
+	 * unexpected behavior, but it's not clear how this problem happens.
+	 * So let's simply skip such corner case. Page migration can often
+	 * fail for various reasons, so it's ok to just skip the address
+	 * unsuitable to hugepage migration.
+	 */
+	if (!PageHeadHuge(page))
+		return 0;
+
 	nid = page_to_nid(page);
 	if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
 		return 0;
-- 
1.8.5.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
