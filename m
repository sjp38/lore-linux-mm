Date: Thu, 10 Jul 2008 18:24:23 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 2/4] mm: create /sys/kernel/mm
Message-ID: <20080710172423.GF6664@csn.ul.ie>
References: <20080708180348.GB14908@us.ibm.com> <20080708180542.GC14908@us.ibm.com> <20080708180644.GD14908@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080708180644.GD14908@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: npiggin@suse.de, agl@us.ibm.com, akpm@linux-foudation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/07/08 11:06), Nishanth Aravamudan didst pronounce:
> Add a kobject to create /sys/kernel/mm when sysfs is mounted. The
> kobject will exist regardless. This will allow for the hugepage related
> sysfs directories to exist under the mm "subsystem" directory. Add an
> ABI file appropriately.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

> diff --git a/Documentation/ABI/testing/sysfs-kernel-mm b/Documentation/ABI/testing/sysfs-kernel-mm
> new file mode 100644
> index 0000000..190d523
> --- /dev/null
> +++ b/Documentation/ABI/testing/sysfs-kernel-mm
> @@ -0,0 +1,6 @@
> +What:		/sys/kernel/mm
> +Date:		July 2008
> +Contact:	Nishanth Aravamudan <nacc@us.ibm.com>, VM maintainers
> +Description:
> +		/sys/kernel/mm/ should contain any and all VM
> +		related information in /sys/kernel/.
> diff --git a/include/linux/kobject.h b/include/linux/kobject.h
> index 60f0d41..5437ac0 100644
> --- a/include/linux/kobject.h
> +++ b/include/linux/kobject.h
> @@ -186,6 +186,8 @@ extern struct kobject *kset_find_obj(struct kset *, const char *);
>  
>  /* The global /sys/kernel/ kobject for people to chain off of */
>  extern struct kobject *kernel_kobj;
> +/* The global /sys/kernel/mm/ kobject for people to chain off of */
> +extern struct kobject *mm_kobj;
>  /* The global /sys/hypervisor/ kobject for people to chain off of */
>  extern struct kobject *hypervisor_kobj;
>  /* The global /sys/power/ kobject for people to chain off of */
> diff --git a/mm/mm_init.c b/mm/mm_init.c
> index eaf0d3b..4775743 100644
> --- a/mm/mm_init.c
> +++ b/mm/mm_init.c
> @@ -7,6 +7,7 @@
>   */
>  #include <linux/kernel.h>
>  #include <linux/init.h>
> +#include <linux/kobject.h>
>  #include "internal.h"
>  
>  #ifdef CONFIG_DEBUG_MEMORY_INIT
> @@ -134,3 +135,17 @@ static __init int set_mminit_loglevel(char *str)
>  }
>  early_param("mminit_loglevel", set_mminit_loglevel);
>  #endif /* CONFIG_DEBUG_MEMORY_INIT */
> +
> +struct kobject *mm_kobj;
> +EXPORT_SYMBOL_GPL(mm_kobj);
> +
> +static int __init mm_sysfs_init(void)
> +{
> +	mm_kobj = kobject_create_and_add("mm", kernel_kobj);
> +	if (!mm_kobj)
> +		return -ENOMEM;
> +
> +	return 0;
> +}
> +
> +__initcall(mm_sysfs_init);
> 
> -- 
> Nishanth Aravamudan <nacc@us.ibm.com>
> IBM Linux Technology Center
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
