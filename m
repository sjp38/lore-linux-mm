Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 933A06B004D
	for <linux-mm@kvack.org>; Fri, 13 Nov 2009 15:14:57 -0500 (EST)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] Allow memory hotplug and hibernation in the same kernel
Date: Fri, 13 Nov 2009 21:16:02 +0100
References: <20091113105944.GA16028@basil.fritz.box>
In-Reply-To: <20091113105944.GA16028@basil.fritz.box>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <200911132116.02659.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, gerald.schaefer@de.ibm.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Friday 13 November 2009, Andi Kleen wrote:
> Allow memory hotplug and hibernation in the same kernel
> 
> Memory hotplug and hibernation was excluded in Kconfig. This is obviously
> a problem for distribution kernels who want to support both in the same
> image.
> 
> After some discussions with Rafael and others the only problem is 
> with parallel memory hotadd or removal while a hibernation operation
> is in process. It was also working for s390 before.
> 
> This patch removes the Kconfig level exclusion, and simply
> makes the memory add / remove functions grab the pm_mutex
> to exclude against hibernation.
> 
> This is a 2.6.32 candidate.
> 
> Cc: gerald.schaefer@de.ibm.com
> Cc: rjw@sisk.pl
> 
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> 
> ---
>  include/linux/suspend.h |   21 +++++++++++++++++++--
>  mm/Kconfig              |    5 +----
>  mm/memory_hotplug.c     |   21 +++++++++++++++++----
>  3 files changed, 37 insertions(+), 10 deletions(-)
> 
> Index: linux-2.6.32-rc6-ak/include/linux/suspend.h
> ===================================================================
> --- linux-2.6.32-rc6-ak.orig/include/linux/suspend.h
> +++ linux-2.6.32-rc6-ak/include/linux/suspend.h
> @@ -301,6 +301,8 @@ static inline int unregister_pm_notifier
>  #define pm_notifier(fn, pri)	do { (void)(fn); } while (0)
>  #endif /* !CONFIG_PM_SLEEP */
>  
> +extern struct mutex pm_mutex;
> +
>  #ifndef CONFIG_HIBERNATION
>  static inline void register_nosave_region(unsigned long b, unsigned long e)
>  {
> @@ -308,8 +310,23 @@ static inline void register_nosave_regio
>  static inline void register_nosave_region_late(unsigned long b, unsigned long e)
>  {
>  }
> -#endif
>  
> -extern struct mutex pm_mutex;
> +static inline void lock_hibernation(void) {}
> +static inline void unlock_hibernation(void) {}
> +
> +#else
> +
> +/* Let some subsystems like memory hotadd exclude hibernation */
> +
> +static inline void lock_hibernation(void)
> +{
> +	mutex_lock(&pm_mutex);
> +}
> +
> +static inline void unlock_hibernation(void)
> +{
> +	mutex_unlock(&pm_mutex);
> +}

This also is going to affect suspend to RAM, which kind of makes sense BTW,
so I'd not put it under the #ifdef.  Also, the names should reflect the fact
that suspend is affected too.  What about block|unblock_system_sleep()?

> +#endif
>  
>  #endif /* _LINUX_SUSPEND_H */

The rest of the patch is fine by me.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
