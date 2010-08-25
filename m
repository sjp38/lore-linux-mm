Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id A24016B0205
	for <linux-mm@kvack.org>; Wed, 25 Aug 2010 16:39:25 -0400 (EDT)
Date: Wed, 25 Aug 2010 16:37:08 -0400
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: Re: [PATCH/RFCv4 3/6] mm: cma: Added SysFS support
Message-ID: <20100825203707.GB5318@phenom.dumpdata.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
 <0b02e05fc21e70a3af39e65e628d117cd89d70a1.1282286941.git.m.nazarewicz@samsung.com>
 <343f4b0edf9b5eef598831700cb459cd428d3f2e.1282286941.git.m.nazarewicz@samsung.com>
 <9883433f103cc84e55db150806d2270200c74c6b.1282286941.git.m.nazarewicz@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <9883433f103cc84e55db150806d2270200c74c6b.1282286941.git.m.nazarewicz@samsung.com>
Sender: owner-linux-mm@kvack.org
To: Michal Nazarewicz <m.nazarewicz@samsung.com>
Cc: linux-mm@kvack.org, Daniel Walker <dwalker@codeaurora.org>, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, Hans Verkuil <hverkuil@xs4all.nl>, Jonathan Corbet <corbet@lwn.net>, Kyungmin Park <kyungmin.park@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Pawel Osciak <p.osciak@samsung.com>, Russell King <linux@arm.linux.org.uk>, Zach Pfeffer <zpfeffer@codeaurora.org>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Fri, Aug 20, 2010 at 11:50:43AM +0200, Michal Nazarewicz wrote:
> The SysFS development interface lets one change the map attribute
> at run time as well as observe what regions have been reserved.
> 
> Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
> Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
> ---
>  .../ABI/testing/sysfs-kernel-mm-contiguous         |   53 +++
>  Documentation/contiguous-memory.txt                |    4 +
>  include/linux/cma.h                                |    7 +
>  mm/Kconfig                                         |   18 +-
>  mm/cma.c                                           |  345 +++++++++++++++++++-
>  5 files changed, 423 insertions(+), 4 deletions(-)
>  create mode 100644 Documentation/ABI/testing/sysfs-kernel-mm-contiguous
> 
> diff --git a/Documentation/ABI/testing/sysfs-kernel-mm-contiguous b/Documentation/ABI/testing/sysfs-kernel-mm-contiguous
> new file mode 100644
> index 0000000..8df15bc
> --- /dev/null
> +++ b/Documentation/ABI/testing/sysfs-kernel-mm-contiguous
> @@ -0,0 +1,53 @@
> +What:		/sys/kernel/mm/contiguous/
> +Date:		August 2010
> +Contact:	Michal Nazarewicz <m.nazarewicz@samsung.com>
> +Description:
> +		If CMA has been built with SysFS support,
> +		/sys/kernel/mm/contiguous/ contains a file called
> +		"map", a file called "allocators" and a directory
> +		called "regions".
> +
> +		The "map" file lets one change the CMA's map attribute
> +		at run-time.
> +
> +		The "allocators" file list all registered allocators.
> +		Allocators with no name are listed as a single minus
> +		sign.
> +
> +		The "regions" directory list all reserved regions.
> +
> +		For more details see
> +		Documentation/contiguous-memory.txt.
> +
> +What:		/sys/kernel/mm/contiguous/regions/
> +Date:		August 2010
> +Contact:	Michal Nazarewicz <m.nazarewicz@samsung.com>
> +Description:
> +		The /sys/kernel/mm/contiguous/regions/ directory
> +		contain directories for each registered CMA region.
> +		The name of the directory is the same as the start
> +		address of the region.
> +
> +		If region is named there is also a symbolic link named
> +		like the region pointing to the region's directory.
> +
> +		Such directory contains the following files:
> +
> +		* "name"  -- the name of the region or an empty file
> +		* "start" -- starting address of the region (formatted
> +		            with %p, ie. hex).
> +		* "size"  -- size of the region (in bytes).
> +		* "free"  -- free space in the region (in bytes).
> +		* "users" -- number of chunks allocated in the region.
> +		* "alloc" -- name of the allocator.
> +
> +		If allocator is not attached to the region, "alloc" is
> +		either the name of desired allocator in square
> +		brackets (ie. "[foo]") or an empty file if region is
> +		to be attached to default allocator.  If an allocator
> +		is attached to the region. "alloc" is either its name
> +		or "-" if attached allocator has no name.
> +
> +		If there are no chunks allocated in given region
> +		("users" is "0") then a name of desired allocator can
> +		be written to "alloc".
> diff --git a/Documentation/contiguous-memory.txt b/Documentation/contiguous-memory.txt
> index 8fc2400..8d189b8 100644
> --- a/Documentation/contiguous-memory.txt
> +++ b/Documentation/contiguous-memory.txt
> @@ -256,6 +256,10 @@
>       iff it matched in previous pattern.  If the second part is
>       omitted it will mach any type of memory requested by device.
>  
> +     If SysFS support is enabled, this attribute is accessible via
> +     SysFS and can be changed at run-time by writing to
> +     /sys/kernel/mm/contiguous/map.
> +
>       Some examples (whitespace added for better readability):
>  
>           cma_map = foo/quaz = r1;
> diff --git a/include/linux/cma.h b/include/linux/cma.h
> index cd63f52..eede28d 100644
> --- a/include/linux/cma.h
> +++ b/include/linux/cma.h
> @@ -17,6 +17,9 @@
>  
>  #include <linux/rbtree.h>
>  #include <linux/list.h>
> +#if defined CONFIG_CMA_SYSFS
> +#  include <linux/kobject.h>
> +#endif
>  
>  
>  struct device;
> @@ -203,6 +206,10 @@ struct cma_region {
>  	unsigned users;
>  	struct list_head list;
>  
> +#if defined CONFIG_CMA_SYSFS
> +	struct kobject kobj;
> +#endif
> +
>  	unsigned used:1;
>  	unsigned registered:1;
>  	unsigned reserved:1;
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 3e9317c..ac0bb08 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -319,12 +319,26 @@ config CMA
>  	  To make use of CMA you need to specify the regions and
>  	  driver->region mapping on command line when booting the kernel.
>  
> -config CMA_DEBUG
> -	bool "CMA debug messages (DEVELOPEMENT)"
> +config CMA_DEVELOPEMENT
> +	bool "Include CMA developement features"
>  	depends on CMA
>  	help
> +	  This lets you enable some developement features of the CMA
> +	  freamework.
> +
> +config CMA_DEBUG
> +	bool "CMA debug messages"
> +	depends on CMA_DEVELOPEMENT
> +	help
>  	  Enable debug messages in CMA code.
>  
> +config CMA_SYSFS
> +	bool "CMA SysFS interface support"
> +	depends on CMA_DEVELOPEMENT
> +	help
> +	  Enable support for SysFS interface.

Whats the rationale for having those #ifdef CONFIG_CMA_SYSFS sprinkled
in the C code? Is SysFS not used on StrongARM? Why not implicitly include
the SysFS support?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
