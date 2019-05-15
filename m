Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6A28CC46470
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:11:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1C4A02084E
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 15:11:50 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1C4A02084E
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BAA696B000C; Wed, 15 May 2019 11:11:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE4AE6B000D; Wed, 15 May 2019 11:11:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9FB766B000E; Wed, 15 May 2019 11:11:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f200.google.com (mail-lj1-f200.google.com [209.85.208.200])
	by kanga.kvack.org (Postfix) with ESMTP id 359F16B000C
	for <linux-mm@kvack.org>; Wed, 15 May 2019 11:11:49 -0400 (EDT)
Received: by mail-lj1-f200.google.com with SMTP id g15so456970ljk.8
        for <linux-mm@kvack.org>; Wed, 15 May 2019 08:11:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=XTDiFLs1g6MB9cJ5m0upXpXhxwoNltSaX8PRg4fpGGw=;
        b=QLMAFJwdHIqOsN9tkrOjBjmvem0VHxNTm/5IxCzC4ZKI0CkepZZA3kv9S1QPDcl1/B
         srH3Nag0AKSBvBO4ylCnK7fBLJO0i72yjYYGjdCCmWmuvrJwXrCY9wMFJ2Cwi/3ssZ/b
         Mfk6r6f09lkwamtE47BQ6V3A45GVUpi27ZYWC6bqW8jzwgOm1TyY7SFuyKFWTpvIr877
         M8IBFA4HGjEj/qQ0nWpXQ2R+O2jutTV4m+v9il5Ld2iZ/1iLcS35E3qGLQQD1Xbwxk9I
         U/NB4MxScZ6KRMIpvKkyo1letWu10XIuK40qyTp2s/mBS+PNVntXBf0+ejCCv114ab4c
         5REQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVYi9zxwkjr3A/tzW5Ny/HwIH101r+8R5asCE9+MB+RPSya16dK
	YV/rlQD/i0v9c3eXX1JC+GV8CdRYoi1aVyV8h7plfAZxywbLY67Bi4kf8dgFgGsD5CELo3FljOH
	iUK8NeHa5iTwdcl5UfLAKcevEQtv6iEEnmIDahWTzvFgFv6IgQI1YcUBnGq9hasPvKA==
X-Received: by 2002:a2e:88ce:: with SMTP id a14mr13999265ljk.122.1557933108652;
        Wed, 15 May 2019 08:11:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxVHJzku8QTZQMfLbqXiSh0tkm6m70U5a1H/3dZ9ep0Kt+iwXobgrem09KYP3JSBgIHArFy
X-Received: by 2002:a2e:88ce:: with SMTP id a14mr13999220ljk.122.1557933107585;
        Wed, 15 May 2019 08:11:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557933107; cv=none;
        d=google.com; s=arc-20160816;
        b=WLctVfeVlI1qy/qspkyhSuCt1oeHGnPSNpzmEfpn0WYyle473PRuyFMCrwhzFK4+4L
         fI+2ft7dJSkl6MgG4k/Ya2DzJpW8D6LUT9KpoFcCweAU/8GI47ftqEA/IE0ixtgxK3No
         q68GjWXWyY9OVNs+KlSZbhCOYXpYrEoMd2r2KAtb79+SQRWilSFRakrK2SiOqdmIBdKF
         Fi4nhDIoAPnWCqNgQN2wH9D2CaFkBo0YvOU9U6W7aAhLe1Pxa1idheAs0gztXMjGPauw
         ubnbcS8lzLcr5EYKk8JaIM3UDyo63qiyfDxJXNbO0mq4iwh3TCIHkJqNs9NxhS/Euq/3
         2AaA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=XTDiFLs1g6MB9cJ5m0upXpXhxwoNltSaX8PRg4fpGGw=;
        b=MMrUweUKUFohCBaab9w/U+C3bn43meCVnhvBj6/lYiK9ozPvuOq68phaITBZ0eVC7r
         akmS7rNr4CEhIP3nqSxhlTMVnkMgDi1x/9Dg005D/vQCJaVhlYeRKuHDgKL3s8PQZLEN
         KmuXk9ZWfCdSgLoRGWf1H0qLua+7r5SkX+JcVcg9VdEsyEyv+H+o9M37RwkK2rTKRCQF
         Gok0EGhlDYmcKcriKN3/52TUMD9hG5fHiBVYIpp5seH+JcsybUGg/cs7ufb5wc4BLPsh
         EmoPkyLYJb4oAAMuV2lg06Ez7NaizlFqSIp6HvbtIo+Tt4VqKarbL4yXZkUfNCE5gK+F
         WiNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id v13si1758574lji.214.2019.05.15.08.11.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 08:11:47 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hQvZI-0001YA-DL; Wed, 15 May 2019 18:11:44 +0300
Subject: [PATCH RFC 5/5] mm: Add process_vm_mmap()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 pasha.tatashin@oracle.com, alexander.h.duyck@linux.intel.com,
 ira.weiny@intel.com, andreyknvl@google.com, arunks@codeaurora.org,
 vbabka@suse.cz, cl@linux.com, riel@surriel.com, keescook@chromium.org,
 hannes@cmpxchg.org, npiggin@gmail.com, mathieu.desnoyers@efficios.com,
 shakeelb@google.com, guro@fb.com, aarcange@redhat.com, hughd@google.com,
 jglisse@redhat.com, mgorman@techsingularity.net, daniel.m.jordan@oracle.com,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org
Date: Wed, 15 May 2019 18:11:44 +0300
Message-ID: <155793310413.13922.4749810361688380807.stgit@localhost.localdomain>
In-Reply-To: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
References: <155793276388.13922.18064660723547377633.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This adds a new syscall to map from or to another
process vma. Flag PVMMAP_FIXED may be specified,
its meaning is similar to mmap()'s MAP_FIXED.

@pid > 0 means to map from process of @pid to current,
@pid < 0 means to map from current to @pid process.

VMA are merged on destination, i.e. if source task
has VMA with address [start; end], and we map it sequentially
twice:

process_vm_mmap(@pid, start, start + (end - start)/2, ...);
process_vm_mmap(@pid, start + (end - start)/2, end,   ...);

the destination task will have single vma [start, end].

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/mm.h                     |    4 +
 include/linux/mm_types.h               |    2 +
 include/uapi/asm-generic/mman-common.h |    5 +
 mm/mmap.c                              |  108 ++++++++++++++++++++++++++++++++
 mm/process_vm_access.c                 |   71 +++++++++++++++++++++
 5 files changed, 190 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 54328d08dbdd..c49bcfac593c 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2382,6 +2382,10 @@ extern int __do_munmap(struct mm_struct *, unsigned long, size_t,
 		       struct list_head *uf, bool downgrade);
 extern int do_munmap(struct mm_struct *, unsigned long, size_t,
 		     struct list_head *uf);
+extern unsigned long mmap_process_vm(struct mm_struct *, unsigned long,
+				     struct mm_struct *, unsigned long,
+				     unsigned long, unsigned long,
+				     struct list_head *);
 
 static inline unsigned long
 do_mmap_pgoff(struct file *file, unsigned long addr,
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 1815fbc40926..885f256f2fb7 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -261,11 +261,13 @@ struct vm_region {
 
 #ifdef CONFIG_USERFAULTFD
 #define NULL_VM_UFFD_CTX ((struct vm_userfaultfd_ctx) { NULL, })
+#define IS_NULL_VM_UFFD_CTX(uctx) ((uctx)->ctx == NULL)
 struct vm_userfaultfd_ctx {
 	struct userfaultfd_ctx *ctx;
 };
 #else /* CONFIG_USERFAULTFD */
 #define NULL_VM_UFFD_CTX ((struct vm_userfaultfd_ctx) {})
+#define IS_NULL_VM_UFFD_CTX(uctx) (true)
 struct vm_userfaultfd_ctx {};
 #endif /* CONFIG_USERFAULTFD */
 
diff --git a/include/uapi/asm-generic/mman-common.h b/include/uapi/asm-generic/mman-common.h
index abd238d0f7a4..44cb6cf77e93 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -28,6 +28,11 @@
 /* 0x0100 - 0x80000 flags are defined in asm-generic/mman.h */
 #define MAP_FIXED_NOREPLACE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
 
+/*
+ * Flags for process_vm_mmap
+ */
+#define PVMMAP_FIXED	0x01
+
 /*
  * Flags for mlock
  */
diff --git a/mm/mmap.c b/mm/mmap.c
index b2a1f77643cd..3dbf280e9f8e 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3274,6 +3274,114 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
 	return NULL;
 }
 
+static int do_mmap_process_vm(struct vm_area_struct *src_vma,
+			      unsigned long src_addr,
+			      struct mm_struct *dst_mm,
+			      unsigned long dst_addr,
+			      unsigned long len,
+			      struct list_head *uf)
+{
+	struct vm_area_struct *dst_vma;
+	unsigned long pgoff, ret;
+	bool unused;
+
+	if (do_munmap(dst_mm, dst_addr, len, uf))
+		return -ENOMEM;
+
+	if (src_vma->vm_flags & VM_ACCOUNT) {
+		if (security_vm_enough_memory_mm(dst_mm, len >> PAGE_SHIFT))
+			return -ENOMEM;
+	}
+
+	pgoff = src_vma->vm_pgoff +
+			((src_addr - src_vma->vm_start) >> PAGE_SHIFT);
+	dst_vma = copy_vma(&src_vma, dst_mm, dst_addr,
+			   len, pgoff, &unused, false);
+	if (!dst_vma) {
+		ret = -ENOMEM;
+		goto unacct;
+	}
+
+	ret = copy_page_range(dst_mm, src_vma->vm_mm, src_vma,
+			      dst_addr, src_addr, src_addr + len);
+	if (ret) {
+		do_munmap(dst_mm, dst_addr, len, uf);
+		return -ENOMEM;
+	}
+
+	if (dst_vma->vm_file)
+		uprobe_mmap(dst_vma);
+	perf_event_mmap(dst_vma);
+
+	dst_vma->vm_flags |= VM_SOFTDIRTY;
+	vma_set_page_prot(dst_vma);
+
+	vm_stat_account(dst_mm, dst_vma->vm_flags, len >> PAGE_SHIFT);
+	return 0;
+
+unacct:
+	vm_unacct_memory(len >> PAGE_SHIFT);
+	return ret;
+}
+
+unsigned long mmap_process_vm(struct mm_struct *src_mm,
+			      unsigned long src_addr,
+			      struct mm_struct *dst_mm,
+			      unsigned long dst_addr,
+			      unsigned long len,
+			      unsigned long flags,
+			      struct list_head *uf)
+{
+	struct vm_area_struct *src_vma = find_vma(src_mm, src_addr);
+	unsigned long gua_flags = 0;
+	unsigned long ret;
+
+	if (!src_vma || src_vma->vm_start > src_addr)
+		return -EFAULT;
+	if (len > src_vma->vm_end - src_addr)
+		return -EFAULT;
+	if (src_vma->vm_flags & (VM_DONTEXPAND | VM_PFNMAP))
+		return -EFAULT;
+	if (is_vm_hugetlb_page(src_vma) || (src_vma->vm_flags & VM_IO))
+		return -EINVAL;
+        if (dst_mm->map_count + 2 > sysctl_max_map_count)
+                return -ENOMEM;
+	if (!IS_NULL_VM_UFFD_CTX(&src_vma->vm_userfaultfd_ctx))
+		return -ENOTSUPP;
+
+	if (src_vma->vm_flags & VM_SHARED)
+		gua_flags |= MAP_SHARED;
+	else
+		gua_flags |= MAP_PRIVATE;
+	if (vma_is_anonymous(src_vma) || vma_is_shmem(src_vma))
+		gua_flags |= MAP_ANONYMOUS;
+	if (flags & PVMMAP_FIXED)
+		gua_flags |= MAP_FIXED;
+	ret = get_unmapped_area(src_vma->vm_file, dst_addr, len,
+				src_vma->vm_pgoff +
+				((src_addr - src_vma->vm_start) >> PAGE_SHIFT),
+				gua_flags);
+	if (offset_in_page(ret))
+                return ret;
+	dst_addr = ret;
+
+	/* Check against address space limit. */
+	if (!may_expand_vm(dst_mm, src_vma->vm_flags, len >> PAGE_SHIFT)) {
+		unsigned long nr_pages;
+
+		nr_pages = count_vma_pages_range(dst_mm, dst_addr, dst_addr + len);
+		if (!may_expand_vm(dst_mm, src_vma->vm_flags,
+					(len >> PAGE_SHIFT) - nr_pages))
+			return -ENOMEM;
+	}
+
+	ret = do_mmap_process_vm(src_vma, src_addr, dst_mm, dst_addr, len, uf);
+	if (ret)
+                return ret;
+
+	return dst_addr;
+}
+
 /*
  * Return true if the calling process may expand its vm space by the passed
  * number of pages
diff --git a/mm/process_vm_access.c b/mm/process_vm_access.c
index a447092d4635..7fca2c5c7edd 100644
--- a/mm/process_vm_access.c
+++ b/mm/process_vm_access.c
@@ -17,6 +17,8 @@
 #include <linux/ptrace.h>
 #include <linux/slab.h>
 #include <linux/syscalls.h>
+#include <linux/mman.h>
+#include <linux/userfaultfd_k.h>
 
 #ifdef CONFIG_COMPAT
 #include <linux/compat.h>
@@ -295,6 +297,68 @@ static ssize_t process_vm_rw(pid_t pid,
 	return rc;
 }
 
+static unsigned long process_vm_mmap(pid_t pid, unsigned long src_addr,
+				     unsigned long len, unsigned long dst_addr,
+				     unsigned long flags)
+{
+	struct mm_struct *src_mm, *dst_mm;
+	struct task_struct *task;
+	unsigned long ret;
+	int depth = 0;
+	LIST_HEAD(uf);
+
+	len = PAGE_ALIGN(len);
+	src_addr = round_down(src_addr, PAGE_SIZE);
+	if (flags & PVMMAP_FIXED)
+		dst_addr = round_down(dst_addr, PAGE_SIZE);
+	else
+		dst_addr = round_hint_to_min(dst_addr);
+
+	if ((flags & ~PVMMAP_FIXED) || len == 0 || len > TASK_SIZE ||
+	    src_addr == 0 || dst_addr > TASK_SIZE - len)
+		return -EINVAL;
+	task = find_get_task_by_vpid(pid > 0 ? pid : -pid);
+	if (!task)
+		return -ESRCH;
+	if (unlikely(task->flags & PF_KTHREAD)) {
+		ret = -EINVAL;
+		goto out_put_task;
+	}
+
+	src_mm = mm_access(task, PTRACE_MODE_ATTACH_REALCREDS);
+	if (!src_mm || IS_ERR(src_mm)) {
+		ret = IS_ERR(src_mm) ? PTR_ERR(src_mm) : -ESRCH;
+		goto out_put_task;
+	}
+	dst_mm = current->mm;
+	mmget(dst_mm);
+
+	if (pid < 0)
+		swap(src_mm, dst_mm);
+
+	/* Double lock mm in address order: smallest is the first */
+	if (src_mm < dst_mm) {
+		down_write(&src_mm->mmap_sem);
+		depth = SINGLE_DEPTH_NESTING;
+	}
+	down_write_nested(&dst_mm->mmap_sem, depth);
+	if (src_mm > dst_mm)
+		down_write_nested(&src_mm->mmap_sem, SINGLE_DEPTH_NESTING);
+
+	ret = mmap_process_vm(src_mm, src_addr, dst_mm, dst_addr, len, flags, &uf);
+
+	up_write(&dst_mm->mmap_sem);
+	if (dst_mm != src_mm)
+		up_write(&src_mm->mmap_sem);
+
+	userfaultfd_unmap_complete(dst_mm, &uf);
+	mmput(src_mm);
+	mmput(dst_mm);
+out_put_task:
+	put_task_struct(task);
+	return ret;
+}
+
 SYSCALL_DEFINE6(process_vm_readv, pid_t, pid, const struct iovec __user *, lvec,
 		unsigned long, liovcnt, const struct iovec __user *, rvec,
 		unsigned long, riovcnt,	unsigned long, flags)
@@ -310,6 +374,13 @@ SYSCALL_DEFINE6(process_vm_writev, pid_t, pid,
 	return process_vm_rw(pid, lvec, liovcnt, rvec, riovcnt, flags, 1);
 }
 
+SYSCALL_DEFINE5(process_vm_mmap, pid_t, pid,
+		unsigned long, src_addr, unsigned long, len,
+		unsigned long, dst_addr, unsigned long, flags)
+{
+	return process_vm_mmap(pid, src_addr, len, dst_addr, flags);
+}
+
 #ifdef CONFIG_COMPAT
 
 static ssize_t

