Subject: Re: memory hotplug and mem=
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20041007170138.GC15186@logos.cnet>
References: <20041001182221.GA3191@logos.cnet>
	 <4160F483.3000309@jp.fujitsu.com> <20041007155854.GC14614@logos.cnet>
	 <1097172146.22025.29.camel@localhost>  <20041007170138.GC15186@logos.cnet>
Content-Type: text/plain
Message-Id: <1097180757.25526.7.camel@localhost>
Mime-Version: 1.0
Date: Thu, 07 Oct 2004 13:25:57 -0700
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Cc: Hiroyuki KAMEZAWA <kamezawa.hiroyu@jp.fujitsu.com>, IWAMOTO Toshihiro <iwamoto@valinux.co.jp>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Turns out that there are a few invalid uses of pfn_to_page() in the
normal code.  If you hand-apply the following chunks, it gets a bit
farther into boot.  These aren't permanent fixes.  We really need a
last_lowmem_pfn instead of highstart_pfn.

 static void __init set_max_mapnr_init(void)
 {
 #ifdef CONFIG_HIGHMEM
-       highmem_start_page = pfn_to_page(highstart_pfn);
+       highmem_start_page = pfn_to_page(highstart_pfn-1);
        max_mapnr = num_physpages = highend_pfn;
 #else
+++ memhotplug-dave/arch/i386/mm/pageattr.c     2004-10-07 13:22:41.000000000 -0700
@@ -109,7 +109,7 @@ __change_page_attr(struct page *page, pg
        struct page *kpte_page;

 #ifdef CONFIG_HIGHMEM
-       if (page >= highmem_start_page)
+       if (page > highmem_start_page)
                BUG();
 #endif


-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
