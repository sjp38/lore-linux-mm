Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id DDAE16B025F
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 19:00:38 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id 198so4158492wmx.2
        for <linux-mm@kvack.org>; Thu, 19 Oct 2017 16:00:38 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id f22si1170929edb.350.2017.10.19.16.00.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Oct 2017 16:00:37 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/1] mm:hugetlbfs: Fix hwpoison reserve accounting
Date: Thu, 19 Oct 2017 16:00:06 -0700
Message-Id: <20171019230007.17043-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@kernel.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Mike Kravetz <mike.kravetz@oracle.com>

The routine hugetlbfs_error_remove_page() incorrectly calls
hugetlb_fix_reserve_counts which will result in bad (negative)
reserved huge page counts.  The following patch addresses this
issue.

A follow up question/issue:
When a hugetlbfs page is poisoned, it appears as an 'in use'
huge page via all the external user visible metrics.  Even the
in internal counters think this is simply an 'in use' huge page.
This usually is not an issue.  However, it may be confusing if
someone adjusts the total number of huge pages.  For example,
if after poisoning a huge page I set the total number of huge
pages to zero, the poisoned page will be counted as 'surplus'.
I was thinking about keeping at least a bad page count (if not
a list) to avoid user confusion.  It may be overkill as I have
not given too much thought to this issue.  Anyone else have
thoughts here?

Mike Kravetz (1):
  mm:hugetlbfs: Fix hwpoison reserve accounting

 fs/hugetlbfs/inode.c | 5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
