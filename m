Return-Path: <SRS0=8Dof=TA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C187DC04AA6
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:22 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7552E2075E
	for <linux-mm@archiver.kernel.org>; Tue, 30 Apr 2019 13:25:22 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="jG67MQO6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7552E2075E
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 055C36B0008; Tue, 30 Apr 2019 09:25:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id F297B6B000A; Tue, 30 Apr 2019 09:25:21 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E0D8B6B000C; Tue, 30 Apr 2019 09:25:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id BB7F86B0008
	for <linux-mm@kvack.org>; Tue, 30 Apr 2019 09:25:21 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id n203so12765722ywd.20
        for <linux-mm@kvack.org>; Tue, 30 Apr 2019 06:25:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=Yt+PWI13/w7NMYz3zwPrNGqq+ReXtpTWddPqmKmBKgk=;
        b=o1vLovvXd34H8t3iP6a2frBpu1MxJPRjBmV3allD85XFFySztOf7YVeSIE2J+o3ATg
         FN3vRsYPDp06O+9Gtc1415mPAIyOcYp/fd/7z0k80L2zMtTS6E7irMbG/qcTQBeXv/+h
         GaBdKfKCc+akSVr5+aMkgRSg8hyJ3wd8fconAjJjCrLhzA/Y2NIsjVIQpnBPkuxGwUNb
         VR7QOycNm+QnXsH5q1WZB4ayav0sO8FZcw7vFCx9zzPSANZjXqzmRCt1B3gO+GdaFzKb
         BpwksrZMHS8tgUB1HMLqUpuiiB9AMAwIKxRO9li11I3vqjJU1/uN9TG6Cy2OjR5kwz57
         A3MQ==
X-Gm-Message-State: APjAAAV2Qx+2t5LZPrcNzUfHuFlxkANjaQCalRzgVYgi1DfpcsFCprkJ
	Xru9D994R3sjOisQEbdXSUOQleIXGHTeuIUyC8rAUEvO0BlThofo1JwkDbxzlheXeb5J/yAOZIT
	akxHweKWoX5kQAevcUYcu9hAqv9c5Mx9C/uDcMj4tvlaWTGHAyLJ3F8mqYM680NeTvA==
X-Received: by 2002:a25:ef44:: with SMTP id w4mr59743704ybm.174.1556630721487;
        Tue, 30 Apr 2019 06:25:21 -0700 (PDT)
X-Received: by 2002:a25:ef44:: with SMTP id w4mr59743626ybm.174.1556630720671;
        Tue, 30 Apr 2019 06:25:20 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556630720; cv=none;
        d=google.com; s=arc-20160816;
        b=d2dit4AxdccV2GnroEe7rdX0f4H6eURR1/C9GMDJPXE8l4B06U1N2X1XmnZA7eIFEr
         GE8IxT16Z8sjGtP7dMEGssTJJFQybiHafUYRC6J0TgtKJXBIZ0OHtu3ax+0dg8vD6jcS
         JepluXk6hFFRP30K2SErryCDIMKnYtSEoIdh+aZBpziywZ2wOyCn5tYgHIosFTaiPh0S
         039umsrzrSx0F5Qv+/n2idKf1KSbueEnLX+p7HuTX7Z4U4sDGOOHeiafxJMoPOlO59kY
         IZiS3KGLZ7KJ8LAn7Oe0lEdBnGERJJOmRbUFQBh9vkoS6eAP/u7QQ9pCIxBkKQvFSifG
         Eclg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=Yt+PWI13/w7NMYz3zwPrNGqq+ReXtpTWddPqmKmBKgk=;
        b=KX8L8yT5iKD7zTcYWg948ivt61kyjKWiuoEjpMvK/cIS9XDRA1K73jptACrl9N74g2
         q8lk+PZ3MI71PKtUvORxSBwZUVPbdKXfinEa1Urkk3uXde/9dAFGo+DnkccnFlgVrRhD
         QUm6XEOYepluu/1Td4OQ7yp1hKizlOu99o8sO3o9i9+C3DZnu9CDH9XLmwj048G7SwdI
         4ZJ9p+axBb4j8YUOhGs/mNEG8jnAxPsh8Y1+GSr3fjTLpNsb2WcGZ4dXRiVvmz3fbKcB
         4nWBJPkR2amM35dAH6j2nGbAqd1jrGgSQIXuf7O/jVI1OPHFUmmMeEwyoaKr974Mbgtj
         Tguw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jG67MQO6;
       spf=pass (google.com: domain of 3wezixaokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3wEzIXAoKCGcFSIWJdPSaQLTTLQJ.HTRQNSZc-RRPaFHP.TWL@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id n206sor12041977ywn.55.2019.04.30.06.25.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 30 Apr 2019 06:25:20 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3wezixaokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=jG67MQO6;
       spf=pass (google.com: domain of 3wezixaokcgcfsiwjdpsaqlttlqj.htrqnszc-rrpafhp.twl@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3wEzIXAoKCGcFSIWJdPSaQLTTLQJ.HTRQNSZc-RRPaFHP.TWL@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=Yt+PWI13/w7NMYz3zwPrNGqq+ReXtpTWddPqmKmBKgk=;
        b=jG67MQO6uSTq+PQJ7NLS3u3pGPqYxBD6j6Z7zSYau7uP7jvgt3bFEq3faUxv1qOiIb
         Lhjg89Y6A0R/eNow3E4oC26RwU4x5nya0AVoMdWDIBSbYBBhFLCViwOATovkHqYFgw83
         hOVUMM4j6unbJMoC5S4qfPmdZGJuwasxoQN5pLBzNoODYCmMWIdN+DK/0OhTFTFrX99t
         6EDwehqEld5biejrj0QAkLSZAfR6m8nobezuReC4ugk/eXbqiTH4l+ivloQAzM7wUwIe
         NZAar432hbtNkfGtL2tuOjYFn681Ww9UC8SmNz4UpJpUm1tSs7E6peMLsrX4yxW2SbA8
         caHA==
X-Google-Smtp-Source: APXvYqzn+VCXcz3/MPYUKI1STEW4oOzSku7o6dMmFF+1zuaxsiuVuMrbdGrvK+1IRDapYK9+TGfb+TbRJGhClYr2
X-Received: by 2002:a81:3d51:: with SMTP id k78mr56599045ywa.106.1556630720203;
 Tue, 30 Apr 2019 06:25:20 -0700 (PDT)
Date: Tue, 30 Apr 2019 15:24:57 +0200
In-Reply-To: <cover.1556630205.git.andreyknvl@google.com>
Message-Id: <c66c15554ff43b09aa97595907d4231be3fb7b31.1556630205.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1556630205.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.21.0.593.g511ec345e18-goog
Subject: [PATCH v14 01/17] uaccess: add untagged_addr definition for other arches
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

To allow arm64 syscalls to accept tagged pointers from userspace, we must
untag them when they are passed to the kernel. Since untagging is done in
generic parts of the kernel, the untagged_addr macro needs to be defined
for all architectures.

Define it as a noop for architectures other than arm64.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/mm.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 6b10c21630f5..44041df804a6 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -99,6 +99,10 @@ extern int mmap_rnd_compat_bits __read_mostly;
 #include <asm/pgtable.h>
 #include <asm/processor.h>
 
+#ifndef untagged_addr
+#define untagged_addr(addr) (addr)
+#endif
+
 #ifndef __pa_symbol
 #define __pa_symbol(x)  __pa(RELOC_HIDE((unsigned long)(x), 0))
 #endif
-- 
2.21.0.593.g511ec345e18-goog

