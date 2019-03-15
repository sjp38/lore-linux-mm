Return-Path: <SRS0=L2Uh=RS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 629CAC43381
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0254E2063F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Mar 2019 19:51:59 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="BEm8cwjt"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0254E2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9B6726B02AD; Fri, 15 Mar 2019 15:51:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 98CB26B02AE; Fri, 15 Mar 2019 15:51:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 856636B02AF; Fri, 15 Mar 2019 15:51:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 641916B02AD
	for <linux-mm@kvack.org>; Fri, 15 Mar 2019 15:51:58 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id 68so13056853ywb.20
        for <linux-mm@kvack.org>; Fri, 15 Mar 2019 12:51:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=ne94nbMAoRi3AMfSYNN+0mcNX8RvX6YNSoJJsIsiTHc=;
        b=SY1E5UJi2i+GgsPWAgbxpyAaKc7FV88dSHRHs3Y5EW6aUX0h1n/TrAb4XNtadDzRRr
         9FxXEA+JzMkew3pSpaPBKdq1QUsQ5peZyje78geWwZy6WTSoz5vFraZnLhngvspOzgOw
         1WootZbjxFq8nxTABbzscOE28I/KvOcBd5zIMs3hhtR/oKU9X3NIKKbPkLcZl39Q6wCN
         ki1CnOiGGzLnOhZ4jcEXe32JTD4VKE2lkV29YtyR5l6+/gtwF74NeAJn9flRqeO+1pq1
         +h+wD/s+vI4XXIto2WT+VOItXH2ZvCa8hb3OO0V7Ng7ekAuzmRj3l9enE/8pju1Gs9+5
         GZMg==
X-Gm-Message-State: APjAAAWsdr2qgH6KSl/44SlIv0FPKhcPOJS0fhkrzcrJ0/6NQIzlpobw
	UNXXJ2QLd/5MTMl4Z6D9E+SLNVf+se0EfqirPpTVw7OcAv4+zITjwvn+8a9fR5L2CXHz3/wxzO0
	YTj4iyk6EqoZNfZgx5Yag480iuSzGb9Jj3hhi97F1WGuCsbL634K2+ZGhY9q7zMeC/A==
X-Received: by 2002:a81:2f94:: with SMTP id v142mr4416078ywv.104.1552679518145;
        Fri, 15 Mar 2019 12:51:58 -0700 (PDT)
X-Received: by 2002:a81:2f94:: with SMTP id v142mr4416015ywv.104.1552679516977;
        Fri, 15 Mar 2019 12:51:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552679516; cv=none;
        d=google.com; s=arc-20160816;
        b=vnX73TgU/1IAKAMf9lS6JUqX0eDrUTVhgxf0ay3W8l6YlL72Gd4fNRZh/jyS4ERUu+
         NXqjpy5Roqqrhsaqjw+fShzjTH3zJMQArbzF2SdHKLsMiHYiNo760Jg6wuIG/EAu/prM
         tQzKqsLI8sE67Eid2MW2e+TlGK+i54yExfOV8XbogTlKAaCFBoKxUMz3Hqp75yWVywQ+
         rtNSLLlxG5DmX8j6/GNQUF77ZxJrREL5GJBJw7oiy+8Ijseox02z0yA1Llu+4IG7fFbR
         L2qnAvzs11U1oP0aPfgUHiZ5/qwpeEp2fi7wRU8jXhD5Ch7X9n1NT4NOMdTL0bhqcgoy
         Nddg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=ne94nbMAoRi3AMfSYNN+0mcNX8RvX6YNSoJJsIsiTHc=;
        b=enu3Wr7chTVg0t5qGegnRF9O7VJhKbYYO2tSc5bGI3hyENkACZZp5pX/9bNHX9En8Y
         7F9I6SvzqWeCitWZ7ybwauiIByPqPP+ET35Sk18cd6cruqx8CEf57xjRcdAI0Pu68du3
         6xCmIgDPRhtwfvksjzzVxQxGbM/KPOe3WI4ooY/zIKom7Owkqi3ZP7PIlrtDI/q8Es7y
         YSUit4NodqArC3AjnpdCSv4v47a4jZeAWrvhDQXR/GUpgn+3IqiSRtym0Q00pGPFzkaT
         SMZCUNl4GqHWFWmgCpzVK0HQAtEiUbSgDle4vXjy9JVwoIOymnGuWXGKR9WRaoISM9H0
         4R0Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BEm8cwjt;
       spf=pass (google.com: domain of 3xakmxaokchszmcqdxjmukfnnfkd.bnlkhmtw-lljuzbj.nqf@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3XAKMXAoKCHsZmcqdxjmukfnnfkd.bnlkhmtw-lljuZbj.nqf@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 8sor1647008ybn.23.2019.03.15.12.51.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 15 Mar 2019 12:51:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3xakmxaokchszmcqdxjmukfnnfkd.bnlkhmtw-lljuzbj.nqf@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=BEm8cwjt;
       spf=pass (google.com: domain of 3xakmxaokchszmcqdxjmukfnnfkd.bnlkhmtw-lljuzbj.nqf@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3XAKMXAoKCHsZmcqdxjmukfnnfkd.bnlkhmtw-lljuZbj.nqf@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=ne94nbMAoRi3AMfSYNN+0mcNX8RvX6YNSoJJsIsiTHc=;
        b=BEm8cwjt382s8RjAGQvo1Hn0RHaQK7uw7NcZ5twzwPH8R8uFonGwKFh2XsX1GQOTnc
         HVSpe8DPgWrIB7nAJ/9/kjtxnclyR68X6nB+IXEDbq7DyLDsU/YQrxWhQLmpe2PrmwHS
         SmJBJs615J6VfN3xI8au5KXuOmYRDjgIjmyrs3qfh9a0ErkJnQ70zKFzJfXyCF0PecT/
         IiARXBhAIwT1xmvaZ9vJ/plCijVm9JXcIijXvok/NLiDL38mt5n2Pwal14DYidxckvna
         v90K6zS2CgkMTtnsj9tEyrx34Z9yU5EYRMEh8ToePcwO4FFC3pM5VjOQu6ZBgwJ0nUa4
         2xEg==
X-Google-Smtp-Source: APXvYqyLSPXIwniLQiTPoq4l3migNGMyo733PToduSZlNziGWPk+S/AKydsLreBxFGh52nvkT0tHaJ/35/yy1bqG
X-Received: by 2002:a25:3f41:: with SMTP id m62mr2357156yba.72.1552679516703;
 Fri, 15 Mar 2019 12:51:56 -0700 (PDT)
Date: Fri, 15 Mar 2019 20:51:28 +0100
In-Reply-To: <cover.1552679409.git.andreyknvl@google.com>
Message-Id: <42332fc5b15c434cfa4730e5906cd303fb8a901a.1552679409.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1552679409.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v11 04/14] mm, arm64: untag user pointers passed to memory syscalls
From: Andrey Konovalov <andreyknvl@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kees Cook <keescook@chromium.org>, Kate Stewart <kstewart@linuxfoundation.org>, 
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Ingo Molnar <mingo@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, 
	Shuah Khan <shuah@kernel.org>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Eric Dumazet <edumazet@google.com>, "David S. Miller" <davem@davemloft.net>, 
	Alexei Starovoitov <ast@kernel.org>, Daniel Borkmann <daniel@iogearbox.net>, 
	Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, 
	Peter Zijlstra <peterz@infradead.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, 
	linux-arm-kernel@lists.infradead.org, linux-doc@vger.kernel.org, 
	linux-mm@kvack.org, linux-arch@vger.kernel.org, netdev@vger.kernel.org, 
	bpf@vger.kernel.org, linux-kselftest@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Chintan Pandya <cpandya@codeaurora.org>, 
	Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, Dave Martin <Dave.Martin@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

This patch allows tagged pointers to be passed to the following memory
syscalls: madvise, mbind, get_mempolicy, mincore, mlock, mlock2, brk,
mmap_pgoff, old_mmap, munmap, remap_file_pages, mprotect, pkey_mprotect,
mremap, msync and shmdt.

This is done by untagging pointers passed to these syscalls in the
prologues of their handlers.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 ipc/shm.c      | 2 ++
 mm/madvise.c   | 2 ++
 mm/mempolicy.c | 5 +++++
 mm/migrate.c   | 1 +
 mm/mincore.c   | 2 ++
 mm/mlock.c     | 5 +++++
 mm/mmap.c      | 7 +++++++
 mm/mprotect.c  | 1 +
 mm/mremap.c    | 2 ++
 mm/msync.c     | 2 ++
 10 files changed, 29 insertions(+)

diff --git a/ipc/shm.c b/ipc/shm.c
index ce1ca9f7c6e9..7af8951e6c41 100644
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -1593,6 +1593,7 @@ SYSCALL_DEFINE3(shmat, int, shmid, char __user *, shmaddr, int, shmflg)
 	unsigned long ret;
 	long err;
 
+	shmaddr = untagged_addr(shmaddr);
 	err = do_shmat(shmid, shmaddr, shmflg, &ret, SHMLBA);
 	if (err)
 		return err;
@@ -1732,6 +1733,7 @@ long ksys_shmdt(char __user *shmaddr)
 
 SYSCALL_DEFINE1(shmdt, char __user *, shmaddr)
 {
+	shmaddr = untagged_addr(shmaddr);
 	return ksys_shmdt(shmaddr);
 }
 
diff --git a/mm/madvise.c b/mm/madvise.c
index 21a7881a2db4..64e6d34a7f9b 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -809,6 +809,8 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	size_t len;
 	struct blk_plug plug;
 
+	start = untagged_addr(start);
+
 	if (!madvise_behavior_valid(behavior))
 		return error;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index af171ccb56a2..31691737c59c 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1334,6 +1334,7 @@ static long kernel_mbind(unsigned long start, unsigned long len,
 	int err;
 	unsigned short mode_flags;
 
+	start = untagged_addr(start);
 	mode_flags = mode & MPOL_MODE_FLAGS;
 	mode &= ~MPOL_MODE_FLAGS;
 	if (mode >= MPOL_MAX)
@@ -1491,6 +1492,8 @@ static int kernel_get_mempolicy(int __user *policy,
 	int uninitialized_var(pval);
 	nodemask_t nodes;
 
+	addr = untagged_addr(addr);
+
 	if (nmask != NULL && maxnode < nr_node_ids)
 		return -EINVAL;
 
@@ -1576,6 +1579,8 @@ COMPAT_SYSCALL_DEFINE6(mbind, compat_ulong_t, start, compat_ulong_t, len,
 	unsigned long nr_bits, alloc_size;
 	nodemask_t bm;
 
+	start = untagged_addr(start);
+
 	nr_bits = min_t(unsigned long, maxnode-1, MAX_NUMNODES);
 	alloc_size = ALIGN(nr_bits, BITS_PER_LONG) / 8;
 
diff --git a/mm/migrate.c b/mm/migrate.c
index ac6f4939bb59..ecc6dcdefb1f 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1612,6 +1612,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 		if (get_user(node, nodes + i))
 			goto out_flush;
 		addr = (unsigned long)p;
+		addr = untagged_addr(addr);
 
 		err = -ENODEV;
 		if (node < 0 || node >= MAX_NUMNODES)
diff --git a/mm/mincore.c b/mm/mincore.c
index 218099b5ed31..c4a3f4484b6b 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -228,6 +228,8 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	unsigned long pages;
 	unsigned char *tmp;
 
+	start = untagged_addr(start);
+
 	/* Check the start address: needs to be page-aligned.. */
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
diff --git a/mm/mlock.c b/mm/mlock.c
index 080f3b36415b..6934ec92bf39 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -715,6 +715,7 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 
 SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
 {
+	start = untagged_addr(start);
 	return do_mlock(start, len, VM_LOCKED);
 }
 
@@ -722,6 +723,8 @@ SYSCALL_DEFINE3(mlock2, unsigned long, start, size_t, len, int, flags)
 {
 	vm_flags_t vm_flags = VM_LOCKED;
 
+	start = untagged_addr(start);
+
 	if (flags & ~MLOCK_ONFAULT)
 		return -EINVAL;
 
@@ -735,6 +738,8 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 {
 	int ret;
 
+	start = untagged_addr(start);
+
 	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
diff --git a/mm/mmap.c b/mm/mmap.c
index 41eb48d9b527..512c679c7f33 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -199,6 +199,8 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
 	bool downgraded = false;
 	LIST_HEAD(uf);
 
+	brk = untagged_addr(brk);
+
 	if (down_write_killable(&mm->mmap_sem))
 		return -EINTR;
 
@@ -1571,6 +1573,8 @@ unsigned long ksys_mmap_pgoff(unsigned long addr, unsigned long len,
 	struct file *file = NULL;
 	unsigned long retval;
 
+	addr = untagged_addr(addr);
+
 	if (!(flags & MAP_ANONYMOUS)) {
 		audit_mmap_fd(fd, flags);
 		file = fget(fd);
@@ -2867,6 +2871,7 @@ EXPORT_SYMBOL(vm_munmap);
 
 SYSCALL_DEFINE2(munmap, unsigned long, addr, size_t, len)
 {
+	addr = untagged_addr(addr);
 	profile_munmap(addr);
 	return __vm_munmap(addr, len, true);
 }
@@ -2885,6 +2890,8 @@ SYSCALL_DEFINE5(remap_file_pages, unsigned long, start, unsigned long, size,
 	unsigned long ret = -EINVAL;
 	struct file *file;
 
+	start = untagged_addr(start);
+
 	pr_warn_once("%s (%d) uses deprecated remap_file_pages() syscall. See Documentation/vm/remap_file_pages.rst.\n",
 		     current->comm, current->pid);
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index 028c724dcb1a..3c2b11629f89 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -468,6 +468,7 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 	if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
 		return -EINVAL;
 
+	start = untagged_addr(start);
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
 	if (!len)
diff --git a/mm/mremap.c b/mm/mremap.c
index e3edef6b7a12..6422aeee65bb 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -605,6 +605,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	LIST_HEAD(uf_unmap_early);
 	LIST_HEAD(uf_unmap);
 
+	addr = untagged_addr(addr);
+
 	if (flags & ~(MREMAP_FIXED | MREMAP_MAYMOVE))
 		return ret;
 
diff --git a/mm/msync.c b/mm/msync.c
index ef30a429623a..c3bd3e75f687 100644
--- a/mm/msync.c
+++ b/mm/msync.c
@@ -37,6 +37,8 @@ SYSCALL_DEFINE3(msync, unsigned long, start, size_t, len, int, flags)
 	int unmapped_error = 0;
 	int error = -EINVAL;
 
+	start = untagged_addr(start);
+
 	if (flags & ~(MS_ASYNC | MS_INVALIDATE | MS_SYNC))
 		goto out;
 	if (offset_in_page(start))
-- 
2.21.0.360.g471c308f928-goog

