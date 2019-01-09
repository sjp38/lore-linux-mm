Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7C6598E009D
	for <linux-mm@kvack.org>; Tue,  8 Jan 2019 21:02:10 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id j5so5221110qtk.11
        for <linux-mm@kvack.org>; Tue, 08 Jan 2019 18:02:10 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id j14si753700qvm.164.2019.01.08.18.02.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Jan 2019 18:02:09 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] mm/hugetlb.c: teach follow_hugetlb_page() to handle FOLL_NOWAIT
Date: Tue,  8 Jan 2019 21:02:03 -0500
Message-Id: <20190109020203.26669-2-aarcange@redhat.com>
In-Reply-To: <20190109020203.26669-1-aarcange@redhat.com>
References: <20190109020203.26669-1-aarcange@redhat.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mike Kravetz <mike.kravetz@oracle.com>, Peter Xu <peterx@redhat.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>

hugetlb needs the same fix as faultin_nopage (which was applied in
96312e61282ae3f6537a562625706498cbc75594) or KVM hangs because it
thinks the mmap_sem was already released by hugetlb_fault() if it
returned VM_FAULT_RETRY, but it wasn't in the FOLL_NOWAIT case.

Fixes: ce53053ce378 ("kvm: switch get_user_page_nowait() to get_user_pages_unlocked()")
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Tested-by: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
Reported-by: "Dr. David Alan Gilbert" <dgilbert@redhat.com>
---
 mm/hugetlb.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index e37efd5d8318..b3622d7888c8 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -4301,7 +4301,8 @@ long follow_hugetlb_page(struct mm_struct *mm, struct vm_area_struct *vma,
 				break;
 			}
 			if (ret & VM_FAULT_RETRY) {
-				if (nonblocking)
+				if (nonblocking &&
+				    !(fault_flags & FAULT_FLAG_RETRY_NOWAIT))
 					*nonblocking = 0;
 				*nr_pages = 0;
 				/*
