Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id DB4146B0259
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 17:34:06 -0500 (EST)
Received: by wmww144 with SMTP id w144so257174579wmw.1
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:34:06 -0800 (PST)
Received: from mx0b-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id kv9si14144939wjb.199.2015.11.19.14.34.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 Nov 2015 14:34:01 -0800 (PST)
Received: from pps.filterd (m0001303.ppops.net [127.0.0.1])
	by m0001303.ppops.net (8.15.0.59/8.15.0.59) with SMTP id tAJMWOt4029274
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:33:59 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by m0001303.ppops.net with ESMTP id 1y8rtt7812-2
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 14:33:59 -0800
Received: from facebook.com (2401:db00:11:d0a2:face:0:39:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 9d560a388f0d11e599990002c95209d8-233f8230 for <linux-mm@kvack.org>;	Thu, 19
 Nov 2015 14:33:54 -0800
From: Shaohua Li <shli@fb.com>
Subject: [RFC 2/8] userfaultfd: support write protection for userfault vma range
Date: Thu, 19 Nov 2015 14:33:47 -0800
Message-ID: <60c73a4374d16d15e3975c590b48a2d2d384c23e.1447964595.git.shli@fb.com>
In-Reply-To: <cover.1447964595.git.shli@fb.com>
References: <cover.1447964595.git.shli@fb.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: kernel-team@fb.com, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Pavel Emelyanov <xemul@parallels.com>, Rik van Riel <riel@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>

Add API to enable/disable writeprotect a vma range. Unlike mprotect,
this doesn't split/merge vmas.

Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Kirill A. Shutemov <kirill@shutemov.name>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Signed-off-by: Shaohua Li <shli@fb.com>
---
 include/linux/userfaultfd_k.h |  2 ++
 mm/userfaultfd.c              | 52 +++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+)

diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 4e22d11..44f5b09 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -35,6 +35,8 @@ extern ssize_t mcopy_atomic(struct mm_struct *dst_mm, unsigned long dst_start,
 extern ssize_t mfill_zeropage(struct mm_struct *dst_mm,
 			      unsigned long dst_start,
 			      unsigned long len);
+extern int mwriteprotect_range(struct mm_struct *dst_mm,
+		unsigned long start, unsigned long len, bool enable_wp);
 
 /* mm helpers */
 static inline bool is_mergeable_vm_userfaultfd_ctx(struct vm_area_struct *vma,
diff --git a/mm/userfaultfd.c b/mm/userfaultfd.c
index 77fee93..3e97e24 100644
--- a/mm/userfaultfd.c
+++ b/mm/userfaultfd.c
@@ -306,3 +306,55 @@ ssize_t mfill_zeropage(struct mm_struct *dst_mm, unsigned long start,
 {
 	return __mcopy_atomic(dst_mm, start, 0, len, true);
 }
+
+int mwriteprotect_range(struct mm_struct *dst_mm, unsigned long start,
+	unsigned long len, bool enable_wp)
+{
+	struct vm_area_struct *dst_vma;
+	pgprot_t newprot;
+	int err;
+
+	/*
+	 * Sanitize the command parameters:
+	 */
+	BUG_ON(start & ~PAGE_MASK);
+	BUG_ON(len & ~PAGE_MASK);
+
+	/* Does the address range wrap, or is the span zero-sized? */
+	BUG_ON(start + len <= start);
+
+	down_read(&dst_mm->mmap_sem);
+
+	/*
+	 * Make sure the vma is not shared, that the dst range is
+	 * both valid and fully within a single existing vma.
+	 */
+	err = -EINVAL;
+	dst_vma = find_vma(dst_mm, start);
+	if (!dst_vma || (dst_vma->vm_flags & VM_SHARED))
+		goto out_unlock;
+	if (start < dst_vma->vm_start ||
+	    start + len > dst_vma->vm_end)
+		goto out_unlock;
+
+	if (!dst_vma->vm_userfaultfd_ctx.ctx)
+		goto out_unlock;
+	if (!userfaultfd_wp(dst_vma))
+		goto out_unlock;
+
+	if (dst_vma->vm_ops)
+		goto out_unlock;
+
+	if (enable_wp)
+		newprot = vm_get_page_prot(dst_vma->vm_flags & ~(VM_WRITE));
+	else
+		newprot = vm_get_page_prot(dst_vma->vm_flags);
+
+	change_protection(dst_vma, start, start + len, newprot,
+				!enable_wp, 0);
+
+	err = 0;
+out_unlock:
+	up_read(&dst_mm->mmap_sem);
+	return err;
+}
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
