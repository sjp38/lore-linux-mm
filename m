Return-Path: <SRS0=h9qD=RX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57087C4360F
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:51:59 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EDF522146E
	for <linux-mm@archiver.kernel.org>; Wed, 20 Mar 2019 14:51:58 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="OyzBlC0/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EDF522146E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A217E6B000A; Wed, 20 Mar 2019 10:51:58 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9A7496B000C; Wed, 20 Mar 2019 10:51:58 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 849476B000D; Wed, 20 Mar 2019 10:51:58 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vk1-f199.google.com (mail-vk1-f199.google.com [209.85.221.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4F4B26B000A
	for <linux-mm@kvack.org>; Wed, 20 Mar 2019 10:51:58 -0400 (EDT)
Received: by mail-vk1-f199.google.com with SMTP id u9so1057270vke.4
        for <linux-mm@kvack.org>; Wed, 20 Mar 2019 07:51:58 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=SRoxSUqmsB49A1VVgrFKE/I4A7Rwq9IqNVIi8CfykWo=;
        b=sB6Nieieba+czVAtJhCh2kKDBtNlnhy4U9ezT7LTQlpYyvjpJPAdKiW+XYMLZtULkp
         FxmX2sIs4FvmX7GSoyRRTAap+dYvbrChoNpa8p74L8YIPi6bawUy9350875bcrr/iE9Q
         +FAAXc/lJ3pLtDVwe619VnoXkAnS6CeO3Gjfj1+PYMjIHFDaz8vChzK+n3cyHKc7/X42
         OHoDORbMP6EhN33e/Ryn64SbE8fSuWPjXfa2ROTbUWwAY3kqUHUHU/alkU4zB8fgG8mo
         Mai7VikrDdCipRGXja59xsa9hg6IOBqy5ZovJV7QYTvCaiM2CEazr5GlPWYzfVjE7Fvn
         QeYg==
X-Gm-Message-State: APjAAAVaY6mjRm9YiQ97nAPDXkTpQPe4+5ZjoRMmL6CsLOUViVdUKAbM
	p/6upUo6S5pH+1ut3QE4RqoEPzB3pQoxoQXg32A8mLyLRcPtOaByVzNv7CYbd47grIwO89c8Wsv
	jkf8ynoMXR8hjoJVegKvUhjXhbyMkU7aDcc+6R/EVOu9lT7/JJiCYxDRVFhAvfQ0oJg==
X-Received: by 2002:a1f:a9c2:: with SMTP id s185mr1652878vke.5.1553093517988;
        Wed, 20 Mar 2019 07:51:57 -0700 (PDT)
X-Received: by 2002:a1f:a9c2:: with SMTP id s185mr1652825vke.5.1553093516706;
        Wed, 20 Mar 2019 07:51:56 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553093516; cv=none;
        d=google.com; s=arc-20160816;
        b=slvWMqm92gj9edqefj5H2OCPSXwfNYGQhlR1TU4DD1UBNvC+TNMmrJ186gKeYxe2YO
         LuHE+16N2TqHdg0aVkawLg1Alh25AX1oBKaq6bved8Xpp+BzXtBRDrYkuxcKmGf7ylhR
         gAZAd3rSKf3ZrPFF4qqG3dCOh6+Oeii3zI8bwaB7oI+LEqgJfHlfuZof5YaEMD8iXEpP
         /ZhqDHvUl0K/lz9+RXayPZsi3wXhp9RIIpUjtJ5xU3IloGt8sdAvZaigp9HZxRkFgXkO
         FRzygZT+aWFyj+36b3kX+M2p4k5JA7nNUZXNzsArnaE4Us/W3pnZ5Tu4jGUwxxvbXSPr
         N+pA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=SRoxSUqmsB49A1VVgrFKE/I4A7Rwq9IqNVIi8CfykWo=;
        b=Yy7hseDh/r8sWuEdXNiyA5+w0nmB9QnQKpmvgd5RcuD1nFB4OeWM52OEX2aA6io+h+
         uStELUgWv0LcjmNs5t6fLPAsuJlmQlB+iAan4OLqN256HDYmZjvhwe8G6RY1N1AJ4VzC
         CuWG32PyD4kSVDc9wevymE5BGhGW59OFfFniX6rXTAbApvn4Bouqmb+GAUPt9GDM2yPt
         l/Lv6pPodrkbgtXtdNNVrbPXbWUs/rIu845JA4qILHfTLuMZ11/zoewBxU8opSsV/3LC
         7iinu0cuyDwJchcxiou9Yswsd33fd+p5T7Fl16n2xXW3DREN4W31veMdo+Gw1Wl/noFl
         PjMA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="OyzBlC0/";
       spf=pass (google.com: domain of 3jfosxaokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3jFOSXAoKCGcFSIWJdPSaQLTTLQJ.HTRQNSZc-RRPaFHP.TWL@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 20sor1205359vkx.1.2019.03.20.07.51.56
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Mar 2019 07:51:56 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3jfosxaokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="OyzBlC0/";
       spf=pass (google.com: domain of 3jfosxaokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3jFOSXAoKCGcFSIWJdPSaQLTTLQJ.HTRQNSZc-RRPaFHP.TWL@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=SRoxSUqmsB49A1VVgrFKE/I4A7Rwq9IqNVIi8CfykWo=;
        b=OyzBlC0/uL5vE1MbnBSsgcN7+jbpmXNZtGY60kuBUM0zSFrlGT3CrF5ZT1ZCmJ+hRs
         B2xng/DpfUZY14vvFMcs+OKuTagQXLSbgUcYCZYD8lCRYocjoE+F6dis/azC0n2LahpR
         fhCbNmj7Sko0sq6SmJ01y5agfyxEJGwen1uXCSzTgtop3qk/9OMZRX0iJ2jvu1LdnV9D
         9KURQrsliO8cca++/6z/5DZO7j5DvF4rmS/X5lt30BPgDAJvqld664x1IsGKsEwB6tZO
         V65ycbY/8qFjv73eCrvAa8au6tfc73nlS7Q4r5OSfX539V26tciuYc2xjorJhbhq7f9n
         jsQQ==
X-Google-Smtp-Source: APXvYqxfdy/dHa2DPGc+wvB2IhPrhmdfYxxS0txmiW8IW3lGujJxMmYD9YK/VuSuwp5F0i7Xka1GzguCbhEvEnt8
X-Received: by 2002:a1f:9644:: with SMTP id y65mr16461102vkd.23.1553093516273;
 Wed, 20 Mar 2019 07:51:56 -0700 (PDT)
Date: Wed, 20 Mar 2019 15:51:18 +0100
In-Reply-To: <cover.1553093420.git.andreyknvl@google.com>
Message-Id: <44ad2d0c55dbad449edac23ae46d151a04102a1d.1553093421.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1553093420.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.225.g810b269d1ac-goog
Subject: [PATCH v13 04/20] mm, arm64: untag user pointers passed to memory syscalls
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
	Alex Deucher <alexander.deucher@amd.com>, 
	"=?UTF-8?q?Christian=20K=C3=B6nig?=" <christian.koenig@amd.com>, "David (ChunMing) Zhou" <David1.Zhou@amd.com>, 
	Yishai Hadas <yishaih@mellanox.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-arch@vger.kernel.org, netdev@vger.kernel.org, bpf@vger.kernel.org, 
	amd-gfx@lists.freedesktop.org, dri-devel@lists.freedesktop.org, 
	linux-rdma@vger.kernel.org, linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org, linux-kernel@vger.kernel.org
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
2.21.0.225.g810b269d1ac-goog

