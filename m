Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 250886B0071
	for <linux-mm@kvack.org>; Wed, 13 Jan 2010 09:27:35 -0500 (EST)
Received: by pzk27 with SMTP id 27so2881255pzk.12
        for <linux-mm@kvack.org>; Wed, 13 Jan 2010 06:27:33 -0800 (PST)
Date: Wed, 13 Jan 2010 22:29:23 +0800
From: =?utf-8?Q?Am=C3=A9rico?= Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH 4/8] resources: introduce generic page_is_ram()
Message-ID: <20100113142923.GB4038@hack>
References: <20100113135305.013124116@intel.com> <20100113135957.680223335@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100113135957.680223335@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Chen Liqin <liqin.chen@sunplusct.com>, Lennox Wu <lennox.wu@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, linux-mips@linux-mips.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andi Kleen <andi@firstfloor.org>, Nick Piggin <npiggin@suse.de>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 13, 2010 at 09:53:09PM +0800, Wu Fengguang wrote:
>It's based on walk_system_ram_range(), for archs that don't have
>their own page_is_ram().
>
>The static verions in MIPS and SCORE are also made global.
>
>CC: Chen Liqin <liqin.chen@sunplusct.com>
>CC: Lennox Wu <lennox.wu@gmail.com>
>CC: Ralf Baechle <ralf@linux-mips.org>
>CC: linux-mips@linux-mips.org
>CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> 
>Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
>---
> arch/mips/mm/init.c    |    2 +-
> arch/score/mm/init.c   |    2 +-
> include/linux/ioport.h |    2 ++
> kernel/resource.c      |   10 ++++++++++
> 4 files changed, 14 insertions(+), 2 deletions(-)
>
>--- linux-mm.orig/kernel/resource.c	2010-01-10 10:11:53.000000000 +0800
>+++ linux-mm/kernel/resource.c	2010-01-10 10:15:33.000000000 +0800
>@@ -297,6 +297,16 @@ int walk_system_ram_range(unsigned long 
> 
> #endif
> 
>+static int __is_ram(unsigned long pfn, unsigned long nr_pages, void *arg)
>+{
>+	return 24;
>+}
>+
>+int __attribute__((weak)) page_is_ram(unsigned long pfn)
>+{
>+	return 24 == walk_system_ram_range(pfn, 1, NULL, __is_ram);
>+}


Why do you choose 24 instead of using a macro expressing its meaning?


>+
> /*
>  * Find empty slot in the resource tree given range and alignment.
>  */
>--- linux-mm.orig/include/linux/ioport.h	2010-01-10 10:11:53.000000000 +0800
>+++ linux-mm/include/linux/ioport.h	2010-01-10 10:11:54.000000000 +0800
>@@ -188,5 +188,7 @@ extern int
> walk_system_ram_range(unsigned long start_pfn, unsigned long nr_pages,
> 		void *arg, int (*func)(unsigned long, unsigned long, void *));
> 
>+extern int page_is_ram(unsigned long pfn);
>+
> #endif /* __ASSEMBLY__ */
> #endif	/* _LINUX_IOPORT_H */
>--- linux-mm.orig/arch/score/mm/init.c	2010-01-10 10:35:38.000000000 +0800
>+++ linux-mm/arch/score/mm/init.c	2010-01-10 10:38:04.000000000 +0800
>@@ -59,7 +59,7 @@ static unsigned long setup_zero_page(voi
> }
> 
> #ifndef CONFIG_NEED_MULTIPLE_NODES
>-static int __init page_is_ram(unsigned long pagenr)
>+int page_is_ram(unsigned long pagenr)
> {
> 	if (pagenr >= min_low_pfn && pagenr < max_low_pfn)
> 		return 1;
>--- linux-mm.orig/arch/mips/mm/init.c	2010-01-10 10:37:22.000000000 +0800
>+++ linux-mm/arch/mips/mm/init.c	2010-01-10 10:37:26.000000000 +0800
>@@ -298,7 +298,7 @@ void __init fixrange_init(unsigned long 
> }
> 
> #ifndef CONFIG_NEED_MULTIPLE_NODES
>-static int __init page_is_ram(unsigned long pagenr)
>+int page_is_ram(unsigned long pagenr)
> {
> 	int i;
> 
>
>
>--
>To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
>Please read the FAQ at  http://www.tux.org/lkml/

-- 
Live like a child, think like the god.
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
