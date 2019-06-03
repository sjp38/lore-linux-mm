Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D922C04AB5
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56593274C8
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="LglK5GIU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56593274C8
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DE6F06B0269; Mon,  3 Jun 2019 12:55:34 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D4C686B026B; Mon,  3 Jun 2019 12:55:34 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B753B6B026C; Mon,  3 Jun 2019 12:55:34 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 8D9026B0269
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:55:34 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id l12so5437508oii.10
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:55:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=20y1HOjqXQjYCoZ3FMKXhe3A/P2l0vyHswuOkJrBoHc=;
        b=MkT8ci+2Cw6+uCgpUoHeYz4nagZ1hcl7Q/mMswC7D2Ty+nYL0UFKvqxdMNC/rSagmT
         zVyOMBfw0gv4B2UhPqxBegK03uZmxmM2IYnwi9BODeV7XZtR1c8RC4i6H+HTCbTUwU9l
         Q6/h30DDuhJgMNrwNekrdK5YAfVegnh2qxQ/4uKErhWbGLCFyyC6Zkql2zGIqlCd6ih8
         Ji9akUx0Ilus7y/q734/hFvZkdJfHtLHDNSXUpXP8wUSXC7aFSiLqucZtxDSd2fmFwzb
         BDCQgZuB4wqTzypeQt+2JGHRL73Y/IFROAvji3r5npjWUyBdLgFK0kq+muX5UwQ7MHzj
         FZWw==
X-Gm-Message-State: APjAAAV560QLBwBGqpNX2qAw9qU7dQyFbExu5LiSvxr91/osAzG9coka
	dRcEsJ6rOORx8uG01d3YLlZI89fBXTCG4TLQUYFws7dA0NCqZ83bGAKFkGgPriUAGy1x1UrmyjZ
	HAxsUHkQAeVB9tdhglBdFOagDzr1hKZvJs0+FK3sHQctwhf72wH870cO0ZTIXH3NXcg==
X-Received: by 2002:a9d:6d8d:: with SMTP id x13mr1836499otp.6.1559580934128;
        Mon, 03 Jun 2019 09:55:34 -0700 (PDT)
X-Received: by 2002:a9d:6d8d:: with SMTP id x13mr1836469otp.6.1559580933575;
        Mon, 03 Jun 2019 09:55:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580933; cv=none;
        d=google.com; s=arc-20160816;
        b=ZAkGf+NK6MbPIvWiq6XwGFbkYbtkPtXJk2T/tJ/pJ8AXqJhqzvold5bjZPYzrS7sYl
         IDp0eFhSZrEDRlSUkoH5yBxz3i4DuxMA/8rhd0ZeM2ND/jGQyp8PN/HvSl8MjRFf4DQk
         POJtb9le1nezXN84nZkll2rLZuPDrL17+HwpuekwvKYHD2F7VUoSnDC4ZmqGkeMmDg3+
         +B2pjxoQDfx+Ku612i95sBDQ+rOnKsD9qh8lrccMamXJAOnj702Uz2V2qt41OymSfrh9
         as/VhMr3QjIJRFhcHjIQ3aR8VLER6LxDatz3aKmMbfVimO8sWcQH27pIFcLzQ66yZhXK
         f/0w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=20y1HOjqXQjYCoZ3FMKXhe3A/P2l0vyHswuOkJrBoHc=;
        b=fzTJW/VjDoHvRc0Hnc0yylgQ00tZrJLCB8d6jh1pILsRwrSdFWQ2MTuotxd7HVMeTW
         fXdyTSJQc6tjPnv0j46xiyBBReuB/aGXe5OwPMSgooOpeFyUbznBcTHLIoWNEIutcH6Q
         4kwK2W6H3x4v7rTARdGJJL/YVEWAUDfPKAxN1yODEkS8Ub9ZaRFVpXyLJTva7QgNBFX+
         ppZgENL+zSNjP07ORDcHknq2PhVbpn/XDvFor3+byK+XnAEnPh4XiZz2Xlp9TxNvgIek
         3Q8yZM0T0THag6nCe2vwm3ZXLPBPKWMrj3T4zv8Df/MAtcMvwG+zFT+3KaxPnUSU52yr
         nUCw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LglK5GIU;
       spf=pass (google.com: domain of 3bvh1xaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3BVH1XAoKCGoIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n13sor1067139otf.39.2019.06.03.09.55.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:55:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3bvh1xaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=LglK5GIU;
       spf=pass (google.com: domain of 3bvh1xaokcgoivlzmgsvdtowwotm.kwutqvcf-uusdiks.wzo@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3BVH1XAoKCGoIVLZMgSVdTOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=20y1HOjqXQjYCoZ3FMKXhe3A/P2l0vyHswuOkJrBoHc=;
        b=LglK5GIUUx/pUH7d33srSrOdoxDJcf6k8RPUUYHzql61oC+wNFESJd5PKVtebHfEHg
         K4rjnwnmDpgmbEhEStseFjNPEkvS+OI72qtgGhLpDEtxWhTvC3aTgCw5FcWPqu/H8YrI
         EsZSEg5fuJNLUqDTf1Y4yx6ojgmyvktu2GiIy1cCbapuFQIW/4LxM06f8+NqNbEgrvNM
         UWcCXb3C0eM0WuvLRS+mPfo8NHHpXEwFgU2WjcbOUcfYUWB+71yFOhi1U1i0mgtvoovy
         MA4D4byZDDLHTtN4PLwPL3K21wgXq++wadXcb7ohaA0PX/0lh5439vbzfphRZaAPKsSb
         Z6iw==
X-Google-Smtp-Source: APXvYqzHKkB2rM9PXXWgsahc+U06gQo0dW3SgxcQRqFmx6XqPzOJDdvsIYpt6xPWzmKaja2zBdl1velx+1PVZjyJ
X-Received: by 2002:a9d:62d5:: with SMTP id z21mr1888837otk.202.1559580933129;
 Mon, 03 Jun 2019 09:55:33 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:05 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <14f17ef1902aa4f07a39f96879394e718a1f5dc1.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 03/16] lib, arm64: untag user pointers in strn*_user
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

strncpy_from_user and strnlen_user accept user addresses as arguments, and
do not go through the same path as copy_from_user and others, so here we
need to handle the case of tagged user addresses separately.

Untag user pointers passed to these functions.

Note, that this patch only temporarily untags the pointers to perform
validity checks, but then uses them as is to perform user memory accesses.

Reviewed-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 lib/strncpy_from_user.c | 3 ++-
 lib/strnlen_user.c      | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
index 023ba9f3b99f..dccb95af6003 100644
--- a/lib/strncpy_from_user.c
+++ b/lib/strncpy_from_user.c
@@ -6,6 +6,7 @@
 #include <linux/uaccess.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
+#include <linux/mm.h>
 
 #include <asm/byteorder.h>
 #include <asm/word-at-a-time.h>
@@ -108,7 +109,7 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
 		return 0;
 
 	max_addr = user_addr_max();
-	src_addr = (unsigned long)src;
+	src_addr = (unsigned long)untagged_addr(src);
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
index 7f2db3fe311f..28ff554a1be8 100644
--- a/lib/strnlen_user.c
+++ b/lib/strnlen_user.c
@@ -2,6 +2,7 @@
 #include <linux/kernel.h>
 #include <linux/export.h>
 #include <linux/uaccess.h>
+#include <linux/mm.h>
 
 #include <asm/word-at-a-time.h>
 
@@ -109,7 +110,7 @@ long strnlen_user(const char __user *str, long count)
 		return 0;
 
 	max_addr = user_addr_max();
-	src_addr = (unsigned long)str;
+	src_addr = (unsigned long)untagged_addr(str);
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
-- 
2.22.0.rc1.311.g5d7573a151-goog

