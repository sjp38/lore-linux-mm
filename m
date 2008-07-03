Date: Wed, 2 Jul 2008 22:36:52 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [-mm][PATCH 1/10] fix UNEVICTABLE_LRU and !PROC_PAGE_MONITOR
 build
Message-Id: <20080702223652.3b57dc4b.akpm@linux-foundation.org>
In-Reply-To: <20080625185950.D84F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080625185950.D84F.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Benjamin Kidwell <benjkidwell@yahoo.com>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Jun 2008 19:01:40 +0900 KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> 
> =
> From: Rik van Riel <riel@redhat.com>
> 
> Both CONFIG_PROC_PAGE_MONITOR and CONFIG_UNEVICTABLE_LRU depend on
> mm/pagewalk.c being built.  Create a CONFIG_PAGE_WALKER Kconfig
> variable that is automatically selected if needed.
> 
> Debugged-by: Benjamin Kidwell <benjkidwell@yahoo.com>
> Signed-off-by: Rik van Riel <riel@redhat.com>
> Signed-off-by: KOSAKI Motohiro <kosaki@jp.fujitsu.com>
> 
> ---
>  init/Kconfig |    1 +
>  mm/Kconfig   |    5 +++++
>  mm/Makefile  |    2 +-
>  3 files changed, 7 insertions(+), 1 deletion(-)
> 
> Index: b/init/Kconfig
> ===================================================================
> --- a/init/Kconfig
> +++ b/init/Kconfig
> @@ -803,6 +803,7 @@ source "arch/Kconfig"
>  config PROC_PAGE_MONITOR
>   	default y
>  	depends on PROC_FS && MMU
> +	select PAGE_WALKER
>  	bool "Enable /proc page monitoring" if EMBEDDED
>   	help
>  	  Various /proc files exist to monitor process memory utilization:

You used select!  With the usual consequences.

mm/pagewalk.c: In function `walk_pud_range':
mm/pagewalk.c:64: error: implicit declaration of function `pud_none_or_clear_bad'
mm/pagewalk.c: In function `walk_page_range':
mm/pagewalk.c:119: error: implicit declaration of function `pgd_addr_end'
mm/pagewalk.c:120: error: implicit declaration of function `pgd_none_or_clear_ba

That's SuperH allmodconfig.  I expect all nommu builds are busted.

> Index: b/mm/Kconfig
> ===================================================================
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -209,9 +209,14 @@ config VIRT_TO_BUS
>  	def_bool y
>  	depends on !ARCH_NO_VIRT_TO_BUS
>  
> +# automatically selected by UNEVICTABLE_LRU or PROC_PAGE_MONITOR
> +config PAGE_WALKER
> +	def_bool n
> +
>  config UNEVICTABLE_LRU
>  	bool "Add LRU list to track non-evictable pages"
>  	default y
> +	select PAGE_WALKER

So what do we do?  Make UNEVICTABLE_LRU depend on CONFIG_MMU?  That
would be even worse than what we have now.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
