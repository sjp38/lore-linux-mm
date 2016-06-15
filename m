Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 80F846B007E
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 20:46:33 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id fg1so8232130pad.1
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 17:46:33 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id tv9si7099528pac.85.2016.06.14.17.46.31
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 17:46:32 -0700 (PDT)
Date: Wed, 15 Jun 2016 09:46:33 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v1 3/3] mm: per-process reclaim
Message-ID: <20160615004633.GC17127@bbox>
References: <040501d1c55a$81d51910$857f4b30$@alibaba-inc.com>
 <040601d1c55b$5934e6b0$0b9eb410$@alibaba-inc.com>
MIME-Version: 1.0
In-Reply-To: <040601d1c55b$5934e6b0$0b9eb410$@alibaba-inc.com>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hillf Danton <hillf.zj@alibaba-inc.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org

On Mon, Jun 13, 2016 at 06:07:09PM +0800, Hillf Danton wrote:
> > +static ssize_t reclaim_write(struct file *file, const char __user *buf,
> > +				size_t count, loff_t *ppos)
> > +{
> > +	struct task_struct *task;
> > +	char buffer[PROC_NUMBUF];
> > +	struct mm_struct *mm;
> > +	struct vm_area_struct *vma;
> > +	int itype;
> > +	int rv;
> > +	enum reclaim_type type;
> > +
> > +	memset(buffer, 0, sizeof(buffer));
> > +	if (count > sizeof(buffer) - 1)
> > +		count = sizeof(buffer) - 1;
> > +	if (copy_from_user(buffer, buf, count))
> > +		return -EFAULT;
> > +	rv = kstrtoint(strstrip(buffer), 10, &itype);
> > +	if (rv < 0)
> > +		return rv;
> > +	type = (enum reclaim_type)itype;
> > +	if (type < RECLAIM_FILE || type > RECLAIM_ALL)
> > +		return -EINVAL;
> > +
> > +	task = get_proc_task(file->f_path.dentry->d_inode);
> > +	if (!task)
> > +		return -ESRCH;
> > +
> > +	mm = get_task_mm(task);
> > +	if (mm) {
> > +		struct mm_walk reclaim_walk = {
> > +			.pmd_entry = reclaim_pte_range,
> > +			.mm = mm,
> > +		};
> > +
> > +		down_read(&mm->mmap_sem);
> > +		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> > +			reclaim_walk.private = vma;
> > +
> > +			if (is_vm_hugetlb_page(vma))
> > +				continue;
> > +
> > +			if (!vma_is_anonymous(vma) && !(type & RECLAIM_FILE))
> > +				continue;
> > +
> > +			if (vma_is_anonymous(vma) && !(type & RECLAIM_ANON))
> > +				continue;
> > +
> > +			walk_page_range(vma->vm_start, vma->vm_end,
> > +					&reclaim_walk);
> 
> Check fatal signal after reclaiming a mapping?

Yeb, We might need it in page_walker.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
