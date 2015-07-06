Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f178.google.com (mail-ie0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id 32BF72802C8
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 18:05:11 -0400 (EDT)
Received: by iebmu5 with SMTP id mu5so122439868ieb.1
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 15:05:11 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id z5si14537084igg.2.2015.07.06.15.05.10
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Jul 2015 15:05:10 -0700 (PDT)
Date: Mon, 6 Jul 2015 15:05:09 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: mm/page_alloc.c:247:6: warning: unused variable 'nid'
Message-Id: <20150706150509.48abfb09376605d611ceadbe@linux-foundation.org>
In-Reply-To: <20150704181008.GA1374@node.dhcp.inet.fi>
References: <201507041743.GoTZWMrj%fengguang.wu@intel.com>
	<20150704181008.GA1374@node.dhcp.inet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: kbuild test robot <fengguang.wu@intel.com>, Mel Gorman <mgorman@suse.de>, kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>

On Sat, 4 Jul 2015 21:10:08 +0300 "Kirill A. Shutemov" <kirill@shutemov.name> wrote:

> On Sat, Jul 04, 2015 at 05:26:47PM +0800, kbuild test robot wrote:
> > tree:   git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git master
> > head:   14a6f1989dae9445d4532941bdd6bbad84f4c8da
> > commit: 3b242c66ccbd60cf47ab0e8992119d9617548c23 x86: mm: enable deferred struct page initialisation on x86-64
> > date:   3 days ago
> > config: x86_64-randconfig-x006-201527 (attached as .config)
> > reproduce:
> >   git checkout 3b242c66ccbd60cf47ab0e8992119d9617548c23
> >   # save the attached .config to linux build tree
> >   make ARCH=x86_64 
> > 
> > All warnings (new ones prefixed by >>):
> > 
> >    mm/page_alloc.c: In function 'early_page_uninitialised':
> > >> mm/page_alloc.c:247:6: warning: unused variable 'nid' [-Wunused-variable]
> >      int nid = early_pfn_to_nid(pfn);
> 
> We can silence the warning with something like patch below. But I'm not
> sure it worth it.
> 
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index 754c25966a0a..746a6a7b0535 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -911,7 +911,7 @@ extern char numa_zonelist_order[];
>  #ifndef CONFIG_NEED_MULTIPLE_NODES
>  
>  extern struct pglist_data contig_page_data;
> -#define NODE_DATA(nid)         (&contig_page_data)
> +#define NODE_DATA(nid)         ((void)nid, &contig_page_data)
>  #define NODE_MEM_MAP(nid)      mem_map
>  
>  #else /* CONFIG_NEED_MULTIPLE_NODES */

Sigh.  Macros do suck.  If NODE_DATA was a regular old C function this
warning wouldn't occur.  Problem is, we should then rename it to
"node_data" and that would require 246 edits.

I suppose we could compromise and do 

	static inline struct pglist_data *NODE_DATA(int nid)

?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
