Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f49.google.com (mail-pa0-f49.google.com [209.85.220.49])
	by kanga.kvack.org (Postfix) with ESMTP id BE5599003D3
	for <linux-mm@kvack.org>; Tue, 14 Jul 2015 10:01:59 -0400 (EDT)
Received: by pachj5 with SMTP id hj5so6319545pac.3
        for <linux-mm@kvack.org>; Tue, 14 Jul 2015 07:01:59 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id rp5si1982531pab.52.2015.07.14.07.01.58
        for <linux-mm@kvack.org>;
        Tue, 14 Jul 2015 07:01:59 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1436550130-112636-14-git-send-email-kirill.shutemov@linux.intel.com>
References: <1436550130-112636-1-git-send-email-kirill.shutemov@linux.intel.com>
 <1436550130-112636-14-git-send-email-kirill.shutemov@linux.intel.com>
Subject: RE: [PATCH 13/36] mm: drop tail page refcounting
Content-Transfer-Encoding: 7bit
Message-Id: <20150714140135.81C368B@black.fi.intel.com>
Date: Tue, 14 Jul 2015 17:01:35 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Christoph Lameter <cl@gentwo.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Steve Capper <steve.capper@linaro.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Kirill A. Shutemov wrote:
> Tail page refcounting is utterly complicated and painful to support.
> 
> It uses ->_mapcount on tail pages to store how many times this page is
> pinned. get_page() bumps ->_mapcount on tail page in addition to
> ->_count on head. This information is required by split_huge_page() to
> be able to distribute pins from head of compound page to tails during
> the split.
> 
> We will need ->_mapcount to account PTE mappings of subpages of the
> compound page. We eliminate need in current meaning of ->_mapcount in
> tail pages by forbidding split entirely if the page is pinned.
> 
> The only user of tail page refcounting is THP which is marked BROKEN for
> now.
> 
> Let's drop all this mess. It makes get_page() and put_page() much
> simpler.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Tested-by: Sasha Levin <sasha.levin@oracle.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>

checkpatch fixlet:

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 57fcb78a3cef..681997bccc52 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -493,7 +493,7 @@ static inline void init_page_count(struct page *page)
 	atomic_set(&page->_count, 1);
 }
 
-void __put_page(struct page* page);
+void __put_page(struct page *page);
 
 static inline void put_page(struct page *page)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
