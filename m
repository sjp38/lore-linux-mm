Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1616C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 62AE221881
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 62AE221881
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 523D76B0266; Fri,  9 Aug 2019 18:58:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4621D6B0269; Fri,  9 Aug 2019 18:58:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 34F376B026A; Fri,  9 Aug 2019 18:58:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 00C6C6B0266
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:58:57 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id q12so2366726pfl.14
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:58:56 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=UDxtL8HgVwQej+23KnshJs9viiQgpKVDDU8kXcefPc4=;
        b=WfisboBiobMit1we+9SqMocXtPFB+l2BsZuYUlgCP9FOo1ed7C9dXNuM4Qcv+saP8T
         DpnSv6wZcuFqEZcV2m5umklsKMwJjGlJbO9u7w7YFOKjlM1AQxa1yohv5OWgDOcDRxWm
         lUN87bn+S9CIuWoqQ7kO2IKFPSWX69mffWJMoSgvxGciDoDFCG/vbcmcilNQmjfmDVpn
         83k0YrJd3eU+TEVk9X7Gk+s+jd3ZxV6RB3/Wq8h0tSGZLi/IW701pGL8t6nwl7Y103iq
         qbxVQWRTw9jqKaRm3mrTN5r2PbA9qV/hp24/i48avC2xuaSklhAV5nof5D02RJ9J/Qud
         uLow==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWcpFBxgBB3/appH6dbKHOTfuAB0GDuJ+2dAFJE3r3rU4/HseE+
	ZwoBEo9LmOmjXqEx6nYRSyIgKNU10OQJnFFuvyvhhxqb3+8jskQgqcrFKDhOXjs7yAGmAopEgpx
	Pap6d0zdnVvrIaFqtZkKKsK8vVqQHj5hPQQmYD0gbKZloi0rUC2E7McX7pWvXtf0Qmg==
X-Received: by 2002:a17:90a:1904:: with SMTP id 4mr12038246pjg.116.1565391536655;
        Fri, 09 Aug 2019 15:58:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHW2VtmnF3We2Km/hdT3KqJ8UNzYqq/lrQB5OQ0FBrQxQIcmT5af0B/2jq2YgpxiSRbbZg
X-Received: by 2002:a17:90a:1904:: with SMTP id 4mr12038196pjg.116.1565391535707;
        Fri, 09 Aug 2019 15:58:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391535; cv=none;
        d=google.com; s=arc-20160816;
        b=RNT5x8uO/e7zZZAk6eIo3IwBtE1E8noBd1O9l5FB/zKH3Fj6eYieuTgcE+Qrr3HDVp
         dfNqav8pi+st9x219VPOTglZ0VA99JQTCgp8v01BI6bUHQCPIU8hL5W/9qPJXEdijqSO
         4eu1BoxP6pIl9Tuzi+PlmM57Y6S0MJpDsgCXNS+Ww4aAJozkaeUxzg6HqmFXP/j4Kq9x
         N6R7uaCATt61S3hjRHAdu6nYSxO2Ic15nzrm3+jES+fU741m7CEYkvpoafWXt7ALFTrK
         o1GLISXE0WFAaj2fWb67kieJLb0R/Q8UEG4+0lKTShIvkB0VGzGfibp2e50bLQZQVdnE
         Yv7g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=UDxtL8HgVwQej+23KnshJs9viiQgpKVDDU8kXcefPc4=;
        b=harRU2o2Hfy46SeFn9tNQwoqe7dkgoPKFf6doAdg0f1AoxyXCQBXXbFEk+Q/9a4299
         i+YBbdek+HWXpKdHu1s4d6LtO05JvbHa4z3CU1wy/D+I6RfPFmX2I02EvM2kL1XOocin
         vxcq8nHJYd62x+m1dprpGKdQHsWOH+wXEsTvhFDMhf58xmF2O+QPgoBHmw01YHjjUL8v
         NPr3k9b+Urs30EOu2pGf5ZJJeIJbJfNBtQc9gN2JTCO9oWMsWG0zC/5KoQCly9e1yOf6
         E0lI8jYOQ2TjEW1G+npVNJJA+EMrcXyIM+Zkd0wT0xAdyoBEA/ClTbpObCH7QmnDqEtC
         yXqg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id j1si54780464pfr.52.2019.08.09.15.58.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:58:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from orsmga005.jf.intel.com ([10.7.209.41])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:55 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="350623637"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by orsmga005-auth.jf.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:58:54 -0700
From: ira.weiny@intel.com
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Gunthorpe <jgg@ziepe.ca>,
	Dan Williams <dan.j.williams@intel.com>,
	Matthew Wilcox <willy@infradead.org>,
	Jan Kara <jack@suse.cz>,
	"Theodore Ts'o" <tytso@mit.edu>,
	John Hubbard <jhubbard@nvidia.com>,
	Michal Hocko <mhocko@suse.com>,
	Dave Chinner <david@fromorbit.com>,
	linux-xfs@vger.kernel.org,
	linux-rdma@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-nvdimm@lists.01.org,
	linux-ext4@vger.kernel.org,
	linux-mm@kvack.org,
	Ira Weiny <ira.weiny@intel.com>
Subject: [RFC PATCH v2 09/19] mm/gup: Introduce vaddr_pin structure
Date: Fri,  9 Aug 2019 15:58:23 -0700
Message-Id: <20190809225833.6657-10-ira.weiny@intel.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190809225833.6657-1-ira.weiny@intel.com>
References: <20190809225833.6657-1-ira.weiny@intel.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Ira Weiny <ira.weiny@intel.com>

Some subsystems need to pass owning file information to GUP calls to
allow for GUP to associate the "owning file" to any files being pinned
within the GUP call.

Introduce an object to specify this information and pass it down through
some of the GUP call stack.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 include/linux/mm.h |  9 +++++++++
 mm/gup.c           | 36 ++++++++++++++++++++++--------------
 2 files changed, 31 insertions(+), 14 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 04f22722b374..befe150d17be 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -971,6 +971,15 @@ static inline bool is_zone_device_page(const struct page *page)
 }
 #endif
 
+/**
+ * @f_owner The file who "owns this GUP"
+ * @mm The mm who "owns this GUP"
+ */
+struct vaddr_pin {
+	struct file *f_owner;
+	struct mm_struct *mm;
+};
+
 #ifdef CONFIG_DEV_PAGEMAP_OPS
 void __put_devmap_managed_page(struct page *page);
 DECLARE_STATIC_KEY_FALSE(devmap_managed_key);
diff --git a/mm/gup.c b/mm/gup.c
index 0b05e22ac05f..7a449500f0a6 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1005,7 +1005,8 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
 						struct page **pages,
 						struct vm_area_struct **vmas,
 						int *locked,
-						unsigned int flags)
+						unsigned int flags,
+						struct vaddr_pin *vaddr_pin)
 {
 	long ret, pages_done;
 	bool lock_dropped;
@@ -1165,7 +1166,8 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
 				       locked,
-				       gup_flags | FOLL_TOUCH | FOLL_REMOTE);
+				       gup_flags | FOLL_TOUCH | FOLL_REMOTE,
+				       NULL);
 }
 EXPORT_SYMBOL(get_user_pages_remote);
 
@@ -1320,7 +1322,8 @@ static long __get_user_pages_locked(struct task_struct *tsk,
 		struct mm_struct *mm, unsigned long start,
 		unsigned long nr_pages, struct page **pages,
 		struct vm_area_struct **vmas, int *locked,
-		unsigned int foll_flags)
+		unsigned int foll_flags,
+		struct vaddr_pin *vaddr_pin)
 {
 	struct vm_area_struct *vma;
 	unsigned long vm_flags;
@@ -1504,7 +1507,7 @@ static long check_and_migrate_cma_pages(struct task_struct *tsk,
 		 */
 		nr_pages = __get_user_pages_locked(tsk, mm, start, nr_pages,
 						   pages, vmas, NULL,
-						   gup_flags);
+						   gup_flags, NULL);
 
 		if ((nr_pages > 0) && migrate_allow) {
 			drain_allow = true;
@@ -1537,7 +1540,8 @@ static long __gup_longterm_locked(struct task_struct *tsk,
 				  unsigned long nr_pages,
 				  struct page **pages,
 				  struct vm_area_struct **vmas,
-				  unsigned int gup_flags)
+				  unsigned int gup_flags,
+				  struct vaddr_pin *vaddr_pin)
 {
 	struct vm_area_struct **vmas_tmp = vmas;
 	unsigned long flags = 0;
@@ -1558,7 +1562,7 @@ static long __gup_longterm_locked(struct task_struct *tsk,
 	}
 
 	rc = __get_user_pages_locked(tsk, mm, start, nr_pages, pages,
-				     vmas_tmp, NULL, gup_flags);
+				     vmas_tmp, NULL, gup_flags, vaddr_pin);
 
 	if (gup_flags & FOLL_LONGTERM) {
 		memalloc_nocma_restore(flags);
@@ -1588,10 +1592,11 @@ static __always_inline long __gup_longterm_locked(struct task_struct *tsk,
 						  unsigned long nr_pages,
 						  struct page **pages,
 						  struct vm_area_struct **vmas,
-						  unsigned int flags)
+						  unsigned int flags,
+						  struct vaddr_pin *vaddr_pin)
 {
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, pages, vmas,
-				       NULL, flags);
+				       NULL, flags, vaddr_pin);
 }
 #endif /* CONFIG_FS_DAX || CONFIG_CMA */
 
@@ -1607,7 +1612,8 @@ long get_user_pages(unsigned long start, unsigned long nr_pages,
 		struct vm_area_struct **vmas)
 {
 	return __gup_longterm_locked(current, current->mm, start, nr_pages,
-				     pages, vmas, gup_flags | FOLL_TOUCH);
+				     pages, vmas, gup_flags | FOLL_TOUCH,
+				     NULL);
 }
 EXPORT_SYMBOL(get_user_pages);
 
@@ -1647,7 +1653,7 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
 				       pages, NULL, locked,
-				       gup_flags | FOLL_TOUCH);
+				       gup_flags | FOLL_TOUCH, NULL);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
@@ -1684,7 +1690,7 @@ long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 
 	down_read(&mm->mmap_sem);
 	ret = __get_user_pages_locked(current, mm, start, nr_pages, pages, NULL,
-				      &locked, gup_flags | FOLL_TOUCH);
+				      &locked, gup_flags | FOLL_TOUCH, NULL);
 	if (locked)
 		up_read(&mm->mmap_sem);
 	return ret;
@@ -2377,7 +2383,8 @@ int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
 EXPORT_SYMBOL_GPL(__get_user_pages_fast);
 
 static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
-				   unsigned int gup_flags, struct page **pages)
+				   unsigned int gup_flags, struct page **pages,
+				   struct vaddr_pin *vaddr_pin)
 {
 	int ret;
 
@@ -2389,7 +2396,8 @@ static int __gup_longterm_unlocked(unsigned long start, int nr_pages,
 		down_read(&current->mm->mmap_sem);
 		ret = __gup_longterm_locked(current, current->mm,
 					    start, nr_pages,
-					    pages, NULL, gup_flags);
+					    pages, NULL, gup_flags,
+					    vaddr_pin);
 		up_read(&current->mm->mmap_sem);
 	} else {
 		ret = get_user_pages_unlocked(start, nr_pages,
@@ -2448,7 +2456,7 @@ int get_user_pages_fast(unsigned long start, int nr_pages,
 		pages += nr;
 
 		ret = __gup_longterm_unlocked(start, nr_pages - nr,
-					      gup_flags, pages);
+					      gup_flags, pages, NULL);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
-- 
2.20.1

