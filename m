Return-Path: <SRS0=qZKM=S2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A51CAC282CE
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:36:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5546B218FD
	for <linux-mm@archiver.kernel.org>; Wed, 24 Apr 2019 14:36:04 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="VYIBq3GU"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5546B218FD
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E50CA6B0005; Wed, 24 Apr 2019 10:36:03 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DFCE06B0006; Wed, 24 Apr 2019 10:36:03 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CC7296B0007; Wed, 24 Apr 2019 10:36:03 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A118A6B0005
	for <linux-mm@kvack.org>; Wed, 24 Apr 2019 10:36:03 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id l74so11936445pfb.23
        for <linux-mm@kvack.org>; Wed, 24 Apr 2019 07:36:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tI/jtw9tY8ggzA4+R9J+7w5ePcbuyMx/HxGbxRoggVc=;
        b=If2NWlwEQZj3z93CGEdW+hEq1uTS9xUsHuCS39JLaSm4WVUJi4TX05JQgKTdgOVBW8
         39NbVpL6qnRieGtVvUVeSFDXFO3gd8VeAkLbBn1nq/LYH9LGtwl0truWzxvr/dJP3/d3
         TTblxPFVdqEzTq2G4hyxrS9f4E/QCHkP3yuTWGaQpYg9NSWyXlSsYt70qEzCHZqVk537
         6z9SsMjcLxHwx6NHV4x9BeOzYn+y7r4rsrE6CGjaysBMbWhSphpzLZAlJ4FepJWqAOxp
         GogNZ0lxG6Lfo38Nl0WIYDLRx0TYdb5aG4E4kNBVAa9eSsAg6WHML6zgOpS76l3e1EaN
         EBSg==
X-Gm-Message-State: APjAAAUrMbnh9lmv6sHd2Zoe7moJZHixadllXf5kXhqLIGMlChpn0mFV
	a2GFx3vjzMdVE5HEwGHqPa1OD0FaPOUhiP9YKRnQq1ltgAlXSb7o6nx+4chlpSqBlBNc9uGSxoE
	p8lv89aYNvO3889FBCYB69qUbGEyKlcCYv2HngFMkEH0wN94K4np909FHsAaiM7+80w==
X-Received: by 2002:aa7:8615:: with SMTP id p21mr33045514pfn.98.1556116563201;
        Wed, 24 Apr 2019 07:36:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy96bhFnWdejpAaZtfAmwTgARtjPqkVhodOo5si1lSKnwszp0ikl9hWFadvak1pfEJ5Uu9a
X-Received: by 2002:aa7:8615:: with SMTP id p21mr33045366pfn.98.1556116561643;
        Wed, 24 Apr 2019 07:36:01 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556116561; cv=none;
        d=google.com; s=arc-20160816;
        b=bsJz4jWQzaUYtuCFn7ki1yT0FgboHK74nz1wvkQyXpjxi1EUFqlcj0/S+IxPfB0lWw
         sp0sZwiuKzeWhiXeyqdBjJuBSNzWVDuhTvErGfaCH1vGTt8G47LNc2DUm2y66b1SO35e
         VuTzPeihjfP28hknWv3x9g6hdgdENL+Xrd3LQ2NsqdRzGiuitU5EDx/aNeCJSsSXkCk7
         ZY4tJ5f0jb8EJ5LhQbY0o0pANNb452dQ3YWUENatK7iHoj9FFrlw5fQxXuowwdUXaglh
         Rpm76wHyk6r66GshqF5QILOjo+XKYqXHoRvqxjJwJ8xTM5OcwAnCS3y9VOPMtA5VBNVC
         xk+A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=tI/jtw9tY8ggzA4+R9J+7w5ePcbuyMx/HxGbxRoggVc=;
        b=K6U2gXaqq8i55SVUkcqDF0KWIi7TfeBeyKGNtv7lwSchw6QIIvyvh4Cv/AjDFcLm2A
         aUzhzEJEPCHT3OHdbei+tfNHsO/yaEfQWziTzuyqbt3R8ilMHa2pHjcLt/ah4CO7LRpl
         J1YwiGXbdcL/fiAfhmWtqwV1F1itfe+2d/7yd1HkqN2Z1QdMzJjBPrE38QugHffU4tuu
         Lh6v5h941RsABS3p1DarjiSGZyV56DLLOWzBAhQlgJ4q4A+zCvr6WUNFGeC76M1D/m3b
         uxb4OsQfuEU7CFT3gV8LbLhCSg09JawTJFoYAZnffGGZqlEz5aGJ+aMcYyNhl9QJm/0/
         epnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VYIBq3GU;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s3si17859877pgl.380.2019.04.24.07.36.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 24 Apr 2019 07:36:01 -0700 (PDT)
Received-SPF: pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) client-ip=198.145.29.99;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@kernel.org header.s=default header.b=VYIBq3GU;
       spf=pass (google.com: domain of sashal@kernel.org designates 198.145.29.99 as permitted sender) smtp.mailfrom=sashal@kernel.org;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 90AF721902;
	Wed, 24 Apr 2019 14:35:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556116561;
	bh=otjoxQm7BFcGcORn54cq0kegkDdiEt5ib0Jw454B8ho=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=VYIBq3GUn86wnPp9qfAOg3aiRLKJN4jdM9YwjDqXiWS2P7lXJ1vSER58icbnJgdok
	 GlQTTeYXlIWoF6TuLZ+igXuslgF8p5utwfaGS4wA/qPBmGpAVl6+U2zet/3/rr9Vd8
	 4zmga4peHSlb1FR0+86vZ2lpbVQ4oCVJTc3LI7Mo=
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
Subject: [PATCH AUTOSEL 5.0 53/66] kmemleak: powerpc: skip scanning holes in the .bss section
Date: Wed, 24 Apr 2019 10:33:27 -0400
Message-Id: <20190424143341.27665-53-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190424143341.27665-1-sashal@kernel.org>
References: <20190424143341.27665-1-sashal@kernel.org>
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
Signed-off-by: Sasha Levin (Microsoft) <sashal@kernel.org>
---
 arch/powerpc/kernel/kvm.c |  7 +++++++
 mm/kmemleak.c             | 16 +++++++++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/arch/powerpc/kernel/kvm.c b/arch/powerpc/kernel/kvm.c
index 683b5b3805bd..cd381e2291df 100644
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
index 707fa5579f66..6c318f5ac234 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -1529,11 +1529,6 @@ static void kmemleak_scan(void)
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
@@ -2071,6 +2066,17 @@ void __init kmemleak_init(void)
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

