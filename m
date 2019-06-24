Return-Path: <SRS0=9FL3=UX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77219C43613
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 35804213F2
	for <linux-mm@archiver.kernel.org>; Mon, 24 Jun 2019 14:33:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="nl7WANT+"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 35804213F2
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3B3818E000A; Mon, 24 Jun 2019 10:33:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 363508E0002; Mon, 24 Jun 2019 10:33:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1DD0A8E000A; Mon, 24 Jun 2019 10:33:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f197.google.com (mail-qt1-f197.google.com [209.85.160.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0035D8E0002
	for <linux-mm@kvack.org>; Mon, 24 Jun 2019 10:33:15 -0400 (EDT)
Received: by mail-qt1-f197.google.com with SMTP id g30so17150785qtm.17
        for <linux-mm@kvack.org>; Mon, 24 Jun 2019 07:33:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=QQXMFisLcqxTDxCx7mpHBfkykflxcDxM95yy0y46L4c=;
        b=r8MaYatNvwkJo9ez43laVFs3Dz+a9d5CFQJ2c047Awkg/fWRG+EXFDeFJ8MDt0Nd6M
         XrbsP3opWn/mc8I+2+AIqxTjTZ95gIK/G+BmV2jJW7fp4i4bx+AI8TSrP7/6ggz8ZWTH
         sPUDU39ZTdqP8ZHtc/O7S6eyEmgrGLJBq3nP25nKC8/zVDuTIhkck5l9nDrDqwRw1/3r
         I7YBsQDir4Zw9ZZkRvmjXxIceKPnC8XwxGCF7gcopLb+ZB1tE+37+w13NkMDJbKaNlkC
         MhEFliMebM5ae/dFSSa3V9ITe2hMkEmgKPaJIaQ271zyi0vJi8an3FSJiKcamaR0h6iD
         BSHQ==
X-Gm-Message-State: APjAAAXtpQCOx9jO4ZnbgC97RQNF1M+eaaseaBGw+9Cr8eMxHVyVQF2o
	oTaEaWNhlnzWIGG1Nf3lc1KNKA/JREIZnJGXRWqnAZSSpj1dep5YKl2AZ3H8Hbvth+8cGzLfRwy
	IqcgN2eC9DXjIqtD8VmBdNEK3cLPYjL/WfvJmpeiX5SzoRfpjX2fj8puo7C1qJSI1dA==
X-Received: by 2002:a37:d16:: with SMTP id 22mr102846616qkn.232.1561386794690;
        Mon, 24 Jun 2019 07:33:14 -0700 (PDT)
X-Received: by 2002:a37:d16:: with SMTP id 22mr102846551qkn.232.1561386794113;
        Mon, 24 Jun 2019 07:33:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561386794; cv=none;
        d=google.com; s=arc-20160816;
        b=D/ArDjmMTzhySPQthfm+QvQCY3eam9aVWmkTuwmRRqTnrVi8xIUS6Z7jT8Oe2HcPpA
         twmg2HvFyyzRCH9uvD2FDi2eG0ZCdVjsWAwEnSagqwatJeymu7qV8lKYugeFrkvmLykh
         ZhaVJHNIFP9tmMCh4E3/Cb0CyLbmahr5JNOGDRrp4IN+1D47j+9O6/9TzUISaOhD5IOS
         KAIlpPuicM4Mgm4rTrvd3/dPLTiXzXnw1MNkySiqRqVzlt1Mh51XJK29/4TTNsCmZlL1
         pUvAp1VYwP7WdhquzdYdxTIE/+dS8IJphsNAYdSJC2ZQSWH8aKWLXzsuxlb+nZKsW4aE
         AQUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=QQXMFisLcqxTDxCx7mpHBfkykflxcDxM95yy0y46L4c=;
        b=RL6k9ux6bMofxcgstLkWpS9wSpeKKAv/pCcxvRZXwO+6yIzDhj17Na1zUDxuXu4tlj
         cpNvGxI/KWreE5njMvwIIjpEeBMCk49tP8cPlMm2Xt6etVrmPk9f2yzWis5gY3P4XCUE
         tN6aw7as+Lj3Pwf3VNqJgveGEbpNpnH7TaEyjO4S1LZwElbvCwzaJ1pNUij7c/763RV5
         bpOOWhicNmhzj1aWbO1fcN7RyNoOONOmbrwWuty4v1i9GK6O8A8v8VkKJYG2uudJ9Rn9
         dwtgFI2mP8dXy3Ixct40zhJ5sEpRohvRS3VpsGI04gRiEQ0eMwqxnaPZKklowj+8Nevu
         CrJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nl7WANT+;
       spf=pass (google.com: domain of 3kd8qxqokcbo0d3h4oadlb6ee6b4.2ecb8dkn-ccal02a.eh6@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Kd8QXQoKCBo0D3H4OADLB6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id i6sor6490538qkc.47.2019.06.24.07.33.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 24 Jun 2019 07:33:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3kd8qxqokcbo0d3h4oadlb6ee6b4.2ecb8dkn-ccal02a.eh6@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=nl7WANT+;
       spf=pass (google.com: domain of 3kd8qxqokcbo0d3h4oadlb6ee6b4.2ecb8dkn-ccal02a.eh6@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3Kd8QXQoKCBo0D3H4OADLB6EE6B4.2ECB8DKN-CCAL02A.EH6@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=QQXMFisLcqxTDxCx7mpHBfkykflxcDxM95yy0y46L4c=;
        b=nl7WANT+T3zzJdQNSfB9+m3b8ydqMfXiozgRLYeQCHFc4zWOn1Q8HlSZi7DGmunKcG
         m48YCubQKuyc5mIC9PWmc95WNcaYrn+rBkilmeEtWye/vcm/w7SgqxmZ+eLuRWNk+dBe
         ilcc0xwMAFdqkWVOavUtr03O5uEwSiv8ah8EA2ZNm/JYdo0vp1VaJuLVzssnLAaxlz0W
         +bGemSNE16fXrFDUhV0Eo7CJiC+zuIHkEvL14QgEfP6YhZ1zpRezDVdue+M4lC6Urd5x
         s/pZSUm/6UDNd/YlF2uYqWPTYuto+748pEjr815zYdNJlDljrtH9f8RpmzII6hCRLyFl
         B0aA==
X-Google-Smtp-Source: APXvYqzup51zNJearylpYQzBo2BoCcuJ3XXHspU9PtHQODnUVY/RZyP6CGJqukGO0YgO4GkOlCbGA2J//cHunZZU
X-Received: by 2002:a37:a2cc:: with SMTP id l195mr16730110qke.362.1561386793770;
 Mon, 24 Jun 2019 07:33:13 -0700 (PDT)
Date: Mon, 24 Jun 2019 16:32:48 +0200
In-Reply-To: <cover.1561386715.git.andreyknvl@google.com>
Message-Id: <1a53da43d69d644793110e85671d20158ebf29cb.1561386715.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1561386715.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.410.gd8fdbe21b5-goog
Subject: [PATCH v18 03/15] lib: untag user pointers in strn*_user
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

strncpy_from_user and strnlen_user accept user addresses as arguments, and
do not go through the same path as copy_from_user and others, so here we
need to handle the case of tagged user addresses separately.

Untag user pointers passed to these functions.

Note, that this patch only temporarily untags the pointers to perform
validity checks, but then uses them as is to perform user memory accesses.

Reviewed-by: Vincenzo Frascino <vincenzo.frascino@arm.com>
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Acked-by: Kees Cook <keescook@chromium.org>
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
2.22.0.410.gd8fdbe21b5-goog

