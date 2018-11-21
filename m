Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id EB7E06B2356
	for <linux-mm@kvack.org>; Tue, 20 Nov 2018 21:44:52 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id j125so5316556qke.12
        for <linux-mm@kvack.org>; Tue, 20 Nov 2018 18:44:52 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s29si1271677qth.384.2018.11.20.18.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Nov 2018 18:44:51 -0800 (PST)
Date: Tue, 20 Nov 2018 21:44:48 -0500 (EST)
From: Pankaj Gupta <pagupta@redhat.com>
Message-ID: <1587169425.35444537.1542768288930.JavaMail.zimbra@redhat.com>
In-Reply-To: <20181119101616.8901-3-david@redhat.com>
References: <20181119101616.8901-1-david@redhat.com> <20181119101616.8901-3-david@redhat.com>
Subject: Re: [PATCH v1 2/8] mm: convert PG_balloon to PG_offline
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, devel@linuxdriverproject.org, linux-fsdevel@vger.kernel.org, linux-pm@vger.kernel.org, xen-devel@lists.xenproject.org, kexec-ml <kexec@lists.infradead.org>, pv-drivers@vmware.com, Jonathan Corbet <corbet@lwn.net>, Alexey Dobriyan <adobriyan@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Christian Hansen <chansen3@cisco.com>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, Matthew Wilcox <willy@infradead.org>, "Michael S. Tsirkin" <mst@redhat.com>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Miles Chen <miles.chen@mediatek.com>, David Rientjes <rientjes@google.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Kazuhito Hagio <k-hagio@ab.jp.nec.com>


> 
> PG_balloon was introduced to implement page migration/compaction for pages
> inflated in virtio-balloon. Nowadays, it is only a marker that a page is
> part of virtio-balloon and therefore logically offline.
> 
> We also want to make use of this flag in other balloon drivers - for
> inflated pages or when onlining a section but keeping some pages offline
> (e.g. used right now by XEN and Hyper-V via set_online_page_callback()).
> 
> We are going to expose this flag to dump tools like makedumpfile. But
> instead of exposing PG_balloon, let's generalize the concept of marking
> pages as logically offline, so it can be reused for other purposes
> later on.
> 
> Rename PG_balloon to PG_offline. This is an indicator that the page is
> logically offline, the content stale and that it should not be touched
> (e.g. a hypervisor would have to allocate backing storage in order for the
> guest to dump an unused page).  We can then e.g. exclude such pages from
> dumps.
> 
> We replace and reuse KPF_BALLOON (23), as this shouldn't really harm
> (and for now the semantics stay the same).  In following patches, we will
> make use of this bit also in other balloon drivers. While at it, document
> PGTABLE.
> 
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: Alexey Dobriyan <adobriyan@gmail.com>
> Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Christian Hansen <chansen3@cisco.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
> Cc: Stephen Rothwell <sfr@canb.auug.org.au>
> Cc: Matthew Wilcox <willy@infradead.org>
> Cc: "Michael S. Tsirkin" <mst@redhat.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Pavel Tatashin <pasha.tatashin@oracle.com>
> Cc: Alexander Duyck <alexander.h.duyck@linux.intel.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: Miles Chen <miles.chen@mediatek.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Kazuhito Hagio <k-hagio@ab.jp.nec.com>
> Signed-off-by: David Hildenbrand <david@redhat.com>
> ---
>  Documentation/admin-guide/mm/pagemap.rst |  9 ++++++---
>  fs/proc/page.c                           |  4 ++--
>  include/linux/balloon_compaction.h       |  8 ++++----
>  include/linux/page-flags.h               | 11 +++++++----
>  include/uapi/linux/kernel-page-flags.h   |  2 +-
>  tools/vm/page-types.c                    |  2 +-
>  6 files changed, 21 insertions(+), 15 deletions(-)
> 
> diff --git a/Documentation/admin-guide/mm/pagemap.rst
> b/Documentation/admin-guide/mm/pagemap.rst
> index 3f7bade2c231..340a5aee9b80 100644
> --- a/Documentation/admin-guide/mm/pagemap.rst
> +++ b/Documentation/admin-guide/mm/pagemap.rst
> @@ -75,9 +75,10 @@ number of times a page is mapped.
>      20. NOPAGE
>      21. KSM
>      22. THP
> -    23. BALLOON
> +    23. OFFLINE
>      24. ZERO_PAGE
>      25. IDLE
> +    26. PGTABLE
>  
>   * ``/proc/kpagecgroup``.  This file contains a 64-bit inode number of the
>     memory cgroup each page is charged to, indexed by PFN. Only available
>     when
> @@ -118,8 +119,8 @@ Short descriptions to the page flags
>      identical memory pages dynamically shared between one or more processes
>  22 - THP
>      contiguous pages which construct transparent hugepages
> -23 - BALLOON
> -    balloon compaction page
> +23 - OFFLINE
> +    page is logically offline
>  24 - ZERO_PAGE
>      zero page for pfn_zero or huge_zero page
>  25 - IDLE
> @@ -128,6 +129,8 @@ Short descriptions to the page flags
>      Note that this flag may be stale in case the page was accessed via
>      a PTE. To make sure the flag is up-to-date one has to read
>      ``/sys/kernel/mm/page_idle/bitmap`` first.
> +26 - PGTABLE
> +    page is in use as a page table
>  
>  IO related page flags
>  ---------------------
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index 6c517b11acf8..378401af4d9d 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -152,8 +152,8 @@ u64 stable_page_flags(struct page *page)
>  	else if (page_count(page) == 0 && is_free_buddy_page(page))
>  		u |= 1 << KPF_BUDDY;
>  
> -	if (PageBalloon(page))
> -		u |= 1 << KPF_BALLOON;
> +	if (PageOffline(page))
> +		u |= 1 << KPF_OFFLINE;
>  	if (PageTable(page))
>  		u |= 1 << KPF_PGTABLE;
>  
> diff --git a/include/linux/balloon_compaction.h
> b/include/linux/balloon_compaction.h
> index cbe50da5a59d..f111c780ef1d 100644
> --- a/include/linux/balloon_compaction.h
> +++ b/include/linux/balloon_compaction.h
> @@ -95,7 +95,7 @@ extern int balloon_page_migrate(struct address_space
> *mapping,
>  static inline void balloon_page_insert(struct balloon_dev_info *balloon,
>  				       struct page *page)
>  {
> -	__SetPageBalloon(page);
> +	__SetPageOffline(page);
>  	__SetPageMovable(page, balloon->inode->i_mapping);
>  	set_page_private(page, (unsigned long)balloon);
>  	list_add(&page->lru, &balloon->pages);
> @@ -111,7 +111,7 @@ static inline void balloon_page_insert(struct
> balloon_dev_info *balloon,
>   */
>  static inline void balloon_page_delete(struct page *page)
>  {
> -	__ClearPageBalloon(page);
> +	__ClearPageOffline(page);
>  	__ClearPageMovable(page);
>  	set_page_private(page, 0);
>  	/*
> @@ -141,13 +141,13 @@ static inline gfp_t balloon_mapping_gfp_mask(void)
>  static inline void balloon_page_insert(struct balloon_dev_info *balloon,
>  				       struct page *page)
>  {
> -	__SetPageBalloon(page);
> +	__SetPageOffline(page);
>  	list_add(&page->lru, &balloon->pages);
>  }
>  
>  static inline void balloon_page_delete(struct page *page)
>  {
> -	__ClearPageBalloon(page);
> +	__ClearPageOffline(page);
>  	list_del(&page->lru);
>  }
>  
> diff --git a/include/linux/page-flags.h b/include/linux/page-flags.h
> index 50ce1bddaf56..f91da3d0a67e 100644
> --- a/include/linux/page-flags.h
> +++ b/include/linux/page-flags.h
> @@ -670,7 +670,7 @@ PAGEFLAG_FALSE(DoubleMap)
>  #define PAGE_TYPE_BASE	0xf0000000
>  /* Reserve		0x0000007f to catch underflows of page_mapcount */
>  #define PG_buddy	0x00000080
> -#define PG_balloon	0x00000100
> +#define PG_offline	0x00000100
>  #define PG_kmemcg	0x00000200
>  #define PG_table	0x00000400
>  
> @@ -700,10 +700,13 @@ static __always_inline void __ClearPage##uname(struct
> page *page)	\
>  PAGE_TYPE_OPS(Buddy, buddy)
>  
>  /*
> - * PageBalloon() is true for pages that are on the balloon page list
> - * (see mm/balloon_compaction.c).
> + * PageOffline() indicates that the pages is logically offline although the
> + * containing section is online. (e.g. inflated in a balloon driver or
> + * not onlined when onlining the section).
> + * The content of these pages is effectively stale. Such pages should not
> + * be touched (read/write/dump/save) except by their owner.
>   */
> -PAGE_TYPE_OPS(Balloon, balloon)
> +PAGE_TYPE_OPS(Offline, offline)
>  
>  /*
>   * If kmemcg is enabled, the buddy allocator will set PageKmemcg() on
> diff --git a/include/uapi/linux/kernel-page-flags.h
> b/include/uapi/linux/kernel-page-flags.h
> index 21b9113c69da..6f2f2720f3ac 100644
> --- a/include/uapi/linux/kernel-page-flags.h
> +++ b/include/uapi/linux/kernel-page-flags.h
> @@ -32,7 +32,7 @@
>  
>  #define KPF_KSM			21
>  #define KPF_THP			22
> -#define KPF_BALLOON		23
> +#define KPF_OFFLINE		23
>  #define KPF_ZERO_PAGE		24
>  #define KPF_IDLE		25
>  #define KPF_PGTABLE		26
> diff --git a/tools/vm/page-types.c b/tools/vm/page-types.c
> index 37908a83ddc2..6c38d3b862e4 100644
> --- a/tools/vm/page-types.c
> +++ b/tools/vm/page-types.c
> @@ -133,7 +133,7 @@ static const char * const page_flag_names[] = {
>  	[KPF_NOPAGE]		= "n:nopage",
>  	[KPF_KSM]		= "x:ksm",
>  	[KPF_THP]		= "t:thp",
> -	[KPF_BALLOON]		= "o:balloon",
> +	[KPF_OFFLINE]		= "o:offline",
>  	[KPF_PGTABLE]		= "g:pgtable",
>  	[KPF_ZERO_PAGE]		= "z:zero_page",
>  	[KPF_IDLE]              = "i:idle_page",
> --
> 2.17.2

Acked-by: Pankaj gupta <pagupta@redhat.com>

> 
> 
