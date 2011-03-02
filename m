Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id AB94C8D0039
	for <linux-mm@kvack.org>; Tue,  1 Mar 2011 19:06:26 -0500 (EST)
Date: Tue, 1 Mar 2011 16:05:50 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] page_cgroup: Reduce allocation overhead for
 page_cgroup array for CONFIG_SPARSEMEM
Message-Id: <20110301160550.0dd3217e.akpm@linux-foundation.org>
In-Reply-To: <20110228100920.GD4648@tiehlicka.suse.cz>
References: <20110228100920.GD4648@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dave Hansen <dave@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Mon, 28 Feb 2011 11:09:20 +0100
Michal Hocko <mhocko@suse.cz> wrote:

> Hi Andrew,
> could you consider the patch bellow, please?
> The patch was discussed at https://lkml.org/lkml/2011/2/23/232
> ---
> >From 7e5b1e7043605891dacd9e32f19985bc675292f5 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.cz>
> Date: Thu, 24 Feb 2011 11:25:44 +0100
> Subject: [PATCH 1/2] page_cgroup: Reduce allocation overhead for page_cgroup array for CONFIG_SPARSEMEM
> 
> Currently we are allocating a single page_cgroup array per memory
> section (stored in mem_section->base) when CONFIG_SPARSEMEM is selected.
> This is correct but memory inefficient solution because the allocated
> memory (unless we fall back to vmalloc) is not kmalloc friendly:
>         - 32b - 16384 entries (20B per entry) fit into 327680B so the
>           524288B slab cache is used
>         - 32b with PAE - 131072 entries with 2621440B fit into 4194304B
>         - 64b - 32768 entries (40B per entry) fit into 2097152 cache
> 
> This is ~37% wasted space per memory section and it sumps up for the
> whole memory. On a x86_64 machine it is something like 6MB per 1GB of
> RAM.
> 
> We can reduce the internal fragmentation by using alloc_pages_exact
> which allocates PAGE_SIZE aligned blocks so we will get down to <4kB
> wasted memory per section which is much better.
> 
> We still need a fallback to vmalloc because we have no guarantees that
> we will have a continuous memory of that size (order-10) later on during
> the hotplug events.
> 
> ...
>

> @@ -114,19 +140,9 @@ static int __init_refok init_section_page_cgroup(unsigned long pfn)
>  	int nid, index;
>  
>  	if (!section->page_cgroup) {
> -		nid = page_to_nid(pfn_to_page(pfn));
>  		table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
> -		VM_BUG_ON(!slab_is_available());
> -		if (node_state(nid, N_HIGH_MEMORY)) {
> -			base = kmalloc_node(table_size,
> -				GFP_KERNEL | __GFP_NOWARN, nid);
> -			if (!base)
> -				base = vmalloc_node(table_size, nid);
> -		} else {
> -			base = kmalloc(table_size, GFP_KERNEL | __GFP_NOWARN);
> -			if (!base)
> -				base = vmalloc(table_size);
> -		}
> +		nid = page_to_nid(pfn_to_page(pfn));
> +		base = alloc_page_cgroup(table_size, nid);
>  		/*
>  		 * The value stored in section->page_cgroup is (base - pfn)
>  		 * and it does not point to the memory block allocated above,

This conflicts with
memcg-remove-direct-page_cgroup-to-page-pointer.patch, which did

 static int __init_refok init_section_page_cgroup(unsigned long pfn)
 {
-	struct mem_section *section = __pfn_to_section(pfn);
 	struct page_cgroup *base, *pc;
+	struct mem_section *section;
 	unsigned long table_size;
+	unsigned long nr;
 	int nid, index;
 
-	if (!section->page_cgroup) {
-		nid = page_to_nid(pfn_to_page(pfn));
-		table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
-		VM_BUG_ON(!slab_is_available());
-		if (node_state(nid, N_HIGH_MEMORY)) {
-			base = kmalloc_node(table_size,
-				GFP_KERNEL | __GFP_NOWARN, nid);
-			if (!base)
-				base = vmalloc_node(table_size, nid);
-		} else {
-			base = kmalloc(table_size, GFP_KERNEL | __GFP_NOWARN);
-			if (!base)
-				base = vmalloc(table_size);
-		}
-		/*
-		 * The value stored in section->page_cgroup is (base - pfn)
-		 * and it does not point to the memory block allocated above,
-		 * causing kmemleak false positives.
-		 */
-		kmemleak_not_leak(base);
+	nr = pfn_to_section_nr(pfn);
+	section = __nr_to_section(nr);
+
+	if (section->page_cgroup)
+		return 0;
+
+	nid = page_to_nid(pfn_to_page(pfn));
+	table_size = sizeof(struct page_cgroup) * PAGES_PER_SECTION;
+	VM_BUG_ON(!slab_is_available());
+	if (node_state(nid, N_HIGH_MEMORY)) {
+		base = kmalloc_node(table_size,
+				    GFP_KERNEL | __GFP_NOWARN, nid);
+		if (!base)
+			base = vmalloc_node(table_size, nid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
