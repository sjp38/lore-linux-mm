Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 69E456B025E
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 06:07:25 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id t8so170501834oif.2
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 03:07:25 -0700 (PDT)
Received: from out4440.biz.mail.alibaba.com (out4440.biz.mail.alibaba.com. [47.88.44.40])
        by mx.google.com with ESMTP id n203si11949124itg.50.2016.06.13.03.07.23
        for <linux-mm@kvack.org>;
        Mon, 13 Jun 2016 03:07:24 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <040501d1c55a$81d51910$857f4b30$@alibaba-inc.com>
In-Reply-To: <040501d1c55a$81d51910$857f4b30$@alibaba-inc.com>
Subject: Re: [PATCH v1 3/3] mm: per-process reclaim
Date: Mon, 13 Jun 2016 18:07:09 +0800
Message-ID: <040601d1c55b$5934e6b0$0b9eb410$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

> +static ssize_t reclaim_write(struct file *file, const char __user *buf,
> +				size_t count, loff_t *ppos)
> +{
> +	struct task_struct *task;
> +	char buffer[PROC_NUMBUF];
> +	struct mm_struct *mm;
> +	struct vm_area_struct *vma;
> +	int itype;
> +	int rv;
> +	enum reclaim_type type;
> +
> +	memset(buffer, 0, sizeof(buffer));
> +	if (count > sizeof(buffer) - 1)
> +		count = sizeof(buffer) - 1;
> +	if (copy_from_user(buffer, buf, count))
> +		return -EFAULT;
> +	rv = kstrtoint(strstrip(buffer), 10, &itype);
> +	if (rv < 0)
> +		return rv;
> +	type = (enum reclaim_type)itype;
> +	if (type < RECLAIM_FILE || type > RECLAIM_ALL)
> +		return -EINVAL;
> +
> +	task = get_proc_task(file->f_path.dentry->d_inode);
> +	if (!task)
> +		return -ESRCH;
> +
> +	mm = get_task_mm(task);
> +	if (mm) {
> +		struct mm_walk reclaim_walk = {
> +			.pmd_entry = reclaim_pte_range,
> +			.mm = mm,
> +		};
> +
> +		down_read(&mm->mmap_sem);
> +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +			reclaim_walk.private = vma;
> +
> +			if (is_vm_hugetlb_page(vma))
> +				continue;
> +
> +			if (!vma_is_anonymous(vma) && !(type & RECLAIM_FILE))
> +				continue;
> +
> +			if (vma_is_anonymous(vma) && !(type & RECLAIM_ANON))
> +				continue;
> +
> +			walk_page_range(vma->vm_start, vma->vm_end,
> +					&reclaim_walk);

Check fatal signal after reclaiming a mapping?

> +		}
> +		flush_tlb_mm(mm);
> +		up_read(&mm->mmap_sem);
> +		mmput(mm);
> +	}
> +	put_task_struct(task);
> +
> +	return count;
> +}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
