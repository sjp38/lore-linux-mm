Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 01840C43219
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:29 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ACD2421734
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="dpVTwFKb"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ACD2421734
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 622186B000C; Tue, 30 Apr 2019 09:25:28 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5AA536B000D; Tue, 30 Apr 2019 09:25:28 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3FEAD6B000E; Tue, 30 Apr 2019 09:25:28 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-vs1-f70.google.com (mail-vs1-f70.google.com [209.85.217.70])
	by kanga.kvack.org (Postfix) with ESMTP id 19A926B000C
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:28 -0400 (EDT)
Received: by mail-vs1-f70.google.com with SMTP id 2so2335266vsp.23
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=BvUTfQkQM7uCDeEtImKKI/2Hme2ZprNLcMmbkGV4djo=;
        b=XXJ7lzxRqN3S9L3ZMEY/5S+RPHSGGMmUrBRsrYIuzXCzFhk/otx769Ef7uS+y/5nuO
         2iCRrIEWaX7QZOcfNZ2redsyvKh6bFUDMGGoUSQXUGXqvFrfBiF07dxcBT6CWlG/MjcB
         pQYhj1uG8/L0jRYDLfj+JH+BdwBIe/lv1hUcaw7xubDMKfoPNUCIlB9wwNVsmktgtX54
         5WORN9X1Q3YWKYTqG6ijw7g/lChSdsNiJobZAjJQgqZFSf6gRRQl5vEIroxbXacaWLHF
         2psXrU74QSmCdeg5Y399LzEODOtDF2pkvo1CXi7PVGBSPx2wq1e4cCPP3YkUP8s5oBlu
         kJJA==
X-Gm-Message-State: APjAAAXy9GvK5jr1UuWYpA2em1tyAgL6vYrx/7DusLPbu3RAHGChA3fj
	MwB6UJDZ26CXChvwz7TVB9AjZNaVltSvx9YO9L31yEAoV0vO/zzu6V7CScV+4ffGjpY8I6YjSEV
	ZWgH8185ABBV3+5siD3m2Atw9n5d0ZDG7+BwWmdktvcP9sO2iTuMnrQls1EidhWIbJw==
X-Received: by 2002:a67:b707:: with SMTP id h7mr13530729vsf.213.1556630727782;
        Tue, 30 Apr 2019 06:25:27 -0700 (PDT)
X-Received: by 2002:a67:b707:: with SMTP id h7mr13530690vsf.213.1556630727028;
        Tue, 30 Apr 2019 06:25:27 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630727; cv=none;
        d=google.com; s=arc-20160816;
        b=qWUxprNpbb0uL2gXxgudZkWWlsl/cqKcbd4MLQbSkqzolpSosYhG4vyF6T6myrImCx
         32NMMg+/2HOiFAUKBnrg4UKdYwwvAiwzVnumjgrFVMF2ySojxdtfUDlgTaCI2CvgJ+Sz
         TLLn2v3evhYntL3ygjwSxWgH6jzrnrFhMHDqCVfnR2LNoFVTbdOSRbvK8ObbEBp4LqKb
         TsBQLYz8V0/xE5dOUzpT226swa7g7qB4ICRvZ5eBSzBAXD+hVs66TiDFcU3Eta9UkEHP
         /fgKHnnLwxsZbZpXtapF0idgAsDXEd/S06qsdYFrEaS8ulQCAb7uLW7+5D09vs2lqWlZ
         UbbQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=BvUTfQkQM7uCDeEtImKKI/2Hme2ZprNLcMmbkGV4djo=;
        b=WY3Asu2DGdgtWNix9BBj5+EUQ1uda1iytSVEOgySfSuYJkVpACTK1pgKSeLzoluACM
         bgbsy7xxRffMOiwMeG4+7uE8qcvpecwsN1HuohhwjaIlk7wfstGC/9/ToDxALgLUNDFK
         yiCoVUT7GzJiD81njzayTCKuzxF5e2KElnhZ8kFka+6d1Mmrmccaw95DlU0Sj/eqfGJG
         DGogGAHNt6r0wrAAz3JWtaNmYkkfZe9rsTFp1S4C5bwIpG4DhXruZc1atP+W8/48eaVQ
         EumRF8tq+fA2BK0ARiGEDFlGZ0SLqq0lgfEjHV70u3BJQFuhqIlNQs+h0WjUFeMnGRN1
         cy9A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dpVTwFKb;
       spf=pass (google.com: domain of 3xkzixaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3xkzIXAoKCG0LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id r16sor8666988vso.33.2019.04.30.06.25.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:27 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3xkzixaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=dpVTwFKb;
       spf=pass (google.com: domain of 3xkzixaokcg0lyocpjvygwrzzrwp.nzxwtyfi-xxvglnv.zcr@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3xkzIXAoKCG0LYOcPjVYgWRZZRWP.NZXWTYfi-XXVgLNV.ZcR@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=BvUTfQkQM7uCDeEtImKKI/2Hme2ZprNLcMmbkGV4djo=;
        b=dpVTwFKbchbVkkb84ng8BnoHNS2SM91wquNJtuly6Sbp7lXj1bPrbJBiP3SyhTU0xP
         LuA/DNrbjhKI/dHi3IXFK1lS8O09Sk1+qA/R7rjDLupO2W7Szy3T1dELXK4hEpZqkwPw
         qD0yKLxb8ZjzpYALNjI1z0dDf4TB8V0IRIOptCx1gDVu9+jOblt+XzKkwvlPuV63pqHj
         wnFsYt5mNXo/Rj6N9Lo9JMQODsljOWPF/MJrAcRLfdznXkGZCgNmaSrk7MrXtOUREZGb
         X2QTJ1/W011vEIe5OofpK81AMWPuQy4lXPQltspauNse0OruElYuf2mJ90h6FolZJ8lL
         VpnA==
X-Google-Smtp-Source: APXvYqyRA/Qu4LKAWcvJoaQQlsyyIllouYjqkXgAFh5vrZ+95OMG6R4QdBb3NSzDXJSn7wdUrbj4M88LAp+D5Hqp
X-Received: by 2002:a67:ea83:: with SMTP id f3mr2107513vso.59.1556630726654;
 Tue, 30 Apr 2019 06:25:26 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:24:59 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <6f38f610cc22dca9aef05d53a5a94b24763cc628.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 03/17] lib, arm64: untag user pointers in strn*_user
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

strncpy_from_user and strnlen_user accept user addresses as arguments, and
do not go through the same path as copy_from_user and others, so here we
need to handle the case of tagged user addresses separately.

Untag user pointers passed to these functions.

Note, that this patch only temporarily untags the pointers to perform
validity checks, but then uses them as is to perform user memory accesses.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 lib/strncpy_from_user.c | 3 ++-
 lib/strnlen_user.c      | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/lib/strncpy_from_user.c b/lib/strncpy_from_user.c
index 58eacd41526c..6209bb9507c7 100644
--- a/lib/strncpy_from_user.c
+++ b/lib/strncpy_from_user.c
@@ -6,6 +6,7 @@
 #include <linux/uaccess.h>
 #include <linux/kernel.h>
 #include <linux/errno.h>
+#include <linux/mm.h>
 
 #include <asm/byteorder.h>
 #include <asm/word-at-a-time.h>
@@ -107,7 +108,7 @@ long strncpy_from_user(char *dst, const char __user *src, long count)
 		return 0;
 
 	max_addr = user_addr_max();
-	src_addr = (unsigned long)src;
+	src_addr = (unsigned long)untagged_addr(src);
 	if (likely(src_addr < max_addr)) {
 		unsigned long max = max_addr - src_addr;
 		long retval;
diff --git a/lib/strnlen_user.c b/lib/strnlen_user.c
index 1c1a1b0e38a5..8ca3d2ac32ec 100644
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
2.21.0.593.g511ec345e18-goog

