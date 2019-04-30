Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 515FEC04AA9
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EF32121707
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="sj70XUZy"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EF32121707
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BED586B000E; Tue, 30 Apr 2019 09:25:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B78D06B0010; Tue, 30 Apr 2019 09:25:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A18586B0266; Tue, 30 Apr 2019 09:25:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qk1-f199.google.com (mail-qk1-f199.google.com [209.85.222.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7876A6B000E
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:34 -0400 (EDT)
Received: by mail-qk1-f199.google.com with SMTP id z20so9408733qkj.6
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=sP41vSza+MgZL4E9JOHZR6SNiiwo3z4wqXp2POej+GY=;
        b=lts4LijYgLPK98WkVtiI0wS3f3wa3XthrS3lqVgv+kLYK91kzJ5bgVlMVSal74K4+u
         7fbH/Kaw6QFCQltGgw8asY9fLITMLtPBuYxcKV7bVZhu30iotlhDHRzr+ENx/3+fPXuM
         XiDgM957N07GEKXQzSTco1mG1cLHiRr0i/69VZmm5mDPqGr5pJvZ35dVlfbFOZO8AhmD
         Ks/QPLw4td72UTN+Hff9vFY7xDSlZehATZh1NFSGaCYncMN5jckOGAbBT8WDylxhtsuz
         cM3Tr0J0Ab8nahfz3ajTe8S++gu9xzqDqZ3Zp7fp2UO4qI9AMCfJEIRU1giQcH5OFLLZ
         o09A==
X-Gm-Message-State: APjAAAXMxs5h6nJVjaCe2IPfD8Kpc52VlUsJNkeIlIOTT6+cLoLpTEJ9
	tJelgQB/CtOm9chVr77EIrvE/nQAz1AJ3ARzq5hEzVErd4r79AKQHYieZNGDLEKzWjMCRmx256Y
	/14a7LTE9t4/iW/3GNncNm4k8Lmr4As+hRaC7yITS49M5XfJMuqrCITD6F4b9LU7Eag==
X-Received: by 2002:ac8:1a41:: with SMTP id q1mr36331083qtk.185.1556630734204;
        Tue, 30 Apr 2019 06:25:34 -0700 (PDT)
X-Received: by 2002:ac8:1a41:: with SMTP id q1mr36331022qtk.185.1556630733364;
        Tue, 30 Apr 2019 06:25:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630733; cv=none;
        d=google.com; s=arc-20160816;
        b=etxObT5HK4+3QAgYV+T0A51zrI3TBrmmGhsGGi5nMpTvmPCy37elIBO9cFqVgkXgf0
         r9F6/A5rsfmY6rOyAFX9cgozZ1Q9VYv1R+KxriUjPoxikQI0zoLzX0jQqb8+g4E8Ekkr
         oPbhORvEnPo832+U8Q2aF6b56dwn2yFZSPPkD9PH4jKaIMwWLwVH3wc+FdBB8M72QGG9
         iRInRH5Y2kSt653oQNabBpC128nMrIgKhv4QAPA5Gr3VeAADIl8ZPgMo3Mbafg6rtSnI
         AfdQUK3hAZWjSOFK4UCyFhVl0YHUkeThkH1xXv7AvN97Y6UPu/DGfKVzGBMgD7ElL5W3
         qbuA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=sP41vSza+MgZL4E9JOHZR6SNiiwo3z4wqXp2POej+GY=;
        b=xnXIrDq7DGxLLkDmbOq4HWFG3fQ7LYUHKMS77MJM674EbxnFuZRmJTQaWHCld/zbmj
         SRWrYsMWThoHlOOeGdlVbcdCorQ3GIMKrO55T1XznTjKqrJUINl7J8eOND2qOucRnLoF
         FnlgIz3uP1rIVdd2aGmnb+FQqh/onAsfKkOosJgqDriYG4yNTvotEcb6iKtsTIcOO/Ts
         GiD8qUFFIIqE87tfFc+3nTMtLSpoOZ5QhP3GSvusgGNpAFYOZk3POGyBIEAaQo17vCBb
         VCWWHQK9oUaNnqrnk/RtBNmNLOTiwRtJcJlw/w1q1V637sN2LRPA5KxlSvuLumqsQNmB
         zkJA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sj70XUZy;
       spf=pass (google.com: domain of 3zezixaokchmreuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3zEzIXAoKCHMReUiVpbemcXffXcV.TfdcZelo-ddbmRTb.fiX@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id c13sor10238960qte.14.2019.04.30.06.25.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3zezixaokchmreuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=sj70XUZy;
       spf=pass (google.com: domain of 3zezixaokchmreuivpbemcxffxcv.tfdczelo-ddbmrtb.fix@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3zEzIXAoKCHMReUiVpbemcXffXcV.TfdcZelo-ddbmRTb.fiX@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=sP41vSza+MgZL4E9JOHZR6SNiiwo3z4wqXp2POej+GY=;
        b=sj70XUZyY78fBBLRN0Y0ejY13Ah+DWSq5MZvdtC4oy13cP3DTQDgLFkcENh07spfmR
         23eMW0ICrpgPZePCfs+0BA1gHPdG5T6uXrEWd81Tbha8dBRDM5Df4bgp8ypNTHmZGxhB
         zSa9r+Rp6W+STnkRdeIoDVRh7qzf6mRVz3aHnzxLBAlwWCR6kWuFgAJ4CJMcjRmxd08s
         WnsYITF9lzQXqyZYteDI696ABzkYAJcaC1sR3amNrgXWNyCgGFhtLoxDguJqocrpZ4Uy
         mOYkJ3BstUbrdtjiLHmZC47MGFm370/x5FYq0YwcLbrA00fWtbMhOMLHm2kOb5VLfvHU
         R2IA==
X-Google-Smtp-Source: APXvYqwOIvRkWypSUt5RnFMU33k3VTnn9YbxJDW32+qwnbYJck7Qr3YzoF+bGVldwhSnM3lKHenrz7Th7S5LU/LL
X-Received: by 2002:ac8:186e:: with SMTP id n43mr29405979qtk.69.1556630732994;
 Tue, 30 Apr 2019 06:25:32 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:01 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <9b9c21f2895b1dfd7079572ea6d9d4fd6b5bbc55.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 05/17] arms64: untag user pointers passed to memory syscalls
From: Andrey Konovalov <andreyknvl@google.com>
To: linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, 
	linux-kernel@vger.kernel.org, amd-gfx@lists.freedesktop.org, 
	dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, 
	linux-media@vger.kernel.org, kvm@vger.kernel.org, 
	linux-kselftest@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, 
	Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, 
	Kees Cook <keescook@chromium.org>, Yishai Hadas <yishaih@mellanox.com>, Kuehling@google.com, 
	Felix <Felix.Kuehling@amd.com>, Deucher@google.com, 
	Alexander <Alexander.Deucher@amd.com>, Koenig@google.com, 
	Christian <Christian.Koenig@amd.com>, Mauro Carvalho Chehab <mchehab@kernel.org>, 
	Jens Wiklander <jens.wiklander@linaro.org>, Alex Williamson <alex.williamson@redhat.com>, 
	Leon Romanovsky <leon@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, 
	Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Chintan Pandya <cpandya@codeaurora.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Kevin Brodsky <kevin.brodsky@arm.com>, 
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Andrey Konovalov <andreyknvl@google.com>
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
2.21.0.593.g511ec345e18-goog

