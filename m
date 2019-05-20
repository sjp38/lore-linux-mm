Return-Path: <SRS0=ymty=TU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8EE31C04AAC
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3288B216B7
	for <linux-mm@archiver.kernel.org>; Mon, 20 May 2019 14:00:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3288B216B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=virtuozzo.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE5136B026D; Mon, 20 May 2019 10:00:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CBC2E6B026E; Mon, 20 May 2019 10:00:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD3796B026F; Mon, 20 May 2019 10:00:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5287D6B026D
	for <linux-mm@kvack.org>; Mon, 20 May 2019 10:00:44 -0400 (EDT)
Received: by mail-lj1-f198.google.com with SMTP id v12so2160292ljv.7
        for <linux-mm@kvack.org>; Mon, 20 May 2019 07:00:44 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:from
         :to:date:message-id:in-reply-to:references:user-agent:mime-version
         :content-transfer-encoding;
        bh=ioYOyKuzdQzKpmA7+EHjpRFnK6vAt19ymD2CLyn7WXo=;
        b=ZH5K4bai+ay6RUlzxIThQnCqp4zDSdwXAhrRmPQDTp/30fBvxGP2+5OKx0zi+405tY
         xZllwYB/kro7x+AAn5tqF6TGhxi/es4k8WbxRB01mQKIGf2sqX+NCIW9tcpT0OQfSl7o
         RR6xCEuDEGsLV73GELANsSMV7CdaoNzaFJKeqGDcZSeMeGJZNxireAjWhm2LuKipsnYc
         EiFUvc858sqS+VOAWJgVew5H0NMu+rSHj64Kk1BZTwpIrdyR5i07N32ocMIT+nF4lEzS
         UZGX0xrcG3XLfdsjlVDECMWi2SiyGLG+eD5+OrbrNJtXv/ffDe9PVHEBOczwZ/xO+7cm
         yIsw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
X-Gm-Message-State: APjAAAVhT/aU0r6T7/jzzUe52KPMxrKHoaySPdoc17fAwc3hJiM7MsXs
	ak0+GAzJRO6gP3NYYJW2HDnfiF8R7gxL7ft1sIs4T/xzW9ysF72T01TguJFNPYrG+L7Bb31xhv2
	rEMtqgke+UlKPRywLjLDe2WjQ72HLXSv4wZICY7lhAPhl2VxfA3dH+KTwHx+YZ1w1LQ==
X-Received: by 2002:a2e:1412:: with SMTP id u18mr2974471ljd.197.1558360843740;
        Mon, 20 May 2019 07:00:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz1ylpmSwx+Q0ZDXVZNBSFXbZ4aKUBsOtxoPQf9EgfvXoJZObJLcWphIl2g24bQJn22RlMJ
X-Received: by 2002:a2e:1412:: with SMTP id u18mr2974408ljd.197.1558360842530;
        Mon, 20 May 2019 07:00:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558360842; cv=none;
        d=google.com; s=arc-20160816;
        b=DjByWxe8B335tJ7ZvtiPTTQOJeQVpAecqmr3orjBxQE6WJ/EvdYgYz9Wo0lzZCoAV6
         YA1ajQh+xv+S/MC8FodIx5hHLbwmqzoPCW6Ci08pmKsyPlcB3tv9x/aF7bYNFr2cq6pn
         AMqyCj40IY+cqvtm6MrzR2oeUqsjITHPgj0nks08YEQg+YmivksKZirvDvSXc7MRdlKh
         LOGV47Xp6zWNfgYlPJh5aN9Kn+bAhF0b/4m9buP06IHoaPmyzzT53yzphHBqfowGHUZj
         cCoBQwaaobyNC1Uc4EyftGpMQqsAYN5Kx6wh0CQqM8e5ticBeRz21mKOpxKgKH8JSqPi
         t+FQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:user-agent:references
         :in-reply-to:message-id:date:to:from:subject;
        bh=ioYOyKuzdQzKpmA7+EHjpRFnK6vAt19ymD2CLyn7WXo=;
        b=w84xNhPMW9xAmmHNVMCufPwuJ9LmEluxlZNXp/IaUWs3ybyNQwF4q7omYc12y7Le7g
         i4T5ykUpBpBBUbvUrBURA7vgCQro8a+hBvSey/Es96PpGohzN7diuvSMojJQe5WmGaHX
         j5941NQ/jvxaWIyhp91NA5+CsgEJXWVjeop0Rdva+Gijrs7B50WkxBMjoY/l24b5MuNY
         2QaHnVoGBfOIi2D3pSy3FhtVVH5/I4qYWgDHXNoTjDUH7XVCRdBGFY2EGbvEGyPcXast
         SUDSRBVYgUUZamnVcVeUxbA7Z/rXoJpNQFBiAP4Z6hX91TSfn5VDudHOul5I1ChMzqtg
         dHFQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from relay.sw.ru (relay.sw.ru. [185.231.240.75])
        by mx.google.com with ESMTPS id m70si16442248lje.194.2019.05.20.07.00.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 May 2019 07:00:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) client-ip=185.231.240.75;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of ktkhai@virtuozzo.com designates 185.231.240.75 as permitted sender) smtp.mailfrom=ktkhai@virtuozzo.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=virtuozzo.com
Received: from [172.16.25.169] (helo=localhost.localdomain)
	by relay.sw.ru with esmtp (Exim 4.91)
	(envelope-from <ktkhai@virtuozzo.com>)
	id 1hSiqF-00084l-Gn; Mon, 20 May 2019 17:00:39 +0300
Subject: [PATCH v2 7/7] mm: Add process_vm_mmap()
From: Kirill Tkhai <ktkhai@virtuozzo.com>
To: akpm@linux-foundation.org, dan.j.williams@intel.com, ktkhai@virtuozzo.com,
 mhocko@suse.com, keith.busch@intel.com, kirill.shutemov@linux.intel.com,
 alexander.h.duyck@linux.intel.com, ira.weiny@intel.com, andreyknvl@google.com,
 arunks@codeaurora.org, vbabka@suse.cz, cl@linux.com, riel@surriel.com,
 keescook@chromium.org, hannes@cmpxchg.org, npiggin@gmail.com,
 mathieu.desnoyers@efficios.com, shakeelb@google.com, guro@fb.com,
 aarcange@redhat.com, hughd@google.com, jglisse@redhat.com,
 mgorman@techsingularity.net, daniel.m.jordan@oracle.com, jannh@google.com,
 kilobyte@angband.pl, linux-api@vger.kernel.org, linux-kernel@vger.kernel.org,
 linux-mm@kvack.org
Date: Mon, 20 May 2019 17:00:39 +0300
Message-ID: <155836083941.2441.1939229815005692644.stgit@localhost.localdomain>
In-Reply-To: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
References: <155836064844.2441.10911127801797083064.stgit@localhost.localdomain>
User-Agent: StGit/0.18
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This adds a new syscall to duplicate a VMA of other
process to current. Flag PVMMAP_FIXED may be specified,
its meaning is similar to mmap()'s MAP_FIXED.

VMA are merged on destination, i.e. if source task
has VMA with address [start; end], and we map it sequentially
twice:

process_vm_mmap(@pid, start, start + (end - start)/2, ...);
process_vm_mmap(@pid, start + (end - start)/2, end,   ...);

the destination task will have single vma [start, end].

v2:
    Add PVMMAP_FIXED_NOREPLACE flag.
    Use find_vma_without_flags() and may_mmap_overlapped_region() helpers.
    Fix whitespaces.

    Previous version has a possibility to duplicate VMA from
    current to remote process, but there was a error, so I
    removed that. It's needed to advance get_unmapped_area
    to make it working with remote VMA (which I missed
    initially). This requires a lot of refactoring, which
    may hide the main logic away from a reader, so let's
    I do that later in a separate series.

Signed-off-by: Kirill Tkhai <ktkhai@virtuozzo.com>
---
 include/linux/mm.h                     |    4 +
 include/linux/mm_types.h               |    2 +
 include/uapi/asm-generic/mman-common.h |    6 ++
 mm/mmap.c                              |  107 ++++++++++++++++++++++++++++++++
 mm/process_vm_access.c                 |   69 +++++++++++++++++++++
 5 files changed, 188 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 65ceb56acd44..9d1c79a44128 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -2385,6 +2385,10 @@ extern int __do_munmap(struct mm_struct *, unsigned long, size_t,
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
index abd238d0f7a4..91803e6ada7c 100644
--- a/include/uapi/asm-generic/mman-common.h
+++ b/include/uapi/asm-generic/mman-common.h
@@ -28,6 +28,12 @@
 /* 0x0100 - 0x80000 flags are defined in asm-generic/mman.h */
 #define MAP_FIXED_NOREPLACE	0x100000	/* MAP_FIXED which doesn't unmap underlying mapping */
 
+/*
+ * Flags for process_vm_mmap
+ */
+#define PVMMAP_FIXED		0x01
+#define PVMMAP_FIXED_NOREPLACE	0x02		/* PVMAP_FIXED which doesn't unmap underlying mapping */
+
 /*
  * Flags for mlock
  */
diff --git a/mm/mmap.c b/mm/mmap.c
index 260e47e917e6..3123ecee5fb8 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3282,6 +3282,113 @@ struct vm_area_struct *copy_vma(struct vm_area_struct **vmap,
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
+	struct vm_area_struct *src_vma, *dst_vma;
+	unsigned long gua_flags = 0;
+	unsigned long ret;
+
+	src_vma = find_vma_without_flags(src_mm, src_addr, len,
+				VM_HUGETLB|VM_DONTEXPAND|VM_PFNMAP|VM_IO);
+	if (IS_ERR(src_vma))
+		return -EFAULT;
+	if (dst_mm->map_count > sysctl_max_map_count - 2)
+		return -ENOMEM;
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
+	if (flags & PVMMAP_FIXED_NOREPLACE)
+		gua_flags |= MAP_FIXED | MAP_FIXED_NOREPLACE;
+
+	ret = get_unmapped_area(src_vma->vm_file, dst_addr, len,
+				src_vma->vm_pgoff +
+				((src_addr - src_vma->vm_start) >> PAGE_SHIFT),
+				gua_flags);
+	if (offset_in_page(ret))
+                return ret;
+	if (flags & PVMMAP_FIXED_NOREPLACE) {
+		dst_vma = find_vma(dst_mm, dst_addr);
+		if (dst_vma && dst_vma->vm_start < dst_addr + len)
+			return -EEXIST;
+	}
+
+	dst_addr = ret;
+
+	/* Check against address space limit. */
+	if (!may_mmap_overlapped_region(dst_mm, src_vma->vm_flags, dst_addr, len))
+		return -ENOMEM;
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
index a447092d4635..e2073f52415b 100644
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
@@ -295,6 +297,66 @@ static ssize_t process_vm_rw(pid_t pid,
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
+	if ((flags & ~(PVMMAP_FIXED|PVMMAP_FIXED_NOREPLACE)) ||
+	    len == 0 || len > TASK_SIZE || src_addr == 0 ||
+	    dst_addr > TASK_SIZE - len || pid <= 0)
+		return -EINVAL;
+	task = find_get_task_by_vpid(pid);
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
@@ -310,6 +372,13 @@ SYSCALL_DEFINE6(process_vm_writev, pid_t, pid,
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

