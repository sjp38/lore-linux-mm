Received: by wa-out-1112.google.com with SMTP id j37so355500waf.22
        for <linux-mm@kvack.org>; Fri, 17 Oct 2008 05:55:40 -0700 (PDT)
Message-ID: <84144f020810170555q655a977bx2c9a9501a214f3d6@mail.gmail.com>
Date: Fri, 17 Oct 2008 15:55:39 +0300
From: "Pekka Enberg" <penberg@cs.helsinki.fi>
Subject: Re: [PATCH 18/31] proc: move /proc/slab_allocators boilerplate to mm/slab.c
In-Reply-To: <20081017124854.GS22653@x200.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20081017124854.GS22653@x200.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Fri, Oct 17, 2008 at 3:48 PM, Alexey Dobriyan <adobriyan@gmail.com> wrote:
> From 777d02988b44d1cc31b7cb6d82c94e4d337f5abe Mon Sep 17 00:00:00 2001
> From: Alexey Dobriyan <adobriyan@gmail.com>
> Date: Mon, 6 Oct 2008 00:59:10 +0400
> Subject: [PATCH 18/31] proc: move /proc/slab_allocators boilerplate to mm/slab.c
>
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Looks good to me.

Acked-by: Pekka Enberg <penberg@cs.helsinki.fi>

> ---
>  fs/proc/proc_misc.c |   30 ------------------------------
>  mm/slab.c           |   36 +++++++++++++++++++++++++++++++++++-
>  2 files changed, 35 insertions(+), 31 deletions(-)
>
> diff --git a/fs/proc/proc_misc.c b/fs/proc/proc_misc.c
> index 1b46976..4fb05d1 100644
> --- a/fs/proc/proc_misc.c
> +++ b/fs/proc/proc_misc.c
> @@ -143,33 +143,6 @@ static const struct file_operations proc_slabinfo_operations = {
>        .llseek         = seq_lseek,
>        .release        = seq_release,
>  };
> -
> -#ifdef CONFIG_DEBUG_SLAB_LEAK
> -extern const struct seq_operations slabstats_op;
> -static int slabstats_open(struct inode *inode, struct file *file)
> -{
> -       unsigned long *n = kzalloc(PAGE_SIZE, GFP_KERNEL);
> -       int ret = -ENOMEM;
> -       if (n) {
> -               ret = seq_open(file, &slabstats_op);
> -               if (!ret) {
> -                       struct seq_file *m = file->private_data;
> -                       *n = PAGE_SIZE / (2 * sizeof(unsigned long));
> -                       m->private = n;
> -                       n = NULL;
> -               }
> -               kfree(n);
> -       }
> -       return ret;
> -}
> -
> -static const struct file_operations proc_slabstats_operations = {
> -       .open           = slabstats_open,
> -       .read           = seq_read,
> -       .llseek         = seq_lseek,
> -       .release        = seq_release_private,
> -};
> -#endif
>  #endif
>
>  #ifdef CONFIG_MMU
> @@ -337,9 +310,6 @@ void __init proc_misc_init(void)
>        /* And now for trickier ones */
>  #ifdef CONFIG_SLABINFO
>        proc_create("slabinfo",S_IWUSR|S_IRUGO,NULL,&proc_slabinfo_operations);
> -#ifdef CONFIG_DEBUG_SLAB_LEAK
> -       proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
> -#endif
>  #endif
>  #ifdef CONFIG_MMU
>        proc_create("vmallocinfo", S_IRUSR, NULL, &proc_vmalloc_operations);
> diff --git a/mm/slab.c b/mm/slab.c
> index e76eee4..d53ac9c 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -95,6 +95,7 @@
>  #include       <linux/init.h>
>  #include       <linux/compiler.h>
>  #include       <linux/cpuset.h>
> +#include       <linux/proc_fs.h>
>  #include       <linux/seq_file.h>
>  #include       <linux/notifier.h>
>  #include       <linux/kallsyms.h>
> @@ -4443,13 +4444,46 @@ static int leaks_show(struct seq_file *m, void *p)
>        return 0;
>  }
>
> -const struct seq_operations slabstats_op = {
> +static const struct seq_operations slabstats_op = {
>        .start = leaks_start,
>        .next = s_next,
>        .stop = s_stop,
>        .show = leaks_show,
>  };
> +
> +static int slabstats_open(struct inode *inode, struct file *file)
> +{
> +       unsigned long *n = kzalloc(PAGE_SIZE, GFP_KERNEL);
> +       int ret = -ENOMEM;
> +       if (n) {
> +               ret = seq_open(file, &slabstats_op);
> +               if (!ret) {
> +                       struct seq_file *m = file->private_data;
> +                       *n = PAGE_SIZE / (2 * sizeof(unsigned long));
> +                       m->private = n;
> +                       n = NULL;
> +               }
> +               kfree(n);
> +       }
> +       return ret;
> +}
> +
> +static const struct file_operations proc_slabstats_operations = {
> +       .open           = slabstats_open,
> +       .read           = seq_read,
> +       .llseek         = seq_lseek,
> +       .release        = seq_release_private,
> +};
> +#endif
> +
> +static int __init slab_proc_init(void)
> +{
> +#ifdef CONFIG_DEBUG_SLAB_LEAK
> +       proc_create("slab_allocators", 0, NULL, &proc_slabstats_operations);
>  #endif
> +       return 0;
> +}
> +module_init(slab_proc_init);
>  #endif
>
>  /**
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
