Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT,
	USER_IN_DEF_DKIM_WL autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 82BAFC4360F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:58:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 34438214AF
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:58:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="m2SSklts"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 34438214AF
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 2F4638E0004; Mon, 11 Mar 2019 20:58:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2A4318E0002; Mon, 11 Mar 2019 20:58:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1BA468E0004; Mon, 11 Mar 2019 20:58:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f72.google.com (mail-io1-f72.google.com [209.85.166.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0FD28E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:58:06 -0400 (EDT)
Received: by mail-io1-f72.google.com with SMTP id y13so609588iol.1
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 17:58:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=0N1MhcRbdixhLcojGjz1JbD9gYvKsU3sALAMDz5L+zQ=;
        b=RP7Nqx5aygFgILxNO+fcwNPF71czk1fIz3dSmghsuX6F+PC0IzeT0eSnBrRB1dGP00
         TGtsX6VQmhQEbG5PoQdJgsh1PN7GbRZ4mYONl+D57aJNdtOD8hKtl/yvyrKhlCv/q0zt
         O8qVSW6APeWcJr3ANg+uTtIDjkOEBYpmffg8cw90ewX/NcJVOhJNbiKwSeV8keQ/fTOL
         5C2zqyEiiRNxHS0nO7+sPDeoaWKKn06uVu+vTtIE7e6MhldcIxE4nJXwfnREZL5sSJSf
         iAQ+JStV1n5qoJ/xpAUZGt/tv9eK+sEQRBedOfP4YZHm7ac+h9PhxdXg20aAeKi0Yjgg
         9qVg==
X-Gm-Message-State: APjAAAVY9XjajN19Wd4nwV96ENJS7zfUiejzj57PpXc7ge3uUkwfT/Ko
	gmeEe2wFsrpuNeFZzXWadmyjEuNK9SefgEirj3auXxI62QXfB8GBRfCgfQW6lZ5arzf0xmCQuMC
	64zKYIfXcRnxKYM9vUAqhO6/e033noUbKTPi0ddCyLxiZo1F1h1croYBQzn6CE3ohBQ==
X-Received: by 2002:a24:68cb:: with SMTP id v194mr511715itb.145.1552352286756;
        Mon, 11 Mar 2019 17:58:06 -0700 (PDT)
X-Received: by 2002:a24:68cb:: with SMTP id v194mr511695itb.145.1552352286052;
        Mon, 11 Mar 2019 17:58:06 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552352286; cv=none;
        d=google.com; s=arc-20160816;
        b=tgkAoMu1i1Bb9PfjF5a7cQpHA7HgK2AUR7RwrBetuXggFRZjtstFXr+CnM3RywengU
         UD42I1O+iFAGCuEYJwwk4Fb3AqJcgX2ZrX9U5SDDCCkEiTKR6A7JMMgPX20yCKR6tLCc
         yqh+o13dJte9q3MoUf5yn4A03Eq70Lx9Su6w65hT2wzQIU8WTjmUoGw9ISOzYG1cEncL
         8MjKZ5xt720eZ04FTCFoD+zuPWETwICds9DCL1/mEwlst/wOaleQIkEF6pD242AvM0Uo
         frcJceTxgYckRziKO8uQLI24fA7JhieFr/4/zYdwkxssTdX9KxnJi+CBzXE0LoD/XOb/
         E3Fw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=0N1MhcRbdixhLcojGjz1JbD9gYvKsU3sALAMDz5L+zQ=;
        b=DXDXkt/D9hAAC/w0C3p6q2qwsyCZXWRcIHFKozL5sREAFIS+S3d55cU4M43jTsibsM
         0z+h8tFyhJ2SXtjW8iWgnE5HmGUbZKGlxjoQZ0umsu5GAuUvzpfv7OwkRSN9Q8EoH+3m
         PA5436CqA0qJd01a86c/fihpFwHRTxL/FuL31cFjcQbVTa24DaZ+YgjHHpgZzQOk68r+
         sCDbFCLafXZPHJiw5fUsBzMl+svzDkm/hSegKXcmuSjTaU2qmbySfmmu3NBB2l97mCWU
         nl/65oFGlthPa5Z5Br3AHORXmWE4104Cj2wx8WrhGEHgYL59rWhDStEIHNLYenFYgzg/
         KUdQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m2SSklts;
       spf=pass (google.com: domain of 3hqshxaykccwgchpiwowwotm.kwutqvcf-uusdiks.wzo@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3HQSHXAYKCCwgchPIWOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id l200sor1330153itb.24.2019.03.11.17.58.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 17:58:06 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3hqshxaykccwgchpiwowwotm.kwutqvcf-uusdiks.wzo@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=m2SSklts;
       spf=pass (google.com: domain of 3hqshxaykccwgchpiwowwotm.kwutqvcf-uusdiks.wzo@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3HQSHXAYKCCwgchPIWOWWOTM.KWUTQVcf-UUSdIKS.WZO@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=0N1MhcRbdixhLcojGjz1JbD9gYvKsU3sALAMDz5L+zQ=;
        b=m2SSklts5axBtBFT99k5kWRqt2k7AZ/UFLe5QDWp2m4MrS9nPTzvu+lW6Cw1GTX91x
         q7m9lX4AdtHIlQvrmJR+9nAGmjI1Sxwo9tCXJq3a4TfLEoryCkDdcW+2PmNyW2gIWRBs
         wTPKiJ0yJ7eAQJXABh3sNDsdXtcGTVXBZd0z6nTiMfX/ZIfTqQq83M55OBXw3KfljcNy
         jwcNX81PR159z9bI7I9PlNagdpSG7F8sKSGKprXJJKepemxzBfeWNYASGdTYUFTIqFFc
         lrAn/W9ub2uGjX9hl5ahbzfE78V49Svncz9HAlXjfo8dyifGlJnK9/F5LsE8kRnM/321
         lOaA==
X-Google-Smtp-Source: APXvYqw5KDZ39HU8Icwu4S6RpSSs7BszMpNyZQ5WJg5vOVgn5k90ODytif1OzlfBC2AtFGb/6BjcJbfFcJE=
X-Received: by 2002:a24:5a04:: with SMTP id v4mr546460ita.37.1552352285759;
 Mon, 11 Mar 2019 17:58:05 -0700 (PDT)
Date: Mon, 11 Mar 2019 18:57:47 -0600
In-Reply-To: <20190312005749.30166-1-yuzhao@google.com>
Message-Id: <20190312005749.30166-2-yuzhao@google.com>
Mime-Version: 1.0
References: <20190310011906.254635-1-yuzhao@google.com> <20190312005749.30166-1-yuzhao@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v4 2/4] arm64: mm: don't call page table ctors for init_mm
From: Yu Zhao <yuzhao@google.com>
To: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, 
	Mark Rutland <mark.rutland@arm.com>
Cc: "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, 
	Andrew Morton <akpm@linux-foundation.org>, Nick Piggin <npiggin@gmail.com>, 
	Peter Zijlstra <peterz@infradead.org>, Joel Fernandes <joel@joelfernandes.org>, 
	"Kirill A . Shutemov" <kirill@shutemov.name>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, 
	Chintan Pandya <cpandya@codeaurora.org>, Jun Yao <yaojun8558363@gmail.com>, 
	Laura Abbott <labbott@redhat.com>, linux-arm-kernel@lists.infradead.org, 
	linux-kernel@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, 
	Yu Zhao <yuzhao@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

init_mm doesn't require page table lock to be initialized at
any level. Add a separate page table allocator for it, and the
new one skips page table ctors.

The ctors allocate memory when ALLOC_SPLIT_PTLOCKS is set. Not
calling them avoids memory leak in case we call pte_free_kernel()
on init_mm.

Acked-by: Mark Rutland <mark.rutland@arm.com>
Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 arch/arm64/mm/mmu.c | 15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index f704b291f2c5..d1dc2a2777aa 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -370,6 +370,16 @@ static void __create_pgd_mapping(pgd_t *pgdir, phys_addr_t phys,
 	} while (pgdp++, addr = next, addr != end);
 }
 
+static phys_addr_t pgd_kernel_pgtable_alloc(int shift)
+{
+	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
+	BUG_ON(!ptr);
+
+	/* Ensure the zeroed page is visible to the page table walker */
+	dsb(ishst);
+	return __pa(ptr);
+}
+
 static phys_addr_t pgd_pgtable_alloc(int shift)
 {
 	void *ptr = (void *)__get_free_page(PGALLOC_GFP);
@@ -594,7 +604,7 @@ static int __init map_entry_trampoline(void)
 	/* Map only the text into the trampoline page table */
 	memset(tramp_pg_dir, 0, PGD_SIZE);
 	__create_pgd_mapping(tramp_pg_dir, pa_start, TRAMP_VALIAS, PAGE_SIZE,
-			     prot, pgd_pgtable_alloc, 0);
+			     prot, pgd_kernel_pgtable_alloc, 0);
 
 	/* Map both the text and data into the kernel page table */
 	__set_fixmap(FIX_ENTRY_TRAMP_TEXT, pa_start, prot);
@@ -1070,7 +1080,8 @@ int arch_add_memory(int nid, u64 start, u64 size, struct vmem_altmap *altmap,
 		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
 
 	__create_pgd_mapping(swapper_pg_dir, start, __phys_to_virt(start),
-			     size, PAGE_KERNEL, pgd_pgtable_alloc, flags);
+			     size, PAGE_KERNEL, pgd_kernel_pgtable_alloc,
+			     flags);
 
 	return __add_pages(nid, start >> PAGE_SHIFT, size >> PAGE_SHIFT,
 			   altmap, want_memblock);
-- 
2.21.0.360.g471c308f928-goog

