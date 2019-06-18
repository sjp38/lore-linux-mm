Return-Path: <SRS0=8DoX=UR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83E36C31E51
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:54:09 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 20425206BA
	for <linux-mm@archiver.kernel.org>; Tue, 18 Jun 2019 09:54:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 20425206BA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arndb.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 84FE26B0003; Tue, 18 Jun 2019 05:54:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 801968E0002; Tue, 18 Jun 2019 05:54:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6EFBD8E0001; Tue, 18 Jun 2019 05:54:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2058B6B0003
	for <linux-mm@kvack.org>; Tue, 18 Jun 2019 05:54:08 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id i2so5880452wrp.12
        for <linux-mm@kvack.org>; Tue, 18 Jun 2019 02:54:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=SgnmHDwEv21XaHv/ypCvWtdlqKd3kLHEL/ZSPKbCoWM=;
        b=BI9x9wpNCMPo+wm2MydXTOCuhR0pUWIIqAYcizIGslpQh29k7UYZebP959scjZEkXU
         l3xjbFfZF1ai9lKrat3/zNNJZ8+0j3Tql3XuFLx03N8ov6WeO5E5pIeDAeNz/JAhqr/d
         NCowybn8b5rmmcILECwuV63Of2ZVip0Hsn+/LKKjbTgTYgc84p2tFmqFQ7oJ7JPwajvb
         6KS0uLz8U2w2LTv/Q2pEY54cIaLKcWmYPhoJEf/7/M4PszJxv5x60HWC3LzARSgKItLd
         fusXLuVqkYSTB4igK3FYzDbKfB5ii/MSy2IrpaVq0GWkoVbqIl0x5KRkkl2+3Se40MVA
         ezlg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 212.227.126.131 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
X-Gm-Message-State: APjAAAWcqz/AYhP40Cy96N6lMmSlVNEUAEHPrTpYHc9rEGgdUEFX1ZJv
	tI9Du9mPZwByjT82X+Ctl0Wv6PN4azj+98hP5hIy2a1+0FCSeMLHYh5jhDWYvegNhavqcSfLHGa
	QjmdKR8xp0o81ySVEuzwD4QSoZ8XF+c36zLJc08mdt1n2UIeFB5wk7H1TdYqeKaQ=
X-Received: by 2002:a5d:540e:: with SMTP id g14mr5201479wrv.346.1560851647527;
        Tue, 18 Jun 2019 02:54:07 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwTN8u+6mgOmRHxwiAApr/HV8snptQiE3Fz1JxVLSfi9zb+AVfzjSjhhFUq84Xd0tySLPDq
X-Received: by 2002:a5d:540e:: with SMTP id g14mr5201416wrv.346.1560851646624;
        Tue, 18 Jun 2019 02:54:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560851646; cv=none;
        d=google.com; s=arc-20160816;
        b=dJhyKlvEn9b7Las5xkLjAk+WoJVmjyr2BgrzDl88Ggt62JrvqYs5uKjK6KxD/UjSba
         C50gFlnrYdJ/DMkEQxrC/2QbgX7g3zhs4r2XgOLSG7paLNA19AwtlurGlJvQFnibjIyL
         vyW8RySCKzQhO29SRCQ75lKgTcmJ8IbFUTV+fc4euU/oGefY1X2MHrb/mdOtOdpTtyPR
         sQtVHYE58wOKVLSVDWeOid+pua1o7mdZx2JW8tWzkKxHQalxGLjU1eHCp5TMvvf+xQlt
         3Kbpfft9RUBbeCTjd8mK8iJBu3rh+jZ2Vj/00j92n8bBmIpdIlyKrc/Os9gRSsz6rsgs
         89PA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=SgnmHDwEv21XaHv/ypCvWtdlqKd3kLHEL/ZSPKbCoWM=;
        b=vrp44MAf1elt+dZ2e+F8PEhD6naVT14RhCPeir7ZRa02H5LnxpS+qdhKiQvjhZP4D1
         MixkbSx/rcEXg9lAUOTxvo8syMlsK7UZnDgelhRGd7MxxPkRuUMO2rEsH9bBJAlRcPhl
         ifl48OxbBFcMDqb1viIvWtsDxVjg2LwKZzI9NettOppQ42MAVIdanYpzmqZB67d/+Ftg
         UvkotWd4VJnnz9wTJq1UzeVHHjUPjmZVNL7jU57AHucMgqhwPA8b9vuFUXdz/cEkjVzu
         PVroyfvAmOBu3GkYTdd8i5VJMHD0l2J+h4J+6/eSZHUnNMTdMBBkEZQSO3Xy7BMBOzU/
         ml7A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 212.227.126.131 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.131])
        by mx.google.com with ESMTPS id d14si13463438wrr.306.2019.06.18.02.54.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jun 2019 02:54:06 -0700 (PDT)
Received-SPF: neutral (google.com: 212.227.126.131 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) client-ip=212.227.126.131;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 212.227.126.131 is neither permitted nor denied by best guess record for domain of arnd@arndb.de) smtp.mailfrom=arnd@arndb.de
Received: from threadripper.lan ([149.172.19.189]) by mrelayeu.kundenserver.de
 (mreue010 [212.227.15.129]) with ESMTPA (Nemesis) id
 1Ma1kC-1i95I60lue-00W10Y; Tue, 18 Jun 2019 11:54:02 +0200
From: Arnd Bergmann <arnd@arndb.de>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>,
	Alexander Potapenko <glider@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	kasan-dev@googlegroups.com,
	linux-mm@kvack.org,
	Arnd Bergmann <arnd@arndb.de>,
	Andrey Konovalov <andreyknvl@google.com>,
	Will Deacon <will.deacon@arm.com>,
	Christoph Lameter <cl@linux.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	linux-kernel@vger.kernel.org
Subject: [PATCH] [v2] page flags: prioritize kasan bits over last-cpuid
Date: Tue, 18 Jun 2019 11:53:27 +0200
Message-Id: <20190618095347.3850490-1-arnd@arndb.de>
X-Mailer: git-send-email 2.20.0
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:bUJwQclvqm/katzhhzycV3+/zOxa7NbjGOKFIqH4EXPNW02vwyN
 lRoCJ9pDU+WbEFJZSH5TpY8rP8VBIOStIKLRBqcBtosxCv5LlrE/rA1pQcShjiptjGdXGMx
 y9Yby5nkzWG9VqIi84t+aokD+Qbu9EaMbAUpG7WpjvuQIBC7Yyl1HNU0eFDofbbcqLY2YTW
 O5MFfR4770dZqo2qlu0aQ==
X-UI-Out-Filterresults: notjunk:1;V03:K0:iIwUq5FcHw4=:EB3SY0U94Oo+TOTWQB9G2D
 PP+nddwoiOQnZ5tkbYk2Lh2TJIc6E+ObTe4LhKccCu1IcrQZOlkZn7KXdl6ZxelHoT4M9EZml
 IDZINoYBhyPor35Ghp0KLV9mzYSYx3vcijpLUUfWcw29jPzNpEVGfaOBKG2VYtAIqvyNA7n95
 nd/aMvU71fn6g9czQwP46IEaIpNTliHYKbqzxuMg/s7U8XTi0LVY56wnsQ0562+KqvoBroqfn
 LwUrik8VyfQ7qcg9vU9KSSKdUaaB744scxeMfp2X/LmyqDsQFb31u0xxf9MkgE9x4sseIEgdY
 tkUDn3azX/IOlZqJOenTjDAc6LyPGbJhgje5/4VyU2M/tgniMR/nivygYSXnAa5FGC3TQr9CK
 mFh7hpTVejfntAP3mziLcPtwJzxx+gF6nhf8Dqeqpv8vcApz51ybXO/JAl8Jjb5YYQA09oXIL
 M4NIcymsuiB6gGIYAGZgiQYFz4wZFfpUl9tnGaYECOUnnDo2MIMdMSPsASgkJ+7/ykwTsm4CK
 PNMcnQvhY/4r0oVL7obwyKN6+N07+L8fmRFkggm8Q6KHWFhHqjjIczLtP05jjiLJzVihadbZz
 QRxQa3jPCD2YHzmIS5qtobDTEM1ixuOl5ENcbORlp06BlPucfyOBj+m+6gGMXlvmMOo1L/LPF
 pwAZsa4fYFeY5Wjj6AYkesP8CdrFlMuQ9Jt1lgOI6adRwOldxtK/0CiT3LI8dPOJp1Be5giSt
 hNB6ySTYYupaUPbKZG3WZvwGdnRbzjmbIetlKQ==
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ARM64 randdconfig builds regularly run into a build error, especially
when NUMA_BALANCING and SPARSEMEM are enabled but not SPARSEMEM_VMEMMAP:

 #error "KASAN: not enough bits in page flags for tag"

The last-cpuid bits are already contitional on the available space,
so the result of the calculation is a bit random on whether they
were already left out or not.

Adding the kasan tag bits before last-cpuid makes it much more likely
to end up with a successful build here, and should be reliable for
randconfig at least, as long as that does not randomize NR_CPUS
or NODES_SHIFT but uses the defaults.

In order for the modified check to not trigger in the x86 vdso32 code
where all constants are wrong (building with -m32), enclose all the
definitions with an #ifdef.

Fixes: 2813b9c02962 ("kasan, mm, arm64: tag non slab memory allocated via pagealloc")
Reviewed-by: Andrey Konovalov <andreyknvl@google.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
Submitted v1 in March and never followed up on the build regression,
which is fixed in this version.
---
 include/linux/page-flags-layout.h | 16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
index 1dda31825ec4..7d794a629822 100644
--- a/include/linux/page-flags-layout.h
+++ b/include/linux/page-flags-layout.h
@@ -32,6 +32,7 @@
 
 #endif /* CONFIG_SPARSEMEM */
 
+#ifndef BUILD_VDSO32_64
 /*
  * page->flags layout:
  *
@@ -76,21 +77,23 @@
 #define LAST_CPUPID_SHIFT 0
 #endif
 
-#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT <= BITS_PER_LONG - NR_PAGEFLAGS
+#ifdef CONFIG_KASAN_SW_TAGS
+#define KASAN_TAG_WIDTH 8
+#else
+#define KASAN_TAG_WIDTH 0
+#endif
+
+#if SECTIONS_WIDTH+ZONES_WIDTH+NODES_SHIFT+LAST_CPUPID_SHIFT+KASAN_TAG_WIDTH \
+	<= BITS_PER_LONG - NR_PAGEFLAGS
 #define LAST_CPUPID_WIDTH LAST_CPUPID_SHIFT
 #else
 #define LAST_CPUPID_WIDTH 0
 #endif
 
-#ifdef CONFIG_KASAN_SW_TAGS
-#define KASAN_TAG_WIDTH 8
 #if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH+LAST_CPUPID_WIDTH+KASAN_TAG_WIDTH \
 	> BITS_PER_LONG - NR_PAGEFLAGS
 #error "KASAN: not enough bits in page flags for tag"
 #endif
-#else
-#define KASAN_TAG_WIDTH 0
-#endif
 
 /*
  * We are going to use the flags for the page to node mapping if its in
@@ -104,4 +107,5 @@
 #define LAST_CPUPID_NOT_IN_PAGE_FLAGS
 #endif
 
+#endif
 #endif /* _LINUX_PAGE_FLAGS_LAYOUT */
-- 
2.20.0

