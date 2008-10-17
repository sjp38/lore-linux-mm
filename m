Received: by wa-out-1112.google.com with SMTP id j37so355794waf.22
        for <linux-mm@kvack.org>; Fri, 17 Oct 2008 05:57:11 -0700 (PDT)
Message-ID: <84144f020810170557j4459790fk6a29e863d83dd340@mail.gmail.com>
Date: Fri, 17 Oct 2008 15:57:11 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 19/31] proc: move /proc/slabinfo boilerplate to mm/slub.c, mm/slab.c
In-Reply-To: <20081017124919.GT22653@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081017124919.GT22653@x200.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cl@linux-foundation.org
List-ID: <linux-mm.kvack.org>

On Fri, Oct 17, 2008 at 3:49 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
> From c0bc1527456ef7c255098e3647eefc7420822c63 Mon Sep 17 00:00:00 2001
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Mon, 6 Oct 2008 02:42:17 +0400
> Subject: [PATCH 19/31] proc: move /proc/slabinfo boilerplate to mm/slub.c, mm/slab.c
>
> Lose dummy ->write hook in case of SLUB, it's possible now.
>
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Looks good to me.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ---
>  fs/proc/proc_misc.c  |   17 -----------------
>  include/linux/slab.h |    5 -----
>  mm/slab.c            |   16 +++++++++++++++-
>  mm/slub.c            |   29 ++++++++++++++++++++---------
>  4 files changed, 35 insertions(+), 32 deletions(-)
>
> diff --git a/fs/proc/proc_misc.c b/fs/proc/proc_misc.c
> index 4fb05d1..911a2d3 100644
> --- a/fs/proc/proc_misc.c
> +++ b/fs/proc/proc_misc.c
> @@ -131,20 +131,6 @@ static const struct file_operations proc_modules_operations = {
>  };
>  #endif
>
> -#ifdef CONFIG_SLABINFO
> -static int slabinfo_open(struct inode *inode, struct file *file)
> -{
> -       return seq_open(file, &slabinfo_op);
> -}
> -static const struct file_operations proc_slabinfo_operations = {
> -       .open           = slabinfo_open,
> -       .read           = seq_read,
> -       .write          = slabinfo_write,
> -       .llseek         = seq_lseek,
> -       .release        = seq_release,
> -};
> -#endif
> -
>  #ifdef CONFIG_MMU
>  static int vmalloc_open(struct inode *inode, struct file *file)
>  {
> @@ -308,9 +294,6 @@ void __init proc_misc_init(void)
>        proc_symlink("mounts", NULL, "self/mounts");
>
>        /* And now for trickier ones */
> -#ifdef CONFIG_SLABINFO
> -       proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
> -#endif
>  #ifdef CONFIG_MMU
>        proc_create("vmallocinfo", S_IRUSR, NULL, &proc_vmalloc_operations);
>  #endif
> diff --git a/include/linux/slab.h b/include/linux/slab.h
> index 5ff9676..ba965c8 100644
> --- a/include/linux/slab.h
> +++ b/include/linux/slab.h
> @@ -288,9 +288,4 @@ static inline void *kzalloc_node(size_t size, gfp_t flags, int node)
>        return kmalloc_node(size, flags | __GFP_ZERO, node);
>  }
>
> -#ifdef CONFIG_SLABINFO
> -extern const struct seq_operations slabinfo_op;
> -ssize_t slabinfo_write(struct file *, const char __user *, size_t, loff_t *);
> -#endif
> -
>  #endif /* _LINUX_SLAB_H */
> diff --git a/mm/slab.c b/mm/slab.c
> index d53ac9c..0918751 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -4259,7 +4259,7 @@ static int s_show(struct seq_file *m, void *p)
>  * + further values on SMP and with statistics enabled
>  */
>
> -const struct seq_operations slabinfo_op = {
> +static const struct seq_operations slabinfo_op = {
>        .start = s_start,
>        .next = s_next,
>        .stop = s_stop,
> @@ -4316,6 +4316,19 @@ ssize_t slabinfo_write(struct file *file, const char __user * buffer,
>        return res;
>  }
>
> +static int slabinfo_open(struct inode *inode, struct file *file)
> +{
> +       return seq_open(file, &slabinfo_op);
> +}
> +
> +static const struct file_operations proc_slabinfo_operations = {
> +       .open           = slabinfo_open,
> +       .read           = seq_read,
> +       .write          = slabinfo_write,
> +       .llseek         = seq_lseek,
> +       .release        = seq_release,
> +};
> +
>  #ifdef CONFIG_DEBUG_SLAB_LEAK
>
>  static void *leaks_start(struct seq_file *m, loff_t *pos)
> @@ -4478,6 +4491,7 @@ static const struct file_operations proc_slabstats_operations = {
>
>  static int __init slab_proc_init(void)
>  {
> +       proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
>  #ifdef CONFIG_DEBUG_SLAB_LEAK
>        proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
>  #endif
> diff --git a/mm/slub.c b/mm/slub.c
> index 0c83e6a..7ad489a 100644
> --- a/mm/slub.c
> +++ b/mm/slub.c
> @@ -14,6 +14,7 @@
>  #include <linux/interrupt.h>
>  #include <linux/bitops.h>
>  #include <linux/slab.h>
> +#include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
>  #include <linux/cpu.h>
>  #include <linux/cpuset.h>
> @@ -4417,14 +4418,6 @@ __initcall(slab_sysfs_init);
>  * The /proc/slabinfo ABI
>  */
>  #ifdef CONFIG_SLABINFO
> -
> -ssize_t slabinfo_write(struct file *file, const char __user *buffer,
> -                      size_t count, loff_t *ppos)
> -{
> -       return -EINVAL;
> -}
> -
> -
>  static void print_slabinfo_header(struct seq_file *m)
>  {
>        seq_puts(m, "slabinfo - version: 2.1\n");
> @@ -4492,11 +4485,29 @@ static int s_show(struct seq_file *m, void *p)
>        return 0;
>  }
>
> -const struct seq_operations slabinfo_op = {
> +static const struct seq_operations slabinfo_op = {
>        .start = s_start,
>        .next = s_next,
>        .stop = s_stop,
>        .show = s_show,
>  };
>
> +static int slabinfo_open(struct inode *inode, struct file *file)
> +{
> +       return seq_open(file, &slabinfo_op);
> +}
> +
> +static const struct file_operations proc_slabinfo_operations = {
> +       .open           = slabinfo_open,
> +       .read           = seq_read,
> +       .llseek         = seq_lseek,
> +       .release        = seq_release,
> +};
> +
> +static int __init slab_proc_init(void)
> +{
> +       proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
> +       return 0;
> +}
> +module_init(slab_proc_init);
>  #endif /* CONFIG_SLABINFO */
> --
> 1.5.6.5
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
