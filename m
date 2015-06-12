Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com [209.85.215.52])
	by kanga.kvack.org (Postfix) with ESMTP id 12CAB6B0038
	for <linux-mm@kvack.org>; Fri, 12 Jun 2015 14:44:36 -0400 (EDT)
Received: by lacdj3 with SMTP id dj3so6213468lac.0
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 11:44:35 -0700 (PDT)
Received: from mail-la0-f52.google.com (mail-la0-f52.google.com. [209.85.215.52])
        by mx.google.com with ESMTPS id xs10si4049136lbb.86.2015.06.12.11.44.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 Jun 2015 11:44:33 -0700 (PDT)
Received: by lacny3 with SMTP id ny3so6172314lac.3
        for <linux-mm@kvack.org>; Fri, 12 Jun 2015 11:44:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150609200015.21971.25692.stgit@zurg>
References: <20150609195333.21971.58194.stgit@zurg>
	<20150609200015.21971.25692.stgit@zurg>
Date: Fri, 12 Jun 2015 19:44:32 +0100
Message-ID: <CAEVpBa+f2SfU5wvq8PZ3h762KVYsDFkNv3f5brJXar9=pm+wuw@mail.gmail.com>
Subject: Re: [PATCH v3 1/4] pagemap: check permissions and capabilities at
 open time
From: Mark Williamson <mwilliamson@undo-software.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Linux API <linux-api@vger.kernel.org>, kernel list <linux-kernel@vger.kernel.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

This looks good from our side - thanks!

Reviewed-by: mwilliamson@undo-software.com
Tested-by: mwilliamson@undo-software.com

On Tue, Jun 9, 2015 at 9:00 PM, Konstantin Khlebnikov <koct9i@gmail.com> wrote:
> From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>
> This patch moves permission checks from pagemap_read() into pagemap_open().
>
> Pointer to mm is saved in file->private_data. This reference pins only
> mm_struct itself. /proc/*/mem, maps, smaps already work in the same way.
>
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> Link: http://lkml.kernel.org/r/CA+55aFyKpWrt_Ajzh1rzp_GcwZ4=6Y=kOv8hBz172CFJp6L8Tg@mail.gmail.com
> ---
>  fs/proc/task_mmu.c |   48 ++++++++++++++++++++++++++++--------------------
>  1 file changed, 28 insertions(+), 20 deletions(-)
>
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 6dee68d..21bc251 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1227,40 +1227,33 @@ static int pagemap_hugetlb_range(pte_t *pte, unsigned long hmask,
>  static ssize_t pagemap_read(struct file *file, char __user *buf,
>                             size_t count, loff_t *ppos)
>  {
> -       struct task_struct *task = get_proc_task(file_inode(file));
> -       struct mm_struct *mm;
> +       struct mm_struct *mm = file->private_data;
>         struct pagemapread pm;
> -       int ret = -ESRCH;
>         struct mm_walk pagemap_walk = {};
>         unsigned long src;
>         unsigned long svpfn;
>         unsigned long start_vaddr;
>         unsigned long end_vaddr;
> -       int copied = 0;
> +       int ret = 0, copied = 0;
>
> -       if (!task)
> +       if (!mm || !atomic_inc_not_zero(&mm->mm_users))
>                 goto out;
>
>         ret = -EINVAL;
>         /* file position must be aligned */
>         if ((*ppos % PM_ENTRY_BYTES) || (count % PM_ENTRY_BYTES))
> -               goto out_task;
> +               goto out_mm;
>
>         ret = 0;
>         if (!count)
> -               goto out_task;
> +               goto out_mm;
>
>         pm.v2 = soft_dirty_cleared;
>         pm.len = (PAGEMAP_WALK_SIZE >> PAGE_SHIFT);
>         pm.buffer = kmalloc(pm.len * PM_ENTRY_BYTES, GFP_TEMPORARY);
>         ret = -ENOMEM;
>         if (!pm.buffer)
> -               goto out_task;
> -
> -       mm = mm_access(task, PTRACE_MODE_READ);
> -       ret = PTR_ERR(mm);
> -       if (!mm || IS_ERR(mm))
> -               goto out_free;
> +               goto out_mm;
>
>         pagemap_walk.pmd_entry = pagemap_pte_range;
>         pagemap_walk.pte_hole = pagemap_pte_hole;
> @@ -1273,10 +1266,10 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
>         src = *ppos;
>         svpfn = src / PM_ENTRY_BYTES;
>         start_vaddr = svpfn << PAGE_SHIFT;
> -       end_vaddr = TASK_SIZE_OF(task);
> +       end_vaddr = mm->task_size;
>
>         /* watch out for wraparound */
> -       if (svpfn > TASK_SIZE_OF(task) >> PAGE_SHIFT)
> +       if (svpfn > mm->task_size >> PAGE_SHIFT)
>                 start_vaddr = end_vaddr;
>
>         /*
> @@ -1303,7 +1296,7 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
>                 len = min(count, PM_ENTRY_BYTES * pm.pos);
>                 if (copy_to_user(buf, pm.buffer, len)) {
>                         ret = -EFAULT;
> -                       goto out_mm;
> +                       goto out_free;
>                 }
>                 copied += len;
>                 buf += len;
> @@ -1313,24 +1306,38 @@ static ssize_t pagemap_read(struct file *file, char __user *buf,
>         if (!ret || ret == PM_END_OF_BUFFER)
>                 ret = copied;
>
> -out_mm:
> -       mmput(mm);
>  out_free:
>         kfree(pm.buffer);
> -out_task:
> -       put_task_struct(task);
> +out_mm:
> +       mmput(mm);
>  out:
>         return ret;
>  }
>
>  static int pagemap_open(struct inode *inode, struct file *file)
>  {
> +       struct mm_struct *mm;
> +
>         /* do not disclose physical addresses: attack vector */
>         if (!capable(CAP_SYS_ADMIN))
>                 return -EPERM;
>         pr_warn_once("Bits 55-60 of /proc/PID/pagemap entries are about "
>                         "to stop being page-shift some time soon. See the "
>                         "linux/Documentation/vm/pagemap.txt for details.\n");
> +
> +       mm = proc_mem_open(inode, PTRACE_MODE_READ);
> +       if (IS_ERR(mm))
> +               return PTR_ERR(mm);
> +       file->private_data = mm;
> +       return 0;
> +}
> +
> +static int pagemap_release(struct inode *inode, struct file *file)
> +{
> +       struct mm_struct *mm = file->private_data;
> +
> +       if (mm)
> +               mmdrop(mm);
>         return 0;
>  }
>
> @@ -1338,6 +1345,7 @@ const struct file_operations proc_pagemap_operations = {
>         .llseek         = mem_lseek, /* borrow this */
>         .read           = pagemap_read,
>         .open           = pagemap_open,
> +       .release        = pagemap_release,
>  };
>  #endif /* CONFIG_PROC_PAGE_MONITOR */
>
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
