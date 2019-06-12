Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 03794C31E47
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:43:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A4FD7208C2
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:43:51 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jG6r3qKX"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A4FD7208C2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 561F96B0008; Wed, 12 Jun 2019 07:43:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 53AAA6B000A; Wed, 12 Jun 2019 07:43:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 450556B000D; Wed, 12 Jun 2019 07:43:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yb1-f200.google.com (mail-yb1-f200.google.com [209.85.219.200])
	by kanga.kvack.org (Postfix) with ESMTP id 263DC6B0008
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:43:51 -0400 (EDT)
Received: by mail-yb1-f200.google.com with SMTP id l184so15212312ybl.3
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:43:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=9yc1Yq7FenUh0AO3dUlc6AUSMFMskh2/7LbKPot9xGI=;
        b=I0AGt2mVF2gO7482NpK6ziFp3oKCj27zWKWd07F0wF24v+Rl4Fv1mjqGu7ZkDaz8qJ
         V7VR/kq3Bk6L160iLZ/nWMcAUGJ2KTsfEdF7c1tsRRepuZ5h3p+1SDV3JXm3a481wYvY
         cfG9e3l1fgraa2lL66vbI1ccAvj4KueBDncQY+zjleNGUQcHuBuqvzeJgpkxl8IoNDjp
         gxT9AeW7X4vrDqXexDjgi6YgrDj0awScNET6hnz0znQxW1KJ/Aq54CJWkuDgvK3mpr27
         iimrrMEqmvzBCTHS/i2NJLCIaMc5KEZ8IY+8jIRKXryqD/zsfRnztIouwtokzItwQB5k
         fzXA==
X-Gm-Message-State: APjAAAXNoTUFm2cjvqC9zWxtb0vmbLSca07ChYc4IgIP9Ie/wz+yYoBe
	WPIrP0pndZAO35gBqqKPLbtrHojta+rV8XJsa0dtmR3sPP4wGKIuUMdey/BmNouPsOwpK/Lf/g9
	/H96xfUiklTfMScTkJCvVlqfy2VlO4oErRt7ALtzrnJTmZ/FhbZ/+Rn3JE2LsNsPX4Q==
X-Received: by 2002:a5b:a8d:: with SMTP id h13mr979836ybq.3.1560339830804;
        Wed, 12 Jun 2019 04:43:50 -0700 (PDT)
X-Received: by 2002:a5b:a8d:: with SMTP id h13mr979815ybq.3.1560339830003;
        Wed, 12 Jun 2019 04:43:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339829; cv=none;
        d=google.com; s=arc-20160816;
        b=D/KVDomL5fXjz5FRzXQEkfdY1stLz64giOYPo1I6knBhXnREmcaBwtCcPYCM0kh59A
         ClO3AXl/aDv4ITfPMDmF+KWvuPIKCb3z7dZojTo/YpsXJ1xHBNMevYx2csFzIeghFq61
         TDBmbR+TKHijJU0SedTpBME/JGFtyrppZv3AAyQXOEwzEFodgruFtiCna7aQpn2TkqbQ
         kCX5/zHMQ+84nzFGU3BiE1au/cbdaoOa90KQOgDxHhVmqXowpPwpC6iLqsaUT6fUL5JW
         FhPTg50yeXVfQl0g8TFCKZb64ad4oVy6NJHOrs8BjTCXenBsWcSOHyR5d0ZD96pkwpbR
         4YQQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=9yc1Yq7FenUh0AO3dUlc6AUSMFMskh2/7LbKPot9xGI=;
        b=KCxPCZ/RNi49dXeAMkXDbjjuIJN9/1FrVxiEAPlZ3Krfj1HvSHHHHX83iJdPfuxazE
         WPxK6KgKwj8Zpgo/yKUeSi8p30G69RYO5we2qTUQCPaV2wqeQXhEyp5XUwW/bDc7HmiV
         USQqwuuZyAwcRSPY6gYkT7kgDA86xz+irTc+C3rBOvicw22J+eL7dR9TwgfaAYFrNU12
         tAcd7Su1Dyv1+Djwx/wPLMg2fhT4Qg0oTwudAiFWo3ezJ9MwOhS2S1VzOTibwjrYT+S3
         rW7Gby4N2Tgmm7LIPZPM0b/X/bFu25HD6uAtTEViD/9rif68pWAv6vMSOUg95xlOc34q
         9iYA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jG6r3qKX;
       spf=pass (google.com: domain of 3deuaxqokcdiobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3deUAXQoKCDIObRfSmYbjZUccUZS.QcaZWbil-aaYjOQY.cfU@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id u6sor8023844ywc.162.2019.06.12.04.43.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:43:49 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3deuaxqokcdiobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jG6r3qKX;
       spf=pass (google.com: domain of 3deuaxqokcdiobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3deUAXQoKCDIObRfSmYbjZUccUZS.QcaZWbil-aaYjOQY.cfU@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=9yc1Yq7FenUh0AO3dUlc6AUSMFMskh2/7LbKPot9xGI=;
        b=jG6r3qKXi5/zKGkjzMFvbQ4XcPl+/QmcSKvFp3utSJtxAUleazRXkJRGwBNNuJ7i7E
         W7vyyFyjCHej12ys6727AQE+zBEoRn7fuGQ0zPXkT7W8rJNSD33sWm4M+L2uLQ9Yr38G
         Tk/yJfeEOxvIPA7bqvovIzoag6j0IkNGtc29ARK/7GdZnbkyHKT1QM3wgM9+VOErwGhl
         DOZEsTVUoN8+b79rOajf7KnGDkH2u/eCR/G6bd5zo2eRqtSAit8bn6BlCrH2lRN5NzMd
         //lJnKytaH0FthsUWMOhqc1e/AQcdKwVvubR2bol5kkiAS3ABJ/10iV11C/N1mocmKiy
         lcUQ==
X-Google-Smtp-Source: APXvYqzWkT0P+p3RG6pP2xT18iDm8BLgmUWrizOHYeFPCBqdgbB+Dc65X4gpAkgZlAg9PVOXah90gk97CBM2CYKI
X-Received: by 2002:a81:2545:: with SMTP id l66mr16760176ywl.489.1560339829646;
 Wed, 12 Jun 2019 04:43:49 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:21 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <f9b50767d639b7116aa986dc67f158131b8d4169.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 04/15] mm, arm64: untag user pointers passed to memory syscalls
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

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

This patch allows tagged pointers to be passed to the following memory
syscalls: get_mempolicy, madvise, mbind, mincore, mlock, mlock2, mprotect,
mremap, msync, munlock, move_pages.

The mmap and mremap syscalls do not currently accept tagged addresses.
Architectures may interpret the tag as a background colour for the
corresponding vma.

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
index 080f3b36415b..e82609eaa428 100644
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
2.22.0.rc2.383.gf4fbbf30c2-goog

