Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4106B0022
	for <linux-mm@kvack.org>; Wed, 18 May 2011 02:58:11 -0400 (EDT)
Subject: Re: [PATCH V3] xen/balloon: Memory hotplug support for Xen balloon
 driver
From: Vasiliy G Tolstov <v.tolstov@selfip.ru>
Reply-To: v.tolstov@selfip.ru
In-Reply-To: <20110517214421.GD30232@router-fw-old.local.net-space.pl>
References: <20110517214421.GD30232@router-fw-old.local.net-space.pl>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 18 May 2011 10:57:48 +0400
Message-ID: <1305701868.28175.1.camel@vase>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Kiper <dkiper@net-space.pl>
Cc: ian.campbell@citrix.com, akpm@linux-foundation.org, andi.kleen@intel.com, haicheng.li@linux.intel.com, fengguang.wu@intel.com, jeremy@goop.org, konrad.wilk@oracle.com, dan.magenheimer@oracle.com, pasik@iki.fi, dave@linux.vnet.ibm.com, wdauchy@gmail.com, rientjes@google.com, xen-devel@lists.xensource.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 2011-05-17 at 23:44 +0200, Daniel Kiper wrote:
> This patch applies to Linus' git tree, v2.6.39-rc7 tag with a few
> prerequisite patches available at https://lkml.org/lkml/2011/5/17/407
> and at https://lkml.org/lkml/2011/3/28/98.
> 
> Memory hotplug support for Xen balloon driver. It should be
> mentioned that hotplugged memory is not onlined automatically.
> It should be onlined by user through standard sysfs interface.
> 
> Memory could be hotplugged in following steps:
> 
>   1) dom0: xl mem-max <domU> <maxmem>
>      where <maxmem> is >= requested memory size,
> 
>   2) dom0: xl mem-set <domU> <memory>
>      where <memory> is requested memory size; alternatively memory
>      could be added by writing proper value to
>      /sys/devices/system/xen_memory/xen_memory0/target or
>      /sys/devices/system/xen_memory/xen_memory0/target_kb on dumU,
> 
>   3) domU: for i in /sys/devices/system/memory/memory*/state; do \
>              [ "`cat "$i"`" = offline ] && echo online > "$i"; done
> 
> Signed-off-by: Daniel Kiper <dkiper@net-space.pl>
> Acked-by: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
> ---
>  drivers/xen/Kconfig   |   24 +++++++++
>  drivers/xen/balloon.c |  139 ++++++++++++++++++++++++++++++++++++++++++++++++-
>  include/xen/balloon.h |    4 ++
>  3 files changed, 165 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/xen/Kconfig b/drivers/xen/Kconfig
> index a59638b..b74501e 100644
> --- a/drivers/xen/Kconfig
> +++ b/drivers/xen/Kconfig
> @@ -9,6 +9,30 @@ config XEN_BALLOON
>  	  the system to expand the domain's memory allocation, or alternatively
>  	  return unneeded memory to the system.
>  
> +config XEN_BALLOON_MEMORY_HOTPLUG
> +	bool "Memory hotplug support for Xen balloon driver"
> +	default n
> +	depends on XEN_BALLOON && MEMORY_HOTPLUG
> +	help
> +	  Memory hotplug support for Xen balloon driver allows expanding memory
> +	  available for the system above limit declared at system startup.
> +	  It is very useful on critical systems which require long
> +	  run without rebooting.
> +
> +	  Memory could be hotplugged in following steps:
> +
> +	    1) dom0: xl mem-max <domU> <maxmem>
> +	       where <maxmem> is >= requested memory size,
> +
> +	    2) dom0: xl mem-set <domU> <memory>
> +	       where <memory> is requested memory size; alternatively memory
> +	       could be added by writing proper value to
> +	       /sys/devices/system/xen_memory/xen_memory0/target or
> +	       /sys/devices/system/xen_memory/xen_memory0/target_kb on dumU,
> +
> +	    3) domU: for i in /sys/devices/system/memory/memory*/state; do \
> +	               [ "`cat "$i"`" = offline ] && echo online > "$i"; done
> +
Very good. Is that possible to eliminate step 3 ? And do it automatic if
domU runs with specific xen balloon param?

-- 
> 
> Vasiliy G Tolstov <v.tolstov@selfip.ru>
> Selfip.Ru

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
