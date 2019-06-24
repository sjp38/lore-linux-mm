Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0262AC43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id AE838208E4
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="WUmcuISq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org AE838208E4
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DEC778E000B; Mon, 24 Jun 2019 10:33:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DA8BD8E0002; Mon, 24 Jun 2019 10:33:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C3E788E000B; Mon, 24 Jun 2019 10:33:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f69.google.com (mail-vs1-f69.google.com [209.85.217.69])
	by kanga.kvack.org (Postfix) with ESMTP id 96F178E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:18 -0400 (EDT)
Received: by mail-vs1-f69.google.com with SMTP id k10so3948062vso.5
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Js+Uq+QN1sbXUiaVQRwOsU0mf+gtz1j4mv8k/PcURo8=;
        b=TWyYCH6pREBNFjLKYEZFotU40EhVrAxMdx/bLkAVRojJ27ryYk1klk/cBN2Xq3zcYR
         hId1YhYyQhRaK4Stml/UdsKVzZo81dMaGa0GJdrjamGu8JcFmVFdvsRaiGo09mUHiJlZ
         64Je14p81PMblv5ANXWOfj/OpXtqdvBZ+py2/UoHjwdERw/wjs+/VDjl5RVxIMg61PMo
         NtcanalClFybS4WwLV25QLv/Bu2Aobtm8HaDAQJWMQzbthwbJ2HfmePGaW1wKfWS7ujf
         gm3PO3ajgVoqFhVFDUp3IgECwTQ23cMlQ3LTWS29zhnwEMfJPU377WAPdSrMCXWUy0P+
         /aXA==
X-Gm-Message-State: APjAAAUroKe+UDAurv4CVAdlxKNIm2hXDqr3MjK70IrxZLTkCIrUh+dS
	RvxRMWMrGk9TnC9AYnY9BaLsRrdDoeylHfsNibl5Zl+CrxmaFxCvqNB+/Py+dH5PwSoAg695VNK
	8KtZSay0PDAJx0Pu2J9HvEz6KhUfIeuZyV6cfeZVFxn2dg3P+Ib9UjsupMItCOb6tHg==
X-Received: by 2002:ab0:5499:: with SMTP id p25mr77022841uaa.2.1561386798231;
        Mon, 24 Jun 2019 07:33:18 -0700 (PDT)
X-Received: by 2002:ab0:5499:: with SMTP id p25mr77022777uaa.2.1561386797202;
        Mon, 24 Jun 2019 07:33:17 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386797; cv=none;
        d=google.com; s=arc-20160816;
        b=gJJORwUYrIF0evLvu8JLibMSIhc3gtMyoS2TMKR/qsi1Pym3KcMsGeGQZ++yoYipOS
         oXo4ES2WpnKKxioiy9S0HF3yBxv24kEKYqRDcMZirqFBo6aTAa+PlLBridTgl0ca7AVG
         7CIIjGneBo0FYrkB6/cxDXAn/zToN5rd3+2QWuG5DU18FKjTLf01rT5n8a4chOZMVrFe
         yNiBH4uHjuqPPl5S6YLFNzJpHNdspRNOP9vrji14yrX/mGWUNXpUEdpd5PIRjyIOx907
         ZzhsEWrV0nO41PJt4Dd8yFMaVTCIt4Ar7/lt/RERo1RtF0gBl73k4Ttx5Z8HcEC0phVN
         GDsQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Js+Uq+QN1sbXUiaVQRwOsU0mf+gtz1j4mv8k/PcURo8=;
        b=BcBwmpZse/xGV+uYO1JNhRerFs4QUjuGnjpFJSchdUGEVsxmfrFGOOYAzpDiFwRmMd
         LP1JRtamsRyU9q6XvwFA0kkb4RUrDaStkcMisadPPRtDyT0yNVCL/kJU6nF3fgNFLDjG
         3HFSXtQIzQu0vMKAmaUR1LTAKHcVs6reheuVlsYTeEhzCzW3hcgJLwouhY0UJ+nm7FnY
         hdcIlBgWaVhWAiEYsrrkOwXdykgPaTxTzQ7WRtaCylVg4wevHoNGKBXlLdIm1A5raZn6
         PEx+jkB5L0QH4sKzkLDCXwYZiPwn0DsROfMjcICThCZKqNEmnaJwmh7zPMk9bxiek8df
         vuAw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WUmcuISq;
       spf=pass (google.com: domain of 3ln8qxqokcb03g6k7rdgoe9hh9e7.5hfebgnq-ffdo35d.hk9@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3LN8QXQoKCB03G6K7RDGOE9HH9E7.5HFEBGNQ-FFDO35D.HK9@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v6sor5931835vsi.25.2019.06.24.07.33.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:17 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3ln8qxqokcb03g6k7rdgoe9hh9e7.5hfebgnq-ffdo35d.hk9@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=WUmcuISq;
       spf=pass (google.com: domain of 3ln8qxqokcb03g6k7rdgoe9hh9e7.5hfebgnq-ffdo35d.hk9@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3LN8QXQoKCB03G6K7RDGOE9HH9E7.5HFEBGNQ-FFDO35D.HK9@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Js+Uq+QN1sbXUiaVQRwOsU0mf+gtz1j4mv8k/PcURo8=;
        b=WUmcuISq69GG5fXOV16ZRYbJqbX03QewrhmWUSnfmneQQxv/bVXoBYPmdDkptO+OQH
         1/ri/E5A/vk+WVGJL91rAId5SPbwcU1J+GEX05oiT/FBX3QCL2+VhrCx25laQbj3KnwW
         0uir1QyGoqb8aJtY+XhjApiqZ1TV2sygux6c5i3/wTSx5YjlviAMiL6rDgYCbrfWKKhP
         SKObpS/Kb5KcFQF3GiBdDIn+XXk54+4aDsioVtDEbCgrm2teMCuqY10Jw19vQvkqN0a9
         +wn60o1NBQ+srPpd9cks85wQk+N4yLFGZhxIXnCiqlOqaI9rp4YIg/Ppw4BnZH2jTZPF
         nKRw==
X-Google-Smtp-Source: APXvYqyg4WJnk6EUjTU/KUznHgpngcCHVd+yKoydagOLQxGVZUbXzn8R7RbZiNlfqU2taVShyYtDXoa3laNIqrwD
X-Received: by 2002:a67:fc19:: with SMTP id o25mr17948112vsq.106.1561386796805;
 Mon, 24 Jun 2019 07:33:16 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:49 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <387274fe8ecad41a73aec347fe24682b633a8147.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 04/15] mm: untag user pointers passed to memory syscalls
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
	Leon Romanovsky <leon@kernel.org>, Luc Van Oostenryck <luc.vanoostenryck@gmail.com>, 
	Dave Martin <Dave.Martin@arm.com>, Khalid Aziz <khalid.aziz@oracle.com>, enh <enh@google.com>, 
	Jason Gunthorpe <jgg@ziepe.ca>, Christoph Hellwig <hch@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, 
	Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, 
	Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, 
	Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Robin Murphy <robin.murphy@arm.com>, 
	Kevin Brodsky <kevin.brodsky@arm.com>, Szabolcs Nagy <Szabolcs.Nagy@arm.com>, 
	Andrey Konovalov <andreyknvl@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends kernel ABI to allow to pass
tagged user pointers (with the top byte set to something else other than
0x00) as syscall arguments.

This patch allows tagged pointers to be passed to the following memory
syscalls: get_mempolicy, madvise, mbind, mincore, mlock, mlock2, mprotect,
mremap, msync, munlock, move_pages.

The mmap and mremap syscalls do not currently accept tagged addresses.
Architectures may interpret the tag as a background colour for the
corresponding vma.

Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Kees Cook <keescook@chromium.org>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/madvise.c   | 2 ++
 mm/mempolicy.c | 3 +++
 mm/migrate.c   | 2 +-
 mm/mincore.c   | 2 ++
 mm/mlock.c     | 4 ++++
 mm/mprotect.c  | 2 ++
 mm/mremap.c    | 7 +++++++
 mm/msync.c     | 2 ++
 8 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/mm/madvise.c b/mm/madvise.c
index 628022e674a7..39b82f8a698f 100644
--- a/mm/madvise.c
+++ b/mm/madvise.c
@@ -810,6 +810,8 @@ SYSCALL_DEFINE3(madvise, unsigned long, start, size_t, len_in, int, behavior)
 	size_t len;
 	struct blk_plug plug;
 
+	start = untagged_addr(start);
+
 	if (!madvise_behavior_valid(behavior))
 		return error;
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 01600d80ae01..78e0a88b2680 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -1360,6 +1360,7 @@ static long kernel_mbind(unsigned long start, unsigned long len,
 	int err;
 	unsigned short mode_flags;
 
+	start = untagged_addr(start);
 	mode_flags = mode & MPOL_MODE_FLAGS;
 	mode &= ~MPOL_MODE_FLAGS;
 	if (mode >= MPOL_MAX)
@@ -1517,6 +1518,8 @@ static int kernel_get_mempolicy(int __user *policy,
 	int uninitialized_var(pval);
 	nodemask_t nodes;
 
+	addr = untagged_addr(addr);
+
 	if (nmask != NULL && maxnode < nr_node_ids)
 		return -EINVAL;
 
diff --git a/mm/migrate.c b/mm/migrate.c
index f2ecc2855a12..d22c45cf36b2 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -1616,7 +1616,7 @@ static int do_pages_move(struct mm_struct *mm, nodemask_t task_nodes,
 			goto out_flush;
 		if (get_user(node, nodes + i))
 			goto out_flush;
-		addr = (unsigned long)p;
+		addr = (unsigned long)untagged_addr(p);
 
 		err = -ENODEV;
 		if (node < 0 || node >= MAX_NUMNODES)
diff --git a/mm/mincore.c b/mm/mincore.c
index c3f058bd0faf..64c322ed845c 100644
--- a/mm/mincore.c
+++ b/mm/mincore.c
@@ -249,6 +249,8 @@ SYSCALL_DEFINE3(mincore, unsigned long, start, size_t, len,
 	unsigned long pages;
 	unsigned char *tmp;
 
+	start = untagged_addr(start);
+
 	/* Check the start address: needs to be page-aligned.. */
 	if (start & ~PAGE_MASK)
 		return -EINVAL;
diff --git a/mm/mlock.c b/mm/mlock.c
index a90099da4fb4..a72c1eeded77 100644
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -674,6 +674,8 @@ static __must_check int do_mlock(unsigned long start, size_t len, vm_flags_t fla
 	unsigned long lock_limit;
 	int error = -ENOMEM;
 
+	start = untagged_addr(start);
+
 	if (!can_do_mlock())
 		return -EPERM;
 
@@ -735,6 +737,8 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
 {
 	int ret;
 
+	start = untagged_addr(start);
+
 	len = PAGE_ALIGN(len + (offset_in_page(start)));
 	start &= PAGE_MASK;
 
diff --git a/mm/mprotect.c b/mm/mprotect.c
index bf38dfbbb4b4..19f981b733bc 100644
--- a/mm/mprotect.c
+++ b/mm/mprotect.c
@@ -465,6 +465,8 @@ static int do_mprotect_pkey(unsigned long start, size_t len,
 	const bool rier = (current->personality & READ_IMPLIES_EXEC) &&
 				(prot & PROT_READ);
 
+	start = untagged_addr(start);
+
 	prot &= ~(PROT_GROWSDOWN|PROT_GROWSUP);
 	if (grows == (PROT_GROWSDOWN|PROT_GROWSUP)) /* can't be both */
 		return -EINVAL;
diff --git a/mm/mremap.c b/mm/mremap.c
index fc241d23cd97..64c9a3b8be0a 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -606,6 +606,13 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
 	LIST_HEAD(uf_unmap_early);
 	LIST_HEAD(uf_unmap);
 
+	/*
+	 * Architectures may interpret the tag passed to mmap as a background
+	 * colour for the corresponding vma. For mremap we don't allow tagged
+	 * new_addr to preserve similar behaviour to mmap.
+	 */
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
2.22.0.410.gd8fdbe21b5-goog

