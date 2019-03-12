Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1746BC43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:14:33 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7A7E82077B
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 19:14:32 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=lca.pw header.i=@lca.pw header.b="Y9l2Xk7Y"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7A7E82077B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lca.pw
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E10088E0003; Tue, 12 Mar 2019 15:14:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DC0658E0002; Tue, 12 Mar 2019 15:14:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C88668E0003; Tue, 12 Mar 2019 15:14:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9BED48E0002
	for <linux-mm@kvack.org>; Tue, 12 Mar 2019 15:14:31 -0400 (EDT)
Received: by mail-qt1-f200.google.com with SMTP id n16so3260677qtp.14
        for <linux-mm@kvack.org>; Tue, 12 Mar 2019 12:14:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=DZ0zrk+Q+rSDOvWbVsPGd6SV907FycK77BA535duIaY=;
        b=mWUkImaXhD8pfI6bERzU4Tbdto2BokkbivOFEQpNGykfw1SF9uAsY3bgRxohH89Krk
         w70xtGGyYTdc+g/Si4sX7mmzA8ZPuC6OcfWXtCDT1dglqiWq7ETucyAUmgJxP/GqSLUR
         wRC/DG6iFflSY/kNGxzuU3+aggwKLq4N9YZ68hM8KASEyYUxnm19+05J3jRSQsffgGMt
         V2pgzJWJwKGOYCEhlcsyntJYo5BAFmSNR23HE1E7HnHOpfsY7mXPoUNhn6+3qVTTc1WR
         1im3pSPGaQtyW09mLTXXWr+P98JOQfmDdJm/oE8FLEvwHBDIt26xbY8Ow2Cg41JlBhZz
         bilg==
X-Gm-Message-State: APjAAAV8G6qUV6Oa23HMHVpAQW6JAu4i+DiPyfVviPG4CJBYUslFzvzH
	LG3TFXelRjOBzZmyr67TtLX4BDaKLEkE0EvmFlKYHL/KVw7N/f59jJwxyNC+sDE8LZFVkp/XDjv
	A5nKn3ZuXiGxwXGuW3o8oLqcsQ69sGbg3/XNZ3eRbINMBtDOuKjzqjyDEToXfRJIzz3tbTrEnRr
	jibH1SF4nu3OzK6Jo/voQkj5Iv7xTyIEY8OZcZIzoVozDBiHWuPY1g03cioR4i98HP6A+yPYVsk
	zVaSSE3WqqJlB3h4d7vYLB0amgvsSnEkpvmHCC+1HRa30c3Z8GPzvM02gjQHpyPJ2kAYmVGF2Lz
	B92nnxNhYWUi6eR7Xj7fQsJFqbXzxZgj5dTfwVK9zS4saTj3QVhDq3+Z3ADFGnrEmjgGA+IkPlP
	M
X-Received: by 2002:ac8:3513:: with SMTP id y19mr31922196qtb.49.1552418071351;
        Tue, 12 Mar 2019 12:14:31 -0700 (PDT)
X-Received: by 2002:ac8:3513:: with SMTP id y19mr31922108qtb.49.1552418070011;
        Tue, 12 Mar 2019 12:14:30 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552418070; cv=none;
        d=google.com; s=arc-20160816;
        b=cLKlHpCMJ2VJeOyHBVtHn3x6RgOOyBp+S87e9zTmqRPu0OUqp/TNTnrbtoftle3kwY
         spRsDPV5yUoez43HKZjJOsEZ/2G8nEWyhtu2tm3xVdv71+VchI4cGHlrvMYjXuAFoH9x
         dhgeEn+pFaqovkcrNzFuToc7csdOfvo5fB+hj/EIxTBWL9RmTYV9lkcGDUXn5Z5H6bZS
         cRhLXcnnG+kmOevpEVoncNeHFWokjPGfynLtXlmmHOf2NK40xbRtDA6ON4b5PqtM6Yi+
         AWWppZWGOquDGGB4uEbk5T7iip34hcbIuwNe/QzIm/EqqTQORTVQ+8mWfVAAXQqru9WN
         aodg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=DZ0zrk+Q+rSDOvWbVsPGd6SV907FycK77BA535duIaY=;
        b=bPJdaG5bEAE0OjL3hfzAMVJv0kYEsyNLMunBEMOacRk6fJ3hyHy6Vjml1v/QB6hfQ+
         3UFdf4bdC5oyWyauDqzIQSzl7hB55L0FGqbCojYkuflsgSqdhZjLne+PEZFWxsZI5I3X
         GDv2J12ql/EXMeaa7IqmKNeNR4iwTZahxUtiE/4pNkPtgpb0D3LCd/SUddUwMSK2H9/7
         36YVH98LRi1qVk6YCYhjQCScAi8n5KWCpmk7Z6YYFffW6DcOA4S4d63CECVh5vo0Wd7/
         3TCplIRSj6MxTN3zVfJ4HDtYF5SmqkD1UqP/Hv4DwKKF1mlb6Sdd6KlAqNnjQ0bfbFad
         ckdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Y9l2Xk7Y;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m34sor11643231qtc.49.2019.03.12.12.14.29
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Mar 2019 12:14:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@lca.pw header.s=google header.b=Y9l2Xk7Y;
       spf=pass (google.com: domain of cai@lca.pw designates 209.85.220.65 as permitted sender) smtp.mailfrom=cai@lca.pw
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=lca.pw; s=google;
        h=from:to:cc:subject:date:message-id;
        bh=DZ0zrk+Q+rSDOvWbVsPGd6SV907FycK77BA535duIaY=;
        b=Y9l2Xk7YmcNPlU7pESh76E+NVmKWcjH/4XxSUYg2DmYLCBGlNF+ge8cXu7sMTges85
         tmVdhk6QM3R8g2Y3wqE535Dzb3XbPxh+0ljDyqANxnNZq0U3wMcv3cSWoOuZbDCZyBto
         DK/eNcWX9kyrN4fwmP2lRtWUlG8piY9B+k0WZotC+4pMVPqAGWxWCWfVDhJUCNTgHXE3
         eRG0JLZPaKfIGk86wAK4d3RKwHcDSqO7zjo2NFY+D1HPg7y3qTQmOMJZsj9Of8KdH9eV
         g0YoUUFEz2iOZrbIEeEbDZIFnCi5d4Xun6IvY49CuxHrkvaGEytpDGPiz2J7JJG7Tz3O
         MQvw==
X-Google-Smtp-Source: APXvYqyaKjuQ9G/lbn+bzG4co0WQXrOgZ88CnaC/q38aNxY5TbGX8BuaCucyZT/J32tQ96EM6dn6Zw==
X-Received: by 2002:ac8:22ea:: with SMTP id g39mr20713118qta.73.1552418069670;
        Tue, 12 Mar 2019 12:14:29 -0700 (PDT)
Received: from ovpn-121-103.rdu2.redhat.com (pool-71-184-117-43.bstnma.fios.verizon.net. [71.184.117.43])
        by smtp.gmail.com with ESMTPSA id j9sm5083856qtb.30.2019.03.12.12.14.28
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Mar 2019 12:14:29 -0700 (PDT)
From: Qian Cai <cai@lca.pw>
To: akpm@linux-foundation.org
Cc: catalin.marinas@arm.com,
	agraf@suse.de,
	paulus@ozlabs.org,
	benh@kernel.crashing.org,
	pe@ellerman.id.au,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org,
	kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	Qian Cai <cai@lca.pw>
Subject: [PATCH] kmemleak: skip scanning holes in the .bss section
Date: Tue, 12 Mar 2019 15:14:12 -0400
Message-Id: <20190312191412.28656-1-cai@lca.pw>
X-Mailer: git-send-email 2.17.2 (Apple Git-113)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

The commit 2d4f567103ff ("KVM: PPC: Introduce kvm_tmp framework") adds
kvm_tmp[] into the .bss section and then free the rest of unused spaces
back to the page allocator.

kernel_init
  kvm_guest_init
    kvm_free_tmp
      free_reserved_area
        free_unref_page
          free_unref_page_prepare

With DEBUG_PAGEALLOC=y, it will unmap those pages from kernel. As the
result, kmemleak scan will trigger a panic below when it scans the .bss
section with unmapped pages.

Since this is done way before the first kmemleak_scan(), just go
lockless to make the implementation simple and skip those pages when
scanning the .bss section. Later, those pages could be tracked by
kmemleak again once allocated by the page allocator. Overall, this is
such a special case, so no need to make it a generic to let kmemleak
gain an ability to skip blocks in scan_large_block().

BUG: Unable to handle kernel data access at 0xc000000001610000
Faulting instruction address: 0xc0000000003cc178
Oops: Kernel access of bad area, sig: 11 [#1]
LE PAGE_SIZE=64K MMU=Hash SMP NR_CPUS=256 DEBUG_PAGEALLOC NUMA pSeries
CPU: 3 PID: 130 Comm: kmemleak Kdump: loaded Not tainted 5.0.0+ #9
REGS: c0000004b05bf940 TRAP: 0300   Not tainted  (5.0.0+)
NIP [c0000000003cc178] scan_block+0xa8/0x190
LR [c0000000003cc170] scan_block+0xa0/0x190
Call Trace:
[c0000004b05bfbd0] [c0000000003cc170] scan_block+0xa0/0x190 (unreliable)
[c0000004b05bfc30] [c0000000003cc2c0] scan_large_block+0x60/0xa0
[c0000004b05bfc70] [c0000000003ccc64] kmemleak_scan+0x254/0x960
[c0000004b05bfd40] [c0000000003cdd50] kmemleak_scan_thread+0xec/0x12c
[c0000004b05bfdb0] [c000000000104388] kthread+0x1b8/0x1c0
[c0000004b05bfe20] [c00000000000b364] ret_from_kernel_thread+0x5c/0x78
Instruction dump:
7fa3eb78 4844667d 60000000 60000000 60000000 60000000 3bff0008 7fbcf840
409d00b8 4bfffeed 2fa30000 409e00ac <e87f0000> e93e0128 7fa91840
419dffdc

Signed-off-by: Qian Cai <cai@lca.pw>
---
 arch/powerpc/kernel/kvm.c |  3 +++
 include/linux/kmemleak.h  |  4 ++++
 mm/kmemleak.c             | 25 ++++++++++++++++++++++++-
 3 files changed, 31 insertions(+), 1 deletion(-)

diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
index 683b5b3805bd..5cddc8fc56bb 100644
--- a/arch/powerpc/kernel/kvm.c
+++ b/arch/powerpc/kernel/kvm.c
@@ -26,6 +26,7 @@
 #include <linux/slab.h>
 #include <linux/of.h>
 #include <linux/pagemap.h>
+#include <linux/kmemleak.h>
 
 #include <asm/reg.h>
 #include <asm/sections.h>
@@ -712,6 +713,8 @@ static void kvm_use_magic_page(void)
 
 static __init void kvm_free_tmp(void)
 {
+	kmemleak_bss_hole(&kvm_tmp[kvm_tmp_index],
+			  &kvm_tmp[ARRAY_SIZE(kvm_tmp)]);
 	free_reserved_area(&kvm_tmp[kvm_tmp_index],
 			   &kvm_tmp[ARRAY_SIZE(kvm_tmp)], -1, NULL);
 }
diff --git a/include/linux/kmemleak.h b/include/linux/kmemleak.h
index 5ac416e2d339..3d8949b9c6f5 100644
--- a/include/linux/kmemleak.h
+++ b/include/linux/kmemleak.h
@@ -46,6 +46,7 @@ extern void kmemleak_alloc_phys(phys_addr_t phys, size_t size, int min_count,
 extern void kmemleak_free_part_phys(phys_addr_t phys, size_t size) __ref;
 extern void kmemleak_not_leak_phys(phys_addr_t phys) __ref;
 extern void kmemleak_ignore_phys(phys_addr_t phys) __ref;
+extern void kmemleak_bss_hole(void *start, void *stop);
 
 static inline void kmemleak_alloc_recursive(const void *ptr, size_t size,
 					    int min_count, slab_flags_t flags,
@@ -131,6 +132,9 @@ static inline void kmemleak_not_leak_phys(phys_addr_t phys)
 static inline void kmemleak_ignore_phys(phys_addr_t phys)
 {
 }
+static inline void kmemleak_bss_hole(void *start, void *stop)
+{
+}
 
 #endif	/* CONFIG_DEBUG_KMEMLEAK */
 
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 707fa5579f66..42349cd9ef7a 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -237,6 +237,10 @@ static int kmemleak_skip_disable;
 /* If there are leaks that can be reported */
 static bool kmemleak_found_leaks;
 
+/* Skip scanning of a range in the .bss section. */
+static void *bss_hole_start;
+static void *bss_hole_stop;
+
 static bool kmemleak_verbose;
 module_param_named(verbose, kmemleak_verbose, bool, 0600);
 
@@ -1265,6 +1269,18 @@ void __ref kmemleak_ignore_phys(phys_addr_t phys)
 }
 EXPORT_SYMBOL(kmemleak_ignore_phys);
 
+/**
+ * kmemleak_bss_hole - skip scanning a range in the .bss section
+ *
+ * @start:	start of the range
+ * @stop:	end of the range
+ */
+void kmemleak_bss_hole(void *start, void *stop)
+{
+	bss_hole_start = start;
+	bss_hole_stop = stop;
+}
+
 /*
  * Update an object's checksum and return true if it was modified.
  */
@@ -1531,7 +1547,14 @@ static void kmemleak_scan(void)
 
 	/* data/bss scanning */
 	scan_large_block(_sdata, _edata);
-	scan_large_block(__bss_start, __bss_stop);
+
+	if (bss_hole_start) {
+		scan_large_block(__bss_start, bss_hole_start);
+		scan_large_block(bss_hole_stop, __bss_stop);
+	} else {
+		scan_large_block(__bss_start, __bss_stop);
+	}
+
 	scan_large_block(__start_ro_after_init, __end_ro_after_init);
 
 #ifdef CONFIG_SMP
-- 
2.17.2 (Apple Git-113)

