Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f177.google.com (mail-vc0-f177.google.com [209.85.220.177])
	by kanga.kvack.org (Postfix) with ESMTP id A49076B0035
	for <linux-mm@kvack.org>; Mon,  4 Aug 2014 11:29:56 -0400 (EDT)
Received: by mail-vc0-f177.google.com with SMTP id hy4so11165665vcb.36
        for <linux-mm@kvack.org>; Mon, 04 Aug 2014 08:29:55 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u2si29107746qap.21.2014.08.04.08.29.53
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 04 Aug 2014 08:29:54 -0700 (PDT)
Date: Mon, 4 Aug 2014 11:29:00 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [PATCH v2 1/3] mm/hugetlb: take refcount under page table lock
 in follow_huge_pmd()
Message-ID: <20140804152900.GA29316@nhori.bos.redhat.com>
References: <1406914663-8631-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20140801145358.0d673fc05235d941ca9dec0e@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140801145358.0d673fc05235d941ca9dec0e@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Hugh Dickins <hughd@google.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Naoya Horiguchi <nao.horiguchi@gmail.com>

On Fri, Aug 01, 2014 at 02:53:58PM -0700, Andrew Morton wrote:
...
> > --- mmotm-2014-07-22-15-58.orig/mm/hugetlb.c
> > +++ mmotm-2014-07-22-15-58/mm/hugetlb.c
> > @@ -3687,6 +3687,33 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
> >  
> >  #endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
> >  
> > +struct page *follow_huge_pmd_lock(struct vm_area_struct *vma,
> > +				unsigned long address, pmd_t *pmd, int flags)
> 
> Some documentation here wouldn't hurt.  Why it exists, what it does. 
> And especially: any preconditions to calling it (ie: locking).

Sorry, I missed this comment.
How about this?

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 1da7ca2e2a02..923465c0b47f 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -3693,6 +3693,14 @@ follow_huge_pud(struct mm_struct *mm, unsigned long address,
 
 #endif /* CONFIG_ARCH_WANT_GENERAL_HUGETLB */
 
+/*
+ * This function calls the architecture dependent variant follow_huge_pmd()
+ * with holding page table lock depending on FOLL_GET.
+ * Whether hugepage migration is supported or not, follow() can be called
+ * with FOLL_GET from do_move_page_to_node_array(), so we need do this in
+ * common code.
+ * Should be called under read mmap_sem.
+ */
 struct page *follow_huge_pmd_lock(struct vm_area_struct *vma,
 				unsigned long address, pmd_t *pmd, int flags)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
