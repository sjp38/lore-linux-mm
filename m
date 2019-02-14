Return-Path: <SRS0=uhAD=QV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70C66C43381
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 06:24:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2B877222B6
	for <linux-mm@archiver.kernel.org>; Thu, 14 Feb 2019 06:24:19 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2B877222B6
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ellerman.id.au
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id A867F8E0002; Thu, 14 Feb 2019 01:24:18 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A35C88E0001; Thu, 14 Feb 2019 01:24:18 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 927758E0002; Thu, 14 Feb 2019 01:24:18 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 51E488E0001
	for <linux-mm@kvack.org>; Thu, 14 Feb 2019 01:24:18 -0500 (EST)
Received: by mail-pg1-f198.google.com with SMTP id n24so3525430pgm.17
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 22:24:18 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=gUv17MV0hhIF1GoOZgbxUwRqxG8x+LxUOMCtuCottY0=;
        b=a3WAukcLHCnnVHgDKWHjxQm1EABewgXKR11dCNyIHCbjEjvR+qircQUVKNMuO/6vRz
         zhFCdRBL5e1YpFtgV3jpwU46xWbbL6uWlEDYhcPMZmP/5UJWwGAA4NmR8SQ/PQQIz2Kq
         ppaTQz1H2L0VR9Uc+49WBRCaoOVaCQZ/dtaNnviHs5lkAaLfKUSqzOAuzQ2/1T6X4uOf
         XbY/zaIlPNp/78+UUQAWTBwM0cj4cbenTXuJxk67qt6kUbOTZS1Ggl5Jb/BloPAIq3Fb
         JEYGeX+V7YTlmgiABDsSmxX+X5sCW+Y/uNn72oJAAYO6bxSLMn1VoKqic7RTuJWDQoSl
         3jHA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=michael@ozlabs.org
X-Gm-Message-State: AHQUAuYQCza8BU2a1ZX2mLx8dgS7/J6X3xuVOjXgqSikYmjwW/a6oULA
	3J1mhwAYzTubRqRE02Us9VzaDJOFebBSJhl+p0T12ZXEQGw1xdREPg4MqeE8gXsUzKeMFF/9LIR
	afg3mfMad6d9VzfaKu7If+UbxEXIEGr53q09lZDZIVM8mQZePCkRqUazYl21JUog=
X-Received: by 2002:a17:902:6bc7:: with SMTP id m7mr2509032plt.106.1550125457998;
        Wed, 13 Feb 2019 22:24:17 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbrDMPDc5FGtdj9jIU8B6MXh0kvjoLdZuy98/ygmfr2lGX/vvH0tQ8XImZ6RfXeTFTSF2vv
X-Received: by 2002:a17:902:6bc7:: with SMTP id m7mr2508989plt.106.1550125457159;
        Wed, 13 Feb 2019 22:24:17 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550125457; cv=none;
        d=google.com; s=arc-20160816;
        b=NtKLW86HOKEtxMlPLyhMz9R4LVJCwtlo53Do63squnYJ4BSYk+rn1NV5nubWtR3eCM
         XvAvK4uzdzU9Hk71+0CJQS3MHVwDPXNNM+109LvptVTYkuAfrFO4qBF+/0Vm+D7jUBk4
         6H9+y9VpM4x+hRFR/0DY1pwqkuWX2rihzO0gYmLrOdU87RYx0OuhHftqgQ3Q8BR8jKOv
         2IkbscYdlcb2Ihd/OYtujhMBdAp1SKsEP39KJI5Jn80t0586KD7+JJM7OKhM/MBtrbj1
         DkKiD39MzMnivedVdqPDOEDHhwEbDUEh92SL3YlwXILKlWSRaxGl3xHMrKx5MS93PzOD
         hFMg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=gUv17MV0hhIF1GoOZgbxUwRqxG8x+LxUOMCtuCottY0=;
        b=WSIJtwquf4uVaK4DRPoHJBBI9LibRl4Drt4+W3JAv34H3wO9DPZWzLxU8nLuzXof28
         wtV2wcp6ZUM3PRT/KfOdqgQmT1TkIgMcNFPbJ5r0usqx6bLQO0IqAQfDKfephnmbpQGS
         XbBzG+HQct8BGq7qyTvmiChadYhSuxpUGBwB+HV8RNp7oBEifA4I3pq1DITSQV/gi98l
         xGWMro2x14rzi1ZvHQcWzG54WZxJFsa2dZkVmvh7zF0/M/t397efh4NfLluTt/NgdVH5
         5sj4L8gw6THxX/AV4UgEFVw324n5Ipmko+T20gN/2Bio1OPA5U6/V3y8hPFLCKWnxQoE
         uKSA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=michael@ozlabs.org
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id c6si1590674plo.270.2019.02.13.22.24.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 22:24:17 -0800 (PST)
Received-SPF: pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) client-ip=2401:3900:2:1::2;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of michael@ozlabs.org designates 2401:3900:2:1::2 as permitted sender) smtp.mailfrom=michael@ozlabs.org
Received: by ozlabs.org (Postfix, from userid 1034)
	id 440RDt0MKLz9sML; Thu, 14 Feb 2019 17:24:13 +1100 (AEDT)
From: Michael Ellerman <mpe@ellerman.id.au>
To: linuxppc-dev@ozlabs.org
Cc: aneesh.kumar@linux.vnet.ibm.com,
	jack@suse.cz,
	erhard_f@mailbox.org,
	linux-kernel@vger.kernel.org,
	linux-mm@kvack.org
Subject: [PATCH] powerpc/64s: Fix possible corruption on big endian due to pgd/pud_present()
Date: Thu, 14 Feb 2019 17:23:39 +1100
Message-Id: <20190214062339.7139-1-mpe@ellerman.id.au>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

In v4.20 we changed our pgd/pud_present() to check for _PAGE_PRESENT
rather than just checking that the value is non-zero, e.g.:

  static inline int pgd_present(pgd_t pgd)
  {
 -       return !pgd_none(pgd);
 +       return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
  }

Unfortunately this is broken on big endian, as the result of the
bitwise && is truncated to int, which is always zero because
_PAGE_PRESENT is 0x8000000000000000ul. This means pgd_present() and
pud_present() are always false at compile time, and the compiler
elides the subsequent code.

Remarkably with that bug present we are still able to boot and run
with few noticeable effects. However under some work loads we are able
to trigger a warning in the ext4 code:

  WARNING: CPU: 11 PID: 29593 at fs/ext4/inode.c:3927 .ext4_set_page_dirty+0x70/0xb0
  CPU: 11 PID: 29593 Comm: debugedit Not tainted 4.20.0-rc1 #1
  ...
  NIP .ext4_set_page_dirty+0x70/0xb0
  LR  .set_page_dirty+0xa0/0x150
  Call Trace:
   .set_page_dirty+0xa0/0x150
   .unmap_page_range+0xbf0/0xe10
   .unmap_vmas+0x84/0x130
   .unmap_region+0xe8/0x190
   .__do_munmap+0x2f0/0x510
   .__vm_munmap+0x80/0x110
   .__se_sys_munmap+0x14/0x30
   system_call+0x5c/0x70

The fix is simple, we need to convert the result of the bitwise && to
an int before returning it.

Thanks to Jan Kara and Aneesh for help with debugging.

Fixes: da7ad366b497 ("powerpc/mm/book3s: Update pmd_present to look at _PAGE_PRESENT bit")
Cc: stable@vger.kernel.org # v4.20+
Reported-by: Erhard F. <erhard_f@mailbox.org>
Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.ibm.com>
Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
---
 arch/powerpc/include/asm/book3s/64/pgtable.h | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index c9bfe526ca9d..d8c8d7c9df15 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -904,7 +904,7 @@ static inline int pud_none(pud_t pud)
 
 static inline int pud_present(pud_t pud)
 {
-	return (pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
+	return !!(pud_raw(pud) & cpu_to_be64(_PAGE_PRESENT));
 }
 
 extern struct page *pud_page(pud_t pud);
@@ -951,7 +951,7 @@ static inline int pgd_none(pgd_t pgd)
 
 static inline int pgd_present(pgd_t pgd)
 {
-	return (pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
+	return !!(pgd_raw(pgd) & cpu_to_be64(_PAGE_PRESENT));
 }
 
 static inline pte_t pgd_pte(pgd_t pgd)
-- 
2.20.1

