Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx195.postini.com [74.125.245.195])
	by kanga.kvack.org (Postfix) with SMTP id 7DC346B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 09:21:01 -0500 (EST)
Date: Tue, 15 Jan 2013 15:20:56 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH V2] memory-hotplug: revert
 register_page_bootmem_info_node() to empty when platform related code is not
 implemented
Message-ID: <20130115142056.GC21725@dhcp22.suse.cz>
References: <1358245203-4181-1-git-send-email-linfeng@cn.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1358245203-4181-1-git-send-email-linfeng@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Lin Feng <linfeng@cn.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, kamezawa.hiroyu@jp.fujitsu.com, mel@csn.ul.ie, minchan@kernel.org, aquini@redhat.com, wency@cn.fujitsu.com, jiang.liu@huawei.com, laijs@cn.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, linux-kernel@vger.kernel.org

On Tue 15-01-13 18:20:03, Lin Feng wrote:
> Memory-hotplug codes for x86_64 have been implemented by patchset:
> https://lkml.org/lkml/2013/1/9/124
> While other platforms haven't been completely implemented yet.
> 
> If we enable both CONFIG_MEMORY_HOTPLUG_SPARSE and CONFIG_SPARSEMEM_VMEMMAP,
> register_page_bootmem_info_node() may be buggy, which is a hotplug generic
> function but falling back to call platform related function
> register_page_bootmem_memmap().
> 
> Other platforms such as powerpc it's not implemented, so on such platforms,
> revert them to empty as they were before.
> 
> It's implemented by adding a new Kconfig option named
> CONFIG_HAVE_BOOTMEM_INFO_NODE, which will be automatically selected by
> supported archs(currently only on x86_64).
> 
> Reported-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Lin Feng <linfeng@cn.fujitsu.com>
> ---
> ChangeLog v1->v2:
> - Add a Kconfig option named HAVE_BOOTMEM_INFO_NODE suggested by Michal, which
>   will be automatically selected by supported archs(currently only on x86_64).
> ---
>  mm/Kconfig          |    8 ++++++++
>  mm/memory_hotplug.c |    7 +++++++
>  2 files changed, 15 insertions(+), 0 deletions(-)
> 
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 278e3ab..f8c5799 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -162,10 +162,18 @@ config MOVABLE_NODE
>  	  Say Y here if you want to hotplug a whole node.
>  	  Say N here if you want kernel to use memory on all nodes evenly.
>  
> +#
> +# Only be set on architectures that have completely implemented memory hotplug
> +# feature. If you are not sure, don't touch it.
> +#
> +config HAVE_BOOTMEM_INFO_NODE
> +	def_bool n
> +
>  # eventually, we can have this option just 'select SPARSEMEM'
>  config MEMORY_HOTPLUG
>  	bool "Allow for memory hot-add"
>  	select MEMORY_ISOLATION
> +	select HAVE_BOOTMEM_INFO_NODE if X86_64
>  	depends on SPARSEMEM || X86_64_ACPI_NUMA
>  	depends on HOTPLUG && ARCH_ENABLE_MEMORY_HOTPLUG
>  	depends on (IA64 || X86 || PPC_BOOK3S_64 || SUPERH || S390)
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index 8aa2b56..ef7a5c8 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -189,6 +189,7 @@ static void register_page_bootmem_info_section(unsigned long start_pfn)
>  }
>  #endif
>  
> +#ifdef CONFIG_HAVE_BOOTMEM_INFO_NODE
>  void register_page_bootmem_info_node(struct pglist_data *pgdat)
>  {
>  	unsigned long i, pfn, end_pfn, nr_pages;
> @@ -230,6 +231,12 @@ void register_page_bootmem_info_node(struct pglist_data *pgdat)
>  			register_page_bootmem_info_section(pfn);
>  	}
>  }
> +#else
> +void register_page_bootmem_info_node(struct pglist_data *pgdat)
> +{
> +	/* TODO */
> +}

I think that TODO is misleading here because the function should be
empty if !CONFIG_HAVE_BOOTMEM_INFO_NODE. I would also suggest updating
include/linux/memory_hotplug.h and removing the arch specific functions
without any implementation. Something like (untested) patch below:
---
diff --git a/arch/ia64/mm/discontig.c b/arch/ia64/mm/discontig.c
index 882a0fd..cb5e1ff 100644
--- a/arch/ia64/mm/discontig.c
+++ b/arch/ia64/mm/discontig.c
@@ -827,9 +827,4 @@ void vmemmap_free(struct page *memmap, unsigned long nr_pages)
 {
 }
 
-void register_page_bootmem_memmap(unsigned long section_nr,
-				  struct page *start_page, unsigned long size)
-{
-	/* TODO */
-}
 #endif
diff --git a/arch/powerpc/mm/init_64.c b/arch/powerpc/mm/init_64.c
index 2969591..7e2246f 100644
--- a/arch/powerpc/mm/init_64.c
+++ b/arch/powerpc/mm/init_64.c
@@ -302,10 +302,5 @@ void vmemmap_free(struct page *memmap, unsigned long nr_pages)
 {
 }
 
-void register_page_bootmem_memmap(unsigned long section_nr,
-				  struct page *start_page, unsigned long size)
-{
-	/* TODO */
-}
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
diff --git a/arch/s390/mm/vmem.c b/arch/s390/mm/vmem.c
index 4073156..139bb48 100644
--- a/arch/s390/mm/vmem.c
+++ b/arch/s390/mm/vmem.c
@@ -240,12 +240,6 @@ void vmemmap_free(struct page *memmap, unsigned long nr_pages)
 {
 }
 
-void register_page_bootmem_memmap(unsigned long section_nr,
-				  struct page *start_page, unsigned long size)
-{
-	/* TODO */
-}
-
 /*
  * Add memory segment to the segment list if it doesn't overlap with
  * an already present segment.
diff --git a/arch/sparc/mm/init_64.c b/arch/sparc/mm/init_64.c
index f0ef3c2..07571a27 100644
--- a/arch/sparc/mm/init_64.c
+++ b/arch/sparc/mm/init_64.c
@@ -2236,11 +2236,6 @@ void vmemmap_free(struct page *memmap, unsigned long nr_pages)
 {
 }
 
-void register_page_bootmem_memmap(unsigned long section_nr,
-				  struct page *start_page, unsigned long size)
-{
-	/* TODO */
-}
 #endif /* CONFIG_SPARSEMEM_VMEMMAP */
 
 static void prot_init_common(unsigned long page_none,
diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index d1b8257..defe6ee 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -1317,7 +1317,7 @@ vmemmap_populate(struct page *start_page, unsigned long size, int node)
 	return 0;
 }
 
-#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
+#if defined(CONFIG_MEMORY_HOTPLUG_SPARSE) && defined(CONFIG_HAVE_BOOTMEM_INFO_NODE)
 void register_page_bootmem_memmap(unsigned long section_nr,
 				  struct page *start_page, unsigned long size)
 {
diff --git a/include/linux/memory_hotplug.h b/include/linux/memory_hotplug.h
index f60e728..34b0511 100644
--- a/include/linux/memory_hotplug.h
+++ b/include/linux/memory_hotplug.h
@@ -174,7 +174,13 @@ static inline void arch_refresh_nodedata(int nid, pg_data_t *pgdat)
 #endif /* CONFIG_NUMA */
 #endif /* CONFIG_HAVE_ARCH_NODEDATA_EXTENSION */
 
+#ifdef CONFIG_HAVE_BOOTMEM_INFO_NODE
 extern void register_page_bootmem_info_node(struct pglist_data *pgdat);
+#else
+static void register_page_bootmem_info_node(struct pglist_data *pgdat)
+{
+}
+#endif
 extern void put_page_bootmem(struct page *page);
 extern void get_page_bootmem(unsigned long ingo, struct page *page,
 			     unsigned long type);
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
