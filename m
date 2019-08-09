Return-Path: <SRS0=XQg4=WF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 104A5C433FF
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B866E21743
	for <linux-mm@archiver.kernel.org>; Fri,  9 Aug 2019 22:59:12 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B866E21743
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=intel.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 01AAC6B026D; Fri,  9 Aug 2019 18:59:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F12E56B026E; Fri,  9 Aug 2019 18:59:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DAE796B026F; Fri,  9 Aug 2019 18:59:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id A49776B026D
	for <linux-mm@kvack.org>; Fri,  9 Aug 2019 18:59:05 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id x19so60559963pgx.1
        for <linux-mm@kvack.org>; Fri, 09 Aug 2019 15:59:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nohmS51GXUJzNN3q6yvtJCXnxdHqg5ERGj/5DxVBf84=;
        b=nGKgqZcvSXSzltIaxP7B6IFdxS3Xwlret/3pXK0eszNN3ndJUbOfDApksN8qeAu536
         EvbTHEx6L8hglaHAvv8E9sjr6lndH1L7u7+oBL8AgRhoRdc1QIfzIHvYYfyEGrS7kOrj
         cu0fhdJr7zEkkCnIuZ/xWkTZ+LlhPws+Ie7mLNridqeckyD/4rw+4OAR2s4QkzvvgGWW
         POr+od9jJiN8aDOEbPgS1d0hDuxAGPmtZ+xs1kCrs8XoquPMby4YrzGGBoR/Gba4ewZN
         khPXk0HpjMVZuHzv/L+w3VSpBgRElozdNK7BCvk9ZupBV09SjGYaQ9MYFkaRcOwhrng7
         5TwQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Gm-Message-State: APjAAAWFy65VpQ2Tbw4j/1/rared4VLK/+BJczK2FafE/Y6u9yJ19vuR
	26yLJLjLeM6nl+sRdQEK4Y6HoRiP84eyTxg34RA2VmUpu3KeE3EnqKjgwjG9xZl/WHbRfM0FXEt
	EsJpBPnX7c+HiInEIZOBDO6eedhqwmIskU1bsYlIXfqde6GiMiy6zW7yh3l0X0k0d8w==
X-Received: by 2002:a17:90a:384d:: with SMTP id l13mr11973505pjf.86.1565391545278;
        Fri, 09 Aug 2019 15:59:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxueCBAbJVGygzqT3XEBU7Hq4bgdVFO8mJjfogkYlginceH+b5NxUdZwUwnTOWz1uhgV8Ix
X-Received: by 2002:a17:90a:384d:: with SMTP id l13mr11973447pjf.86.1565391544204;
        Fri, 09 Aug 2019 15:59:04 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565391544; cv=none;
        d=google.com; s=arc-20160816;
        b=VXFYIKbRo2QcLev47BOKK3TftYJvtF2CLycXj/Flogc2djvEf+WsBjzvBtzr+1GDgd
         3PZa7KfOOMi/E7e8gEH0c7hUVLz+zCBMK3XOpSpMVqNOcAtnFQNdu/12Iqhr2TNHCJfl
         X4Y+N6UheOV7dAqwJSq256SYQtEibYyl5MaRqve/CcySJx7TOnb6m/YGFCU+7BwQdW9u
         bDCTBf7To5p5T3lU38MIMGTzt0vg1HITaojGJYz1IsjJjf8YGVA1Tic85zWYZFpTvaK0
         2eEEtN/cE7qRcehqILNE4ndaSJFMBonS9C+RzJkhFmfFZc1IRdfWpLZhm0YMOXvSCjqK
         qq4w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=nohmS51GXUJzNN3q6yvtJCXnxdHqg5ERGj/5DxVBf84=;
        b=0NyhsUsLOxMFvvM1Xufcq1D0zvKbwiAwWo6iCZDiIW/sSfYe10xN1sRIED75qIaaUp
         9v81ygDdoKW+o1MH4uPJW+NIuWUZtAC64XnH9LGjKOcAL5/ZL690qox4SSNt6D71IYNA
         7G5SeqF6hpwYO0quJp6PInD8jxa1vTJ5qwHihJ2E88xr4NG7ONePMLvK4VS2oKQbhH5r
         +aRDRmVWhqPE2N3ZppzusATTdjC1PrFAcHWiqOBbEDZkPopA9UYrC1heuZpNDtKgFZ4L
         FBi1uYdRpMDCfC6K4CG1vcEqR0byfp2rpDlOyYeAFj3lXzD0zktFEtd/VxybZRf6UDXN
         qFgA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id h189si55552068pgc.236.2019.08.09.15.59.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Aug 2019 15:59:04 -0700 (PDT)
Received-SPF: pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) client-ip=192.55.52.115;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ira.weiny@intel.com designates 192.55.52.115 as permitted sender) smtp.mailfrom=ira.weiny@intel.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=intel.com
X-Amp-Result: SKIPPED(no attachment in message)
X-Amp-File-Uploaded: False
Received: from fmsmga008.fm.intel.com ([10.253.24.58])
  by fmsmga103.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:03 -0700
X-IronPort-AV: E=Sophos;i="5.64,367,1559545200"; 
   d="scan'208";a="175282026"
Received: from iweiny-desk2.sc.intel.com (HELO localhost) ([10.3.52.157])
  by fmsmga008-auth.fm.intel.com with ESMTP/TLS/DHE-RSA-AES256-GCM-SHA384; 09 Aug 2019 15:59:03 -0700
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
Subject: [RFC PATCH v2 14/19] fs/locks: Associate file pins while performing GUP
Date: Fri,  9 Aug 2019 15:58:28 -0700
Message-Id: <20190809225833.6657-15-ira.weiny@intel.com>
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

When a file back area is being pinned add the appropriate file pin
information to the appropriate file or mm owner.  This information can
then be used by admins to determine who is causing a failure to change
the layout of a file.

Signed-off-by: Ira Weiny <ira.weiny@intel.com>
---
 fs/locks.c         | 195 ++++++++++++++++++++++++++++++++++++++++++++-
 include/linux/mm.h |  35 +++++++-
 mm/gup.c           |   8 +-
 mm/huge_memory.c   |   4 +-
 4 files changed, 230 insertions(+), 12 deletions(-)

diff --git a/fs/locks.c b/fs/locks.c
index 14892c84844b..02c525446d25 100644
--- a/fs/locks.c
+++ b/fs/locks.c
@@ -168,6 +168,7 @@
 #include <linux/pid_namespace.h>
 #include <linux/hashtable.h>
 #include <linux/percpu.h>
+#include <linux/sched/mm.h>
 
 #define CREATE_TRACE_POINTS
 #include <trace/events/filelock.h>
@@ -2972,9 +2973,194 @@ static int __init filelock_init(void)
 }
 core_initcall(filelock_init);
 
+static struct file_file_pin *alloc_file_file_pin(struct inode *inode,
+						 struct file *file)
+{
+	struct file_file_pin *fp = kzalloc(sizeof(*fp), GFP_ATOMIC);
+
+	if (!fp)
+		return ERR_PTR(-ENOMEM);
+
+	INIT_LIST_HEAD(&fp->list);
+	kref_init(&fp->ref);
+	return fp;
+}
+
+static int add_file_pin_to_f_owner(struct vaddr_pin *vaddr_pin,
+				   struct inode *inode,
+				   struct file *file)
+{
+	struct file_file_pin *fp;
+
+	list_for_each_entry(fp, &vaddr_pin->f_owner->file_pins, list) {
+		if (fp->file == file) {
+			kref_get(&fp->ref);
+			return 0;
+		}
+	}
+
+	fp = alloc_file_file_pin(inode, file);
+	if (IS_ERR(fp))
+		return PTR_ERR(fp);
+
+	fp->file = get_file(file);
+	/* NOTE no reference needed here.
+	 * It is expected that the caller holds a reference to the owner file
+	 * for the duration of this pin.
+	 */
+	fp->f_owner = vaddr_pin->f_owner;
+
+	spin_lock(&fp->f_owner->fp_lock);
+	list_add(&fp->list, &fp->f_owner->file_pins);
+	spin_unlock(&fp->f_owner->fp_lock);
+
+	return 0;
+}
+
+static void release_file_file_pin(struct kref *ref)
+{
+	struct file_file_pin *fp = container_of(ref, struct file_file_pin, ref);
+
+	spin_lock(&fp->f_owner->fp_lock);
+	list_del(&fp->list);
+	spin_unlock(&fp->f_owner->fp_lock);
+	fput(fp->file);
+	kfree(fp);
+}
+
+static struct mm_file_pin *alloc_mm_file_pin(struct inode *inode,
+					     struct file *file)
+{
+	struct mm_file_pin *fp = kzalloc(sizeof(*fp), GFP_ATOMIC);
+
+	if (!fp)
+		return ERR_PTR(-ENOMEM);
+
+	INIT_LIST_HEAD(&fp->list);
+	kref_init(&fp->ref);
+	return fp;
+}
+
+/**
+ * This object bridges files and the mm struct for the purpose of tracking
+ * which files have GUP pins on them.
+ */
+static int add_file_pin_to_mm(struct vaddr_pin *vaddr_pin, struct inode *inode,
+			      struct file *file)
+{
+	struct mm_file_pin *fp;
+
+	list_for_each_entry(fp, &vaddr_pin->mm->file_pins, list) {
+		if (fp->inode == inode) {
+			kref_get(&fp->ref);
+			return 0;
+		}
+	}
+
+	fp = alloc_mm_file_pin(inode, file);
+	if (IS_ERR(fp))
+		return PTR_ERR(fp);
+
+	fp->inode = igrab(inode);
+	if (!fp->inode) {
+		kfree(fp);
+		return -EFAULT;
+	}
+
+	fp->file = get_file(file);
+	fp->mm = vaddr_pin->mm;
+	mmgrab(fp->mm);
+
+	spin_lock(&fp->mm->fp_lock);
+	list_add(&fp->list, &fp->mm->file_pins);
+	spin_unlock(&fp->mm->fp_lock);
+
+	return 0;
+}
+
+static void release_mm_file_pin(struct kref *ref)
+{
+	struct mm_file_pin *fp = container_of(ref, struct mm_file_pin, ref);
+
+	spin_lock(&fp->mm->fp_lock);
+	list_del(&fp->list);
+	spin_unlock(&fp->mm->fp_lock);
+
+	mmdrop(fp->mm);
+	fput(fp->file);
+	iput(fp->inode);
+	kfree(fp);
+}
+
+static void remove_file_file_pin(struct vaddr_pin *vaddr_pin)
+{
+	struct file_file_pin *fp;
+	struct file_file_pin *tmp;
+
+	list_for_each_entry_safe(fp, tmp, &vaddr_pin->f_owner->file_pins,
+				 list) {
+		kref_put(&fp->ref, release_file_file_pin);
+	}
+}
+
+static void remove_mm_file_pin(struct vaddr_pin *vaddr_pin,
+			       struct inode *inode)
+{
+	struct mm_file_pin *fp;
+	struct mm_file_pin *tmp;
+
+	list_for_each_entry_safe(fp, tmp, &vaddr_pin->mm->file_pins, list) {
+		if (fp->inode == inode)
+			kref_put(&fp->ref, release_mm_file_pin);
+	}
+}
+
+static bool add_file_pin(struct vaddr_pin *vaddr_pin, struct inode *inode,
+			 struct file *file)
+{
+	bool ret = true;
+
+	if (!vaddr_pin || (!vaddr_pin->f_owner && !vaddr_pin->mm))
+		return false;
+
+	if (vaddr_pin->f_owner) {
+		if (add_file_pin_to_f_owner(vaddr_pin, inode, file))
+			ret = false;
+	} else {
+		if (add_file_pin_to_mm(vaddr_pin, inode, file))
+			ret = false;
+	}
+
+	return ret;
+}
+
+void mapping_release_file(struct vaddr_pin *vaddr_pin, struct page *page)
+{
+	struct inode *inode;
+
+	if (WARN_ON(!page) || WARN_ON(!vaddr_pin) ||
+	    WARN_ON(!vaddr_pin->mm && !vaddr_pin->f_owner))
+		return;
+
+	if (PageAnon(page) ||
+	    !page->mapping ||
+	    !page->mapping->host)
+		return;
+
+	inode = page->mapping->host;
+
+	if (vaddr_pin->f_owner)
+		remove_file_file_pin(vaddr_pin);
+	else
+		remove_mm_file_pin(vaddr_pin, inode);
+}
+EXPORT_SYMBOL_GPL(mapping_release_file);
+
 /**
  * mapping_inode_has_layout - ensure a file mapped page has a layout lease
  * taken
+ * @vaddr_pin: pin owner information to store with this pin if a proper layout
+ * is lease is found.
  * @page: page we are trying to GUP
  *
  * This should only be called on DAX pages.  DAX pages which are mapped through
@@ -2983,9 +3169,12 @@ core_initcall(filelock_init);
  * This allows the user to opt-into the fact that truncation operations will
  * fail for the duration of the pin.
  *
+ * Also if the proper layout leases are found we store pining information into
+ * the owner passed in via the vaddr_pin structure.
+ *
  * Return true if the page has a LAYOUT lease associated with it's file.
  */
-bool mapping_inode_has_layout(struct page *page)
+bool mapping_inode_has_layout(struct vaddr_pin *vaddr_pin, struct page *page)
 {
 	bool ret = false;
 	struct inode *inode;
@@ -3003,12 +3192,12 @@ bool mapping_inode_has_layout(struct page *page)
 	if (inode->i_flctx &&
 	    !list_empty_careful(&inode->i_flctx->flc_lease)) {
 		spin_lock(&inode->i_flctx->flc_lock);
-		ret = false;
 		list_for_each_entry(fl, &inode->i_flctx->flc_lease, fl_list) {
 			if (fl->fl_pid == current->tgid &&
 			    (fl->fl_flags & FL_LAYOUT) &&
 			    (fl->fl_flags & FL_EXCLUSIVE)) {
-				ret = true;
+				ret = add_file_pin(vaddr_pin, inode,
+						   fl->fl_file);
 				break;
 			}
 		}
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 9d37cafbef9a..657c947bda49 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -981,9 +981,11 @@ struct vaddr_pin {
 };
 
 #ifdef CONFIG_DEV_PAGEMAP_OPS
+void mapping_release_file(struct vaddr_pin *vaddr_pin, struct page *page);
 void __put_devmap_managed_page(struct page *page);
 DECLARE_STATIC_KEY_FALSE(devmap_managed_key);
-static inline bool put_devmap_managed_page(struct page *page)
+
+static inline bool page_is_devmap_managed(struct page *page)
 {
 	if (!static_branch_unlikely(&devmap_managed_key))
 		return false;
@@ -992,7 +994,6 @@ static inline bool put_devmap_managed_page(struct page *page)
 	switch (page->pgmap->type) {
 	case MEMORY_DEVICE_PRIVATE:
 	case MEMORY_DEVICE_FS_DAX:
-		__put_devmap_managed_page(page);
 		return true;
 	default:
 		break;
@@ -1000,11 +1001,39 @@ static inline bool put_devmap_managed_page(struct page *page)
 	return false;
 }
 
+static inline bool put_devmap_managed_page(struct page *page)
+{
+	bool is_devmap = page_is_devmap_managed(page);
+	if (is_devmap)
+		__put_devmap_managed_page(page);
+	return is_devmap;
+}
+
+static inline bool put_devmap_managed_user_page(struct vaddr_pin *vaddr_pin,
+						struct page *page)
+{
+	bool is_devmap = page_is_devmap_managed(page);
+
+	if (is_devmap) {
+		if (page->pgmap->type == MEMORY_DEVICE_FS_DAX)
+			mapping_release_file(vaddr_pin, page);
+
+		__put_devmap_managed_page(page);
+	}
+
+	return is_devmap;
+}
+
 #else /* CONFIG_DEV_PAGEMAP_OPS */
 static inline bool put_devmap_managed_page(struct page *page)
 {
 	return false;
 }
+static inline bool put_devmap_managed_user_page(struct vaddr_pin *vaddr_pin,
+						struct page *page)
+{
+	return false;
+}
 #endif /* CONFIG_DEV_PAGEMAP_OPS */
 
 static inline bool is_device_private_page(const struct page *page)
@@ -1574,7 +1603,7 @@ int account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc);
 int __account_locked_vm(struct mm_struct *mm, unsigned long pages, bool inc,
 			struct task_struct *task, bool bypass_rlim);
 
-bool mapping_inode_has_layout(struct page *page);
+bool mapping_inode_has_layout(struct vaddr_pin *vaddr_pin, struct page *page);
 
 /* Container for pinned pfns / pages */
 struct frame_vector {
diff --git a/mm/gup.c b/mm/gup.c
index 10cfd30ff668..eeaa0ddd08a6 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -34,7 +34,7 @@ static void __put_user_page(struct vaddr_pin *vaddr_pin, struct page *page)
 	 * page is free and we need to inform the device driver through
 	 * callback. See include/linux/memremap.h and HMM for details.
 	 */
-	if (put_devmap_managed_page(page))
+	if (put_devmap_managed_user_page(vaddr_pin, page))
 		return;
 
 	if (put_page_testzero(page))
@@ -272,7 +272,7 @@ static struct page *follow_page_pte(struct vm_area_struct *vma,
 
 		if (unlikely(flags & FOLL_LONGTERM) &&
 		    (*pgmap)->type == MEMORY_DEVICE_FS_DAX &&
-		    !mapping_inode_has_layout(page)) {
+		    !mapping_inode_has_layout(ctx->vaddr_pin, page)) {
 			page = ERR_PTR(-EPERM);
 			goto out;
 		}
@@ -1915,7 +1915,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 		if (pte_devmap(pte) &&
 		    unlikely(flags & FOLL_LONGTERM) &&
 		    pgmap->type == MEMORY_DEVICE_FS_DAX &&
-		    !mapping_inode_has_layout(head)) {
+		    !mapping_inode_has_layout(vaddr_pin, head)) {
 			put_user_page(head);
 			goto pte_unmap;
 		}
@@ -1972,7 +1972,7 @@ static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 
 		if (unlikely(flags & FOLL_LONGTERM) &&
 		    pgmap->type == MEMORY_DEVICE_FS_DAX &&
-		    !mapping_inode_has_layout(page)) {
+		    !mapping_inode_has_layout(vaddr_pin, page)) {
 			undo_dev_pagemap(nr, nr_start, pages);
 			return 0;
 		}
diff --git a/mm/huge_memory.c b/mm/huge_memory.c
index 7e09f2f17ed8..2d700e21d4af 100644
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -957,7 +957,7 @@ struct page *follow_devmap_pmd(struct vm_area_struct *vma, unsigned long addr,
 
 	if (unlikely(flags & FOLL_LONGTERM) &&
 	    (*pgmap)->type == MEMORY_DEVICE_FS_DAX &&
-	    !mapping_inode_has_layout(page))
+	    !mapping_inode_has_layout(ctx->vaddr_pin, page))
 		return ERR_PTR(-EPERM);
 
 	get_page(page);
@@ -1104,7 +1104,7 @@ struct page *follow_devmap_pud(struct vm_area_struct *vma, unsigned long addr,
 
 	if (unlikely(flags & FOLL_LONGTERM) &&
 	    (*pgmap)->type == MEMORY_DEVICE_FS_DAX &&
-	    !mapping_inode_has_layout(page))
+	    !mapping_inode_has_layout(ctx->vaddr_pin, page))
 		return ERR_PTR(-EPERM);
 
 	get_page(page);
-- 
2.20.1

