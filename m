Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 53E9AC04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F622274CD
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="IhwpzfJq"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F622274CD
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A15BB6B026C; Mon,  3 Jun 2019 12:55:41 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 99FAF6B026D; Mon,  3 Jun 2019 12:55:41 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 81D256B026E; Mon,  3 Jun 2019 12:55:41 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f71.google.com (mail-yw1-f71.google.com [209.85.161.71])
	by kanga.kvack.org (Postfix) with ESMTP id 51EF96B026C
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:55:41 -0400 (EDT)
Received: by mail-yw1-f71.google.com with SMTP id l184so13377157ywe.10
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:55:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=ai2S3fD+fr3rvCBmSGFiSuVAfjaa7sExxiTSFFYH1Fc=;
        b=GT/pzVVDrSG9mrDmJ7TwIIYbpdSFuSUkV2v38Mj+gWay3DadgXOLIbaGmtWIozrp8v
         UtYerLrUDbr91ZI6qwGVQV9NI9AeVn1Snv2vHbYlXvBVYLka8jkEU6mCijjOwNvc8Cd0
         zuaJlssKjeh75Zg2AHfd6u7k2qh16z+eGs7kSCBsdFZBpnpfszGrv5hpOUjLbYLUqfpG
         P3cc5EVi6FsGj813VrnnxwecrlP07G8EbiVYj0t9TxTabB3H6rjnY1sXvma1iD7Ho+Cq
         8DZTjFl0YpJDj2b+tandu+nPBMB55o3T4LNl7MsU+YktyDT4quq1Brd1XmU7q47b3YOG
         L7VQ==
X-Gm-Message-State: APjAAAXEHNvttzQWLNJWqocvuYTiCkeogOOu801GMrd8aSKsOcAfbvXh
	//BII86dj1CRA5z6NXatrIPy+NYhgajTDe6S6kGCxoeruaRnsLl4q8agnqihZwAerGkkG4D3Z5w
	C0KTTV2taP44fpUXjyFGwp5NgOer1cuO/PPRONSYhInLQYBxSHJXxg0PC2iNT7Y8jcA==
X-Received: by 2002:a81:5cd6:: with SMTP id q205mr13543304ywb.13.1559580941079;
        Mon, 03 Jun 2019 09:55:41 -0700 (PDT)
X-Received: by 2002:a81:5cd6:: with SMTP id q205mr13543260ywb.13.1559580940103;
        Mon, 03 Jun 2019 09:55:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580940; cv=none;
        d=google.com; s=arc-20160816;
        b=YMLVaZ8wFqO1rbbm/Gb9eHC6Icsvtfc6WY4rEZeTp9djamhdHf5TOa2K63rR+rAVj7
         zMGXqWja9nJ1zq9YjsM5o6ENCiY/ujydhl6mgm8b7ffYd468mE6w4P1Y8Su/wQQk/48R
         Lk/qjZkNit6GGNY89SyyiOb1KWbscV1ssD77QIyB+hv9w47aVj3gIey2qTzaB/CYC8HI
         XFAr3kUbheEWWpRka+k7D2TzQ6IBDrVAo7Rl7m4HfojB5/ycvpTf2eiPg9DIW8pqP3oh
         /UrI9LuP4zaEXo4s8S15xd427KrIY1X6ebS+/gGvQY/CjUVRPVWAA+MohktLPdptH/yt
         TZkQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=ai2S3fD+fr3rvCBmSGFiSuVAfjaa7sExxiTSFFYH1Fc=;
        b=rgD85U/79oJn+kDB0FBVm2dNyTB+fLJIxA2EDCPFtLs9RKH4PBVgOGsmR2wGjd9plU
         k14TqUNIvchu/+kKt3BoiXSC+GQ+AYoF2jSUaeVgbww5US8g7l/uZkwJl7tWPt3AHJ8D
         fPfhOgPUlOoyaUmfwo5ulTrFqgSut7DbB77R3g2kixOpGL5c2lQ4p28r0CHzg7lf5JHU
         us+VALgs3RBfqBBNAttKaDwrXp7sRlMDJA8L1CUJUxrx//aK0xGW6D/UMn8N1X7m7kRo
         Fa9AqWh0ZzA5wu7KPVNx0A6FNoTSBiny08TU6uZvGIk6d6bbpiln9x/AkEa/j23j/yDv
         S5jg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IhwpzfJq;
       spf=pass (google.com: domain of 3c1h1xaokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3C1H1XAoKCHAObRfSmYbjZUccUZS.QcaZWbil-aaYjOQY.cfU@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 65sor6512069ybg.46.2019.06.03.09.55.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:55:40 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3c1h1xaokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=IhwpzfJq;
       spf=pass (google.com: domain of 3c1h1xaokchaobrfsmybjzuccuzs.qcazwbil-aayjoqy.cfu@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3C1H1XAoKCHAObRfSmYbjZUccUZS.QcaZWbil-aaYjOQY.cfU@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=ai2S3fD+fr3rvCBmSGFiSuVAfjaa7sExxiTSFFYH1Fc=;
        b=IhwpzfJqwE3DvUc/g2ohuoF7FRDSV+OKLdbdm3aHJhyQC5R8qffzGm3GUGDEK5mLGU
         HwRFraAw3ADQD0MAJJ3addDW9VF2xcSR/1cU+MqYWb30fZYz6OI+lqi9l0mvrBzJRKlx
         9Jf/vJ7t9tP8BgDAD/yBWpZTteEGqZVu6BQfOgaOZ55GquSpR/7KRV6XVaghO9dlfSJI
         nnlViXK79lK70wRQBUW327/n/PMH7XujjWiQLfV9EFwKMzG6uOgMIpIPl3C2s4DgbvSu
         MCtmUckwctT1sQWlCUv7u3dxJmI+R7ltNLatQs+ATRBm1UQXWv9Bi0Pz/MXuzZkI0IoN
         5eSw==
X-Google-Smtp-Source: APXvYqyU8lBI93nJuhlJYUnIY7lf1oCA3Bdyf6XCo68IA8G3gKcVv3P8yXxzoFzeAZRqfZIBiTZMwuBdZZXNUsQZ
X-Received: by 2002:a25:bfcf:: with SMTP id q15mr11764130ybm.453.1559580939725;
 Mon, 03 Jun 2019 09:55:39 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:07 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <045a94326401693e015bf80c444a4d946a5c68ed.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 05/16] arm64: untag user pointers passed to memory syscalls
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
mremap, msync, munlock.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/madvise.c   | 2 ++
 mm/mempolicy.c | 3 +++
 mm/mincore.c   | 2 ++
 mm/mlock.c     | 4 ++++
 mm/mprotect.c  | 2 ++
 mm/mremap.c    | 2 ++
 mm/msync.c     | 2 ++
 7 files changed, 17 insertions(+)

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
index fc241d23cd97..1d98281f7204 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -606,6 +606,8 @@ SYSCALL_DEFINE5(mremap, unsigned long, addr, unsigned long, old_len,
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
2.22.0.rc1.311.g5d7573a151-goog

