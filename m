Return-Path: <SRS0=RIH8=R4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2AE7C43381
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:31 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 616A42087C
	for <linux-mm@archiver.kernel.org>; Mon, 25 Mar 2019 14:40:31 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 616A42087C
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8E79F6B000E; Mon, 25 Mar 2019 10:40:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8465E6B0010; Mon, 25 Mar 2019 10:40:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 673946B0266; Mon, 25 Mar 2019 10:40:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2CC5A6B000E
	for <linux-mm@kvack.org>; Mon, 25 Mar 2019 10:40:20 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id n64so8808904qkb.0
        for <linux-mm@kvack.org>; Mon, 25 Mar 2019 07:40:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rYJUG340wBNeS+cZiOqGWpjbsOovvX98Lu+ozYutPTM=;
        b=dyAZ00fcGaBlKBe2efyv9JI+Co+XLOZgUZaHIczgu/YKqm5lOco1MNg0QfMMkbZ/8J
         kJj3IUZzM5wHiQCEzLuLsid1e1Ve3AxW1SiNDqnAlny5MZJ96N+qWCb8lPQRGkObBzCJ
         qGC/tlYQRyD9FY97+HlBIqCtr02D/qPUJwGFdzdgsO0MGjR3SMU0giT39NecZVNke6mJ
         OOJvCBBGt/6U27m3KLvnhvGWTQqUZwF5IM+9gPS1I/KDHCYzO8U4K8IwlpLbsfEOe4RF
         gJ4P6737NH7HoZiuFrSvogpItkMdnkALBFqL5wZ0uPaPUO3HG3QsIF9P9bU8unSh2Br6
         amew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: APjAAAXS7KBJbpiLBMxHZvydImg8ctLHtmaiIy45a09+q9t6CVP7lM2u
	+wsS+/gMF565jWt8mxKEvJX6e8m1AA1HIUtvWqPL9f3IgM/SWF2mw3UnWBmomGr4NvLwd0C+mCh
	rsOK89GVrtwQi0v/yDXbQB3xp76XynvA2X7ieVdw50kKrLyOy585sBVIZj6vipeiEhg==
X-Received: by 2002:aed:3988:: with SMTP id m8mr21497224qte.177.1553524819912;
        Mon, 25 Mar 2019 07:40:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxalqpSmZX14XH9kbK09W7LmjxltAWWKk99GzgzhBuDtx1sJNwokcgvYZ0SRBE938DHeo0l
X-Received: by 2002:aed:3988:: with SMTP id m8mr21497165qte.177.1553524819197;
        Mon, 25 Mar 2019 07:40:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553524819; cv=none;
        d=google.com; s=arc-20160816;
        b=PpFWFibj9ONPDMtQMrU6ZUedf2PJkZEQIQCIrmm7NI/3Ug2Jv0hBiAJIejlYyCRFsv
         BU9o6ESgimUBBSmHIiLU/3TLKFhMx2XeaGUxOzrQXgk3ZOlwardaQNE+Tl9wWcfgjAk0
         XFw2s+S0Nv9ZqdgKrff8eEKxFyF8+5vKtjWJKa8WF+5XGIdf4IdaW0OcV8vgppe6K1W5
         tqsAIJeaaD5z2VscQZwOr9EZ00790oXESmnX3xXH484rAkiFl5pVwDeaSrRb4EJfAH3U
         ucWeKlsxX/R9XQmG0qCJHWuF3ADumtIr0rbEEqo5N2YAWWcWpN+vyPD9Kk5CJFJk0Rvn
         t5FA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=rYJUG340wBNeS+cZiOqGWpjbsOovvX98Lu+ozYutPTM=;
        b=wIs8R02Mf5w4SAyS+j6nEJkWPBv8P9mW4ibqVjS6TyXSm1GNiFd+H/FvGP90ZBvW5D
         ps5AVXXd1zd7BcQ6mxaclOkqRd6FiqMIQL2EYJAzCl99+TI9kSA0j6y2IgstILkmEF0y
         EYQHjleqyuj7QyE7QBngL40Uegd8KhZcM54QkQcAhxdhHmSXMjW73IkPTjeXIe75O4DL
         0iETiSyeHHPUkOl32Y2kjIexb3VSb1WjKR2QucCZI8qbBOIs8qiKVXNXO/vsSMXrCj93
         A8aVaO6gfF2FT8HawfadFdagHAodRH+WgDbEIgC76H6pCebPgM+0BM362Nl1q5scHuJV
         xfow==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 58si1093478qtr.13.2019.03.25.07.40.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 25 Mar 2019 07:40:19 -0700 (PDT)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 6A0E2307D860;
	Mon, 25 Mar 2019 14:40:18 +0000 (UTC)
Received: from localhost.localdomain.com (unknown [10.20.6.236])
	by smtp.corp.redhat.com (Postfix) with ESMTP id BDE5E1001DC8;
	Mon, 25 Mar 2019 14:40:17 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	John Hubbard <jhubbard@nvidia.com>,
	Dan Williams <dan.j.williams@intel.com>
Subject: [PATCH v2 05/11] mm/hmm: improve and rename hmm_vma_fault() to hmm_range_fault() v2
Date: Mon, 25 Mar 2019 10:40:05 -0400
Message-Id: <20190325144011.10560-6-jglisse@redhat.com>
In-Reply-To: <20190325144011.10560-1-jglisse@redhat.com>
References: <20190325144011.10560-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.48]); Mon, 25 Mar 2019 14:40:18 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Rename for consistency between code, comments and documentation. Also
improves the comments on all the possible returns values. Improve the
function by returning the number of populated entries in pfns array.

Changes since v1:
    - updated documentation
    - reformated some comments

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Reviewed-by: Ralph Campbell <rcampbell@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: John Hubbard <jhubbard@nvidia.com>
Cc: Dan Williams <dan.j.williams@intel.com>
---
 Documentation/vm/hmm.rst |  8 +---
 include/linux/hmm.h      | 13 +++++-
 mm/hmm.c                 | 91 +++++++++++++++++-----------------------
 3 files changed, 52 insertions(+), 60 deletions(-)

diff --git a/Documentation/vm/hmm.rst b/Documentation/vm/hmm.rst
index d9b27bdadd1b..61f073215a8d 100644
--- a/Documentation/vm/hmm.rst
+++ b/Documentation/vm/hmm.rst
@@ -190,13 +190,7 @@ When the device driver wants to populate a range of virtual addresses, it can
 use either::
 
   long hmm_range_snapshot(struct hmm_range *range);
-  int hmm_vma_fault(struct vm_area_struct *vma,
-                    struct hmm_range *range,
-                    unsigned long start,
-                    unsigned long end,
-                    hmm_pfn_t *pfns,
-                    bool write,
-                    bool block);
+  long hmm_range_fault(struct hmm_range *range, bool block);
 
 The first one (hmm_range_snapshot()) will only fetch present CPU page table
 entries and will not trigger a page fault on missing or non-present entries.
diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index 32206b0b1bfd..e9afd23c2eac 100644
--- a/include/linux/hmm.h
+++ b/include/linux/hmm.h
@@ -391,7 +391,18 @@ bool hmm_vma_range_done(struct hmm_range *range);
  *
  * See the function description in mm/hmm.c for further documentation.
  */
-int hmm_vma_fault(struct hmm_range *range, bool block);
+long hmm_range_fault(struct hmm_range *range, bool block);
+
+/* This is a temporary helper to avoid merge conflict between trees. */
+static inline int hmm_vma_fault(struct hmm_range *range, bool block)
+{
+	long ret = hmm_range_fault(range, block);
+	if (ret == -EBUSY)
+		ret = -EAGAIN;
+	else if (ret == -EAGAIN)
+		ret = -EBUSY;
+	return ret < 0 ? ret : 0;
+}
 
 /* Below are for HMM internal use only! Not to be used by device driver! */
 void hmm_mm_destroy(struct mm_struct *mm);
diff --git a/mm/hmm.c b/mm/hmm.c
index 91361aa74b8b..7860e63c3ba7 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -336,13 +336,13 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
 	flags |= write_fault ? FAULT_FLAG_WRITE : 0;
 	ret = handle_mm_fault(vma, addr, flags);
 	if (ret & VM_FAULT_RETRY)
-		return -EBUSY;
+		return -EAGAIN;
 	if (ret & VM_FAULT_ERROR) {
 		*pfn = range->values[HMM_PFN_ERROR];
 		return -EFAULT;
 	}
 
-	return -EAGAIN;
+	return -EBUSY;
 }
 
 static int hmm_pfns_bad(unsigned long addr,
@@ -368,7 +368,7 @@ static int hmm_pfns_bad(unsigned long addr,
  * @fault: should we fault or not ?
  * @write_fault: write fault ?
  * @walk: mm_walk structure
- * Returns: 0 on success, -EAGAIN after page fault, or page fault error
+ * Returns: 0 on success, -EBUSY after page fault, or page fault error
  *
  * This function will be called whenever pmd_none() or pte_none() returns true,
  * or whenever there is no page directory covering the virtual address range.
@@ -391,12 +391,12 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
 
 			ret = hmm_vma_do_fault(walk, addr, write_fault,
 					       &pfns[i]);
-			if (ret != -EAGAIN)
+			if (ret != -EBUSY)
 				return ret;
 		}
 	}
 
-	return (fault || write_fault) ? -EAGAIN : 0;
+	return (fault || write_fault) ? -EBUSY : 0;
 }
 
 static inline void hmm_pte_need_fault(const struct hmm_vma_walk *hmm_vma_walk,
@@ -527,11 +527,11 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 	uint64_t orig_pfn = *pfn;
 
 	*pfn = range->values[HMM_PFN_NONE];
-	cpu_flags = pte_to_hmm_pfn_flags(range, pte);
-	hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
-			   &fault, &write_fault);
+	fault = write_fault = false;
 
 	if (pte_none(pte)) {
+		hmm_pte_need_fault(hmm_vma_walk, orig_pfn, 0,
+				   &fault, &write_fault);
 		if (fault || write_fault)
 			goto fault;
 		return 0;
@@ -570,7 +570,7 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 				hmm_vma_walk->last = addr;
 				migration_entry_wait(vma->vm_mm,
 						     pmdp, addr);
-				return -EAGAIN;
+				return -EBUSY;
 			}
 			return 0;
 		}
@@ -578,6 +578,10 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 		/* Report error for everything else */
 		*pfn = range->values[HMM_PFN_ERROR];
 		return -EFAULT;
+	} else {
+		cpu_flags = pte_to_hmm_pfn_flags(range, pte);
+		hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
+				   &fault, &write_fault);
 	}
 
 	if (fault || write_fault)
@@ -628,7 +632,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		if (fault || write_fault) {
 			hmm_vma_walk->last = addr;
 			pmd_migration_entry_wait(vma->vm_mm, pmdp);
-			return -EAGAIN;
+			return -EBUSY;
 		}
 		return 0;
 	} else if (!pmd_present(pmd))
@@ -856,53 +860,34 @@ bool hmm_vma_range_done(struct hmm_range *range)
 EXPORT_SYMBOL(hmm_vma_range_done);
 
 /*
- * hmm_vma_fault() - try to fault some address in a virtual address range
+ * hmm_range_fault() - try to fault some address in a virtual address range
  * @range: range being faulted
  * @block: allow blocking on fault (if true it sleeps and do not drop mmap_sem)
- * Returns: 0 success, error otherwise (-EAGAIN means mmap_sem have been drop)
+ * Returns: number of valid pages in range->pfns[] (from range start
+ *          address). This may be zero. If the return value is negative,
+ *          then one of the following values may be returned:
+ *
+ *           -EINVAL  invalid arguments or mm or virtual address are in an
+ *                    invalid vma (ie either hugetlbfs or device file vma).
+ *           -ENOMEM: Out of memory.
+ *           -EPERM:  Invalid permission (for instance asking for write and
+ *                    range is read only).
+ *           -EAGAIN: If you need to retry and mmap_sem was drop. This can only
+ *                    happens if block argument is false.
+ *           -EBUSY:  If the the range is being invalidated and you should wait
+ *                    for invalidation to finish.
+ *           -EFAULT: Invalid (ie either no valid vma or it is illegal to access
+ *                    that range), number of valid pages in range->pfns[] (from
+ *                    range start address).
  *
  * This is similar to a regular CPU page fault except that it will not trigger
- * any memory migration if the memory being faulted is not accessible by CPUs.
+ * any memory migration if the memory being faulted is not accessible by CPUs
+ * and caller does not ask for migration.
  *
  * On error, for one virtual address in the range, the function will mark the
  * corresponding HMM pfn entry with an error flag.
- *
- * Expected use pattern:
- * retry:
- *   down_read(&mm->mmap_sem);
- *   // Find vma and address device wants to fault, initialize hmm_pfn_t
- *   // array accordingly
- *   ret = hmm_vma_fault(range, write, block);
- *   switch (ret) {
- *   case -EAGAIN:
- *     hmm_vma_range_done(range);
- *     // You might want to rate limit or yield to play nicely, you may
- *     // also commit any valid pfn in the array assuming that you are
- *     // getting true from hmm_vma_range_monitor_end()
- *     goto retry;
- *   case 0:
- *     break;
- *   case -ENOMEM:
- *   case -EINVAL:
- *   case -EPERM:
- *   default:
- *     // Handle error !
- *     up_read(&mm->mmap_sem)
- *     return;
- *   }
- *   // Take device driver lock that serialize device page table update
- *   driver_lock_device_page_table_update();
- *   hmm_vma_range_done(range);
- *   // Commit pfns we got from hmm_vma_fault()
- *   driver_unlock_device_page_table_update();
- *   up_read(&mm->mmap_sem)
- *
- * YOU MUST CALL hmm_vma_range_done() AFTER THIS FUNCTION RETURN SUCCESS (0)
- * BEFORE FREEING THE range struct OR YOU WILL HAVE SERIOUS MEMORY CORRUPTION !
- *
- * YOU HAVE BEEN WARNED !
  */
-int hmm_vma_fault(struct hmm_range *range, bool block)
+long hmm_range_fault(struct hmm_range *range, bool block)
 {
 	struct vm_area_struct *vma = range->vma;
 	unsigned long start = range->start;
@@ -974,7 +959,8 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 	do {
 		ret = walk_page_range(start, range->end, &mm_walk);
 		start = hmm_vma_walk.last;
-	} while (ret == -EAGAIN);
+		/* Keep trying while the range is valid. */
+	} while (ret == -EBUSY && range->valid);
 
 	if (ret) {
 		unsigned long i;
@@ -984,6 +970,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 			       range->end);
 		hmm_vma_range_done(range);
 		hmm_put(hmm);
+		return ret;
 	} else {
 		/*
 		 * Transfer hmm reference to the range struct it will be drop
@@ -993,9 +980,9 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 		range->hmm = hmm;
 	}
 
-	return ret;
+	return (hmm_vma_walk.last - range->start) >> PAGE_SHIFT;
 }
-EXPORT_SYMBOL(hmm_vma_fault);
+EXPORT_SYMBOL(hmm_range_fault);
 #endif /* IS_ENABLED(CONFIG_HMM_MIRROR) */
 
 
-- 
2.17.2

