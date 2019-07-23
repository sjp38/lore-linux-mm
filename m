Return-Path: <SRS0=2U+7=VU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-17.4 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT,USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1A7DFC76194
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:18 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CA98122543
	for <linux-mm@archiver.kernel.org>; Tue, 23 Jul 2019 17:59:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="bdR5/fk0"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CA98122543
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 542A18E000A; Tue, 23 Jul 2019 13:59:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4F55F8E0002; Tue, 23 Jul 2019 13:59:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 322A58E000A; Tue, 23 Jul 2019 13:59:17 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0FA968E0002
	for <linux-mm@kvack.org>; Tue, 23 Jul 2019 13:59:17 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id i63so32797833ywc.1
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 10:59:17 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=JFgaWDMGqAls6G489iThigfOi0kr7eFjggN3NFe6qBQ=;
        b=LZoWFVkVcivvxqPVLDgINbaGhvGW7DAE8YZYoq/Yr2dBNxRi8W2NFillsUVrzp9QD5
         mzaaV9VpD2nR1vX1RxykoSFqEwP0Xg8YZ77J0x3gtZcqeEXcq3xY80n24BjdIhjJr9Hz
         cJs6e/nFmGpCYHU6cq5Hprx1Mf+NVGC1cblBqAVYqgj7E3ojfpDWAA6Rab3tL3r1Y8o8
         mqTVVq97jMWVOwKqGIKYAJbDCf94klkamMcVosAKawnuA7ZgjHk+owWceEl3LpCBExaK
         a5A4hmafxhU5REkzadAiiBnManLyYXjrFhZrblu2y8Qcsn3dyOLx5S8/MsW1/q6sWp+D
         kEaA==
X-Gm-Message-State: APjAAAUrNr014CmP+IV9VtI9E3n1gMy8L/CoJig1jcXX8QsqVhsLwkgq
	njbsmCiE+OwU6Qi04/sLIYZKOukIrpUGWLJTEbyjP4XtvUw7IVtx9HPgB5diH4XPkOUO9WXoqu3
	Ns+GC5/MOaKWTdkY6V4iUp6HQYkJm/rIpyHe4J4zWUnNnCAbLNxnCX82sUql/wZqHsA==
X-Received: by 2002:a25:8b01:: with SMTP id i1mr35734028ybl.478.1563904756767;
        Tue, 23 Jul 2019 10:59:16 -0700 (PDT)
X-Received: by 2002:a25:8b01:: with SMTP id i1mr35734005ybl.478.1563904756165;
        Tue, 23 Jul 2019 10:59:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563904756; cv=none;
        d=google.com; s=arc-20160816;
        b=blDxVJTOkzLZQhaZ/3hjNZnuDPwU+xaEhlNnyUb6BhtRaKbHaRkAI8dsd5G2+U8c4q
         uwb1SIASR2wREx8EFSm83i3FeDN2TgMjT0KOS9MdkRrWhhgdq5mVjIavND2G92Famwjb
         4SECozREzQrGMeA5Kp6cVm0SSQnQ/36vtwcz2Z04plFh8x1kMlDtw+/9zl84PQpA2hK8
         Bq89aV/5ux7DKlkjLHZfS8/iD0dm9w2/rjiXWtctU2pR43aT6zUdcvoN2ixtC5gicbf0
         xcQFCZslwkW7UfFEA4h2G5XKe/JUt0M+9VfMQgkbo8AqU2QbE1tZF4MccYmRNJEKdwvA
         89xg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=JFgaWDMGqAls6G489iThigfOi0kr7eFjggN3NFe6qBQ=;
        b=YoyP/cpPJ5hP2dTyWkQQmVy5nGIEaWGORc9MrePGPucZ3/yneCcOaGp37WjErz85GX
         LrE7cHcLqBGwg8er2bMCRS3LJER3JDcmXK+mZcn3jGZAydYqW1xmrvT7uYcrh7hKHNyG
         GLFJHE6sBqMAPigKRyGcfoWtjC/ErBpwS35v45xZKRv9cnwriodaNW94gQwLJqXP/4Sl
         SE9rNJRGZ7WZ0DxzN0jh3gjTSDoeuXSPD6uXkcmd2pvlv5YDSch4PkNMH/ScHT3aoxsS
         wft6t20rbxXKhb4872fLD/G+dCnXUBYReUN0Yygi8eO/qjg73eA/5k6gXZ78iBGX0rqE
         na5w==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="bdR5/fk0";
       spf=pass (google.com: domain of 380o3xqokcfyyb1f2m8bj94cc492.0ca96bil-aa8jy08.cf4@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=380o3XQoKCFYyB1F2M8BJ94CC492.0CA96BIL-AA8Jy08.CF4@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id w6sor12751600ywg.199.2019.07.23.10.59.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Jul 2019 10:59:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of 380o3xqokcfyyb1f2m8bj94cc492.0ca96bil-aa8jy08.cf4@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="bdR5/fk0";
       spf=pass (google.com: domain of 380o3xqokcfyyb1f2m8bj94cc492.0ca96bil-aa8jy08.cf4@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=380o3XQoKCFYyB1F2M8BJ94CC492.0CA96BIL-AA8Jy08.CF4@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=JFgaWDMGqAls6G489iThigfOi0kr7eFjggN3NFe6qBQ=;
        b=bdR5/fk0JGKoW7w0SFkFyWDsbkS1I0veDFpzyivmTwHIiT1ZA97yr7ZNBj0H2AShr3
         pJNPC/lixw/WX323ImP4bsjq93mjJZOu3XmkpNpFXgCiVzkeEYaOnJlxDz/E8gDEr+0Z
         7c+WyXnemQpO1dfLw6iPwN48OpAMyrI2pHKz9BmhLCsXRKcJ8hMZ0q56McGVdIPQVUpC
         wU6S0XoQlY0qPAb6VoXtHP5wFmiEaCJNy21C3scQNSBD97gIywyYsw0LYzCg0A9GdhDR
         +widw+4UdtR8VyNJh7brTEfaRq+BSrao4/hRns/7LOx28RgrtCz6SeEtUQ8FFyTY31id
         9AMg==
X-Google-Smtp-Source: APXvYqyP8TuTil7EZTQQhTgA2DwZYNvsIYk2hVJOr9gyh7gqwx0FC8mj4nBRBXxdbEE2muRKlx89y5GRj7Mj4rf4
X-Received: by 2002:a81:9c0b:: with SMTP id m11mr45173898ywa.3.1563904755656;
 Tue, 23 Jul 2019 10:59:15 -0700 (PDT)
Date: Tue, 23 Jul 2019 19:58:40 +0200
In-Reply-To: <cover.1563904656.git.andreyknvl@google.com>
Message-Id: <c5a78bcad3e94d6cda71fcaa60a423231ae71e4c.1563904656.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1563904656.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.709.g102302147b-goog
Subject: [PATCH v19 03/15] lib: untag user pointers in strn*_user
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
2.22.0.709.g102302147b-goog

