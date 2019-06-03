Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 43F97C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:05 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F3835274E3
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:56:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="TJVcn1cL"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F3835274E3
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A181E6B0273; Mon,  3 Jun 2019 12:56:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 9C6EC6B0274; Mon,  3 Jun 2019 12:56:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 844156B0275; Mon,  3 Jun 2019 12:56:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 565B06B0273
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:56:04 -0400 (EDT)
Received: by mail-qt1-f198.google.com with SMTP id a18so5980993qtj.18
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:56:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=EspxEupGJGiWEDXD9P4jjgWKmcXH74NzvYIbJ/AWgMI=;
        b=NoM8oGHpXv6f2v+gbnGWs8vqKEJunmzw460cLohLRNTttl2BVFBXOxpKrSLcfVjUf0
         qCcxQbpCLGW2CueN/ddjepAgSvZ/VDs4qGnyt2jcdbfI8vgiw92hEDRHVs6lR56Tj25U
         291Y32Z3i5v3kC5Ug2i1cZhmZzeZNVy2YKNR2ljduiOwkdpVNR9g+m7CRs6KPLTICCzQ
         Hel6crsFE9SdFJYxBMNFK/kHZDrtotnkkU/MqgkrAtJ42gvuAsISWKAq9N2rm7n8bVWS
         DIDvdE4e1gLox6SsFCXstBNMWzsNMfByatqhXB9l5AMP7ITYbHAa4ISdB3STlh6EaR42
         VBeg==
X-Gm-Message-State: APjAAAVDLXip6vxZrDkjA/zrrHgvlqmZ2E/OmfTDVXKqPvq4uMbMaC9k
	jHNe1UyU8XktpkDv2EKRt8pgz5jtRTSfijTqTZbSSh0+72XXTwINLwMw9s2f3G8xVaEGn8nVO7p
	tavq2TAftXXppY5e3cSq1D7JZc/Ar0Vc+9rk0suWweilRvj7grutSBFU3wnyvcK2htg==
X-Received: by 2002:a0c:b929:: with SMTP id u41mr22918219qvf.50.1559580964059;
        Mon, 03 Jun 2019 09:56:04 -0700 (PDT)
X-Received: by 2002:a0c:b929:: with SMTP id u41mr22918180qvf.50.1559580963540;
        Mon, 03 Jun 2019 09:56:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580963; cv=none;
        d=google.com; s=arc-20160816;
        b=SZ5SbGvAufYFmj3GwMlrRNG+oZIQ1Ulsbl4lp3xdr+jf88vW6mBB8+SSBV1fhDfXfe
         9rSY72HYodjCTPz2EyQ4rfUyviD6UeH5XQI2ES18MMOpVe0pL/I1HhdD9GbLvFMKkX7p
         ttJBaEwC4J8hle5lXi+1tDXLdicjlgtJILdBAx0j3j+r+xqaACpBdAc25ppL04ot5+JW
         +VQaiQXOOxnKHrirB/1HR/KFwoImdPqaG10WNkcc+NS0HMDoz85l5ycwHFMRC3h4Lcd5
         +B1FSanAnnLk0FBmU920hYX2pp86rBoiQQ8Mj0YpQSIlwtikTavsaXLvgpd08lx0Bl2f
         z+2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=EspxEupGJGiWEDXD9P4jjgWKmcXH74NzvYIbJ/AWgMI=;
        b=q0hbZjxMomRWuiKeOQdhP3Rj1+keyiWZl6WhLgiUy10c9w+r3Kq4az0MCj0LSM4+X1
         z7WzlLVJntz9+fmWzSy4EPH9poNLhwO0HcHifYtEevswKpYVI8QBYeQLWkXTRdoSa1/T
         ee0F1HNYvltQdx+it1BUnyaLpQYKyZxMoFXUgX6UvWOBWiRaACKSS8xxxMgSdozZ6+d+
         MDPIpVS0uqI91fKGT1CXgHzjQAmjPHhq1BsLMGETGbTRyjXS93xRQtg1BxyXiIWfDF+b
         2iPp+Zx4Lu83ERhgVF4KbTGduKkK58jLkuRFDCvcopjQsiWwmKGjotzdg2EKa4dsbxz2
         PZ/w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TJVcn1cL;
       spf=pass (google.com: domain of 3i1h1xaokcigmzp3qawz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3I1H1XAoKCIgmzp3qAwz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w14sor1718257qvf.57.2019.06.03.09.56.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:56:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3i1h1xaokcigmzp3qawz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=TJVcn1cL;
       spf=pass (google.com: domain of 3i1h1xaokcigmzp3qawz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3I1H1XAoKCIgmzp3qAwz7xs00sxq.o0yxuz69-yyw7mow.03s@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=EspxEupGJGiWEDXD9P4jjgWKmcXH74NzvYIbJ/AWgMI=;
        b=TJVcn1cLKwrCDqfOoDXp30a4H6TaXBKiwiHjDAdwongHK/bKzo02AftS+NOLHZV2qk
         uaXFTsh7OP9kK6tBgKChXJ2KBusgSI13ByE5QAJT4opcCyHzVAEN7KnoiqvVvgIk9UeZ
         thbX5DYw+Ya/O9Bt8a5AL4KNqAUsZ4B4hEfnsQKdt+gJFBe02e/Gllpw40I3Eh8jjzXh
         yX2E6mPgl8q0tFyhEApdfs/i0GKdcLnrmq2mOZHSQm727N+W9pKIuuH8ohRLmjbmQDTf
         QCPeVpMCsS5AlW/faffrLj+KIOBAFryuyM2XhBVLl0qrMu2w3WMArdINiV+/WP+bh/um
         j3qg==
X-Google-Smtp-Source: APXvYqyTJQX58jIU+0IdRLMyhel9C9SXAf29MqpC57OIYMzhYLqjfoH2DhcsbA5oBHVd1rJqiIiEUBwjKZJxchdB
X-Received: by 2002:a0c:be87:: with SMTP id n7mr3853859qvi.65.1559580963191;
 Mon, 03 Jun 2019 09:56:03 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:14 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <c829f93b19ad6af1b13be8935ce29baa8e58518f.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 12/16] IB, arm64: untag user pointers in ib_uverbs_(re)reg_mr()
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

ib_uverbs_(re)reg_mr() use provided user pointers for vma lookups (through
e.g. mlx4_get_umem_mr()), which can only by done with untagged pointers.

Untag user pointers in these functions.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/infiniband/core/uverbs_cmd.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/infiniband/core/uverbs_cmd.c b/drivers/infiniband/core/uverbs_cmd.c
index 5a3a1780ceea..f88ee733e617 100644
--- a/drivers/infiniband/core/uverbs_cmd.c
+++ b/drivers/infiniband/core/uverbs_cmd.c
@@ -709,6 +709,8 @@ static int ib_uverbs_reg_mr(struct uverbs_attr_bundle *attrs)
 	if (ret)
 		return ret;
 
+	cmd.start = untagged_addr(cmd.start);
+
 	if ((cmd.start & ~PAGE_MASK) != (cmd.hca_va & ~PAGE_MASK))
 		return -EINVAL;
 
@@ -791,6 +793,8 @@ static int ib_uverbs_rereg_mr(struct uverbs_attr_bundle *attrs)
 	if (ret)
 		return ret;
 
+	cmd.start = untagged_addr(cmd.start);
+
 	if (cmd.flags & ~IB_MR_REREG_SUPPORTED || !cmd.flags)
 		return -EINVAL;
 
-- 
2.22.0.rc1.311.g5d7573a151-goog

