Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 403E06B6F01
	for <linux-mm@kvack.org>; Tue,  4 Sep 2018 15:02:44 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id r2-v6so2239226pgp.3
        for <linux-mm@kvack.org>; Tue, 04 Sep 2018 12:02:44 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id m32-v6si22019507pld.404.2018.09.04.12.02.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 04 Sep 2018 12:02:42 -0700 (PDT)
Date: Tue, 4 Sep 2018 12:02:41 -0700
From: Sean Christopherson <sean.j.christopherson@intel.com>
Subject: Re: [RFC][PATCH 2/5] [PATCH 2/5] proc: introduce
 /proc/PID/idle_bitmap
Message-ID: <20180904190241.GB5869@linux.intel.com>
References: <20180901112818.126790961@intel.com>
 <20180901124811.530300789@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180901124811.530300789@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Huang Ying <ying.huang@intel.com>, Brendan Gregg <bgregg@netflix.com>, Peng DongX <dongx.peng@intel.com>, Liu Jingqi <jingqi.liu@intel.com>, Dong Eddie <eddie.dong@intel.com>, Dave Hansen <dave.hansen@intel.com>, kvm@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>

On Sat, Sep 01, 2018 at 07:28:20PM +0800, Fengguang Wu wrote:
> diff --git a/fs/proc/internal.h b/fs/proc/internal.h
> index da3dbfa09e79..732a502acc27 100644
> --- a/fs/proc/internal.h
> +++ b/fs/proc/internal.h
> @@ -305,6 +305,7 @@ extern const struct file_operations proc_pid_smaps_rollup_operations;
>  extern const struct file_operations proc_tid_smaps_operations;
>  extern const struct file_operations proc_clear_refs_operations;
>  extern const struct file_operations proc_pagemap_operations;
> +extern const struct file_operations proc_mm_idle_operations;
>  
>  extern unsigned long task_vsize(struct mm_struct *);
>  extern unsigned long task_statm(struct mm_struct *,
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index dfd73a4616ce..376406a9cf45 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -1564,6 +1564,69 @@ const struct file_operations proc_pagemap_operations = {
>  	.open		= pagemap_open,
>  	.release	= pagemap_release,
>  };
> +
> +/* will be filled when kvm_ept_idle module loads */
> +struct file_operations proc_ept_idle_operations = {
> +};
> +EXPORT_SYMBOL_GPL(proc_ept_idle_operations);

Exposing EPT outside of VMX specific code is wrong, e.g. this should
be something like proc_kvm_idle_operations.  This is a common theme
for all of the patches.  Only the low level bits that are EPT specific
should be named as such, everything else should be encapsulated via
KVM or some other appropriate name. 

> +static ssize_t mm_idle_read(struct file *file, char __user *buf,
> +			    size_t count, loff_t *ppos)
> +{
> +	struct task_struct *task = file->private_data;
> +	ssize_t ret = -ESRCH;

No need for @ret, just return the error directly at the end.  And
-ESRCH isn't appropriate for a task that exists but doesn't have an
associated KVM object.

> +
> +	// TODO: implement mm_walk for normal tasks
> +
> +	if (task_kvm(task)) {
> +		if (proc_ept_idle_operations.read)
> +			return proc_ept_idle_operations.read(file, buf, count, ppos);
> +	}

Condensing the task_kvm and ops check into a single if saves two lines
per instance, e.g.:

	if (task_kvm(task) && proc_ept_idle_operations.read)
		return proc_ept_idle_operations.read(file, buf, count, ppos);
> +
> +	return ret;
> +}
> +
> +
> +static int mm_idle_open(struct inode *inode, struct file *file)
> +{
> +	struct task_struct *task = get_proc_task(inode);
> +
> +	if (!task)
> +		return -ESRCH;
> +
> +	file->private_data = task;
> +
> +	if (task_kvm(task)) {
> +		if (proc_ept_idle_operations.open)
> +			return proc_ept_idle_operations.open(inode, file);
> +	}
> +
> +	return 0;
> +}
> +
> +static int mm_idle_release(struct inode *inode, struct file *file)
> +{
> +	struct task_struct *task = file->private_data;
> +
> +	if (!task)
> +		return 0;
> +
> +	if (task_kvm(task)) {
> +		if (proc_ept_idle_operations.release)
> +			return proc_ept_idle_operations.release(inode, file);
> +	}
> +
> +	put_task_struct(task);
> +	return 0;
> +}
> +
> +const struct file_operations proc_mm_idle_operations = {
> +	.llseek		= mem_lseek, /* borrow this */
> +	.read		= mm_idle_read,
> +	.open		= mm_idle_open,
> +	.release	= mm_idle_release,
> +};
> +
>  #endif /* CONFIG_PROC_PAGE_MONITOR */
>  
>  #ifdef CONFIG_NUMA
> -- 
> 2.15.0
> 
> 
> 
