Return-Path: <SRS0=ZkFZ=UC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,T_DKIMWL_WL_MED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90755C282CE
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4820C251FA
	for <linux-mm@archiver.kernel.org>; Mon,  3 Jun 2019 16:55:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="Gd3MS7x4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4820C251FA
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C89216B000D; Mon,  3 Jun 2019 12:55:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BEAAB6B0266; Mon,  3 Jun 2019 12:55:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C8DD6B0269; Mon,  3 Jun 2019 12:55:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-yw1-f69.google.com (mail-yw1-f69.google.com [209.85.161.69])
	by kanga.kvack.org (Postfix) with ESMTP id 75C916B000D
	for <linux-mm@kvack.org>; Mon,  3 Jun 2019 12:55:27 -0400 (EDT)
Received: by mail-yw1-f69.google.com with SMTP id q188so17290308ywc.15
        for <linux-mm@kvack.org>; Mon, 03 Jun 2019 09:55:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=BzAJ0+9x2pcfr7Do5TUN53ZGOyHm87DfwLwwZIYymzc=;
        b=BZzU61zpW3R1WMgBYK78uuRGUz/pnko0bMplfqY6xsgVAN2BeSH7afHee/jLg67oIJ
         WXUodbMi7ntAgC/geqKDBBZPaQSd77cNV58IZNSfp0KTHsKw77uF7xyc7mIddvJX4Cjy
         CY6ZRXVkLepz1n78f6MN9Vll1kg5pXLWrTfC2N1Htomb8E33tX5cNOPEk9UJ9vzj2LMy
         nxHmrKxkudOQRqGlbTgaIDzdYvovhl365klWi+MGVyoiB+bJvpX0oJtocU5HjaI50S4k
         5vZNDZ+WARQqW7MCwxzXV7WPfqMRWLw3gRpXdiWeLTRjiU31oosSlCRAhSzw4wbaePMN
         qOmA==
X-Gm-Message-State: APjAAAW1btjgM+AQuOex8tjhufLleG/4FaWrTKHYHnowJSdyez6Q71nM
	2vypng1p554OFwFNbmHytozH0emm07Qdqeh4iT8n/bePXBEfp5X0R/dO8vufRoMcnSLkri2OJZg
	LrICodso90u37mEnT/WDTiM/ESNStzi0NEAt3dH/bjvoXol0PV+QiQK0pG0lfQGqr2w==
X-Received: by 2002:a81:550c:: with SMTP id j12mr13911883ywb.503.1559580927196;
        Mon, 03 Jun 2019 09:55:27 -0700 (PDT)
X-Received: by 2002:a81:550c:: with SMTP id j12mr13911870ywb.503.1559580926684;
        Mon, 03 Jun 2019 09:55:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559580926; cv=none;
        d=google.com; s=arc-20160816;
        b=GBDnIANTHbeWAmjSebOkLwfSPexT5ahURVpL5H/64tdCCiYZY9P0tqVpURuPKLWcGq
         zT/Eg3xFxtFFNhrUSmhUqaYuVPJFQ9OQQEZ9lU0S0cccAPbqKKShCFdMWG79MJDVE+D3
         Wi4PBFPC8WNVlr7/BKqpblXweeJa1j5WaWJl2VOuePrjPzG5k3VcHZVASDkI7OZYOfQC
         sVfR7Ta7TRL52tTp5jFikmAU9LnPZBtCatQAKe151fCP2oFziRSTXRlxrDVE4o6hxpS5
         4OOhyQoj9UyKM1RdIIUvUCnIRmGolSVNJFndB2mOX3yPQYgzZNsNLp5KOzkq/aLn1qcI
         3ckg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=BzAJ0+9x2pcfr7Do5TUN53ZGOyHm87DfwLwwZIYymzc=;
        b=rE451iZS3chl+PwKaYSwxDIefDbx5mHUDcLivyHk2KrMtZZ2oPmJuwaApKGbb4pfln
         yZs2sEOq8emxpwyPv8sCpw4fmp4zFPp5dQr8YYlvT/UD/l67ax2X/XfYYCdYNriELC7l
         aFTKaB7/e1PbHNyHEirI/2Z64zIq0IbafmHhplQgJYEdcEp5hpa9DOkAfzt9pN2KSS9/
         MRzgjL+uzi1+9IHPFCjHlK/m/T2Lquzh0pFinMGwntSTBcsxMbyH1UxECbLsGX/oyRtc
         qF++17/Ai2aCCDB4C2AU1y5XiiVj87tzeyZhtCHuvvGbZOrfjL6HDbaDUWICIvxHANBS
         98WA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Gd3MS7x4;
       spf=pass (google.com: domain of 3_ld1xaokcgmboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3_lD1XAoKCGMBOESFZLOWMHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id 184sor6842332ybf.146.2019.06.03.09.55.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Jun 2019 09:55:26 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3_ld1xaokcgmboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=Gd3MS7x4;
       spf=pass (google.com: domain of 3_ld1xaokcgmboesfzlowmhpphmf.dpnmjovy-nnlwbdl.psh@flex--andreyknvl.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3_lD1XAoKCGMBOESFZLOWMHPPHMF.DPNMJOVY-NNLWBDL.PSH@flex--andreyknvl.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=BzAJ0+9x2pcfr7Do5TUN53ZGOyHm87DfwLwwZIYymzc=;
        b=Gd3MS7x4gwNqCAsuebDb+LQXe1ROUCAjzPqIs7DNAteGO+I/k2kuk/JUQDg2yytLs0
         mAnj4aXyNOLD53bou+rnAjAI+DoFCDM6597Xb+r9d5tHdnUBLOhHUJdZUvwspRQQklB/
         nVb9mJ+RVgKXuTmdk46XK6MPO9GX2CvoeDiI4JmSZych6aS7p7s1LkUgQ8IFSJW5YLx/
         IwfItaZEAlz+YxcxGixqEutWhh0H0I+YiPlFdGJFMPEbbW0iVK8sXmL/5Dzp9W2t8wq7
         Jn42agr19zJj2QbOHan385htTUuPv+QknbBnCycF9d956GlhodbETKPupW6IU9maR3WJ
         cryQ==
X-Google-Smtp-Source: APXvYqw8qo6YCAA2LDG0hCmceBSOfUoHZIsTSjRJKNeADMAk1c3BAJX7XTjP1o6wTWUARrevZDffoxW7ORioylDq
X-Received: by 2002:a25:4445:: with SMTP id r66mr13094125yba.55.1559580926346;
 Mon, 03 Jun 2019 09:55:26 -0700 (PDT)
Date: Mon,  3 Jun 2019 18:55:03 +0200
In-Reply-To: <cover.1559580831.git.andreyknvl@google.com>
Message-Id: <097bc300a5c6554ca6fd1886421bb2e0adb03420.1559580831.git.andreyknvl@google.com>
Mime-Version: 1.0
References: <cover.1559580831.git.andreyknvl@google.com>
X-Mailer: git-send-email 2.22.0.rc1.311.g5d7573a151-goog
Subject: [PATCH v16 01/16] uaccess: add untagged_addr definition for other arches
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

To allow arm64 syscalls to accept tagged pointers from userspace, we must
untag them when they are passed to the kernel. Since untagging is done in
generic parts of the kernel, the untagged_addr macro needs to be defined
for all architectures.

Define it as a noop for architectures other than arm64.

Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/mm.h | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0e8834ac32b7..949d43e9c0b6 100644
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
2.22.0.rc1.311.g5d7573a151-goog

