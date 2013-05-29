Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx147.postini.com [74.125.245.147])
	by kanga.kvack.org (Postfix) with SMTP id 2E91E6B014F
	for <linux-mm@kvack.org>; Wed, 29 May 2013 12:32:04 -0400 (EDT)
Received: by mail-pa0-f51.google.com with SMTP id lf10so8465963pab.38
        for <linux-mm@kvack.org>; Wed, 29 May 2013 09:32:03 -0700 (PDT)
Message-ID: <51A62D7F.4030607@gmail.com>
Date: Thu, 30 May 2013 00:31:59 +0800
From: Liu Jiang <liuj97@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH updated] drivers/base: Use attribute groups to create
 sysfs memory files
References: <51A58F4D.3020804@linux.vnet.ibm.com>
In-Reply-To: <51A58F4D.3020804@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nathan Fontenot <nfont@linux.vnet.ibm.com>
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

Hi Nathan,
         Good cleanup!
Reviewed-by: Jiang Liu <jiang.liu@huawei.com>

On Wed 29 May 2013 01:17:01 PM CST, Nathan Fontenot wrote:
> Update the sysfs memory code to create/delete files at the time of device
> and subsystem registration.
>
> The current code creates files in the root memory directory explicitly
> through
> the use of init_* routines. The files for each memory block are
> created and
> deleted explicitly using the mem_[create|delete]_simple_file macros.
>
> This patch creates attribute groups for the memory root files and
> files in
> each memory block directory so that they are created and deleted
> implicitly
> at subsys and device register and unregister time.
>
> This did necessitate moving the register_memory() routine and update
> it to set the dev.groups field.
>
> Signed-off-by: Nathan Fontenot <nfont@linux.vnet.ibm.com>
>
> Updated to apply cleanly to rc2.
>
> Please cc me on responses/comments.
> ---
>  drivers/base/memory.c |  143
> +++++++++++++++++++++-----------------------------
>  1 file changed, 62 insertions(+), 81 deletions(-)
>
> Index: linux/drivers/base/memory.c
> ===================================================================
> --- linux.orig/drivers/base/memory.c    2013-05-28 22:53:58.000000000
> -0500
> +++ linux/drivers/base/memory.c 2013-05-28 22:56:49.000000000 -0500
> @@ -77,22 +77,6 @@
>         kfree(mem);
>  }
>
> -/*
> - * register_memory - Setup a sysfs device for a memory block
> - */
> -static
> -int register_memory(struct memory_block *memory)
> -{
> -       int error;
> -
> -       memory->dev.bus = &memory_subsys;
> -       memory->dev.id = memory->start_section_nr / sections_per_block;
> -       memory->dev.release = memory_block_release;
> -
> -       error = device_register(&memory->dev);
> -       return error;
> -}
> -
>  unsigned long __weak memory_block_size_bytes(void)
>  {
>         return MIN_MEMORY_BLOCK_SIZE;
> @@ -371,11 +355,6 @@
>  static DEVICE_ATTR(phys_device, 0444, show_phys_device, NULL);
>  static DEVICE_ATTR(removable, 0444, show_mem_removable, NULL);
>
> -#define mem_create_simple_file(mem, attr_name) \
> -       device_create_file(&mem->dev, &dev_attr_##attr_name)
> -#define mem_remove_simple_file(mem, attr_name) \
> -       device_remove_file(&mem->dev, &dev_attr_##attr_name)
> -
>  /*
>   * Block size attribute stuff
>   */
> @@ -388,12 +367,6 @@
>
>  static DEVICE_ATTR(block_size_bytes, 0444, print_block_size, NULL);
>
> -static int block_size_init(void)
> -{
> -       return device_create_file(memory_subsys.dev_root,
> -                                 &dev_attr_block_size_bytes);
> -}
> -
>  /*
>   * Some architectures will have custom drivers to do this, and
>   * will not need to do it from userspace.  The fake hot-add code
> @@ -429,17 +402,8 @@
>  out:
>         return ret;
>  }
> -static DEVICE_ATTR(probe, S_IWUSR, NULL, memory_probe_store);
>
> -static int memory_probe_init(void)
> -{
> -       return device_create_file(memory_subsys.dev_root,
> &dev_attr_probe);
> -}
> -#else
> -static inline int memory_probe_init(void)
> -{
> -       return 0;
> -}
> +static DEVICE_ATTR(probe, S_IWUSR, NULL, memory_probe_store);
>  #endif
>
>  #ifdef CONFIG_MEMORY_FAILURE
> @@ -485,23 +449,6 @@
>
>  static DEVICE_ATTR(soft_offline_page, S_IWUSR, NULL,
> store_soft_offline_page);
>  static DEVICE_ATTR(hard_offline_page, S_IWUSR, NULL,
> store_hard_offline_page);
> -
> -static __init int memory_fail_init(void)
> -{
> -       int err;
> -
> -       err = device_create_file(memory_subsys.dev_root,
> -                               &dev_attr_soft_offline_page);
> -       if (!err)
> -               err = device_create_file(memory_subsys.dev_root,
> -                               &dev_attr_hard_offline_page);
> -       return err;
> -}
> -#else
> -static inline int memory_fail_init(void)
> -{
> -       return 0;
> -}
>  #endif
>
>  /*
> @@ -546,6 +493,41 @@
>         return find_memory_block_hinted(section, NULL);
>  }
>
> +static struct attribute *memory_memblk_attrs[] = {
> +       &dev_attr_phys_index.attr,
> +       &dev_attr_end_phys_index.attr,
> +       &dev_attr_state.attr,
> +       &dev_attr_phys_device.attr,
> +       &dev_attr_removable.attr,
> +       NULL
> +};
> +
> +static struct attribute_group memory_memblk_attr_group = {
> +       .attrs = memory_memblk_attrs,
> +};
> +
> +static const struct attribute_group *memory_memblk_attr_groups[] = {
> +       &memory_memblk_attr_group,
> +       NULL,
> +};
> +
> +/*
> + * register_memory - Setup a sysfs device for a memory block
> + */
> +static
> +int register_memory(struct memory_block *memory)
> +{
> +       int error;
> +
> +       memory->dev.bus = &memory_subsys;
> +       memory->dev.id = memory->start_section_nr / sections_per_block;
> +       memory->dev.release = memory_block_release;
> +       memory->dev.groups = memory_memblk_attr_groups;
> +
> +       error = device_register(&memory->dev);
> +       return error;
> +}
> +
>  static int init_memory_block(struct memory_block **memory,
>                              struct mem_section *section, unsigned
> long state)
>  {
> @@ -569,16 +551,6 @@
>         mem->phys_device = arch_get_memory_phys_device(start_pfn);
>
>         ret = register_memory(mem);
> -       if (!ret)
> -               ret = mem_create_simple_file(mem, phys_index);
> -       if (!ret)
> -               ret = mem_create_simple_file(mem, end_phys_index);
> -       if (!ret)
> -               ret = mem_create_simple_file(mem, state);
> -       if (!ret)
> -               ret = mem_create_simple_file(mem, phys_device);
> -       if (!ret)
> -               ret = mem_create_simple_file(mem, removable);
>
>         *memory = mem;
>         return ret;
> @@ -656,14 +628,9 @@
>         unregister_mem_sect_under_nodes(mem, __section_nr(section));
>
>         mem->section_count--;
> -       if (mem->section_count == 0) {
> -               mem_remove_simple_file(mem, phys_index);
> -               mem_remove_simple_file(mem, end_phys_index);
> -               mem_remove_simple_file(mem, state);
> -               mem_remove_simple_file(mem, phys_device);
> -               mem_remove_simple_file(mem, removable);
> +       if (mem->section_count == 0)
>                 unregister_memory(mem);
> -       } else
> +       else
>                 kobject_put(&mem->dev.kobj);
>
>         mutex_unlock(&mem_sysfs_mutex);
> @@ -700,6 +667,29 @@
>         return mem->state == MEM_OFFLINE;
>  }
>
> +static struct attribute *memory_root_attrs[] = {
> +#ifdef CONFIG_ARCH_MEMORY_PROBE
> +       &dev_attr_probe.attr,
> +#endif
> +
> +#ifdef CONFIG_MEMORY_FAILURE
> +       &dev_attr_soft_offline_page.attr,
> +       &dev_attr_hard_offline_page.attr,
> +#endif
> +
> +       &dev_attr_block_size_bytes.attr,
> +       NULL
> +};
> +
> +static struct attribute_group memory_root_attr_group = {
> +       .attrs = memory_root_attrs,
> +};
> +
> +static const struct attribute_group *memory_root_attr_groups[] = {
> +       &memory_root_attr_group,
> +       NULL,
> +};
> +
>  /*
>   * Initialize the sysfs support for memory devices...
>   */
> @@ -711,7 +701,7 @@
>         unsigned long block_sz;
>         struct memory_block *mem = NULL;
>
> -       ret = subsys_system_register(&memory_subsys, NULL);
> +       ret = subsys_system_register(&memory_subsys,
> memory_root_attr_groups);
>         if (ret)
>                 goto out;
>
> @@ -734,15 +724,6 @@
>                         ret = err;
>         }
>
> -       err = memory_probe_init();
> -       if (!ret)
> -               ret = err;
> -       err = memory_fail_init();
> -       if (!ret)
> -               ret = err;
> -       err = block_size_init();
> -       if (!ret)
> -               ret = err;
>  out:
>         if (ret)
>                 printk(KERN_ERR "%s() failed: %d\n", __func__, ret);
>
> --
> To unsubscribe from this list: send the line "unsubscribe
> linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
