Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f42.google.com (mail-ee0-f42.google.com [74.125.83.42])
	by kanga.kvack.org (Postfix) with ESMTP id F3BE46B017E
	for <linux-mm@kvack.org>; Wed, 19 Mar 2014 16:49:36 -0400 (EDT)
Received: by mail-ee0-f42.google.com with SMTP id d17so7122258eek.1
        for <linux-mm@kvack.org>; Wed, 19 Mar 2014 13:49:36 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id z42si28695062eel.272.2014.03.19.13.49.33
        for <linux-mm@kvack.org>;
        Wed, 19 Mar 2014 13:49:34 -0700 (PDT)
Date: Wed, 19 Mar 2014 16:49:28 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <532a02de.c2af0e0a.01a2.7654SMTPIN_ADDED_BROKEN@mx.google.com>
In-Reply-To: <5329C4CC.2000200@oracle.com>
References: <1395196179-4075-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <1395196179-4075-2-git-send-email-n-horiguchi@ah.jp.nec.com>
 <5329C4CC.2000200@oracle.com>
Subject: Re: [PATCH RESEND -mm 2/2] mm/mempolicy.c: add comment in
 queue_pages_hugetlb()
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: sasha.levin@oracle.com
Cc: akpm@linux-foundation.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 19, 2014 at 12:24:44PM -0400, Sasha Levin wrote:
> On 03/18/2014 10:29 PM, Naoya Horiguchi wrote:
> >We have a race where we try to migrate an invalid page, resulting in
> >hitting VM_BUG_ON_PAGE in isolate_huge_page().
> >queue_pages_hugetlb() is OK to fail, so let's check !PageHeadHuge to keep
> >invalid hugepage from queuing.
> >
> >Reported-by: Sasha Levin <sasha.levin@oracle.com>
> >Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >---
> >  mm/mempolicy.c | 11 +++++++++++
> >  1 file changed, 11 insertions(+)
> >
> >diff --git v3.14-rc7-mmotm-2014-03-18-16-37.orig/mm/mempolicy.c v3.14-rc7-mmotm-2014-03-18-16-37/mm/mempolicy.c
> >index 9d2ef4111a4c..ae6e2d9dc855 100644
> >--- v3.14-rc7-mmotm-2014-03-18-16-37.orig/mm/mempolicy.c
> >+++ v3.14-rc7-mmotm-2014-03-18-16-37/mm/mempolicy.c
> >@@ -530,6 +530,17 @@ static int queue_pages_hugetlb(pte_t *pte, unsigned long addr,
> >  	if (!pte_present(entry))
> >  		return 0;
> >  	page = pte_page(entry);
> >+
> >+	/*
> >+	 * Trinity found that page could be a non-hugepage. This is an
> >+	 * unexpected behavior, but it's not clear how this problem happens.
> >+	 * So let's simply skip such corner case. Page migration can often
> >+	 * fail for various reasons, so it's ok to just skip the address
> >+	 * unsuitable to hugepage migration.
> >+	 */
> >+	if (!PageHeadHuge(page))
> >+		return 0;
> >+
> >  	nid = page_to_nid(page);
> >  	if (node_isset(nid, *qp->nmask) == !!(flags & MPOL_MF_INVERT))
> >  		return 0;
> >
> 
> I have to say that I really dislike this method of solving the issue.

Yes, I understand that this is not the best solution.

> I think it's something fine to do for testing, but this will just hide this issue
> and will let it sneak upstream. I'm really not sure if the trace I've reported is
> the only codepath that would trigger it, so if we let it sneak upstream we're risking
> of someone hitting it some other way.

Unfortunately, I didn't have a reliable reproducer focusing on this problem
(trinity hits other errors rather than this in my trials, so it gave me no
crucial hint for my detailed analysis.)
I think that if reproduced differently this could give us another information
about how the problem happens.
What I'm suggesting here is not a final-form fix, but kind of "needinfo".
I must (and will) try to work on this more after LSFMM summit.

Thanks,
Naoya

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
