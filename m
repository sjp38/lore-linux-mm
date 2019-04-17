Return-Path: <SRS0=7cPG=ST=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,
	SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76118C282DC
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 10:46:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 25FB520821
	for <linux-mm@archiver.kernel.org>; Wed, 17 Apr 2019 10:46:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=synopsys.com header.i=@synopsys.com header.b="bRbh/bvP"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 25FB520821
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=synopsys.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id AC9766B0003; Wed, 17 Apr 2019 06:46:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A7A276B0006; Wed, 17 Apr 2019 06:46:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 969416B0007; Wed, 17 Apr 2019 06:46:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 615DA6B0003
	for <linux-mm@kvack.org>; Wed, 17 Apr 2019 06:46:27 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id e20so16039362pfn.8
        for <linux-mm@kvack.org>; Wed, 17 Apr 2019 03:46:27 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id;
        bh=H5qA+xaLiKYAH0vO3rc8Zm1a1boQ6e4tpqTNh9ER2Sk=;
        b=OtQCwywlvZam7YZi9IrE7obiEVv7qKfbOeNOY2OQDnJbOVH2QHtU6IFnLVEFyd10ah
         TkDrZ0KobcI/cDYeFmFSFjteju3ACf+tCgNj6guyl8NzNLq0gDaD2wWK6zfaJWi+/aID
         eIBIDmsH597uXa7ofcESmG6D6y6azI8uzQmpgrT4+lxphyCxbH+mbLlVxFbptpwIyZ/Y
         Dp2JKSOTQ73Mkc+ByjxmYHDukWgniYCHfuT2rV+Q+lHx5FDXUcoerkocVBkUfGdRFWsb
         NcW0CasVTUU4ceeLKimIFY9Be3G66QRAXcgeBQxoMBU8T4sZOcyQn36JyELCvQFfZajF
         Ss4Q==
X-Gm-Message-State: APjAAAUr1IF6RQlXERz8eELYE8lEt+1nR2JCExZ7MYJ/8S74i43g5xyk
	AVHDE0O6Z9OgsEnmJarJKAbGsNCS8b546wDh1L6FCRqcLEieeMD67v0YmfWEQ+PJ/LFboUvDBnt
	h4Ul05M5Daa1GkR8tkd9bQOJbLOivsQLJXpn7IWbhkZRiWe54lKGkI0uTN1tz0p3jIA==
X-Received: by 2002:a17:902:3064:: with SMTP id u91mr66702037plb.169.1555497986510;
        Wed, 17 Apr 2019 03:46:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy3CD8Dkhw5VdbRI4EaPUZIAYKSwQFgdcS9pzz+RAKYmR5RAYAZCVHSCTe5gS7xfeFG5Pp0
X-Received: by 2002:a17:902:3064:: with SMTP id u91mr66701924plb.169.1555497984821;
        Wed, 17 Apr 2019 03:46:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1555497984; cv=none;
        d=google.com; s=arc-20160816;
        b=KTnKO1gEF5dQbTa39SUC7LBuPOzrwIC2HA2CJbJWoyWOgTpbDtqEjFLb3UeYbvWGkJ
         xQyI3Bi+Vq/4Uob5lzzGA4NIch4mvrpad/EHsJWkj1I/4/mkRGZbyF0dY2VLKBl5VPzl
         U9zqJ03reeA1Vnkl/q0gsF+11ctWJkW1E32JeFTxDFd9IeWvz2qnRmegJDHgsgMvzYIM
         xAkk6LnoWRpc/XsyqxKHkZGlKC8/Z5Btd9sypXdsUG31qEqYONiGzljRYsMkElVbvZgG
         ztIheyjBfXkZ9oXfsrmnryI+V0lDOe8ETC0qCuulnRAVaQV4jvIHpBkjVmQNuZ3ozd9k
         V9rg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:cc:to:from:dkim-signature;
        bh=H5qA+xaLiKYAH0vO3rc8Zm1a1boQ6e4tpqTNh9ER2Sk=;
        b=fWHcfS7sxUN4BsroCZEtEbgHk4dXmY8nz6WcFy3ymTT8sHydDWXhz2fjnOnlgvhhI7
         2BztMyyi6bNDfpeb5jZU6DMhk3vMKFYdxWrqOL2lBbMx+UHK+RVA/6kLDhKFhfZxy0gp
         Fkc6zfpFMkMMob/FfJkkRMCRrrtwvGnuRwBXZjmBwq+EsXDZaGlAh4nM3ledg9hx+Drz
         BpjYJwWvh5xC2wOZWyjRtZ3Abzbwy/WfbLiuFZoSYsgvW9mMW3Bw7+d4elXv7SbpJrvu
         fkVg9e+zPfbL0ielHFAzq6Oypi+C2LZ31/H6BTIaBKHCVIoba5vsFoHO4fh6z/YMxcBs
         EOrA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b="bRbh/bvP";
       spf=pass (google.com: domain of eugeniy.paltsev@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=eugeniy.paltsev@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from smtprelay.synopsys.com (smtprelay4.synopsys.com. [198.182.47.9])
        by mx.google.com with ESMTPS id g10si50374576pll.374.2019.04.17.03.46.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Apr 2019 03:46:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of eugeniy.paltsev@synopsys.com designates 198.182.47.9 as permitted sender) client-ip=198.182.47.9;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@synopsys.com header.s=mail header.b="bRbh/bvP";
       spf=pass (google.com: domain of eugeniy.paltsev@synopsys.com designates 198.182.47.9 as permitted sender) smtp.mailfrom=eugeniy.paltsev@synopsys.com;
       dmarc=pass (p=NONE sp=NONE dis=NONE) header.from=synopsys.com
Received: from mailhost.synopsys.com (dc8-mailhost2.synopsys.com [10.13.135.210])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtprelay.synopsys.com (Postfix) with ESMTPS id 4307424E13E8;
	Wed, 17 Apr 2019 03:46:24 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=synopsys.com; s=mail;
	t=1555497984; bh=x/hKVd6chHWC3xqn/pWkx+5QalIJTh6awxUnqpDGkmo=;
	h=From:To:Cc:Subject:Date:From;
	b=bRbh/bvP2DT35ElP4JFEKjFmzkweqMx1xRpofjfif6NVh6bfDQJlmsKwu+al9Y3p1
	 qq5wKMJlQvVUjmn7jrBFXqMyg3ILFCjW51y9xzxzHNly6a/W1Sqw6AzcJy2+W4m5CA
	 hZAos+rgRzea69z0ntH2COcNhUbgRHvijEy8dR5WQbDhkQ44fO6CKFlB5eq1YTWnJ1
	 68mRJL4Jt3aa25jKTn3h+7Z8nlRinaGUUNAve53LQYJG6rDvsXg9K3wK2R028T9Plz
	 hcjR4SYst/z4Ch6dt0GaH2xX4A7G9SeJucTlUcdIvKUH8G8VvLoSnY/MSuZj3ZQBuA
	 WF79S4g5mgBZQ==
Received: from paltsev-e7480.internal.synopsys.com (paltsev-e7480.internal.synopsys.com [10.121.8.106])
	by mailhost.synopsys.com (Postfix) with ESMTP id ED02EA0132;
	Wed, 17 Apr 2019 10:46:16 +0000 (UTC)
From: Eugeniy Paltsev <eugeniy.paltsev@synopsys.com>
To: linux-snps-arc@lists.infradead.org,
	Vineet Gupta <vineet.gupta1@synopsys.com>
Cc: linux-kernel@vger.kernel.org,
	Alexey Brodkin <alexey.brodkin@synopsys.com>,
	linux-arch@vger.kernel.org, linux-mm@kvack.org,
	Eugeniy Paltsev <eugeniy.paltsev@synopsys.com>
Subject: [PATCH v2] ARC: fix memory nodes topology in case of highmem enabled
Date: Wed, 17 Apr 2019 13:46:11 +0300
Message-Id: <20190417104611.13257-1-Eugeniy.Paltsev@synopsys.com>
X-Mailer: git-send-email 2.14.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Tweak generic node topology in case of CONFIG_HIGHMEM enabled to
prioritize allocations from ZONE_HIGHMEM to avoid ZONE_NORMAL
pressure.

Here is example when we can see problems on ARC with currently
existing topology configuration:

Generic statements:
 - *NOT* every memory allocation which could be done from
   ZONE_NORMAL also could be done from ZONE_HIGHMEM.
 - Every memory allocation which could be done from ZONE_HIGHMEM
   also could be done from ZONE_NORMAL (In other words ZONE_NORMAL
   is more universal than ZONE_HIGHMEM)

ARC statements:
In case of CONFIG_HIGHMEM enabled we have 2 memory nodes:
 - "node 0" has only ZONE_NORMAL memory.
 - "node 1" has only ZONE_HIGHMEM memory.

Steps to reproduce the problem:
1) Let's try to allocate some memory from userspace. It can be
   allocate from anywhere (ZONE_HIGHMEM/ZONE_NORMAL).
2) Kernel tries to allocate memory from the closest memory node
   to this CPU. As we don't have NUMA enabled and don't override
   any define from "include/asm-generic/topology.h" the closest
   memory node to any CPU will be "node 0"
3) OK, we'll allocate memory from "node 0". Let's choose ZONE
   to allocate from. This allocation could be done from both
   ZONE_HIGHMEM / ZONE_NORMAL in this node. The allocation
   priority between zones is ZONE_HIGHMEM > ZONE_NORMAL.
   This is pretty logical - we don't want waste *universal*
   ZONE_NORMAL if we can use ZONE_HIGHMEM. But we don't have
   ZONE_HIGHMEM in "node 0" that's why we rollback to
   ZONE_NORMAL and allocate memory from it.
4) Let's try to allocate a lot of memory [more than we have free
   memory in lowmem] from userspace.
5) Kernel allocates as much memory as it can from the closest
   memory node ("node 0"). But there is no enough memory in
   "node 0". So we'll rollback to another memory node ("node 1")
   and allocate the rest of the amount from it.

   In other words we have following memory lookup path:
      (node 0, ZONE_HIGHMEM) ->
   -> (node 0, ZONE_NORMAL)  ->
   -> (node 1, ZONE_HIGHMEM)

   Now we don't have any free memory in (node 0, ZONE_NORMAL)
   [Actually this is a simplification, but it doesn't matter
   in this example]
6) Oops, some internal kernel memory allocation happen which
   requires ZONE_NORMAL. For example "kmalloc(size, GFP_KERNEL)"
   was called.
   So the we have following memory lookup path:
   (node 0, ZONE_NORMAL) -> ("node 1", ZONE_NORMAL)
   There is no free memory in "node 0". And there is no
   ZONE_NORMAL in "node 1". We only have some free memory in
   (node 1, ZONE_HIGHMEM) but HIGHMEM isn't suitable in this
   case.
7) As we can't allocate memory OOM-Killer is invoked, even if
   we have some free memory in (node 1, ZONE_HIGHMEM).

This patch tweaks generic node topology and mark memory from
"node 1" as the closest to any CPU.

So the we'll have following memory lookup path:
    (node 1, ZONE_HIGHMEM) ->
 -> (node 1, ZONE_NORMAL)  ->
 -> (node 0, ZONE_HIGHMEM) ->
 -> (node 0, ZONE_NORMAL)
In case of node configuration on ARC we obtain the degenerate case
of this path:
(node 1, ZONE_HIGHMEM) -> (node 0, ZONE_NORMAL)

In this case we don't waste *universal* ZONE_NORMAL if we can use
ZONE_HIGHMEM so we don't face with the issue pointed in [5-7]

Signed-off-by: Eugeniy Paltsev <Eugeniy.Paltsev@synopsys.com>
---
Changes v1->v2:
 * Changes in commit message and comments in a code. No functional
   change intended.

 arch/arc/include/asm/Kbuild     |  1 -
 arch/arc/include/asm/topology.h | 24 ++++++++++++++++++++++++
 2 files changed, 24 insertions(+), 1 deletion(-)
 create mode 100644 arch/arc/include/asm/topology.h

diff --git a/arch/arc/include/asm/Kbuild b/arch/arc/include/asm/Kbuild
index caa270261521..e64e0439baff 100644
--- a/arch/arc/include/asm/Kbuild
+++ b/arch/arc/include/asm/Kbuild
@@ -18,7 +18,6 @@ generic-y += msi.h
 generic-y += parport.h
 generic-y += percpu.h
 generic-y += preempt.h
-generic-y += topology.h
 generic-y += trace_clock.h
 generic-y += user.h
 generic-y += vga.h
diff --git a/arch/arc/include/asm/topology.h b/arch/arc/include/asm/topology.h
new file mode 100644
index 000000000000..c3b8ab7ed011
--- /dev/null
+++ b/arch/arc/include/asm/topology.h
@@ -0,0 +1,24 @@
+#ifndef _ASM_ARC_TOPOLOGY_H
+#define _ASM_ARC_TOPOLOGY_H
+
+/*
+ * On ARC (w/o PAE) HIGHMEM addresses are smaller (0x0 based) than addresses in
+ * NORMAL aka low memory (0x8000_0000 based).
+ * Thus HIGHMEM on ARC is implemented with DISCONTIGMEM which requires multiple
+ * nodes. So here is memory node map on ARC:
+ *  - node 0: ZONE_NORMAL  memory (always)
+ *  - node 1: ZONE_HIGHMEM memory (only if CONFIG_HIGHMEM is enabled)
+ *
+ * In case of CONFIG_HIGHMEM enabled we tweak generic node topology and mark
+ * node 1 as the closest to all CPUs to prioritize allocations from ZONE_HIGHMEM
+ * where it is possible to avoid ZONE_NORMAL pressure.
+ */
+#ifdef CONFIG_HIGHMEM
+#define cpu_to_node(cpu)	((void)(cpu), 1)
+#define cpu_to_mem(cpu)		((void)(cpu), 1)
+#define cpumask_of_node(node)	((node) == 1 ? cpu_online_mask : cpu_none_mask)
+#endif /* CONFIG_HIGHMEM */
+
+#include <asm-generic/topology.h>
+
+#endif /* _ASM_ARC_TOPOLOGY_H */
-- 
2.14.5

