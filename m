Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 032E86B0390
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 13:59:20 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id p64so11212578wrb.18
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 10:59:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v74si9197707wmf.84.2017.04.07.10.59.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 07 Apr 2017 10:59:18 -0700 (PDT)
Date: Fri, 7 Apr 2017 19:59:12 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [HMM 01/16] mm/memory/hotplug: add memory type parameter to
 arch_add/remove_memory
Message-ID: <20170407175912.GL16413@dhcp22.suse.cz>
References: <20170405204026.3940-1-jglisse@redhat.com>
 <20170405204026.3940-2-jglisse@redhat.com>
 <20170407121349.GB16392@dhcp22.suse.cz>
 <20170407143246.GA15098@redhat.com>
 <20170407144504.GG16413@dhcp22.suse.cz>
 <20170407145740.GA15335@redhat.com>
 <20170407151105.GH16413@dhcp22.suse.cz>
 <20170407160959.GA15945@redhat.com>
 <20170407163737.GI16413@dhcp22.suse.cz>
 <20170407171055.GA16527@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170407171055.GA16527@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Nellans <dnellans@nvidia.com>, Russell King <linux@armlinux.org.uk>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Yoshinori Sato <ysato@users.sourceforge.jp>, Rich Felker <dalias@libc.org>, Chris Metcalf <cmetcalf@mellanox.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>

On Fri 07-04-17 13:10:59, Jerome Glisse wrote:
> On Fri, Apr 07, 2017 at 06:37:37PM +0200, Michal Hocko wrote:
> > On Fri 07-04-17 12:10:00, Jerome Glisse wrote:
[...]
> > > No guaranteed so yes i somewhat care about max_pfn, i do not care about
> > > any of its existing user last time i check but it might matter for some
> > > new user.
> > 
> > OK, then we can add add_pages() which would do __add_pages by default
> > (#ifndef ARCH_HAS_ADD_PAGES) and x86 would override it do also call
> > update_end_of_memory_vars. This sounds easier to me than updating all
> > the archs and add something that most of them do not really care about.
> > 
> > But I will not insist. If you think that your approach is better I will
> > not object.
> 
> Something like attached patch ?

No I meant something like the diff below but maybe even that is too
excessive.
 
> > 
> > Btw. is your series reviewed and ready to be applied to the mm tree? I
> > planed to post mine on Monday so I would like to know how do we
> > coordinate. I rebase on topo of yours or vice versa.
> 
> Well v18 core patches were review by Mel, i did include all of his comment
> in v19 (i don't think i did miss any). I think Dan still want to look at
> patch 1 and 3 for ZONE_DEVICE.
> 
> But i always welcome more review. I know Anshuman replied to this patch
> to improve a comments. Balbir had issue on powerpc because iomem_resource.end
> isn't clamped to MAX_PHYSMEM_BITS But that is all review i got so far on v19.
> 
> I don't mind rebasing on top of your patchset. What ever is easier for
> Andrew i guess.

Well, considering that my patchset is changing the behavior of the core
of the memory hotplug I would prefer if it could go first and add new
user on top. But I realize that you are maintaining your series for a
_long_ time so I would completely understand if you wouldn't be
impressed by another rebase...

If you are OK with rebasing and I will help you with that as much as I
can I would be really grateful.

---
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 69188841717a..66e74928c2f0 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -2260,6 +2260,10 @@ config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 	depends on X86_64 || (X86_32 && HIGHMEM)
 
+config ARCH_HAS_ADD_PAGES
+	def_bool y
+	depends on X86_64 && ARCH_ENABLE_MEMORY_HOTPLUG
+
 config ARCH_ENABLE_MEMORY_HOTREMOVE
 	def_bool y
 	depends on MEMORY_HOTPLUG
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 754d47cb2847..ed1bb63d8f90 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -626,9 +626,9 @@ void __init paging_init(void)
  * After memory hotplug the variables max_pfn, max_low_pfn and high_memory need
  * updating.
  */
-static void  update_end_of_memory_vars(u64 start, u64 size)
+static void  update_end_of_memory_vars(u64 start_pfn, u64 nr_pages)
 {
-	unsigned long end_pfn = PFN_UP(start + size);
+	unsigned long end_pfn = start_pfn + nr_pages;
 
 	if (end_pfn > max_pfn) {
 		max_pfn = end_pfn;
@@ -637,22 +637,29 @@ static void  update_end_of_memory_vars(u64 start, u64 size)
 	}
 }
 
-int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+int add_pages(int nid, unsigned long start_pfn,
+	unsigned long nr_pages, bool want_memblock)
 {
-	unsigned long start_pfn = start >> PAGE_SHIFT;
-	unsigned long nr_pages = size >> PAGE_SHIFT;
 	int ret;
 
-	init_memory_mapping(start, start + size);
-
 	ret = __add_pages(nid, start_pfn, nr_pages, want_memblock);
 	WARN_ON_ONCE(ret);
 
 	/* update max_pfn, max_low_pfn and high_memory */
-	update_end_of_memory_vars(start, size);
+	update_end_of_memory_vars(start_pfn, nr_pages);
 
 	return ret;
 }
+
+int arch_add_memory(int nid, u64 start, u64 size, bool want_memblock)
+{
+	unsigned long start_pfn = start >> PAGE_SHIFT;
+	unsigned long nr_pages = size >> PAGE_SHIFT;
+
+	init_memory_mapping(start, start + size);
+
+	return add_pages(nid, start_pfn, nr_pages, want_memblock);
+}
 EXPORT_SYMBOL_GPL(arch_add_memory);
 
 #define PAGE_INUSE 0xFD
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index a9985f6c460a..a0973fc80e60 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -113,6 +113,14 @@ extern int __remove_pages(struct zone *zone, unsigned long start_pfn,
 extern int __add_pages(int nid, unsigned long start_pfn,
 	unsigned long nr_pages, bool want_memblock);
 
+#ifndef CONFIG_ARCH_HAS_ADD_PAGES
+static inline int add_pages(int nid, unsigned long start_pfn,
+	unsigned long nr_pages, bool want_memblock)
+{
+	return __add_pages(nid, start_pfn, nr_pages, want_memblock);
+}
+#endif
+
 #ifdef CONFIG_NUMA
 extern int memory_add_physaddr_to_nid(u64 start);
 #else
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
