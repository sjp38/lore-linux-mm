Return-Path: <SRS0=I31T=WR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 77529C3A59E
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:40:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 29F1522DA7
	for <linux-mm@archiver.kernel.org>; Wed, 21 Aug 2019 15:40:45 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 29F1522DA7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=redhat.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CE0246B02F8; Wed, 21 Aug 2019 11:40:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CB7026B02F9; Wed, 21 Aug 2019 11:40:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B7F1E6B02FA; Wed, 21 Aug 2019 11:40:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from forelay.hostedemail.com (smtprelay0088.hostedemail.com [216.40.44.88])
	by kanga.kvack.org (Postfix) with ESMTP id 970006B02F8
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 11:40:44 -0400 (EDT)
Received: from smtpin11.hostedemail.com (10.5.19.251.rfc1918.com [10.5.19.251])
	by forelay05.hostedemail.com (Postfix) with SMTP id 355EE181AC9CC
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:40:44 +0000 (UTC)
X-FDA: 75846847608.11.fight56_65fa2c411229
X-HE-Tag: fight56_65fa2c411229
X-Filterd-Recvd-Size: 12811
Received: from mx1.redhat.com (mx1.redhat.com [209.132.183.28])
	by imf40.hostedemail.com (Postfix) with ESMTP
	for <linux-mm@kvack.org>; Wed, 21 Aug 2019 15:40:43 +0000 (UTC)
Received: from smtp.corp.redhat.com (int-mx01.intmail.prod.int.phx2.redhat.com [10.5.11.11])
	(using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.redhat.com (Postfix) with ESMTPS id 1837481F13;
	Wed, 21 Aug 2019 15:40:41 +0000 (UTC)
Received: from t460s.redhat.com (unknown [10.36.118.29])
	by smtp.corp.redhat.com (Postfix) with ESMTP id 1FE9A2B9D7;
	Wed, 21 Aug 2019 15:40:31 +0000 (UTC)
From: David Hildenbrand <david@redhat.com>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org,
	David Hildenbrand <david@redhat.com>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will@kernel.org>,
	Tony Luck <tony.luck@intel.com>,
	Fenghua Yu <fenghua.yu@intel.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Vasily Gorbik <gor@linux.ibm.com>,
	Christian Borntraeger <borntraeger@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Steve Capper <steve.capper@arm.com>,
	Mike Rapoport <rppt@linux.ibm.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>,
	Yu Zhao <yuzhao@google.com>,
	Jun Yao <yaojun8558363@gmail.com>,
	Robin Murphy <robin.murphy@arm.com>,
	Michal Hocko <mhocko@suse.com>,
	Oscar Salvador <osalvador@suse.de>,
	"Matthew Wilcox (Oracle)" <willy@infradead.org>,
	Christophe Leroy <christophe.leroy@c-s.fr>,
	"Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>,
	Pavel Tatashin <pasha.tatashin@soleen.com>,
	Gerald Schaefer <gerald.schaefer@de.ibm.com>,
	Halil Pasic <pasic@linux.ibm.com>,
	Tom Lendacky <thomas.lendacky@amd.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Dan Williams <dan.j.williams@intel.com>,
	Wei Yang <richard.weiyang@gmail.com>,
	Qian Cai <cai@lca.pw>,
	Jason Gunthorpe <jgg@ziepe.ca>,
	Logan Gunthorpe <logang@deltatee.com>,
	Ira Weiny <ira.weiny@intel.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-ia64@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org
Subject: [PATCH v1 5/5] mm/memory_hotplug: Remove zone parameter from __remove_pages()
Date: Wed, 21 Aug 2019 17:40:06 +0200
Message-Id: <20190821154006.1338-6-david@redhat.com>
In-Reply-To: <20190821154006.1338-1-david@redhat.com>
References: <20190821154006.1338-1-david@redhat.com>
MIME-Version: 1.0
X-Scanned-By: MIMEDefang 2.79 on 10.5.11.11
X-Greylist: Sender IP whitelisted, not delayed by milter-greylist-4.5.16 (mx1.redhat.com [10.5.110.25]); Wed, 21 Aug 2019 15:40:41 +0000 (UTC)
Content-Transfer-Encoding: quoted-printable
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

No longer in use, let's drop it. We no longer access the zone of
possibly never onlined memory (and therefore don't read garabage in
these scenarios).

Cc: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will@kernel.org>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Fenghua Yu <fenghua.yu@intel.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: Vasily Gorbik <gor@linux.ibm.com>
Cc: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: x86@kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Steve Capper <steve.capper@arm.com>
Cc: Mike Rapoport <rppt@linux.ibm.com>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Yu Zhao <yuzhao@google.com>
Cc: Jun Yao <yaojun8558363@gmail.com>
Cc: Robin Murphy <robin.murphy@arm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oscar Salvador <osalvador@suse.de>
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Cc: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.ibm.com>
Cc: Pavel Tatashin <pasha.tatashin@soleen.com>
Cc: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Halil Pasic <pasic@linux.ibm.com>
Cc: Tom Lendacky <thomas.lendacky@amd.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Dan Williams <dan.j.williams@intel.com>
Cc: Wei Yang <richard.weiyang@gmail.com>
Cc: Qian Cai <cai@lca.pw>
Cc: Jason Gunthorpe <jgg@ziepe.ca>
Cc: Logan Gunthorpe <logang@deltatee.com>
Cc: Ira Weiny <ira.weiny@intel.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: linux-ia64@vger.kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: linux-s390@vger.kernel.org
Cc: linux-sh@vger.kernel.org
Signed-off-by: David Hildenbrand <david@redhat.com>
---
 arch/arm64/mm/mmu.c            | 4 +---
 arch/ia64/mm/init.c            | 4 +---
 arch/powerpc/mm/mem.c          | 3 +--
 arch/s390/mm/init.c            | 4 +---
 arch/sh/mm/init.c              | 4 +---
 arch/x86/mm/init_32.c          | 4 +---
 arch/x86/mm/init_64.c          | 4 +---
 include/linux/memory_hotplug.h | 4 ++--
 mm/memory_hotplug.c            | 6 +++---
 mm/memremap.c                  | 3 +--
 10 files changed, 13 insertions(+), 27 deletions(-)

diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
index e67bab4d613e..b3843aff12bf 100644
--- a/arch/arm64/mm/mmu.c
+++ b/arch/arm64/mm/mmu.c
@@ -1080,7 +1080,6 @@ void arch_remove_memory(int nid, u64 start, u64 siz=
e,
 {
 	unsigned long start_pfn =3D start >> PAGE_SHIFT;
 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
-	struct zone *zone;
=20
 	/*
 	 * FIXME: Cleanup page tables (also in arch_add_memory() in case
@@ -1089,7 +1088,6 @@ void arch_remove_memory(int nid, u64 start, u64 siz=
e,
 	 * unplug. ARCH_ENABLE_MEMORY_HOTREMOVE must not be
 	 * unlocked yet.
 	 */
-	zone =3D page_zone(pfn_to_page(start_pfn));
-	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pages(start_pfn, nr_pages, altmap);
 }
 #endif
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index bf9df2625bc8..a6dd80a2c939 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -689,9 +689,7 @@ void arch_remove_memory(int nid, u64 start, u64 size,
 {
 	unsigned long start_pfn =3D start >> PAGE_SHIFT;
 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
-	struct zone *zone;
=20
-	zone =3D page_zone(pfn_to_page(start_pfn));
-	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pages(start_pfn, nr_pages, altmap);
 }
 #endif
diff --git a/arch/powerpc/mm/mem.c b/arch/powerpc/mm/mem.c
index 9191a66b3bc5..7351c44c435a 100644
--- a/arch/powerpc/mm/mem.c
+++ b/arch/powerpc/mm/mem.c
@@ -130,10 +130,9 @@ void __ref arch_remove_memory(int nid, u64 start, u6=
4 size,
 {
 	unsigned long start_pfn =3D start >> PAGE_SHIFT;
 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
-	struct page *page =3D pfn_to_page(start_pfn) + vmem_altmap_offset(altma=
p);
 	int ret;
=20
-	__remove_pages(page_zone(page), start_pfn, nr_pages, altmap);
+	__remove_pages(start_pfn, nr_pages, altmap);
=20
 	/* Remove htab bolted mappings for this section of memory */
 	start =3D (unsigned long)__va(start);
diff --git a/arch/s390/mm/init.c b/arch/s390/mm/init.c
index 20340a03ad90..6f13eb66e375 100644
--- a/arch/s390/mm/init.c
+++ b/arch/s390/mm/init.c
@@ -296,10 +296,8 @@ void arch_remove_memory(int nid, u64 start, u64 size=
,
 {
 	unsigned long start_pfn =3D start >> PAGE_SHIFT;
 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
-	struct zone *zone;
=20
-	zone =3D page_zone(pfn_to_page(start_pfn));
-	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pages(start_pfn, nr_pages, altmap);
 	vmem_remove_mapping(start, size);
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/arch/sh/mm/init.c b/arch/sh/mm/init.c
index dfdbaa50946e..d1b1ff2be17a 100644
--- a/arch/sh/mm/init.c
+++ b/arch/sh/mm/init.c
@@ -434,9 +434,7 @@ void arch_remove_memory(int nid, u64 start, u64 size,
 {
 	unsigned long start_pfn =3D PFN_DOWN(start);
 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
-	struct zone *zone;
=20
-	zone =3D page_zone(pfn_to_page(start_pfn));
-	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pages(start_pfn, nr_pages, altmap);
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/arch/x86/mm/init_32.c b/arch/x86/mm/init_32.c
index 4068abb9427f..9d036be27aaa 100644
--- a/arch/x86/mm/init_32.c
+++ b/arch/x86/mm/init_32.c
@@ -865,10 +865,8 @@ void arch_remove_memory(int nid, u64 start, u64 size=
,
 {
 	unsigned long start_pfn =3D start >> PAGE_SHIFT;
 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
-	struct zone *zone;
=20
-	zone =3D page_zone(pfn_to_page(start_pfn));
-	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pages(start_pfn, nr_pages, altmap);
 }
 #endif
=20
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index a6b5c653727b..b8541d77452c 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1212,10 +1212,8 @@ void __ref arch_remove_memory(int nid, u64 start, =
u64 size,
 {
 	unsigned long start_pfn =3D start >> PAGE_SHIFT;
 	unsigned long nr_pages =3D size >> PAGE_SHIFT;
-	struct page *page =3D pfn_to_page(start_pfn) + vmem_altmap_offset(altma=
p);
-	struct zone *zone =3D page_zone(page);
=20
-	__remove_pages(zone, start_pfn, nr_pages, altmap);
+	__remove_pages(start_pfn, nr_pages, altmap);
 	kernel_physical_mapping_remove(start, start + size);
 }
 #endif /* CONFIG_MEMORY_HOTPLUG */
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplu=
g.h
index f46ea71b4ffd..f75d9483864f 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -125,8 +125,8 @@ static inline bool movable_node_is_enabled(void)
=20
 extern void arch_remove_memory(int nid, u64 start, u64 size,
 			       struct vmem_altmap *altmap);
-extern void __remove_pages(struct zone *zone, unsigned long start_pfn,
-			   unsigned long nr_pages, struct vmem_altmap *altmap);
+extern void __remove_pages(unsigned long start_pfn, unsigned long nr_pag=
es,
+			   struct vmem_altmap *altmap);
=20
 /* reasonably generic interface to expand the physical pages */
 extern int __add_pages(int nid, unsigned long start_pfn, unsigned long n=
r_pages,
diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
index e88c96cf9d77..7a9719a762fe 100644
--- a/mm/memory_hotplug.c
+++ b/mm/memory_hotplug.c
@@ -532,7 +532,6 @@ static void __remove_section(unsigned long pfn, unsig=
ned long nr_pages,
=20
 /**
  * __remove_pages() - remove sections of pages from a zone
- * @zone: zone from which pages need to be removed
  * @pfn: starting pageframe (must be aligned to start of a section)
  * @nr_pages: number of pages to remove (must be multiple of section siz=
e)
  * @altmap: alternative device page map or %NULL if default memmap is us=
ed
@@ -542,12 +541,13 @@ static void __remove_section(unsigned long pfn, uns=
igned long nr_pages,
  * sure that pages are marked reserved and zones are adjust properly by
  * calling offline_pages().
  */
-void __remove_pages(struct zone *zone, unsigned long pfn,
-		    unsigned long nr_pages, struct vmem_altmap *altmap)
+void __remove_pages(unsigned long pfn, unsigned long nr_pages,
+		    struct vmem_altmap *altmap)
 {
 	const unsigned long end_pfn =3D pfn + nr_pages;
 	unsigned long cur_nr_pages;
 	unsigned long map_offset =3D 0;
+	struct zone *zone;
=20
 	if (check_pfn_span(pfn, nr_pages, "remove"))
 		return;
diff --git a/mm/memremap.c b/mm/memremap.c
index 8a394552b5bd..7e34f42e5f5a 100644
--- a/mm/memremap.c
+++ b/mm/memremap.c
@@ -138,8 +138,7 @@ static void devm_memremap_pages_release(void *data)
 	mem_hotplug_begin();
 	if (pgmap->type =3D=3D MEMORY_DEVICE_PRIVATE) {
 		pfn =3D PHYS_PFN(res->start);
-		__remove_pages(page_zone(pfn_to_page(pfn)), pfn,
-				 PHYS_PFN(resource_size(res)), NULL);
+		__remove_pages(pfn, PHYS_PFN(resource_size(res)), NULL);
 	} else {
 		arch_remove_memory(nid, res->start, resource_size(res),
 				pgmap_altmap(pgmap));
--=20
2.21.0


