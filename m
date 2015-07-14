Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0359003D3
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 09:58:50 -0400 (EDT)
Received: by padck2 with SMTP id ck2so6315350pad.0
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 06:58:50 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id cj2si1917646pdb.187.2015.07.14.06.58.48
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 06:58:49 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-4-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436550130-112636-4-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH 03/36] memcg: adjust to support new THP refcounting
Content-Transfer-Encoding: 7bit
Message-Id: <20150714135842.D7E9D8B@black.fi.intel.com>
Date: Tue, 14 Jul 2015 16:58:42 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill A. Shutemov wrote:
> As with rmap, with new refcounting we cannot rely on PageTransHuge() to
> check if we need to charge size of huge page form the cgroup. We need to
> get information from caller to know whether it was mapped with PMD or
> PTE.
> 
> We do uncharge when last reference on the page gone. At that point if we
> see PageTransHuge() it means we need to unchange whole huge page.
> 
> The tricky part is partial unmap -- when we try to unmap part of huge
> page. We don't do a special handing of this situation, meaning we don't
> uncharge the part of huge page unless last user is gone or
> split_huge_page() is triggered. In case of cgroup memory pressure
> happens the partial unmapped page will be split through shrinker. This
> should be good enough.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

checkpatch fixlet:

diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6dd365d1c488..117bedd02db2 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -1103,8 +1103,8 @@ static int unuse_pte(struct vm_area_struct *vma, pmd_t *pmd,
 	if (unlikely(!page))
 		return -ENOMEM;
 
-	if (mem_cgroup_try_charge(page, vma->vm_mm, GFP_KERNEL, &memcg, false))
-	{
+	if (mem_cgroup_try_charge(page, vma->vm_mm, GFP_KERNEL,
+				&memcg, false)) {
 		ret = -ENOMEM;
 		goto out_nolock;
 	}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
