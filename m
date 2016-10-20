Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id E92C56B0038
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 23:11:39 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id n85so12600974pfi.7
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 20:11:39 -0700 (PDT)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id h190si39663583pgc.331.2016.10.19.20.11.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 20:11:39 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH 0/1] mm/hugetlb: fix huge page reservation leak in private mapping error paths
Date: Wed, 19 Oct 2016 20:11:16 -0700
Message-Id: <1476933077-23091-1-git-send-email-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Michal Hocko <mhocko@suse.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jan Stancek <jstancek@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>

This issue was discovered by Jan Stancek as described in
https://lkml.kernel.org/r/57FF7BB4.1070202@redhat.com

Error paths in hugetlb_cow() and hugetlb_no_page() do not properly clean
up reservation entries when freeing a newly allocated huge page.  This
issue was introduced with commit 67961f9db8c4 ("mm/hugetlb: fix huge page
reserve accounting for private mappings).  That commit uses the information
in private mapping reserve maps to determine if a reservation was already
consumed.  This is important in the case of hole punch and truncate as the
pages are released, but reservation entries are not restored.

This patch restores the reserve entries in hugetlb_cow and hugetlb_no_page
such that reserve entries are consistent with the global reservation count.

The huge page reservation code is quite hard to follow, and this patch
makes it even more complex.  One thought I had was to change the way
hole punch and truncate work so that private mapping pages are not thrown
away.  This would eliminate the need for this patch as well as 67961f9db8c4.
It would change the existing semantics (as seen by the user) in this area,
but I believe the documentation (man pages) say the behavior is unspecified.
This could be a future change as well as rewriting the existing reservation
code to make it easier to understand/maintain.  Thoughts?

In any case, this patch addresses the immediate issue.

Mike Kravetz (1):
  mm/hugetlb: fix huge page reservation leak in private mapping error
    paths

 mm/hugetlb.c | 66 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 66 insertions(+)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
