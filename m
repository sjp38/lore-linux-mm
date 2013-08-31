Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 89FB16B0032
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 20:24:51 -0400 (EDT)
Message-ID: <1377908599.10300.901.camel@misato.fc.hp.com>
Subject: Re: [PATCH 3/3] PM / hibernate / memory hotplug: Rework mutual
 exclusion
From: Toshi Kani <toshi.kani@hp.com>
Date: Fri, 30 Aug 2013 18:23:19 -0600
In-Reply-To: <1562298.ZjRvhqQzT7@vostro.rjw.lan>
References: <9589253.Co8jZpnWdd@vostro.rjw.lan>
	 <1562298.ZjRvhqQzT7@vostro.rjw.lan>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: ACPI Devel Maling List <linux-acpi@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux PM list <linux-pm@vger.kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, linux-mm@kvack.org

On Thu, 2013-08-29 at 23:18 +0200, Rafael J. Wysocki wrote:
> From: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> 
> Since all of the memory hotplug operations have to be carried out
> under device_hotplug_lock, they won't need to acquire pm_mutex if
> device_hotplug_lock is held around hibernation.
> 
> For this reason, make the hibernation code acquire
> device_hotplug_lock after freezing user space processes and
> release it before thawing them.  At the same tim drop the
> lock_system_sleep() and unlock_system_sleep() calls from
> lock_memory_hotplug() and unlock_memory_hotplug(), respectively.
> 
> Signed-off-by: Rafael J. Wysocki <rafael.j.wysocki@intel.com>
> ---
>  kernel/power/hibernate.c |    4 ++++
>  kernel/power/user.c      |    2 ++
>  mm/memory_hotplug.c      |    4 ----
>  3 files changed, 6 insertions(+), 4 deletions(-)
> 
> Index: linux-pm/kernel/power/hibernate.c
> ===================================================================
> --- linux-pm.orig/kernel/power/hibernate.c
> +++ linux-pm/kernel/power/hibernate.c
> @@ -652,6 +652,7 @@ int hibernate(void)
>  	if (error)
>  		goto Exit;
>  
> +	lock_device_hotplug();

Since hibernate() can be called from sysfs, do you think the tool may
see this as a circular dependency with p_active again?  This shouldn't
be a problem in practice, though.

Thanks,
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
