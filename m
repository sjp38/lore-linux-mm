Return-Path: <SRS0=pZwQ=TG=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.5 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B584EC04AAD
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58BAF2173E
	for <linux-mm@archiver.kernel.org>; Mon,  6 May 2019 16:31:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="YtLNTr71"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58BAF2173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9434A6B0269; Mon,  6 May 2019 12:31:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8F2CA6B026A; Mon,  6 May 2019 12:31:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7E4776B026B; Mon,  6 May 2019 12:31:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5A5BF6B0269
	for <linux-mm@kvack.org>; Mon,  6 May 2019 12:31:24 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id v7so2701027vsc.12
        for <linux-mm@kvack.org>; Mon, 06 May 2019 09:31:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=5/U30IDTpMzOZZUHty5OaCehkawNQwuaMdmb1lxJ4Z0=;
        b=K9nwQp80TFXcTSRQgIrtYLCvtj5Yq7UMGZNTPRgYOuCr3ELjUd7Pqmjkp2ZxFZ1kcM
         6P57AOOf4MPlpPjbA7SKFIlnzD6MPKePGJfQ9alsMqpLyJfLbjneN7KTW41WWhWX2OJT
         KLqRRbGxMj/N6j5mKY7ew3vSS9Uer+Cs3gCW1zhUSi44U6IA3dpM9t81BJ1Jn7+pjVTv
         hiEkS8Jf08kHciAyzF1MkGTOYGt6PVgcN9FHgAcGpNuXnlksFPv049qJQg923LDvt8WL
         itBCigY4K8esIUdc71QS4nXQrJre/BE+BfcGcvSnOquUAwCYb6nmUBNFdNSoc0p7idri
         hSlA==
X-Gm-Message-State: APjAAAWiUyzaDEMEs1j/vwHAGjU97kHWNxAfnO826JefTHu0LUYEsWhX
	ZYoCwmadryr7Mw8nAdQrZzFIajihRcQ4CyRTFTQPXi1zZFM7uceniqnOXB5J3zexT96fazDTSuh
	mN8ZDi7rxMFz8It/H+9qAsg15exNuAsxy/udnbl9YnWae7DDIKhDqQS0+iuDCzkvf9Q==
X-Received: by 2002:a9f:2b02:: with SMTP id p2mr13640237uaj.29.1557160283922;
        Mon, 06 May 2019 09:31:23 -0700 (PDT)
X-Received: by 2002:a9f:2b02:: with SMTP id p2mr13640177uaj.29.1557160283008;
        Mon, 06 May 2019 09:31:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557160283; cv=none;
        d=google.com; s=arc-20160816;
        b=CzS69/lRd7hn2cx8D820lGaunQdF4wEIDmo/dCr1+ae6r7QmGKFWsl36/87Co9H58X
         JsfHj6TO08czIsn87yYcCWaC5DDn+hISSCdRm/pUqMvWFFX5m5Yr/6Ol8NeWeXqF4J0q
         OLM0T3CZXc3YYIOFiD3DqjOpmWwIDQiCw5XAfs4bkLJR65JzhLMHnS3+jWe4ufs3OQAI
         M+OoVFFkQyZhxS++EUIqVDFSPvXzXnl04igQ7LPnCdg8Lkc7CLkoJJ0V3x7YwrLjLlcu
         tD0mxJog1JVFiD2DcuoghDsoKFY5bRH7N8DGT+cf8wz1UZ+VbPFKqRautCukP9fXKzU3
         syhA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=5/U30IDTpMzOZZUHty5OaCehkawNQwuaMdmb1lxJ4Z0=;
        b=sQquKqsHk4fqI3DQTV2C1w2v1fyiKV+5D54LAzbANaa1tMgEclIRsAd1lSYoWb/Clq
         NYW5tjTuuQKoHSRhtgfclgbMrQJSf/FNKnWCccu0gQ0x4b3etouAGb6oaPe8B15gZ2j1
         eRMUIMh4/a8Ba6OqPvNpKKzGxvkPeQ8pL0Wq8YtO4h04Y3Zi0/j2UFelbThfXA2ceZGQ
         0vxQfiXBHc/foFMVjztd7UUZ1eRhcjQMpMeOMqYXBdguI/F2u9s6ynp2izORF5sB/COn
         qmL4JXIwOxjV8i7wJZUjkeIFBY3eNuzMJ4rjzHFwepXsFcENcZjESntrgd4VuXqKNXW0
         deWg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YtLNTr71;
       spf=pass (google.com: domain of 3wmhqxaokcesn0q4rbx08yt11tyr.p1zyv07a-zzx8npx.14t@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3WmHQXAoKCEsn0q4rBx08yt11tyr.p1zyv07A-zzx8npx.14t@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id x134sor5451832vsc.7.2019.05.06.09.31.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 May 2019 09:31:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3wmhqxaokcesn0q4rbx08yt11tyr.p1zyv07a-zzx8npx.14t@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=YtLNTr71;
       spf=pass (google.com: domain of 3wmhqxaokcesn0q4rbx08yt11tyr.p1zyv07a-zzx8npx.14t@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3WmHQXAoKCEsn0q4rBx08yt11tyr.p1zyv07A-zzx8npx.14t@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=5/U30IDTpMzOZZUHty5OaCehkawNQwuaMdmb1lxJ4Z0=;
        b=YtLNTr71LQtDtm4+fIzPRqVEmsig4jIZm+5Xq1i7HEuxqe92Fba7UIz0P7LGc/lCae
         dXG34rcNIps8e/OHQ3Qzc2dw8Q2cw02t5CRXFsyAuFyvOSJWHO7z9kGM+zFce82aoyA3
         qtrPznLya17o1jSMBsriB2NxUvL6TNepNcLFNmzdS0xujMY5BYhLZIcZKNLcHkkh0W1L
         /UJ5RkfdxqJMDgKHhR9weZLpKLMZYLR2mkyZcMWZXKn0tWKezIF4luzZUNs3aAJ9eSxT
         OA5Tz3eW90ZO6gwE2fYYKkT2xZxlwtZaQj4M4Oni1/3Ul1zlOiWvHRCQ7SYhl4fTWfl6
         H0KQ==
X-Google-Smtp-Source: APXvYqzPcSLCkM7yKRgWAgtLPPmtlxC3d1i0NZJgfFSPt5rWBLpStTcU2VVry9J5XQbhU5Djgso0ZhxSZBobo+In
X-Received: by 2002:a67:ed0b:: with SMTP id l11mr13351119vsp.55.1557160282543;
 Mon, 06 May 2019 09:31:22 -0700 (PDT)
Date: Mon,  6 May 2019 18:30:51 +0200
In-Reply-To: <cover.1557160186.git.andreyknvl@google.com>
Message-Id: <00eb4c63fefc054e2c8d626e8fedfca11d7c2600.1557160186.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1557160186.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.1020.gf2820cf01a-goog
Subject: [PATCH v15 05/17] arms64: untag user pointers passed to memory syscalls
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, 
	Felix Kuehling <Felix.Kuehling@amd.com>, Alexander Deucher <Alexander.Deucher@amd.com>, 
	Christian Koenig <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
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
syscalls: brk, get_mempolicy, madvise, mbind, mincore, mlock, mlock2,
mmap, mmap_pgoff, mprotect, mremap, msync, munlock, munmap,
remap_file_pages, shmat and shmdt.

This is done by untagging pointers passed to these syscalls in the
prologues of their handlers.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/kernel/sys.c | 128 +++++++++++++++++++++++++++++++++++++++-
 1 file changed, 127 insertions(+), 1 deletion(-)

diff --git a/arch/arm64/kernel/sys.c b/arch/arm64/kernel/sys.c
index b44065fb1616..933bb9f3d6ec 100644
--- a/arch/arm64/kernel/sys.c
+++ b/arch/arm64/kernel/sys.c
@@ -35,10 +35,33 @@ SYSCALL_DEFINE6(mmap, unsigned long, addr, unsigned long, len,
 {
 	if (offset_in_page(off) != 0)
 		return -EINVAL;
-
+	addr = untagged_addr(addr);
 	return ksys_mmap_pgoff(addr, len, prot, flags, fd, off >> PAGE_SHIFT);
 }
 
+SYSCALL_DEFINE6(arm64_mmap_pgoff, unsigned long, addr, unsigned long, len,
+		unsigned long, prot, unsigned long, flags,
+		unsigned long, fd, unsigned long, pgoff)
+{
+	addr = untagged_addr(addr);
+	return ksys_mmap_pgoff(addr, len, prot, flags, fd, pgoff);
+}
+
+SYSCALL_DEFINE5(arm64_mremap, unsigned long, addr, unsigned long, old_len,
+		unsigned long, new_len, unsigned long, flags,
+		unsigned long, new_addr)
+{
+	addr = untagged_addr(addr);
+	new_addr = untagged_addr(new_addr);
+	return ksys_mremap(addr, old_len, new_len, flags, new_addr);
+}
+
+SYSCALL_DEFINE2(arm64_munmap, unsigned long, addr, size_t, len)
+{
+	addr = untagged_addr(addr);
+	return ksys_munmap(addr, len);
+}
+
 SYSCALL_DEFINE1(arm64_personality, unsigned int, personality)
 {
 	if (personality(personality) == PER_LINUX32 &&
@@ -47,10 +70,113 @@ SYSCALL_DEFINE1(arm64_personality, unsigned int, personality)
 	return ksys_personality(personality);
 }
 
+SYSCALL_DEFINE1(arm64_brk, unsigned long, brk)
+{
+	brk = untagged_addr(brk);
+	return ksys_brk(brk);
+}
+
+SYSCALL_DEFINE5(arm64_get_mempolicy, int __user *, policy,
+		unsigned long __user *, nmask, unsigned long, maxnode,
+		unsigned long, addr, unsigned long, flags)
+{
+	addr = untagged_addr(addr);
+	return ksys_get_mempolicy(policy, nmask, maxnode, addr, flags);
+}
+
+SYSCALL_DEFINE3(arm64_madvise, unsigned long, start,
+		size_t, len_in, int, behavior)
+{
+	start = untagged_addr(start);
+	return ksys_madvise(start, len_in, behavior);
+}
+
+SYSCALL_DEFINE6(arm64_mbind, unsigned long, start, unsigned long, len,
+		unsigned long, mode, const unsigned long __user *, nmask,
+		unsigned long, maxnode, unsigned int, flags)
+{
+	start = untagged_addr(start);
+	return ksys_mbind(start, len, mode, nmask, maxnode, flags);
+}
+
+SYSCALL_DEFINE2(arm64_mlock, unsigned long, start, size_t, len)
+{
+	start = untagged_addr(start);
+	return ksys_mlock(start, len, VM_LOCKED);
+}
+
+SYSCALL_DEFINE2(arm64_mlock2, unsigned long, start, size_t, len)
+{
+	start = untagged_addr(start);
+	return ksys_mlock(start, len, VM_LOCKED);
+}
+
+SYSCALL_DEFINE2(arm64_munlock, unsigned long, start, size_t, len)
+{
+	start = untagged_addr(start);
+	return ksys_munlock(start, len);
+}
+
+SYSCALL_DEFINE3(arm64_mprotect, unsigned long, start, size_t, len,
+		unsigned long, prot)
+{
+	start = untagged_addr(start);
+	return ksys_mprotect_pkey(start, len, prot, -1);
+}
+
+SYSCALL_DEFINE3(arm64_msync, unsigned long, start, size_t, len, int, flags)
+{
+	start = untagged_addr(start);
+	return ksys_msync(start, len, flags);
+}
+
+SYSCALL_DEFINE3(arm64_mincore, unsigned long, start, size_t, len,
+		unsigned char __user *, vec)
+{
+	start = untagged_addr(start);
+	return ksys_mincore(start, len, vec);
+}
+
+SYSCALL_DEFINE5(arm64_remap_file_pages, unsigned long, start,
+		unsigned long, size, unsigned long, prot,
+		unsigned long, pgoff, unsigned long, flags)
+{
+	start = untagged_addr(start);
+	return ksys_remap_file_pages(start, size, prot, pgoff, flags);
+}
+
+SYSCALL_DEFINE3(arm64_shmat, int, shmid, char __user *, shmaddr, int, shmflg)
+{
+	shmaddr = untagged_addr(shmaddr);
+	return ksys_shmat(shmid, shmaddr, shmflg);
+}
+
+SYSCALL_DEFINE1(arm64_shmdt, char __user *, shmaddr)
+{
+	shmaddr = untagged_addr(shmaddr);
+	return ksys_shmdt(shmaddr);
+}
+
 /*
  * Wrappers to pass the pt_regs argument.
  */
 #define sys_personality		sys_arm64_personality
+#define sys_mmap_pgoff		sys_arm64_mmap_pgoff
+#define sys_mremap		sys_arm64_mremap
+#define sys_munmap		sys_arm64_munmap
+#define sys_brk			sys_arm64_brk
+#define sys_get_mempolicy	sys_arm64_get_mempolicy
+#define sys_madvise		sys_arm64_madvise
+#define sys_mbind		sys_arm64_mbind
+#define sys_mlock		sys_arm64_mlock
+#define sys_mlock2		sys_arm64_mlock2
+#define sys_munlock		sys_arm64_munlock
+#define sys_mprotect		sys_arm64_mprotect
+#define sys_msync		sys_arm64_msync
+#define sys_mincore		sys_arm64_mincore
+#define sys_remap_file_pages	sys_arm64_remap_file_pages
+#define sys_shmat		sys_arm64_shmat
+#define sys_shmdt		sys_arm64_shmdt
 
 asmlinkage long sys_ni_syscall(const struct pt_regs *);
 #define __arm64_sys_ni_syscall	sys_ni_syscall
-- 
2.21.0.1020.gf2820cf01a-goog

