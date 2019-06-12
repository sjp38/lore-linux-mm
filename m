Return-Path: <SRS0=Ax9E=UL=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.3 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6F185C31E48
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:13 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2E0712082C
	for <linux-mm@archiver.kernel.org>; Wed, 12 Jun 2019 11:44:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="UD79Ay48"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2E0712082C
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D2D176B026A; Wed, 12 Jun 2019 07:44:12 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D00696B026B; Wed, 12 Jun 2019 07:44:12 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BC9D06B026C; Wed, 12 Jun 2019 07:44:12 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9E4B46B026A
	for <linux-mm@kvack.org>; Wed, 12 Jun 2019 07:44:12 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id q26so14485416qtr.3
        for <linux-mm@kvack.org>; Wed, 12 Jun 2019 04:44:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=eb4SnUCHaoFPTU0EqMrx7H6L5ANcvzM3zwsiyq0FV40=;
        b=aaokBjGaSM4PUx//olVbzhTkuNXgnhM/7YUSKia82wTNEUihdUzzNu152pKsRj2LCn
         MUhU4vk9A8RaitHzBHgNYAakOmv0DlpQdDzeSfy7TTqgdjbNSxuBNh0TpULHDHg7h0EB
         kWtCmmk7F1PxZH15OPRtqKxFO3c9Wk64VwFQtjn2PVmIzsmT27nx2FXvCI7Ni1QkEeNC
         DWRlqZdK8MWUc2dUsBgjjsqCoFodMyb/bDZOxeIxlCfqukxILkyuYtHOG15yR9JwiO83
         4dAjqeHvc7uh3PZ9TEDoCKWEb16LuFKf8EJYVfAFyvWkEGRNNZPXwqYu7Mx1kHRBQ7TE
         lj4Q==
X-Gm-Message-State: APjAAAXTdNqQtIJYXBisylszHVpOoPtHmQujbm+QarEIdyV+3mCCq3bf
	fshKGsqoTwqRjQJCZv3kadhNkbFv3SCIKchNvlxMQN6Gaa7n6os6bA+R0KlDwLan48mVIyqFgD6
	Kbz1+TSK7tzGVKL7LC63TZGLugVz4m3xfOt33kp/XbOPj0gAvjRoTHyrMB9pwh3FkTg==
X-Received: by 2002:a05:620a:12ef:: with SMTP id f15mr21611833qkl.340.1560339852429;
        Wed, 12 Jun 2019 04:44:12 -0700 (PDT)
X-Received: by 2002:a05:620a:12ef:: with SMTP id f15mr21611798qkl.340.1560339851932;
        Wed, 12 Jun 2019 04:44:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560339851; cv=none;
        d=google.com; s=arc-20160816;
        b=lzhl6H8JjArd0sn7TBITtX2XFRSdV73Iuvrov/9kVs1wXKY9J8VyrzoBUufA+/Rl8K
         xsXcy+VrkyVnOLUAgiPaPAkqfryDYDX4V9eNG4EqGPmAdkuokyj6rgXsHvceeZJlV3h4
         dJpbBd077FnEhi6050PD/AnX8Dsf66eJKIusNUbNzTnag4D0sR0K/+E7gtBDGSwYRtyy
         cbTGAhcW11u4mgAHn4iONseZHbgHHy2MFlmYVP2ow8EWM4g0gsUQ3SH7xPTZc9jWsQxS
         MR+xLj9TktJLcqGno1soG9gHp47Z9aiei9XJXNr9tZLUfbV1XuM63ETuif/jsgXaTGIk
         RsYw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=eb4SnUCHaoFPTU0EqMrx7H6L5ANcvzM3zwsiyq0FV40=;
        b=jUeoooE1T/FxdP75O95hmVqp6LQ6KckGD/+VSl6SMVnCDqucRAyexrPIsrk/UEla0z
         /DpvpRaXPWkUWWL7QuM5d948LVMiNo7YpMVOW3mXj0sASKDoHVFZBJEe3UYClDeJe8lK
         CGJi5n0Ss0s8XOPUmSagrWdsQ7tZC5v91pdaIqzPP6WjhidFXfURx23cKJDYysL1Fm5S
         lZtrOZPPbbmvc37W8+e193ZcvxF4QqK3qLJMaPyXr5HxsChPUtylzwLB4uyS/a6RBnvT
         GdJV2B3+OofPZsrsjk8csbmAKIMcgHQse7phAzFY/Q1KLQlDx6YKQalkzRuCbg3ECNFJ
         g39w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UD79Ay48;
       spf=pass (google.com: domain of 3i-uaxqokcegkxn1o8ux5vqyyqvo.mywvsx47-wwu5kmu.y1q@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3i-UAXQoKCEgkxn1o8ux5vqyyqvo.mywvsx47-wwu5kmu.y1q@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v83sor9203215qkb.100.2019.06.12.04.44.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Jun 2019 04:44:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3i-uaxqokcegkxn1o8ux5vqyyqvo.mywvsx47-wwu5kmu.y1q@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=UD79Ay48;
       spf=pass (google.com: domain of 3i-uaxqokcegkxn1o8ux5vqyyqvo.mywvsx47-wwu5kmu.y1q@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3i-UAXQoKCEgkxn1o8ux5vqyyqvo.mywvsx47-wwu5kmu.y1q@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=eb4SnUCHaoFPTU0EqMrx7H6L5ANcvzM3zwsiyq0FV40=;
        b=UD79Ay48r+Qt/fUB4eQQS+u7jB3BFWRYtdLCt6Qa95VfLfmvvw7Hya/RkyTUwkhx0D
         +1vmB8M4RBQZbJNIhwkYxv5AEL21ErrNvQCQ8+lOs4BCA4LMOTjJTuV8BlTNIfNEsvvi
         S8RTYx74gNWKftQMTjEJ+kHo6ZnD8masl8ZG8ezS9xy8uaiMn8te593VaiscKSGKojp2
         e5Cc4FqtUoN3q8YTe+OydLtjYtDNOm5Wm5t/bbuGQhbg9sf44AZgifS6zPiIE4WlbsCF
         2CX+HbBHE4vO/HCGylKIpSsIsXiK8frsZe8Lb15lkTfFpYP5OsKznhL91S0FrbJQy23X
         yoqw==
X-Google-Smtp-Source: APXvYqziQbsGJB+s1a1ziaRcl+e8Gmo6MzSM6gFLtwRxsTnl2K0xyr2RS7DkrrH2w0nPz/f56zeYNt9ix1U3jsHZ
X-Received: by 2002:ae9:f107:: with SMTP id k7mr2472892qkg.215.1560339851579;
 Wed, 12 Jun 2019 04:44:11 -0700 (PDT)
Date: Wed, 12 Jun 2019 13:43:28 +0200
In-Reply-To: <cover.1560339705.git.andreyknvl@google.com>
Message-Id: <50293fea168d5252f79ee0bf160c64c72edbf270.1560339705.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1560339705.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc2.383.gf4fbbf30c2-goog
Subject: [PATCH v17 11/15] IB/mlx4, arm64: untag user pointers in mlx4_get_umem_mr
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

mlx4_get_umem_mr() uses provided user pointers for vma lookups, which can
only by done with untagged pointers.

Untag user pointers in this function.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/infiniband/hw/mlx4/mr.c | 7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/mr.c b/drivers/infiniband/hw/mlx4/mr.c
index 355205a28544..13d9f917f249 100644
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
2.22.0.rc2.383.gf4fbbf30c2-goog

