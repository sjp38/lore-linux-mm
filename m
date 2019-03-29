Return-Path: <SRS0=6kLG=SA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-16.6 required=3.0 tests=DKIMWL_WL_MED,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT,USER_IN_DEF_DKIM_WL
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 6DAC5C43381
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:28:53 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D470C21773
	for <linux-mm@archiver.kernel.org>; Fri, 29 Mar 2019 01:28:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=google.com header.i=@google.com header.b="MCNu8JKS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D470C21773
Authentication-Results: mail.kernel.org; dmarc=fail (p=reject dis=none) header.from=google.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 30CAC6B0005; Thu, 28 Mar 2019 21:28:52 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2BC6F6B0008; Thu, 28 Mar 2019 21:28:52 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1AD246B000C; Thu, 28 Mar 2019 21:28:52 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-io1-f69.google.com (mail-io1-f69.google.com [209.85.166.69])
	by kanga.kvack.org (Postfix) with ESMTP id EC7CE6B0005
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 21:28:51 -0400 (EDT)
Received: by mail-io1-f69.google.com with SMTP id n15so572209ioc.0
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 18:28:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:date:message-id:mime-version
         :subject:from:to:cc;
        bh=4T5MUEH2ZwoDYdu9ANRKZqoThspT7kSM7OLP02B0X0U=;
        b=oSV43P+1BHhxZTJUEFjoKRWEXtHTr4MNj8qUzxQ3s6xwO/5068KRWEGTA6m529G58e
         NA+KI99EwVBkHvmk2F5T1viAqDvlc+eB3NGFtcf0aBwDWOtUFF7VAJE8Xcbn7y8lm/pY
         9OQHZrBL60o5dfioptV9GFpwmwQkXD/Wnkl6ZWaikelktIpr1sj4dKBC5OKhF55kdm28
         Ts4YkA+FWWjYOOcHoVFIRiv1PAhokVtrqKWquJMSeRwda0km9+ATY5BywJ/72UUCtOx2
         kYcd8fATFxv/tP3c8gMwTl8ERlnQfPGUAqyX/IjLgeXWyJEMDAfesfFc0wK8Ey9RH5dn
         N7Ow==
X-Gm-Message-State: APjAAAVR9AavZwS0vekQpe2OR7fMeG72yC/c/9x81RLnjUn3xNwZSB+Z
	2S0yGU9jl5EIx1lbe3CuOBUQsuk0FrpikdE51l8AeARUndb7qSZUsP0j6pqhPpoIocQ0V5gicc6
	5bNokDDV7C35IyGDikGlX7+H3V7rLku4XSgSgyWzBMofRKm4zi8xIEUtRN5+tzy/QGQ==
X-Received: by 2002:a24:254c:: with SMTP id g73mr2554117itg.77.1553822931639;
        Thu, 28 Mar 2019 18:28:51 -0700 (PDT)
X-Received: by 2002:a24:254c:: with SMTP id g73mr2554075itg.77.1553822930514;
        Thu, 28 Mar 2019 18:28:50 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553822930; cv=none;
        d=google.com; s=arc-20160816;
        b=eDZQveQtAZaGR3/b3lrVeAmifuULMfLy4CbrD9ba/m+GEMEbBXSuzFDcTCKwoyycHf
         xtrwfSU0tZcEtWguNjBAMYs4EUU8ah9BlOQ9gQaqpST0pYldRIQnyiCiO28lP98QmTEi
         hNXwtzOsGGCjFPH13qEte0M8nQVWfXj5S6eGee0bDZGNxzjSKIKzGlxsrQlgHWVPrs62
         yc+qKDkgv7xtf5tj+aytOA2ynmKCkWRHy8aWMqQDEmIumBOCNK0RVRO3hV7ducf/1oF3
         FdhwRu/OZuBraGOCuw142zDSdQ9O6flXcna93VYGTbf1g2h4SfXQ8KTefTjs3+Q1VzGO
         p+zg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:from:subject:mime-version:message-id:date:dkim-signature;
        bh=4T5MUEH2ZwoDYdu9ANRKZqoThspT7kSM7OLP02B0X0U=;
        b=IbOZCPFGwPMMUgU/l3HcQNeg3fHKELK5oaKyOfO2WuA9XGKOyWSi+oN4fmtPWHfLpH
         h7ajc1keQw8QxgJF+iAFexJz8cMD1si0og9AInZf2Jno+DN1gleX+6HU5NTBQ00qwoFH
         XNQPVUkwKa1ch5efqjeoX5cWXut+rcaTKxKcDSTmQKTe554aK/SkVLX2FY0a8tgrPU/z
         nQPWIO6FaE/4OQ7p8/SWWy3FhjtG7e38dv1zhXA6nboBHvoRm83rO10DnPlA+O7Ib1SD
         jTGJBPbT7tlauum3QAjSab5KmB/69fNeDKDg9571ss+f+2BBpT2dFC2G2FbZA+nfsH/f
         tc6A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MCNu8JKS;
       spf=pass (google.com: domain of 30nsdxagkcb0la3d77e49hh9e7.5hfebgnq-ffdo35d.hk9@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30nSdXAgKCB0LA3D77E49HH9E7.5HFEBGNQ-FFDO35D.HK9@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
Received: from mail-sor-f73.google.com (mail-sor-f73.google.com. [209.85.220.73])
        by mx.google.com with SMTPS id v133sor795769itb.35.2019.03.28.18.28.50
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 28 Mar 2019 18:28:50 -0700 (PDT)
Received-SPF: pass (google.com: domain of 30nsdxagkcb0la3d77e49hh9e7.5hfebgnq-ffdo35d.hk9@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) client-ip=209.85.220.73;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@google.com header.s=20161025 header.b=MCNu8JKS;
       spf=pass (google.com: domain of 30nsdxagkcb0la3d77e49hh9e7.5hfebgnq-ffdo35d.hk9@flex--shakeelb.bounces.google.com designates 209.85.220.73 as permitted sender) smtp.mailfrom=30nSdXAgKCB0LA3D77E49HH9E7.5HFEBGNQ-FFDO35D.HK9@flex--shakeelb.bounces.google.com;
       dmarc=pass (p=REJECT sp=REJECT dis=NONE) header.from=google.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=google.com; s=20161025;
        h=date:message-id:mime-version:subject:from:to:cc;
        bh=4T5MUEH2ZwoDYdu9ANRKZqoThspT7kSM7OLP02B0X0U=;
        b=MCNu8JKS44wPWIpPESaw89q4D2UcNs/MhIuoQmsdXKySRXIQldKv70crIqexGYEGdG
         DqvNejtNzC3Euo8Y/Y3E6xkLNC1XPJvK2eC/eOgolWclv2eFd5YN0OV4AufeqO4b6o76
         GMzb4pZSO6M2U/RH7vNxuuexqDgNPUNXjGlNxLbUsrN0uP02xbs51KEtn7HXtw9CFi2T
         XAStb8JepS5oASqG4EWul/lHaJmmrlrvgMzj1s162xTBqmnTlLdP1hNXTllD7umlIDSi
         qAdGJxIdbbPKbsAa4BSXrzRMnQZH+RYoXxDLRLCbWrzCHn1WwE9o26sQ/wD67LrzQp7j
         Jonw==
X-Google-Smtp-Source: APXvYqxshljcgDf+76yaBeCOGOqEHIcR2cmMVQaSy+GKHPZqSDplxZVVcxbGXfITPe0CQPnD+E7csBwgvBb3sA==
X-Received: by 2002:a24:9884:: with SMTP id n126mr919316itd.30.1553822930204;
 Thu, 28 Mar 2019 18:28:50 -0700 (PDT)
Date: Thu, 28 Mar 2019 18:28:36 -0700
Message-Id: <20190329012836.47013-1-shakeelb@google.com>
Mime-Version: 1.0
X-Mailer: git-send-email 2.21.0.392.gf8f6787159e-goog
Subject: [RFC PATCH] mm, kvm: account kvm_vcpu_mmap to kmemcg
From: Shakeel Butt <shakeelb@google.com>
To: Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, 
	Michal Hocko <mhocko@suse.com>, Andrew Morton <akpm@linux-foundation.org>, 
	Matthew Wilcox <willy@infradead.org>, Paolo Bonzini <pbonzini@redhat.com>, 
	Ben Gardon <bgardon@google.com>, 
	"=?UTF-8?q?Radim=20Kr=C4=8Dm=C3=A1=C5=99?=" <rkrcmar@redhat.com>
Cc: linux-mm@kvack.org, kvm@vger.kernel.org, linux-kernel@vger.kernel.org, 
	Shakeel Butt <shakeelb@google.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

A VCPU of a VM can allocate upto three pages which can be mmap'ed by the
user space application. At the moment this memory is not charged. On a
large machine running large number of VMs (or small number of VMs having
large number of VCPUs), this unaccounted memory can be very significant.
So, this memory should be charged to a kmemcg. However that is not
possible as these pages are mmapped to the userspace and PageKmemcg()
was designed with the assumption that such pages will never be mmapped
to the userspace.

One way to solve this problem is by introducing an additional memcg
charging API similar to mem_cgroup_[un]charge_skmem(). However skmem
charging API usage is contained and shared and no new users are
expected but the pages which can be mmapped and should be charged to
kmemcg can and will increase. So, requiring the usage for such API will
increase the maintenance burden. The simplest solution is to remove the
assumption of no mmapping PageKmemcg() pages to user space.

Signed-off-by: Shakeel Butt <shakeelb@google.com>
---
 arch/s390/kvm/kvm-s390.c       |  2 +-
 arch/x86/kvm/x86.c             |  2 +-
 include/linux/page-flags.h     | 26 ++++++++++++++++++--------
 include/trace/events/mmflags.h |  9 ++++++++-
 virt/kvm/coalesced_mmio.c      |  2 +-
 virt/kvm/kvm_main.c            |  2 +-
 6 files changed, 30 insertions(+), 13 deletions(-)

diff --git a/arch/s390/kvm/kvm-s390.c b/arch/s390/kvm/kvm-s390.c
index 4638303ba6a8..1a9e337ed5da 100644
--- a/arch/s390/kvm/kvm-s390.c
+++ b/arch/s390/kvm/kvm-s390.c
@@ -2953,7 +2953,7 @@ struct kvm_vcpu *kvm_arch_vcpu_create(struct kvm *kvm,
 		goto out;
 
 	BUILD_BUG_ON(sizeof(struct sie_page) != 4096);
-	sie_page = (struct sie_page *) get_zeroed_page(GFP_KERNEL);
+	sie_page = (struct sie_page *) get_zeroed_page(GFP_KERNEL_ACCOUNT);
 	if (!sie_page)
 		goto out_free_cpu;
 
diff --git a/arch/x86/kvm/x86.c b/arch/x86/kvm/x86.c
index 65e4559eef2f..05c0c7eaa5c6 100644
--- a/arch/x86/kvm/x86.c
+++ b/arch/x86/kvm/x86.c
@@ -9019,7 +9019,7 @@ int kvm_arch_vcpu_init(struct kvm_vcpu *vcpu)
 	else
 		vcpu->arch.mp_state = KVM_MP_STATE_UNINITIALIZED;
 
-	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+	page = alloc_page(GFP_KERNEL_ACCOUNT | __GFP_ZERO);
 	if (!page) {
 		r = -ENOMEM;
 		goto fail;
diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
index 9f8712a4b1a5..b47a6a327d6a 100644
--- a/include/linux/page-flags.h
+++ b/include/linux/page-flags.h
@@ -78,6 +78,10 @@
  * PG_hwpoison indicates that a page got corrupted in hardware and contains
  * data with incorrect ECC bits that triggered a machine check. Accessing is
  * not safe since it may cause another machine check. Don't touch!
+ *
+ * PG_kmemcg indicates that a kmem page is charged to a memcg. If kmemcg is
+ * enabled, the page allocator will set PageKmemcg() on  pages allocated with
+ * __GFP_ACCOUNT. It gets cleared on page free.
  */
 
 /*
@@ -130,6 +134,9 @@ enum pageflags {
 #if defined(CONFIG_IDLE_PAGE_TRACKING) && defined(CONFIG_64BIT)
 	PG_young,
 	PG_idle,
+#endif
+#ifdef CONFIG_MEMCG_KMEM
+	PG_kmemcg,
 #endif
 	__NR_PAGEFLAGS,
 
@@ -289,6 +296,9 @@ static inline int Page##uname(const struct page *page) { return 0; }
 #define SETPAGEFLAG_NOOP(uname)						\
 static inline void SetPage##uname(struct page *page) {  }
 
+#define __SETPAGEFLAG_NOOP(uname)					\
+static inline void __SetPage##uname(struct page *page) {  }
+
 #define CLEARPAGEFLAG_NOOP(uname)					\
 static inline void ClearPage##uname(struct page *page) {  }
 
@@ -427,6 +437,13 @@ TESTCLEARFLAG(Young, young, PF_ANY)
 PAGEFLAG(Idle, idle, PF_ANY)
 #endif
 
+#ifdef CONFIG_MEMCG_KMEM
+__PAGEFLAG(Kmemcg, kmemcg, PF_NO_TAIL)
+#else
+TESTPAGEFLAG_FALSE(kmemcg)
+__SETPAGEFLAG_NOOP(kmemcg)
+__CLEARPAGEFLAG_NOOP(kmemcg)
+#endif
 /*
  * On an anonymous page mapped into a user virtual memory area,
  * page->mapping points to its anon_vma, not to a struct address_space;
@@ -701,8 +718,7 @@ PAGEFLAG_FALSE(DoubleMap)
 #define PAGE_MAPCOUNT_RESERVE	-128
 #define PG_buddy	0x00000080
 #define PG_offline	0x00000100
-#define PG_kmemcg	0x00000200
-#define PG_table	0x00000400
+#define PG_table	0x00000200
 
 #define PageType(page, flag)						\
 	((page->page_type & (PAGE_TYPE_BASE | flag)) == PAGE_TYPE_BASE)
@@ -743,12 +759,6 @@ PAGE_TYPE_OPS(Buddy, buddy)
  */
 PAGE_TYPE_OPS(Offline, offline)
 
-/*
- * If kmemcg is enabled, the buddy allocator will set PageKmemcg() on
- * pages allocated with __GFP_ACCOUNT. It gets cleared on page free.
- */
-PAGE_TYPE_OPS(Kmemcg, kmemcg)
-
 /*
  * Marks pages in use as page tables.
  */
diff --git a/include/trace/events/mmflags.h b/include/trace/events/mmflags.h
index a1675d43777e..d93b78eac5b9 100644
--- a/include/trace/events/mmflags.h
+++ b/include/trace/events/mmflags.h
@@ -79,6 +79,12 @@
 #define IF_HAVE_PG_IDLE(flag,string)
 #endif
 
+#ifdef CONFIG_MEMCG_KMEM
+#define IF_HAVE_PG_KMEMCG(flag,string) ,{1UL << flag, string}
+#else
+#define IF_HAVE_PG_KMEMCG(flag,string)
+#endif
+
 #define __def_pageflag_names						\
 	{1UL << PG_locked,		"locked"	},		\
 	{1UL << PG_waiters,		"waiters"	},		\
@@ -105,7 +111,8 @@ IF_HAVE_PG_MLOCK(PG_mlocked,		"mlocked"	)		\
 IF_HAVE_PG_UNCACHED(PG_uncached,	"uncached"	)		\
 IF_HAVE_PG_HWPOISON(PG_hwpoison,	"hwpoison"	)		\
 IF_HAVE_PG_IDLE(PG_young,		"young"		)		\
-IF_HAVE_PG_IDLE(PG_idle,		"idle"		)
+IF_HAVE_PG_IDLE(PG_idle,		"idle"		)		\
+IF_HAVE_PG_KMEMCG(PG_kmemcg,		"kmemcg"	)
 
 #define show_page_flags(flags)						\
 	(flags) ? __print_flags(flags, "|",				\
diff --git a/virt/kvm/coalesced_mmio.c b/virt/kvm/coalesced_mmio.c
index 5294abb3f178..ebf1601de2a5 100644
--- a/virt/kvm/coalesced_mmio.c
+++ b/virt/kvm/coalesced_mmio.c
@@ -110,7 +110,7 @@ int kvm_coalesced_mmio_init(struct kvm *kvm)
 	int ret;
 
 	ret = -ENOMEM;
-	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+	page = alloc_page(GFP_KERNEL_ACCOUNT | __GFP_ZERO);
 	if (!page)
 		goto out_err;
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index f25aa98a94df..de6328dff251 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -306,7 +306,7 @@ int kvm_vcpu_init(struct kvm_vcpu *vcpu, struct kvm *kvm, unsigned id)
 	vcpu->pre_pcpu = -1;
 	INIT_LIST_HEAD(&vcpu->blocked_vcpu_list);
 
-	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+	page = alloc_page(GFP_KERNEL_ACCOUNT | __GFP_ZERO);
 	if (!page) {
 		r = -ENOMEM;
 		goto fail;
-- 
2.21.0.392.gf8f6787159e-goog

