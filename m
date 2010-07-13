Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 6C1A66B02A3
	for <linux-mm@kvack.org>; Mon, 12 Jul 2010 23:24:38 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o6D3OZKw023043
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 13 Jul 2010 12:24:35 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 0590245DE6E
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 12:24:35 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D5E4745DE4D
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 12:24:34 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BF3BB1DB8037
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 12:24:34 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 67D1E1DB803B
	for <linux-mm@kvack.org>; Tue, 13 Jul 2010 12:24:31 +0900 (JST)
Date: Tue, 13 Jul 2010 12:19:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Tight check of pfn_valid on sparsemem
Message-Id: <20100713121947.612bd656.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100712155348.GA2815@barrios-desktop>
References: <20100712155348.GA2815@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux@arm.linux.org.uk, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Shaohua Li <shaohua.li@intel.com>, Yakui Zhao <yakui.zhao@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, arm-kernel@lists.infradead.org, kgene.kim@samsung.com, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Tue, 13 Jul 2010 00:53:48 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Kukjin, Could you test below patch?
> I don't have any sparsemem system. Sorry. 
> 
> -- CUT DOWN HERE --
> 
> Kukjin reported oops happen while he change min_free_kbytes
> http://www.spinics.net/lists/arm-kernel/msg92894.html
> It happen by memory map on sparsemem. 
> 
> The system has a memory map following as. 
>      section 0             section 1              section 2
> 0x20000000-0x25000000, 0x40000000-0x50000000, 0x50000000-0x58000000
> SECTION_SIZE_BITS 28(256M)
> 
> It means section 0 is an incompletely filled section.
> Nontheless, current pfn_valid of sparsemem checks pfn loosely. 
> 
> It checks only mem_section's validation.
> So in above case, pfn on 0x25000000 can pass pfn_valid's validation check.
> It's not what we want. 
> 
> The Following patch adds check valid pfn range check on pfn_valid of sparsemem.
> 
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> Reported-by: Kukjin Kim <kgene.kim@samsung.com>
> 
> P.S) 
> It is just RFC. If we agree with this, I will make the patch on mmotm.
> 
> --
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index b4d109e..6c2147a 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -979,6 +979,8 @@ struct mem_section {
>         struct page_cgroup *page_cgroup;
>         unsigned long pad;
>  #endif
> +       unsigned long start_pfn;
> +       unsigned long end_pfn;
>  };
>  

I have 2 concerns.
 1. This makes mem_section twice. Wasting too much memory and not good for cache.
    But yes, you can put this under some CONFIG which has small number of mem_section[].

 2. This can't be help for a case where a section has multiple small holes.


Then, my proposal for HOLES_IN_MEMMAP sparsemem is below.
==
Some architectures unmap memmap[] for memory holes even with SPARSEMEM.
To handle that, pfn_valid() should check there are really memmap or not.
For that purpose, __get_user() can be used.
This idea is from ia64_pfn_valid().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
---
 include/linux/mmzone.h |   12 ++++++++++++
 mm/sparse.c            |   17 +++++++++++++++++
 2 files changed, 29 insertions(+)

Index: mmotm-2.6.35-0701/include/linux/mmzone.h
===================================================================
--- mmotm-2.6.35-0701.orig/include/linux/mmzone.h
+++ mmotm-2.6.35-0701/include/linux/mmzone.h
@@ -1047,12 +1047,24 @@ static inline struct mem_section *__pfn_
 	return __nr_to_section(pfn_to_section_nr(pfn));
 }
 
+#ifndef CONFIG_ARCH_HAS_HOLES_IN_MEMMAP
 static inline int pfn_valid(unsigned long pfn)
 {
 	if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
 		return 0;
 	return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
 }
+#else
+extern int pfn_valid_mapped(unsigned long pfn);
+static inline int pfn_valid(unsigned long pfn)
+{
+	if (pfn_to_seciton_nr(pfn) >= NR_MEM_SECTIONS)
+		return 0;
+	if (!valid_section(__nr_to_section(pfn_to_section_nr(pfn))))
+		return 0;
+	return pfn_valid_mapped(pfn);
+}
+#endif
 
 static inline int pfn_present(unsigned long pfn)
 {
Index: mmotm-2.6.35-0701/mm/sparse.c
===================================================================
--- mmotm-2.6.35-0701.orig/mm/sparse.c
+++ mmotm-2.6.35-0701/mm/sparse.c
@@ -799,3 +799,20 @@ void sparse_remove_one_section(struct zo
 	free_section_usemap(memmap, usemap);
 }
 #endif
+
+#ifdef CONFIG_ARCH_HAS_HOLES_IN_MEMMAP
+int pfn_valid_mapped(unsigned long pfn)
+{
+	struct page *page = pfn_to_page(pfn);
+	char *lastbyte = (char *)(page+1)-1;
+	char byte;
+
+	if(__get_user(byte, page) != 0)
+		return 0;
+
+	if ((((unsigned long)page) & PAGE_MASK) ==
+	    (((unsigned long)lastbyte) & PAGE_MASK))
+		return 1;
+	return (__get_user(byte,lastbyte) == 0);
+}
+#endif





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
