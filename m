Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 38FBF280281
	for <linux-mm@kvack.org>; Sat,  4 Jul 2015 14:10:21 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so122178310wib.1
        for <linux-mm@kvack.org>; Sat, 04 Jul 2015 11:10:20 -0700 (PDT)
Received: from johanna1.inet.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id 15si21439812wjx.108.2015.07.04.11.10.18
        for <linux-mm@kvack.org>;
        Sat, 04 Jul 2015 11:10:19 -0700 (PDT)
Date: Sat, 4 Jul 2015 21:10:08 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mm/page_alloc.c:247:6: warning: unused variable 'nid'
Message-ID: <20150704181008.GA1374@node.dhcp.inet.fi>
References: <201507041743.GoTZWMrj%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201507041743.GoTZWMrj%fengguang.wu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kbuild test robot <fengguang.wu@intel.com>
Cc: Mel Gorman <mgorman@suse.de>, kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

On Sat, Jul 04, 2015 at 05:26:47PM +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> head:   14a6f1989dae9445d4532941bdd6bbad84f4c8da
> commit: 3b242c66ccbd60cf47ab0e8992119d9617548c23 x86: mm: enable deferred struct page initialisation on x86-64
> date:   3 days ago
> config: x86_64-randconfig-x006-201527 (attached as .config)
> reproduce:
>   git checkout 3b242c66ccbd60cf47ab0e8992119d9617548c23
>   # save the attached .config to linux build tree
>   make ARCH=x86_64 
> 
> All warnings (new ones prefixed by >>):
> 
>    mm/page_alloc.c: In function 'early_page_uninitialised':
> >> mm/page_alloc.c:247:6: warning: unused variable 'nid' [-Wunused-variable]
>      int nid = early_pfn_to_nid(pfn);

We can silence the warning with something like patch below. But I'm not
sure it worth it.

diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
index 754c25966a0a..746a6a7b0535 100644
--- a/include/linux/mmzone.h
+++ b/include/linux/mmzone.h
@@ -911,7 +911,7 @@ extern char numa_zonelist_order[];
 #ifndef CONFIG_NEED_MULTIPLE_NODES
 
 extern struct pglist_data contig_page_data;
-#define NODE_DATA(nid)         (&contig_page_data)
+#define NODE_DATA(nid)         ((void)nid, &contig_page_data)
 #define NODE_MEM_MAP(nid)      mem_map
 
 #else /* CONFIG_NEED_MULTIPLE_NODES */
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
