Return-Path: <SRS0=zC2G=RP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B8606C43381
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:58:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6916D2087F
	for <linux-mm@archiver.kernel.org>; Tue, 12 Mar 2019 00:58:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="oedD/egg"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6916D2087F
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BCD6C8E0005; Mon, 11 Mar 2019 20:58:08 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B57448E0002; Mon, 11 Mar 2019 20:58:08 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A6E308E0005; Mon, 11 Mar 2019 20:58:08 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A56A8E0002
	for <linux-mm@kvack.org>; Mon, 11 Mar 2019 20:58:08 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id r21so576872iod.12
        for <linux-mm@kvack.org>; Mon, 11 Mar 2019 17:58:08 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:in-reply-to:message-id
         :mime-version:references:subject:from:to:cc;
        bh=srduQGUMd+1T0rMo1nAAhODDuDFnWSZKCOfw6uJonls=;
        b=RsmKcunCUGDJ/N8dkCK40CFAfXm7Ql1HLB/IqcpNEkPPQ9E15MI2WKrjVU0zbWPDkB
         VCo03YfI1B7QIIuDEL5ntVhh0FnLlYXJLVe4jMeV1InX9EgxcHedrHUc6PUOaAsRct7n
         Si/xBCnjgKEuOzL2dICJqV2NOt3d0NZso9DuWt8mZVRx/nyWr3+Ams/UxR7i11ausECL
         yXZ1vTRZlS5+VBR3o+wBkJQG78jB2/ndu0g6Hti+rLZ79R7MohfGQta+JDHA6I7ebcgx
         wNWc7ANrJMfim5BIFXA+q/I76mz179+fXEBO9nAjb7U0+k7bnA4bkt/gbsAiDOiAZc0v
         UwAg==
X-Gm-Message-State: APjAAAWZqAeFvYq6gyduN42jlYkJ58PREf8kyki4z8qEusnSnz8H/cdi
	6CpJQY0z+/TtE4S8A2C2yR8J/pOuDovEeInGrd5VXq9W9VLE+5FyYRkSatI9DOgotYz7sKzXsCv
	vP8kkIDlSVRE5DC5IPrqc3S2t+LblmzvDnE+fgS86SrH6dXphmwxDzS4WOjrTe/yd3A==
X-Received: by 2002:a24:1f84:: with SMTP id d126mr632481itd.67.1552352288385;
        Mon, 11 Mar 2019 17:58:08 -0700 (PDT)
X-Received: by 2002:a24:1f84:: with SMTP id d126mr632460itd.67.1552352287602;
        Mon, 11 Mar 2019 17:58:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552352287; cv=none;
        d=google.com; s=arc-20160816;
        b=AXmlcfT9a3Bz+o4/1czILNuPvgPvVqyyhlBYikyS/WEEgKNaPPmcsm8MB1C5+fZlor
         ekoS2m8uMbmrdOeepRvnBYuo5KprhgWIy21KPvcjj+OGtV/VJTPs0zE/M8mxhckgQNpm
         Sy9xF8qcV2hnVG4hS6xBcslDG7kzbbOOFxTCv+aq9rNlXwhFVs2AkIFz28B4Q1/q0QhA
         4Mv4ryYhf8MfMfdeyYyT6LbxuBXk8onPhnZwXnm/0AfToyhEJiH/AhG0l90h4ZsvvZLm
         zXAJPWWD6IbPC3iqbcVRRbHlIeKZWStC/p3BGM+6x2EtQoBjEdYMFIDRGc3XRF08V+ch
         HMqA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:references:mime-version:message-id:in-reply-to
         :date:dkim-signature;
        bh=srduQGUMd+1T0rMo1nAAhODDuDFnWSZKCOfw6uJonls=;
        b=fnIFKXxcG1uIgPxxS5Zwc0TAqjy27eRMtZ3CNrQa9UMe4iCG8WRpWjmx5niPCPbdpq
         bfXAEiwlPQcPBNWSC4J2FgoFExM/VI383rYfYxhuS85q7lFHRTIcP6jzoLOZ8qpg9XAQ
         ln5P+kPN6P3pQb1PRxAUrh95iNpRDi14rQCFhJywn0trJBOo0ZlEhAcpxjdxbsuUiTFC
         kfZHqjLtiWSBzMTb88icaMqlGXNSkLxoLwv76LJiA09oStRlWmHgAubqi+huPBCoovHw
         IQqPUIZWDCxa0oFYICZa/J+6C33ZnhlFd8+tv4755PZLxDk6rDkufW7ZUyggdEwtvRQC
         iFHQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="oedD/egg";
       spf=pass (google.com: domain of 3hwshxaykcc4iejrkyqyyqvo.mywvsxeh-wwufkmu.ybq@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3HwSHXAYKCC4iejRKYQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id f74sor1342602itf.11.2019.03.11.17.58.07
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 11 Mar 2019 17:58:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of 3hwshxaykcc4iejrkyqyyqvo.mywvsxeh-wwufkmu.ybq@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b="oedD/egg";
       spf=pass (google.com: domain of 3hwshxaykcc4iejrkyqyyqvo.mywvsxeh-wwufkmu.ybq@flex--yuzhao.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=3HwSHXAYKCC4iejRKYQYYQVO.MYWVSXeh-WWUfKMU.YbQ@flex--yuzhao.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:in-reply-to:message-id:mime-version:references:subject:from:to
         :cc;
        bh=srduQGUMd+1T0rMo1nAAhODDuDFnWSZKCOfw6uJonls=;
        b=oedD/eggmV+SIgYB11JrwAoZLhFWdb50S/XNtFqL8BtNX+SDe5Glssl7AopEbDqcNA
         HCKLJ/V3bjISgT2y2KxWp3VykVnCmF5Y6Eu7pAUj8ZigjSaNi2yJ90jUlcOctuxB1Fbm
         A3C127QaAa54k+3O0L7KF5QaqVgnfjPJr6a85bI04USgXp04seBuyvB1LjH9V5YVSO4n
         9poZ+ZPTh65xeVRUyWd030y18tK6PcucnaLZg/I1TUKe2kC6W9D9AdSqG6CQmwyqYYKV
         4olxX5RbFrrKkNYKcwWg7HTaRF8nnkjP+yLqbV7GoSTMRn558HpMjY8QWgCmjB5DLMAj
         nSOA==
X-Google-Smtp-Source: APXvYqxqCOwYBxF/7ICjEeopmZPTb2uYLa3V2NjdBJYx9miVxqzRT+/6zNK7zIhloXUYTCZtvdQJhkLhhWk=
X-Received: by 2002:a24:e984:: with SMTP id f126mr583102ith.1.1552352287403;
 Mon, 11 Mar 2019 17:58:07 -0700 (PDT)
Date: Mon, 11 Mar 2019 18:57:48 -0600
In-Reply-To: <20190312005749.30166-1-yuzhao@google.com>
Message-Id: <20190312005749.30166-3-yuzhao@google.com>
Mime-Version: 1.0
References: <20190310011906.254635-1-yuzhao@google.com> <20190312005749.30166-1-yuzhao@google.com>
X-Mailer: git-send-email 2.21.0.360.g471c308f928-goog
Subject: [PATCH v4 3/4] arm64: mm: call ctor for stage2 pmd page
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

Call pgtable_pmd_page_dtor() for pmd page allocated by
mmu_memory_cache_alloc() so kernel won't crash when it's freed
through stage2_pmd_free()->pmd_free()->pgtable_pmd_page_dtor().

This is needed if we are going to enable split pmd pt lock.

Signed-off-by: Yu Zhao <yuzhao@google.com>
---
 arch/arm64/include/asm/stage2_pgtable.h | 15 ++++++++++++---
 virt/kvm/arm/mmu.c                      | 13 +++++++++++--
 2 files changed, 23 insertions(+), 5 deletions(-)

diff --git a/arch/arm64/include/asm/stage2_pgtable.h b/arch/arm64/include/asm/stage2_pgtable.h
index 5412fa40825e..0d9207144257 100644
--- a/arch/arm64/include/asm/stage2_pgtable.h
+++ b/arch/arm64/include/asm/stage2_pgtable.h
@@ -174,10 +174,19 @@ static inline bool stage2_pud_present(struct kvm *kvm, pud_t pud)
 		return 1;
 }
 
-static inline void stage2_pud_populate(struct kvm *kvm, pud_t *pud, pmd_t *pmd)
+static inline int stage2_pud_populate(struct kvm *kvm, pud_t *pud, pmd_t *pmd)
 {
-	if (kvm_stage2_has_pmd(kvm))
-		pud_populate(NULL, pud, pmd);
+	if (!kvm_stage2_has_pmd(kvm))
+		return 0;
+
+	/* paired with pgtable_pmd_page_dtor() in pmd_free() below */
+	if (!pgtable_pmd_page_ctor(virt_to_page(pmd))) {
+		free_page((unsigned long)pmd);
+		return -ENOMEM;
+	}
+
+	pud_populate(NULL, pud, pmd);
+	return 0;
 }
 
 static inline pmd_t *stage2_pmd_offset(struct kvm *kvm,
diff --git a/virt/kvm/arm/mmu.c b/virt/kvm/arm/mmu.c
index e9d28a7ca673..11922d84be83 100644
--- a/virt/kvm/arm/mmu.c
+++ b/virt/kvm/arm/mmu.c
@@ -1037,6 +1037,7 @@ static pud_t *stage2_get_pud(struct kvm *kvm, struct kvm_mmu_memory_cache *cache
 static pmd_t *stage2_get_pmd(struct kvm *kvm, struct kvm_mmu_memory_cache *cache,
 			     phys_addr_t addr)
 {
+	int ret;
 	pud_t *pud;
 	pmd_t *pmd;
 
@@ -1048,7 +1049,9 @@ static pmd_t *stage2_get_pmd(struct kvm *kvm, struct kvm_mmu_memory_cache *cache
 		if (!cache)
 			return NULL;
 		pmd = mmu_memory_cache_alloc(cache);
-		stage2_pud_populate(kvm, pud, pmd);
+		ret = stage2_pud_populate(kvm, pud, pmd);
+		if (ret)
+			return ERR_PTR(ret);
 		get_page(virt_to_page(pud));
 	}
 
@@ -1061,6 +1064,9 @@ static int stage2_set_pmd_huge(struct kvm *kvm, struct kvm_mmu_memory_cache
 	pmd_t *pmd, old_pmd;
 
 	pmd = stage2_get_pmd(kvm, cache, addr);
+	if (IS_ERR(pmd))
+		return PTR_ERR(pmd);
+
 	VM_BUG_ON(!pmd);
 
 	old_pmd = *pmd;
@@ -1198,6 +1204,7 @@ static int stage2_set_pte(struct kvm *kvm, struct kvm_mmu_memory_cache *cache,
 			  phys_addr_t addr, const pte_t *new_pte,
 			  unsigned long flags)
 {
+	int ret;
 	pud_t *pud;
 	pmd_t *pmd;
 	pte_t *pte, old_pte;
@@ -1227,7 +1234,9 @@ static int stage2_set_pte(struct kvm *kvm, struct kvm_mmu_memory_cache *cache,
 		if (!cache)
 			return 0; /* ignore calls from kvm_set_spte_hva */
 		pmd = mmu_memory_cache_alloc(cache);
-		stage2_pud_populate(kvm, pud, pmd);
+		ret = stage2_pud_populate(kvm, pud, pmd);
+		if (ret)
+			return ret;
 		get_page(virt_to_page(pud));
 	}
 
-- 
2.21.0.360.g471c308f928-goog

