Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id E111D6B0038
	for <linux-mm@kvack.org>; Fri, 17 Mar 2017 00:52:22 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b2so123913663pgc.6
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 21:52:22 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id e9si7401602plk.170.2017.03.16.21.52.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 21:52:21 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id 81so299448pgh.3
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 21:52:21 -0700 (PDT)
Subject: Re: [HMM 07/16] mm/migrate: new memory migration helper for use with
 device memory v4
References: <1489680335-6594-1-git-send-email-jglisse@redhat.com>
 <1489680335-6594-8-git-send-email-jglisse@redhat.com>
 <20170316160520.d03ac02474cad6d2c8eba9bc@linux-foundation.org>
 <d4e8433d-4680-dced-4f11-2f3cc8ebc613@nvidia.com>
 <CAKTCnzmYob5uq11zkJE781BX9rDH9EYM7zxHH+ZMtTs4D5kkiQ@mail.gmail.com>
 <94e0d115-7deb-c748-3dc2-60d6289e6551@nvidia.com>
 <CAKTCnznV1D4iZcn-PWvfu92_NB-Ree=cOT3bKfuJSPSXVB_QAg@mail.gmail.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <a8b67ed5-118c-6da5-1db6-6edf836f9230@gmail.com>
Date: Fri, 17 Mar 2017 15:51:33 +1100
MIME-Version: 1.0
In-Reply-To: <CAKTCnznV1D4iZcn-PWvfu92_NB-Ree=cOT3bKfuJSPSXVB_QAg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: John Hubbard <jhubbard@nvidia.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Evgeny Baskakov <ebaskakov@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Sherry Cheung <SCheung@nvidia.com>, Subhash Gutti <sgutti@nvidia.com>



On 17/03/17 14:42, Balbir Singh wrote:
>>> Or make the HMM Kconfig feature 64BIT only by making it depend on 64BIT?
>>>
>>
>> Yes, that was my first reaction too, but these particular routines are
>> aspiring to be generic routines--in fact, you have had an influence there,
>> because these might possibly help with NUMA migrations. :)
>>
> 
> Yes, I still stick to them being generic, but I'd be OK if they worked
> just for 64 bit systems.
> Having said that even the 64 bit works version work for upto physical
> sizes of 64 - PAGE_SHIFT
> which is a little limiting I think.
> 
> One option is to make pfn's unsigned long long and do 32 and 64 bit computations
> separately
> 
> Option 2, could be something like you said
> 
> a. Define a __weak migrate_vma to return -EINVAL
> b. In a 64BIT only file define migrate_vma
> 
> Option 3
> 
> Something totally different
> 
> If we care to support 32 bit we go with 1, else option 2 is a good
> starting point. There might
> be other ways of doing option 2, like you've suggested


So this is what I ended up with, a quick fix for the 32 bit
build failures

Date: Fri, 17 Mar 2017 15:42:52 +1100
Subject: [PATCH] mm/hmm: Fix build on 32 bit systems

Fix build breakage of hmm-v18 in the current mmotm by
making the migrate_vma() and related functions 64
bit only. The 32 bit variant will return -EINVAL.
There are other approaches to solving this problem,
but we can enable 32 bit systems as we need them.

This patch tries to limit the impact on 32 bit systems
by turning HMM off on them and not enabling the migrate
functions.

I've built this on ppc64/i386 and x86_64

Signed-off-by: Balbir Singh <bsingharora@gmail.com>
---
 include/linux/migrate.h | 18 +++++++++++++++++-
 mm/Kconfig              |  4 +++-
 mm/migrate.c            |  3 ++-
 3 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/include/linux/migrate.h b/include/linux/migrate.h
index 01f4945..1888a70 100644
--- a/include/linux/migrate.h
+++ b/include/linux/migrate.h
@@ -124,7 +124,7 @@ static inline int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 }
 #endif /* CONFIG_NUMA_BALANCING && CONFIG_TRANSPARENT_HUGEPAGE*/
 
-
+#ifdef CONFIG_64BIT
 #define MIGRATE_PFN_VALID	(1UL << (BITS_PER_LONG_LONG - 1))
 #define MIGRATE_PFN_MIGRATE	(1UL << (BITS_PER_LONG_LONG - 2))
 #define MIGRATE_PFN_HUGE	(1UL << (BITS_PER_LONG_LONG - 3))
@@ -145,6 +145,7 @@ static inline unsigned long migrate_pfn_size(unsigned long mpfn)
 {
 	return mpfn & MIGRATE_PFN_HUGE ? PMD_SIZE : PAGE_SIZE;
 }
+#endif
 
 /*
  * struct migrate_vma_ops - migrate operation callback
@@ -194,6 +195,7 @@ struct migrate_vma_ops {
 				 void *private);
 };
 
+#ifdef CONFIG_64BIT
 int migrate_vma(const struct migrate_vma_ops *ops,
 		struct vm_area_struct *vma,
 		unsigned long mentries,
@@ -202,5 +204,19 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 		unsigned long *src,
 		unsigned long *dst,
 		void *private);
+#else
+static inline int migrate_vma(const struct migrate_vma_ops *ops,
+				struct vm_area_struct *vma,
+				unsigned long mentries,
+				unsigned long start,
+				unsigned long end,
+				unsigned long *src,
+				unsigned long *dst,
+				void *private)
+{
+	return -EINVAL;
+}
+#endif
+
 
 #endif /* _LINUX_MIGRATE_H */
diff --git a/mm/Kconfig b/mm/Kconfig
index a430d51..c13677f 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -291,7 +291,7 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 
 config HMM
 	bool
-	depends on MMU
+	depends on MMU && 64BIT
 
 config HMM_MIRROR
 	bool "HMM mirror CPU page table into a device page table"
@@ -307,6 +307,7 @@ config HMM_MIRROR
 	  Second side of the equation is replicating CPU page table content for
 	  range of virtual address. This require careful synchronization with
 	  CPU page table update.
+	depends on 64BIT
 
 config HMM_DEVMEM
 	bool "HMM device memory helpers (to leverage ZONE_DEVICE)"
@@ -314,6 +315,7 @@ config HMM_DEVMEM
 	help
 	  HMM devmem are helpers to leverage new ZONE_DEVICE feature. This is
 	  just to avoid device driver to replicate boiler plate code.
+	depends on 64BIT
 
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT || ARCH_PHYS_ADDR_T_64BIT
diff --git a/mm/migrate.c b/mm/migrate.c
index b9d25d1..15f2972 100644
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -2080,7 +2080,7 @@ int migrate_misplaced_transhuge_page(struct mm_struct *mm,
 
 #endif /* CONFIG_NUMA */
 
-
+#ifdef CONFIG_64BIT
 struct migrate_vma {
 	struct vm_area_struct	*vma;
 	unsigned long		*dst;
@@ -2787,3 +2787,4 @@ int migrate_vma(const struct migrate_vma_ops *ops,
 	return 0;
 }
 EXPORT_SYMBOL(migrate_vma);
+#endif
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
