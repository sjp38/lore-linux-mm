Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id A07E46B0069
	for <linux-mm@kvack.org>; Fri, 14 Oct 2016 07:25:47 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id d185so215427335oig.1
        for <linux-mm@kvack.org>; Fri, 14 Oct 2016 04:25:47 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id 5si6289650otc.274.2016.10.14.04.25.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 14 Oct 2016 04:25:46 -0700 (PDT)
Subject: Re: [PATCH] base memory: introduce CONFIG_MEMORY_DEVICE
References: <1476098800-3796-1-git-send-email-xieyisheng1@huawei.com>
From: Yisheng Xie <xieyisheng1@huawei.com>
Message-ID: <bd1550b1-22df-76f3-e2a9-f7767f479e1f@huawei.com>
Date: Fri, 14 Oct 2016 18:53:51 +0800
MIME-Version: 1.0
In-Reply-To: <1476098800-3796-1-git-send-email-xieyisheng1@huawei.com>
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, andrew@lunn.ch, daniel.kiper@oracle.com, srinivas.kandagatla@linaro.org, gregkh@linuxfoundation.org, vkuznets@redhat.com
Cc: linux-kernel@vger.kernel.org, ak@linux.intel.com, guohanjun@huawei.com, qiuxishi@huawei.com, n-horiguchi@ah.jp.nec.com, linux-mm <linux-mm@kvack.org>


+ mm mail list

On 2016/10/10 19:26, Yisheng Xie wrote:
> MEMORY_FAILURE do not depend on SPARSEMEM_MANUAL,
> nor MEMORY_HOTPLUG_SPARSE. However, when I tried to use sysfs:
> /sys/devices/system/memory/soft_offline_page
> /sys/devices/system/memory/hard_offline_page
> to test memory failure function with FLATMEM_MANUAL && MEMORY_FAILURE
> enabled on arch like i386, it failed for no such sysfs.
> 
> To make sysfs soft_offline_page usable once MEMORY_FAILURE is enabled,
> this patch introduces CONFIG_MEMORY_DEVICE, and selects it when
> MEMORY_FAILURE or MEMORY_HOTPLUG_SPARSE is enabled.
> 
> Signed-off-by: Yisheng Xie <xieyisheng1@huawei.com>
> ---
>  drivers/base/Kconfig   |  3 +++
>  drivers/base/Makefile  |  2 +-
>  drivers/base/memory.c  | 32 ++++++++++++++++++++++++++++++--
>  include/linux/memory.h |  4 ++++
>  4 files changed, 38 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
> index fdf44ca..b4eac4e 100644
> --- a/drivers/base/Kconfig
> +++ b/drivers/base/Kconfig
> @@ -271,6 +271,9 @@ config DMA_CMA
>  	  For more information see <include/linux/dma-contiguous.h>.
>  	  If unsure, say "n".
>  
> +config MEMORY_DEVICE
> +	def_bool MEMORY_HOTPLUG_SPARSE || MEMORY_FAILURE
> +
>  if  DMA_CMA
>  comment "Default contiguous memory area size:"
>  
> diff --git a/drivers/base/Makefile b/drivers/base/Makefile
> index 2609ba2..aafe34b 100644
> --- a/drivers/base/Makefile
> +++ b/drivers/base/Makefile
> @@ -13,7 +13,7 @@ obj-$(CONFIG_HAVE_GENERIC_DMA_COHERENT) += dma-coherent.o
>  obj-$(CONFIG_ISA_BUS_API)	+= isa.o
>  obj-$(CONFIG_FW_LOADER)	+= firmware_class.o
>  obj-$(CONFIG_NUMA)	+= node.o
> -obj-$(CONFIG_MEMORY_HOTPLUG_SPARSE) += memory.o
> +obj-$(CONFIG_MEMORY_DEVICE) += memory.o
>  ifeq ($(CONFIG_SYSFS),y)
>  obj-$(CONFIG_MODULES)	+= module.o
>  endif
> diff --git a/drivers/base/memory.c b/drivers/base/memory.c
> index dc75de9..fb00965 100644
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -25,10 +25,11 @@
>  #include <linux/atomic.h>
>  #include <asm/uaccess.h>
>  
> -static DEFINE_MUTEX(mem_sysfs_mutex);
> -
>  #define MEMORY_CLASS_NAME	"memory"
>  
> +#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
> +static DEFINE_MUTEX(mem_sysfs_mutex);
> +
>  #define to_memory_block(dev) container_of(dev, struct memory_block, dev)
>  
>  static int sections_per_block;
> @@ -381,6 +382,7 @@ static ssize_t show_phys_device(struct device *dev,
>  	struct memory_block *mem = to_memory_block(dev);
>  	return sprintf(buf, "%d\n", mem->phys_device);
>  }
> +#endif
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  static ssize_t show_valid_zones(struct device *dev,
> @@ -427,6 +429,7 @@ static ssize_t show_valid_zones(struct device *dev,
>  static DEVICE_ATTR(valid_zones, 0444, show_valid_zones, NULL);
>  #endif
>  
> +#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
>  static DEVICE_ATTR(phys_index, 0444, show_mem_start_phys_index, NULL);
>  static DEVICE_ATTR(state, 0644, show_mem_state, store_mem_state);
>  static DEVICE_ATTR(phys_device, 0444, show_phys_device, NULL);
> @@ -474,6 +477,7 @@ store_auto_online_blocks(struct device *dev, struct device_attribute *attr,
>  
>  static DEVICE_ATTR(auto_online_blocks, 0644, show_auto_online_blocks,
>  		   store_auto_online_blocks);
> +#endif
>  
>  /*
>   * Some architectures will have custom drivers to do this, and
> @@ -557,6 +561,7 @@ static DEVICE_ATTR(soft_offline_page, S_IWUSR, NULL, store_soft_offline_page);
>  static DEVICE_ATTR(hard_offline_page, S_IWUSR, NULL, store_hard_offline_page);
>  #endif
>  
> +#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
>  /*
>   * Note that phys_device is optional.  It is here to allow for
>   * differentiation between which *physical* devices each
> @@ -723,6 +728,7 @@ out:
>  	mutex_unlock(&mem_sysfs_mutex);
>  	return ret;
>  }
> +#endif
>  
>  #ifdef CONFIG_MEMORY_HOTREMOVE
>  static void
> @@ -766,11 +772,13 @@ int unregister_memory_section(struct mem_section *section)
>  }
>  #endif /* CONFIG_MEMORY_HOTREMOVE */
>  
> +#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
>  /* return true if the memory block is offlined, otherwise, return false */
>  bool is_memblock_offlined(struct memory_block *mem)
>  {
>  	return mem->state == MEM_OFFLINE;
>  }
> +#endif
>  
>  static struct attribute *memory_root_attrs[] = {
>  #ifdef CONFIG_ARCH_MEMORY_PROBE
> @@ -782,8 +790,10 @@ static struct attribute *memory_root_attrs[] = {
>  	&dev_attr_hard_offline_page.attr,
>  #endif
>  
> +#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
>  	&dev_attr_block_size_bytes.attr,
>  	&dev_attr_auto_online_blocks.attr,
> +#endif
>  	NULL
>  };
>  
> @@ -799,6 +809,7 @@ static const struct attribute_group *memory_root_attr_groups[] = {
>  /*
>   * Initialize the sysfs support for memory devices...
>   */
> +#ifdef CONFIG_MEMORY_HOTPLUG_SPARSE
>  int __init memory_dev_init(void)
>  {
>  	unsigned int i;
> @@ -830,3 +841,20 @@ out:
>  		printk(KERN_ERR "%s() failed: %d\n", __func__, ret);
>  	return ret;
>  }
> +#else
> +static struct bus_type memory_subsys = {
> +	.name = MEMORY_CLASS_NAME,
> +	.dev_name = MEMORY_CLASS_NAME,
> +};
> +
> +int __init memory_dev_init(void)
> +{
> +	int ret = 0;
> +
> +	ret = subsys_system_register(&memory_subsys, memory_root_attr_groups);
> +
> +	if (ret)
> +		pr_err("%s() failed: %d\n", __func__, ret);
> +	return ret;
> +}
> +#endif
> diff --git a/include/linux/memory.h b/include/linux/memory.h
> index 093607f..9fe1089 100644
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -77,10 +77,14 @@ struct mem_section;
>  #define IPC_CALLBACK_PRI        10
>  
>  #ifndef CONFIG_MEMORY_HOTPLUG_SPARSE
> +#ifdef CONFIG_MEMORY_DEVICE
> +extern int memory_dev_init(void);
> +#else
>  static inline int memory_dev_init(void)
>  {
>  	return 0;
>  }
> +#endif
>  static inline int register_memory_notifier(struct notifier_block *nb)
>  {
>  	return 0;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
