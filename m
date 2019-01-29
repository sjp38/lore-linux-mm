Return-Path: <SRS0=Ydgi=QF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 13AC7C169C4
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C0D7E20989
	for <linux-mm@archiver.kernel.org>; Tue, 29 Jan 2019 16:54:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C0D7E20989
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 407298E0006; Tue, 29 Jan 2019 11:54:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 389FB8E0001; Tue, 29 Jan 2019 11:54:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C2A98E0006; Tue, 29 Jan 2019 11:54:45 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f197.google.com (mail-qk1-f197.google.com [209.85.222.197])
	by kanga.kvack.org (Postfix) with ESMTP id DE81A8E0001
	for <linux-mm@kvack.org>; Tue, 29 Jan 2019 11:54:44 -0500 (EST)
Received: by mail-qk1-f197.google.com with SMTP id d196so22331183qkb.6
        for <linux-mm@kvack.org>; Tue, 29 Jan 2019 08:54:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=yqdJDvmMZhZHyM6z9qE/KfFqFLTwNaQykLYJ1YaZ0HY=;
        b=GZBADnDJ+8yeHzujUU/CfTvTGIsUrIV4HIhuKtqjXY9XfTuuagZw4QB23bAnsAp5PK
         eVAeyuH6zhyl2XJ8ly/YV4nXa2DE3YzjbMNXJX9zke8cHwqG6CcAHFVw5pOHMTiaHN6f
         YZK5FhnA3UFGuryLBCJ7PamfZ9+g63cfzRx8d/dnk2qBH1c+Ilm0lgGSmszdqdCyYbQ6
         056Bu9s8x3HJgQ2qUhlcziHBd+epcgzpVfRQQBV4yfo1Q/xIN1YdQqsvzXBMwfr2Xwi8
         wE/f2daUXvgT9xfaoV+2iE+nGsYJiYFbYo2d2E+PNlxCK8b0GnE6xRZoiRyuApmXBIpo
         wXDA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
X-Gm-Message-State: AJcUukfZAtroc/sOYtoeAFl4SQPOnQ6U/X7W721WJmKozetkCNOv27EJ
	CVmCOjaupc+EYpDCM0QnLknZpPrpHtvDIxlfu/tIho0A+fqVf1h3M84yOvce6aOeyveppyAbJui
	yGYRiNmp4WsAMlnmzKtM8G9NJ/OQPNZIjoD+rEQv98tMZk4InjP1bJDtuf/qS4m2Urw==
X-Received: by 2002:a0c:9257:: with SMTP id 23mr24850162qvz.142.1548780884641;
        Tue, 29 Jan 2019 08:54:44 -0800 (PST)
X-Google-Smtp-Source: ALg8bN4bqIZ/Id/dcbMDM5OHrgYthFOA+UVQo5tuq7Jy/4eyD2za3yP7/0o7DtMOc8Yyyuwxnr32
X-Received: by 2002:a0c:9257:: with SMTP id 23mr24850123qvz.142.1548780884028;
        Tue, 29 Jan 2019 08:54:44 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1548780884; cv=none;
        d=google.com; s=arc-20160816;
        b=iGK9RplzcCecRjJ41RKNFjgewqG2KGyg75Lyt887NCBJpAPuRmnmntB/Y8yhdduX2+
         xQYi+DB6UjCiOuvSHGhxugFH+8rOHVLa4MAvZlsmL7vsyaMU1rQsy0LGc3z+1hTdjQnF
         QbcUPTIoA3ohiu89Zbuba5xc67cOsLWssE8B3UWJs3J3CjMyviiJ36UFszu3owW4sZFN
         C+lXBr9SiJVsoN7AFnUtWBsx70J4+upgIzjvalL7nV0fWRETEgWJQKoFNJvCc1myTTaw
         rKbStA97SwCnydv6V5jWyofn5lcE0ABOHNJKMLbcCa8fMvENUXPpjid7JynBDS/pLoPM
         6p8Q==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=yqdJDvmMZhZHyM6z9qE/KfFqFLTwNaQykLYJ1YaZ0HY=;
        b=C2ik/k+nKqWtYbFSubJ0/M4LOohqnrysOrQ3Fi81qSrEgOGQzwi1qkN1GZTGmKEXm0
         +C901/yyllkpwhd1VKSGoAqXYBbLPk8kE+pZWzAI6gU4pagWiWzvkpZ23s4IbJ13K/mA
         qzcfmeGYjtVAsGVa0ZOAtQgmsJabJ7kui7ogNtV93aYXuR4mkm4MWCfZuEifCDkbfCkh
         9uWYgEsKRHW9MLikUtxgWapugPTWIVJptQnqSomeQjGVoKSt+iIptcR0zsTj8BrV8Wt7
         E0pQgGsWFg4NX0vhWZybiRWjrR2UaB+b33AnMBKd7MFLjCKbG3MfrcLSfFDh53fiKt87
         Qi7g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g51si200588qtc.224.2019.01.29.08.54.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Jan 2019 08:54:44 -0800 (PST)
Received-SPF: pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) client-ip=209.132.183.28;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of jglisse@redhat.com designates 209.132.183.28 as permitted sender) smtp.mailfrom=jglisse@redhat.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=redhat.com
Received: from smtp.corp.redhat.com (int-mx07.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 2D7C3A4D21;
	Tue, 29 Jan 2019 16:54:43 +0000 (UTC)
Received: from localhost.localdomain.com (ovpn-122-2.rdu2.redhat.com [10.10.122.2])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 2772C102BCEB;
	Tue, 29 Jan 2019 16:54:42 +0000 (UTC)
From: jglisse@redhat.com
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Ralph Campbell <rcampbell@nvidia.com>,
	John Hubbard <jhubbard@nvidia.com>
Subject: [PATCH 04/10] mm/hmm: improve and rename hmm_vma_fault() to hmm_range_fault()
Date: Tue, 29 Jan 2019 11:54:22 -0500
Message-Id: <20190129165428.3931-5-jglisse@redhat.com>
In-Reply-To: <20190129165428.3931-1-jglisse@redhat.com>
References: <20190129165428.3931-1-jglisse@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 2.84 on 10.5.11.22
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.38]); Tue, 29 Jan 2019 16:54:43 +0000 (UTC)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Jérôme Glisse <jglisse@redhat.com>

Rename for consistency between code, comments and documentation. Also
improves the comments on all the possible returns values. Improve the
function by returning the number of populated entries in pfns array.

Signed-off-by: Jérôme Glisse <jglisse@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Ralph Campbell <rcampbell@nvidia.com>
Cc: John Hubbard <jhubbard@nvidia.com>
---
 include/linux/hmm.h | 13 ++++++-
 mm/hmm.c            | 93 ++++++++++++++++++++-------------------------
 2 files changed, 53 insertions(+), 53 deletions(-)

diff --git a/include/linux/hmm.h b/include/linux/hmm.h
index ddf49c1b1f5e..ccf2b630447e 100644
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
index 0d9ecd3337e5..04235455b4d2 100644
--- a/mm/hmm.c
+++ b/mm/hmm.c
@@ -344,13 +344,13 @@ static int hmm_vma_do_fault(struct mm_walk *walk, unsigned long addr,
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
@@ -376,7 +376,7 @@ static int hmm_pfns_bad(unsigned long addr,
  * @fault: should we fault or not ?
  * @write_fault: write fault ?
  * @walk: mm_walk structure
- * Returns: 0 on success, -EAGAIN after page fault, or page fault error
+ * Returns: 0 on success, -EBUSY after page fault, or page fault error
  *
  * This function will be called whenever pmd_none() or pte_none() returns true,
  * or whenever there is no page directory covering the virtual address range.
@@ -399,12 +399,12 @@ static int hmm_vma_walk_hole_(unsigned long addr, unsigned long end,
 
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
@@ -535,11 +535,11 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
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
@@ -578,7 +578,7 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 				hmm_vma_walk->last = addr;
 				migration_entry_wait(vma->vm_mm,
 						     pmdp, addr);
-				return -EAGAIN;
+				return -EBUSY;
 			}
 			return 0;
 		}
@@ -586,6 +586,10 @@ static int hmm_vma_handle_pte(struct mm_walk *walk, unsigned long addr,
 		/* Report error for everything else */
 		*pfn = range->values[HMM_PFN_ERROR];
 		return -EFAULT;
+	} else {
+		cpu_flags = pte_to_hmm_pfn_flags(range, pte);
+		hmm_pte_need_fault(hmm_vma_walk, orig_pfn, cpu_flags,
+				   &fault, &write_fault);
 	}
 
 	if (fault || write_fault)
@@ -636,7 +640,7 @@ static int hmm_vma_walk_pmd(pmd_t *pmdp,
 		if (fault || write_fault) {
 			hmm_vma_walk->last = addr;
 			pmd_migration_entry_wait(vma->vm_mm, pmdp);
-			return -EAGAIN;
+			return -EBUSY;
 		}
 		return 0;
 	} else if (!pmd_present(pmd))
@@ -858,53 +862,36 @@ bool hmm_vma_range_done(struct hmm_range *range)
 EXPORT_SYMBOL(hmm_vma_range_done);
 
 /*
- * hmm_vma_fault() - try to fault some address in a virtual address range
+ * hmm_range_fault() - try to fault some address in a virtual address range
  * @range: range being faulted
  * @block: allow blocking on fault (if true it sleeps and do not drop mmap_sem)
- * Returns: 0 success, error otherwise (-EAGAIN means mmap_sem have been drop)
+ * Returns: 0 on success ortherwise:
+ *      -EINVAL:
+ *              Invalid argument
+ *      -ENOMEM:
+ *              Out of memory.
+ *      -EPERM:
+ *              Invalid permission (for instance asking for write and range
+ *              is read only).
+ *      -EAGAIN:
+ *              If you need to retry and mmap_sem was drop. This can only
+ *              happens if block argument is false.
+ *      -EBUSY:
+ *              If the the range is being invalidated and you should wait for
+ *              invalidation to finish.
+ *      -EFAULT:
+ *              Invalid (ie either no valid vma or it is illegal to access that
+ *              range), number of valid pages in range->pfns[] (from range start
+ *              address).
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
@@ -976,7 +963,8 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 	do {
 		ret = walk_page_range(start, range->end, &mm_walk);
 		start = hmm_vma_walk.last;
-	} while (ret == -EAGAIN);
+		/* Keep trying while the range is valid. */
+	} while (ret == -EBUSY && range->valid);
 
 	if (ret) {
 		unsigned long i;
@@ -986,6 +974,7 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
 			       range->end);
 		hmm_vma_range_done(range);
 		hmm_put(hmm);
+		return ret;
 	} else {
 		/*
 		 * Transfer hmm reference to the range struct it will be drop
@@ -995,9 +984,9 @@ int hmm_vma_fault(struct hmm_range *range, bool block)
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

