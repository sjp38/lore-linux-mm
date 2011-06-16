Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id AABF56B0012
	for <linux-mm@kvack.org>; Thu, 16 Jun 2011 06:36:11 -0400 (EDT)
Date: Thu, 16 Jun 2011 11:35:59 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: mmotm 2011-06-15-16-56 uploaded (mm/page_cgroup.c)
Message-ID: <20110616103559.GA5244@suse.de>
References: <201106160034.p5G0Y4dr028904@imap1.linux-foundation.org>
 <20110615214917.a7dce8e6.randy.dunlap@oracle.com>
 <20110616172819.1e2d325c.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20110616172819.1e2d325c.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>, dave@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org

On Thu, Jun 16, 2011 at 05:28:19PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 15 Jun 2011 21:49:17 -0700
> Randy Dunlap <randy.dunlap@oracle.com> wrote:
> 
> > On Wed, 15 Jun 2011 16:56:49 -0700 akpm@linux-foundation.org wrote:
> > 
> > > The mm-of-the-moment snapshot 2011-06-15-16-56 has been uploaded to
> > > 
> > >    http://userweb.kernel.org/~akpm/mmotm/
> > > 
> > > and will soon be available at
> > >    git://zen-kernel.org/kernel/mmotm.git
> > > or
> > >    git://git.cmpxchg.org/linux-mmotm.git
> > > 
> > > It contains the following patches against 3.0-rc3:
> > 
> > 
> > (x86_64 build:)
> > 
> > mm/page_cgroup.c: In function 'page_cgroup_init':
> > mm/page_cgroup.c:308: error: implicit declaration of function 'node_start_pfn'
> > mm/page_cgroup.c:309: error: implicit declaration of function 'node_end_pfn'
> > 
> > 
> 
> Bug fix is here. Added CC to Mel to get review.
> ==
> From add3b670119f1c1f762194b432d3997d595bc213 Mon Sep 17 00:00:00 2001
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Date: Thu, 16 Jun 2011 17:28:07 +0900
> Subject: [PATCH] Fix node_start/end_pfn() definition for mm/page_cgroup.c
> 
> commit 21a3c96 uses node_start/end_pfn(nid) for detection start/end
> of nodes. But, it's not defined in linux/mmzone.h but defined in
> /arch/???/include/mmzone.h which is included only under
> CONFIG_NEED_MULTIPLE_NODES=y.
> 
> Then, we see
> mm/page_cgroup.c: In function 'page_cgroup_init':
> mm/page_cgroup.c:308: error: implicit declaration of function 'node_start_pfn'
> mm/page_cgroup.c:309: error: implicit declaration of function 'node_end_pfn'
> 
> So, fixing page_cgroup.c is an idea...
> 
> But node_start_pfn()/node_end_pfn() is a very generic macro and
> should be implemented in the same manner for all archs.
> (m32r has different implementation...)
> 

I would expect node_start_pfn to always be the equivalent of
NODE_DATA(nid)->node_start_pfn and that does appear to be case even
though it is not universally defined;

alpha/include/asm/mmzone.h:#define node_start_pfn(nid) (NODE_DATA(nid)->node_start_pfn)
m32r/include/asm/mmzone.h:#define node_start_pfn(nid) (NODE_DATA(nid)->node_start_pfn)
parisc/include/asm/mmzone.h:#define node_start_pfn(nid) (NODE_DATA(nid)->node_start_pfn)
powerpc/include/asm/mmzone.h:#define node_start_pfn(nid) (NODE_DATA(nid)->node_start_pfn)
sh/include/asm/mmzone.h:#define node_start_pfn(nid) (NODE_DATA(nid)->node_start_pfn)
sparc/include/asm/mmzone.h:#define node_start_pfn(nid) (NODE_DATA(nid)->node_start_pfn)
tile/include/asm/mmzone.h:#define node_start_pfn(nid) (NODE_DATA(nid)->node_start_pfn)
x86/include/asm/mmzone_32.h:#define node_start_pfn(nid) (NODE_DATA(nid)->node_start_pfn)
x86/include/asm/mmzone_64.h:#define node_start_pfn(nid) (NODE_DATA(nid)->node_start_pfn)

Similarly I would always expect node_end_pfn to be related to
node_spanned_pages which is true of x86, tile, sh and parisc. sparc
and powerpc uses node_end_pfn which is a good trick because that
is not a member of pglist_data (suspect they do not build on
!CONFIG_NEED_MULTIPLE_NODES?).

m32r does differ from everyone else in that it's
__pgdat->node_start_pfn + __pgdat->node_spanned_pages - 1 and this was
the case when it was introduced in 2004. It's not explained why it is
like this but I suspect it's a mistake and I think your cleanup is
appropriate.

> This patch removes definitions of node_start/end_pfn() in each archs
> and defines a unified one in linux/mmzone.h. It's not under
> CONFIG_NEED_MULTIPLE_NODES, now.
> 

Does anyone remember *why* this did not happen in the first place? I
can't think of a good reason so I've cc'd Dave Hansen as he might
remember.

Would it also be worth cleaning up users of node_spanned_pages to
use node_end_pfn in mm/ where appropriate rather than having a mix
of spanned_pages and node_end_pfn?

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

For the most part, it looks good! I haven't compile-tested this but
I did spot one one problem unfortunately;

> <SNIP>
> diff --git a/arch/x86/include/asm/mmzone_32.h b/arch/x86/include/asm/mmzone_32.h
> index 5e83a41..224e8c5 100644
> --- a/arch/x86/include/asm/mmzone_32.h
> +++ b/arch/x86/include/asm/mmzone_32.h
> @@ -48,17 +48,6 @@ static inline int pfn_to_nid(unsigned long pfn)
>  #endif
>  }
>  
> -/*
> - * Following are macros that each numa implmentation must define.
> - */
> -
> -#define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
> -#define node_end_pfn(nid)						\
> -({									\
> -	pg_data_t *__pgdat = NODE_DATA(nid);				\
> -	__pgdat->node_start_pfn + __pgdat->node_spanned_pages;		\
> -})
> -
>  static inline int pfn_valid(int pfn)
>  {
>  	int nid = pfn_to_nid(pfn);
> diff --git a/arch/x86/include/asm/mmzone_64.h b/arch/x86/include/asm/mmzone_64.h
> index b3f88d7..129d9aa 100644
> --- a/arch/x86/include/asm/mmzone_64.h
> +++ b/arch/x86/include/asm/mmzone_64.h
> @@ -13,8 +13,5 @@ extern struct pglist_data *node_data[];
>  
>  #define NODE_DATA(nid)		(node_data[nid])
>  
> -#define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
> -#define node_end_pfn(nid)       (NODE_DATA(nid)->node_start_pfn +	\
> -				 NODE_DATA(nid)->node_spanned_pages)
>  #endif
>  #endif /* _ASM_X86_MMZONE_64_H */
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index c928dac..892862e 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -647,6 +647,9 @@ typedef struct pglist_data {
>  #endif
>  #define nid_page_nr(nid, pagenr) 	pgdat_page_nr(NODE_DATA(nid),(pagenr))
>  
> +#define node_start_pfn(nid)	(NODE_DATA(nid)->node_start_pfn)
> +#define node_end_pfn(nid)	(node_start_pfn(nid) + node_spanned_pages(nid))
> +

A caller that does node_end_pfn(nid++) will get a nasty surprise
due to side-effects. I know architectures currently get this wrong
including x86_64 but we might as well fix it up now. The definition
in arch/x86/include/asm/mmzone_32.h is immune to side-effects and
might be a better choice despite the use of a temporary variable.

>  #include <linux/memory_hotplug.h>
>  
>  extern struct mutex zonelists_mutex;
> -- 
> 1.7.4.1
> 
> 

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
