Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9B52E2802A6
	for <linux-mm@kvack.org>; Wed, 15 Jul 2015 15:03:19 -0400 (EDT)
Received: by igvi1 with SMTP id i1so84356838igv.1
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:03:19 -0700 (PDT)
Received: from mail-ig0-x233.google.com (mail-ig0-x233.google.com. [2607:f8b0:4001:c05::233])
        by mx.google.com with ESMTPS id h6si11774364igg.4.2015.07.15.12.03.19
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jul 2015 12:03:19 -0700 (PDT)
Received: by igbpg9 with SMTP id pg9so43735341igb.0
        for <linux-mm@kvack.org>; Wed, 15 Jul 2015 12:03:19 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <c6cbd44b9d5127cdaaa6f7d330e9bf715ec55534.1436967694.git.vdavydov@parallels.com>
References: <cover.1436967694.git.vdavydov@parallels.com>
	<c6cbd44b9d5127cdaaa6f7d330e9bf715ec55534.1436967694.git.vdavydov@parallels.com>
Date: Wed, 15 Jul 2015 12:03:18 -0700
Message-ID: <CAJu=L58kZW2WRpx8wLx=FXdS29BJ+euLRdDcTXJKwf-VLT6SCA@mail.gmail.com>
Subject: Re: [PATCH -mm v8 4/7] proc: add kpagecgroup file
From: Andres Lagar-Cavilla <andreslc@google.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vladimir Davydov <vdavydov@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Greg Thelen <gthelen@google.com>, Michel Lespinasse <walken@google.com>, David Rientjes <rientjes@google.com>, Pavel Emelyanov <xemul@parallels.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Jonathan Corbet <corbet@lwn.net>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

On Wed, Jul 15, 2015 at 6:54 AM, Vladimir Davydov
<vdavydov@parallels.com> wrote:
> /proc/kpagecgroup contains a 64-bit inode number of the memory cgroup
> each page is charged to, indexed by PFN. Having this information is
> useful for estimating a cgroup working set size.
>
> The file is present if CONFIG_PROC_PAGE_MONITOR && CONFIG_MEMCG.
>
> Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
> ---
>  Documentation/vm/pagemap.txt |  6 ++++-
>  fs/proc/page.c               | 53 ++++++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 58 insertions(+), 1 deletion(-)
>
> diff --git a/Documentation/vm/pagemap.txt b/Documentation/vm/pagemap.txt
> index 6bfbc172cdb9..a9b7afc8fbc6 100644
> --- a/Documentation/vm/pagemap.txt
> +++ b/Documentation/vm/pagemap.txt
> @@ -5,7 +5,7 @@ pagemap is a new (as of 2.6.25) set of interfaces in the kernel that allow
>  userspace programs to examine the page tables and related information by
>  reading files in /proc.
>
> -There are three components to pagemap:
> +There are four components to pagemap:
>
>   * /proc/pid/pagemap.  This file lets a userspace process find out which
>     physical frame each virtual page is mapped to.  It contains one 64-bit
> @@ -65,6 +65,10 @@ There are three components to pagemap:
>      23. BALLOON
>      24. ZERO_PAGE
>
> + * /proc/kpagecgroup.  This file contains a 64-bit inode number of the
> +   memory cgroup each page is charged to, indexed by PFN. Only available when
> +   CONFIG_MEMCG is set.
> +
>  Short descriptions to the page flags:
>
>   0. LOCKED
> diff --git a/fs/proc/page.c b/fs/proc/page.c
> index 7eee2d8b97d9..70d23245dd43 100644
> --- a/fs/proc/page.c
> +++ b/fs/proc/page.c
> @@ -9,6 +9,7 @@
>  #include <linux/proc_fs.h>
>  #include <linux/seq_file.h>
>  #include <linux/hugetlb.h>
> +#include <linux/memcontrol.h>
>  #include <linux/kernel-page-flags.h>
>  #include <asm/uaccess.h>
>  #include "internal.h"
> @@ -225,10 +226,62 @@ static const struct file_operations proc_kpageflags_operations = {
>         .read = kpageflags_read,
>  };
>
> +#ifdef CONFIG_MEMCG
> +static ssize_t kpagecgroup_read(struct file *file, char __user *buf,
> +                               size_t count, loff_t *ppos)
> +{
> +       u64 __user *out = (u64 __user *)buf;
> +       struct page *ppage;
> +       unsigned long src = *ppos;
> +       unsigned long pfn;
> +       ssize_t ret = 0;
> +       u64 ino;
> +
> +       pfn = src / KPMSIZE;
> +       count = min_t(unsigned long, count, (max_pfn * KPMSIZE) - src);
> +       if (src & KPMMASK || count & KPMMASK)
> +               return -EINVAL;
> +
> +       while (count > 0) {
> +               if (pfn_valid(pfn))
> +                       ppage = pfn_to_page(pfn);
> +               else
> +                       ppage = NULL;
> +
> +               if (ppage)
> +                       ino = page_cgroup_ino(ppage);
> +               else
> +                       ino = 0;
> +

For both /proc/kpage* interfaces you add (and more critically for the
rmap-causing one, kpageidle):

It's a good idea to do cond_sched(). Whether after each pfn, each Nth
pfn, each put_user, I leave to you, but a reasonable cadence is
needed, because user-space can call this on the entire physical
address space, and that's a lot of work to do without re-scheduling.

Andres

> +               if (put_user(ino, out)) {
> +                       ret = -EFAULT;
> +                       break;
> +               }
> +
> +               pfn++;
> +               out++;
> +               count -= KPMSIZE;
> +       }
> +
> +       *ppos += (char __user *)out - buf;
> +       if (!ret)
> +               ret = (char __user *)out - buf;
> +       return ret;
> +}
> +
> +static const struct file_operations proc_kpagecgroup_operations = {
> +       .llseek = mem_lseek,
> +       .read = kpagecgroup_read,
> +};
> +#endif /* CONFIG_MEMCG */
> +
>  static int __init proc_page_init(void)
>  {
>         proc_create("kpagecount", S_IRUSR, NULL, &proc_kpagecount_operations);
>         proc_create("kpageflags", S_IRUSR, NULL, &proc_kpageflags_operations);
> +#ifdef CONFIG_MEMCG
> +       proc_create("kpagecgroup", S_IRUSR, NULL, &proc_kpagecgroup_operations);
> +#endif
>         return 0;
>  }
>  fs_initcall(proc_page_init);
> --
> 2.1.4
>



-- 
Andres Lagar-Cavilla | Google Kernel Team | andreslc@google.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
