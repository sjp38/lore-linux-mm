Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CC0ECC43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:26:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7ED092173E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:26:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="g9CCdO8J"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7ED092173E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A187A6B026E; Tue, 30 Apr 2019 09:25:59 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9CA126B026F; Tue, 30 Apr 2019 09:25:59 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 868E86B0270; Tue, 30 Apr 2019 09:25:59 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 65FBA6B026E
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:59 -0400 (EDT)
Received: by mail-qt1-f199.google.com with SMTP id i38so9264485qte.18
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:59 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=5l0a3uzMK38mxhU43HR3pLkdTsHYkFU/5p0+WtYx5vA=;
        b=RIQm4F41V2LfRP1a5Th4apt4aXCSQ2ZT89yzr7g/IazQzU2DC4p6rl5hzPHzsLAF9i
         yvUc3E6rJ54QyrArPKU5PvzTFi0Bdp3ZdWXMNxdok9UeYfgpIpUVj1wOxnzMoZCdVAow
         Y5Tw566EU98V7oMbN5+vuE7v5VpHjycr1A4zwPtLyhWUn7d7vmXXDV4MU33HNgnTSU6s
         b8TWxmB8FK3OiD6WCYdvwu+jOX+J3fyKsclzImeyy3qNREIuvMSPdkXLOcR37clc7PE6
         GLseYGS2BYwHTWSX1EXF8flkdAFGOu83vh5VHWZ3fms5WzG7o5dP4jKchFWKDo6KgbdJ
         EE4A==
X-Gm-Message-State: APjAAAV3Ya0FIfp4JTT5rrxEGJLVd27J2Vv2MnCT8NLzfK6BCxccS+15
	lJka3ZMj7DmXmw55p8XuZfwxhtNbMszn3D4qIMe8caXh8h/45WJo2pstMwKQLx9qt++wKLCppyZ
	u3QzziePMbNYHmQwAESlU+HBHQiX7ZyB7FHSZIi096gv6vJZqkR7B3EduTSW6W2RaZg==
X-Received: by 2002:ac8:2be8:: with SMTP id n37mr55057036qtn.303.1556630759100;
        Tue, 30 Apr 2019 06:25:59 -0700 (PDT)
X-Received: by 2002:ac8:2be8:: with SMTP id n37mr55056975qtn.303.1556630758369;
        Tue, 30 Apr 2019 06:25:58 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630758; cv=none;
        d=google.com; s=arc-20160816;
        b=usMB2i7Ik5H948T32+Cdt2FJkKAkEiUoiU4bHx/NG4sT8sG6v7uTzNNQfW3w4UMzqB
         /Gq6na6pCJqxcas8nINjh+V0hAaEbAIgr7NEfH2wGKulrjUb3IiN5K7uLRbKts2Fly5k
         tqRtPwDFrw2se/N1kwUO0+w0MfWOWie5uCWU9vZgJMuyhlJDrbEVoxWNnzG3KMrXFVJy
         B+1u9aQ3SiZGCfldcmNon4u27GObvfWggFx94YwBEV9Jg58e9N6NiKHcVSinz+qFbOgS
         O+BtqwGKq+X3zLR3GyUX0kpfDkUQLuhP6B0ezRARaGEClhuAyw3WDbxmJjv7QLgmJ7EI
         1tsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=5l0a3uzMK38mxhU43HR3pLkdTsHYkFU/5p0+WtYx5vA=;
        b=XjwzjIKiqQOj1Wld7SnjJE2UIcMqcOak0Tl846S8aA5E0BU5bFaROGMFfHHrxy8BU8
         bP3SdSzUqT2EnJIUSM/XsGyg4Vvu3Z2Nory2D7PG2v4oNISsZKedWAXTgSe+1CzvHJkL
         Uuu0ju2CHJOJx9PksJXXoX+gEHC3od0ngCsVs/iIgyOkHubLcfZNevFXtokowrys7YAX
         Jwz8wk6vF+vXme0hdLy/NUWuoe6fwliXIMT0C0D/jpOsUtXrohLgAQgLvQVbAeoZDaja
         5Akb4bwOE5DBBcb9VuHyuDiL1YrEa1KmqVTuIuzTlT1xbSBCM/Ds7T2H/7FDnmkhsYin
         RnPQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=g9CCdO8J;
       spf=pass (google.com: domain of 35uzixaokciwq3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35UzIXAoKCIwq3t7uE03B1w44w1u.s421y3AD-220Bqs0.47w@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f40sor31438485qve.60.2019.04.30.06.25.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of 35uzixaokciwq3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=g9CCdO8J;
       spf=pass (google.com: domain of 35uzixaokciwq3t7ue03b1w44w1u.s421y3ad-220bqs0.47w@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=35UzIXAoKCIwq3t7uE03B1w44w1u.s421y3AD-220Bqs0.47w@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=5l0a3uzMK38mxhU43HR3pLkdTsHYkFU/5p0+WtYx5vA=;
        b=g9CCdO8J183ztwieMKtxq5bQgdPwn8MyKUl5zlyySPt09tOB1Gypd0bdF1FTgPWg9U
         vgl3VSH+QbfWqwQxuQNAq18fHGv2grDucix13/YUy3bvOI1BB9BrzAgOyNFI+ychptbo
         BVp24qrS90whe3PqSvAaQ8Kncxvv8pqzjLbVvi9smoyLBamx2Dg/fg59oj/C1VgTZmLk
         po6sIoVdSb935f+/5YJnlpWSaOQYjK3//t7Ql3k3IgbH35nE1TWkeZ08/rMUWbwR2R7Q
         rNZsAyxKMZqUS4nVVdVnnh9Mowjk/e6QvbUTkAZYjeM7AIkIVd6G6w9+5n4IsjstGWE8
         jwFg==
X-Google-Smtp-Source: APXvYqzcKJMSJm3saTG/Jy9RV9wnqiRL/1GQ7HSUwiNcvOVWaTtiFz1xHas1LLHxgSsag1rnBPh3sxDf1Qf0ekUW
X-Received: by 2002:a05:6214:18d:: with SMTP id q13mr1705396qvr.213.1556630757432;
 Tue, 30 Apr 2019 06:25:57 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:25:09 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <05c0c078b8b5984af4cc3b105a58c711dcd83342.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 13/17] IB/mlx4, arm64: untag user pointers in mlx4_get_umem_mr
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
	Szabolcs Nagy <Szabolcs.Nagy@arm.com>, Andrey Konovalov <andreyknvl@google.com>, 
	Leon Romanovsky <leonro@mellanox.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This patch is a part of a series that extends arm64 kernel ABI to allow to
pass tagged user pointers (with the top byte set to something else other
than 0x00) as syscall arguments.

mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
Reviewed-by: Leon Romanovsky <leonro@mellanox.com>
---
 drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index 395379a480cb..9a35ed2c6a6f 100644
--- a/drivers/infiniband/hw/mlx4/mr.c
+++ b/drivers/infiniband/hw/mlx4/mr.c
@@ -378,6 +378,7 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
 	 * again
 	 */
 	if (!ib_access_writable(access_flags)) {
+		unsigned long untagged_start = untagged_addr(start);
 		struct vm_area_struct *vma;
 
 		down_read(&current->mm->mmap_sem);
@@ -386,9 +387,9 @@ static struct ib_umem *mlx4_get_umem_mr(struct ib_udata *udata, u64 start,
 		 * cover the memory, but for now it requires a single vma to
 		 * entirely cover the MR to support RO mappings.
 		 */
-		vma = find_vma(current->mm, start);
-		if (vma && vma->vm_end >= start + length &&
-		    vma->vm_start <= start) {
+		vma = find_vma(current->mm, untagged_start);
+		if (vma && vma->vm_end >= untagged_start + length &&
+		    vma->vm_start <= untagged_start) {
 			if (vma->vm_flags & VM_WRITE)
 				access_flags |= IB_ACCESS_LOCAL_WRITE;
 		} else {
-- 
2.21.0.593.g511ec345e18-goog

