Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6E8F4C282E1
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:48:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 1FBBD21903
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:48:30 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="E+a9eU1w"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 1FBBD21903
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C21D56B026B; Wed, 24 Apr 2019 10:48:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BD1A36B026F; Wed, 24 Apr 2019 10:48:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AE7256B0270; Wed, 24 Apr 2019 10:48:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 76F576B026B
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:48:29 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id u2so12244140pgi.10
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:48:29 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/UTx89KtqRDbG9rx2vJHJQmu2IphGwtqwTZNays3jkU=;
        b=Hhz/LYPVnUqiGPx1gv+9+hc9IG33X5kAP8M58b8nO0aRZs6BrqlrBkhM4KXyhF74vA
         qr5WT6N+7KuzbNSGTDma4/hwNdFKyk4syfflflBuj4y9hmC2y/bhp1sLTz5z2WiPmgJF
         M3LUueI1VqytzsGL4KShExF3oMUnr7xTKo4cDc6gsBtC9+xklmn30pHWXYyXkk5e1K02
         /Utf+AT7J00byQYVjRs2mv68ACUFBNprTJD5GjmOC76NhPbIkZY8xcyBSODXFh1Td5jW
         whTM9ZUSV9l4N1pMaMmGqDz2nE83EndK1t0egdP9NKht/xaCKiZpqfYHA7EjHwYBKoks
         JnWA==
X-Gm-Message-State: APjAAAXLESVgIqEuDd8DsQ0O6pSOWZcpnxuNMpiHm9ucVVRXglKDOYCu
	cj9rDBAsCrfegJdjyotZ+PZhQchSJmVgtDSR3v+TyG2X+UWPu97ayFnK/lKqYU8AoDk7ZTNTV+W
	aQyMQknUOSr8yimZFZxRFkFcMMUMYBEaOXTdKu64HOwblTL13V3hKBvRbrtEJ0HfYaw==
X-Received: by 2002:a17:902:a60b:: with SMTP id u11mr13630870plq.198.1556117308899;
        Wed, 24 Apr 2019 07:48:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyuERG7dr6i4bT0O4O4beFoCuEjWzzHHZe7KPQSPbhQcF0Qr6TYKdMbNe8/ylGuYCTPd5oc
X-Received: by 2002:a17:902:a60b:: with SMTP id u11mr13630819plq.198.1556117308140;
        Wed, 24 Apr 2019 07:48:28 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556117308; cv=none;
        d=google.com; s=arc-20160816;
        b=wUcl+IIKdVCTgyIAYHT3aYlDA6QM3EfUuDoRPkft32brIYdeKghGLP6fMcKK4ocbXa
         pUwr+3gGqZU+Jurki4mfjAaapoz+0UtCwoZ3+3BtsinD/lf2LEIOzvM/kH/1qbLMlcG6
         N2Xo9/N181r3c/1vHgsgPZbqmvy+1LxFJavEf52NthZjAa4ArRKsqciO9H3KJLzwOYUG
         kFfL3aZ1Ib2jrH8CvhwUzzHs3Oy2gh0OxRV1Uyk4DVksSskRo8fH9wK9adjIAxJiCSeX
         YdzHDAAKckpnA8LFjI5TZEOBtQHzn0OSNviaxzEgQIkAh77CJNYgPbSP2PS8NJMrw5/p
         C2xw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=/UTx89KtqRDbG9rx2vJHJQmu2IphGwtqwTZNays3jkU=;
        b=07tC+gCC77VVZ/VdanTMCMSvs5biSV76RU07He8MzJKNDu583PtPJXLAmiWOgR3YXo
         48ffIYnfb68EpuM38KLj5jaDikyO5MdPITAhTR2F4NCWJwTT+2l8ka8otn9NMkXaiCJI
         MhNyvLJHQmddQ8L8toUZb+qhHVg0Ug+b3ulxyC1BGMcXBLJMesWbqyEAnwAb/B6p2Dc/
         hKbqAQhmBeD2zHYQU+MAa2MaTGtNaol4Q4tJwEPMjqUaQPRAwYYimpVsltzbc9Tn5+nV
         KE7cGcC8VPXPLBIQE1bt2q0GXlMv/alTIuECLwXYjzC3bqaId+Z9FFN6I/yE73MwJutr
         oDsg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=E+a9eU1w;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 14si18847662ple.218.2019.04.24.07.48.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:48:28 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=E+a9eU1w;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2082D218FE;
	Wed, 24 Apr 2019 14:48:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556117307;
	bh=5HDGAh0QbI2VY/kbAiK5FAqvJFcRtvLJDVA3Il/vCuM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=E+a9eU1wrQsk6nObqZ/8xl7udl4eQ87xlUgJCS1FPmODkgXUSwG97za5zI4KuIsFO
	 ZAfm4xKML72RP4P7wz7aO5nCMN10isHOBDOUtXF/SMM13R9sKtUcq+SNR6hiPV79vE
	 ioW8LARRKUc43W1i37zX7kfggsng+gBr4vXbUv60=
From: Sasha Levin <sashal@kernel.org>
To: linux-kernel@vger.kernel.org,
	stable@vger.kernel.org
Cc: Catalin Marinas <catalin.marinas@arm.com>,
	Paul Mackerras <paulus@samba.org>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Avi Kivity <avi@redhat.com>,
	Paolo Bonzini <pbonzini@redhat.com>,
	Radim Krcmar <rkrcmar@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Sasha Levin <sashal@kernel.org>,
	kvm-ppc@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org
Subject: [PATCH AUTOSEL 4.14 29/35] kmemleak: powerpc: skip scanning holes in the .bss section
Date: Wed, 24 Apr 2019 10:47:03 -0400
Message-Id: <20190424144709.30215-29-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190424144709.30215-1-sashal@kernel.org>
References: <20190424144709.30215-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Catalin Marinas <catalin.marinas@arm.com>

[ Upstream commit 298a32b132087550d3fa80641ca58323c5dfd4d9 ]

Commit 2d4f567103ff ("KVM: PPC: Introduce kvm_tmp framework") adds
kvm_tmp[] into the .bss section and then free the rest of unused spaces
back to the page allocator.

kernel_init
  kvm_guest_init
    kvm_free_tmp
      free_reserved_area
        free_unref_page
          free_unref_page_prepare

With DEBUG_PAGEALLOC=y, it will unmap those pages from kernel.  As the
result, kmemleak scan will trigger a panic when it scans the .bss
section with unmapped pages.

This patch creates dedicated kmemleak objects for the .data, .bss and
potentially .data..ro_after_init sections to allow partial freeing via
the kmemleak_free_part() in the powerpc kvm_free_tmp() function.

Link: http://lkml.kernel.org/r/20190321171917.62049-1-catalin.marinas@arm.com
Signed-off-by: Catalin Marinas <catalin.marinas@arm.com>
Reported-by: Qian Cai <cai@lca.pw>
Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)
Tested-by: Qian Cai <cai@lca.pw>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Avi Kivity <avi@redhat.com>
Cc: Paolo Bonzini <pbonzini@redhat.com>
Cc: Radim Krcmar <rkrcmar@redhat.com>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 arch/powerpc/kernel/kvm.c |  7 +++++++
 mm/kmemleak.c             | 16 +++++++++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
index 9ad37f827a97..7b59cc853abf 100644
--- a/arch/powerpc/kernel/kvm.c
+++ b/arch/powerpc/kernel/kvm.c
@@ -22,6 +22,7 @@
 #include <linux/kvm_host.h>
 #include <linux/init.h>
 #include <linux/export.h>
+#include <linux/kmemleak.h>
 #include <linux/kvm_para.h>
 #include <linux/slab.h>
 #include <linux/of.h>
@@ -712,6 +713,12 @@ static void kvm_use_magic_page(void)
 
 static __init void kvm_free_tmp(void)
 {
+	/*
+	 * Inform kmemleak about the hole in the .bss section since the
+	 * corresponding pages will be unmapped with DEBUG_PAGEALLOC=y.
+	 */
+	kmemleak_free_part(&kvm_tmp[kvm_tmp_index],
+			   ARRAY_SIZE(kvm_tmp) - kvm_tmp_index);
 	free_reserved_area(&kvm_tmp[kvm_tmp_index],
 			   &kvm_tmp[ARRAY_SIZE(kvm_tmp)], -1, NULL);
 }
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index d9e0be2a8189..337be9aacb7a 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1492,11 +1492,6 @@ static void kmemleak_scan(void)
 	}
 	rcu_read_unlock();
 
-	/* data/bss scanning */
-	scan_large_block(_sdata, _edata);
-	scan_large_block(__bss_start, __bss_stop);
-	scan_large_block(__start_ro_after_init, __end_ro_after_init);
-
 #ifdef CONFIG_SMP
 	/* per-cpu sections scanning */
 	for_each_possible_cpu(i)
@@ -2027,6 +2022,17 @@ void __init kmemleak_init(void)
 	}
 	local_irq_restore(flags);
 
+	/* register the data/bss sections */
+	create_object((unsigned long)_sdata, _edata - _sdata,
+		      KMEMLEAK_GREY, GFP_ATOMIC);
+	create_object((unsigned long)__bss_start, __bss_stop - __bss_start,
+		      KMEMLEAK_GREY, GFP_ATOMIC);
+	/* only register .data..ro_after_init if not within .data */
+	if (__start_ro_after_init < _sdata || __end_ro_after_init > _edata)
+		create_object((unsigned long)__start_ro_after_init,
+			      __end_ro_after_init - __start_ro_after_init,
+			      KMEMLEAK_GREY, GFP_ATOMIC);
+
 	/*
 	 * This is the point where tracking allocations is safe. Automatic
 	 * scanning is started during the late initcall. Add the early logged
-- 
2.19.1

