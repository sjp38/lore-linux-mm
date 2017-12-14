Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D89D6B025E
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:43:45 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 3so4745068pfo.1
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 05:43:45 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u14si3232030pfh.288.2017.12.14.05.43.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 14 Dec 2017 05:43:44 -0800 (PST)
Date: Thu, 14 Dec 2017 14:43:38 +0100
From: Jan Kara <jack@suse.cz>
Subject: Re: [PATCH] mm: save/restore current->journal_info in handle_mm_fault
Message-ID: <20171214134338.GA1474@quack2.suse.cz>
References: <20171214105527.5885-1-zyan@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171214105527.5885-1-zyan@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Yan, Zheng" <zyan@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, ceph-devel@vger.kernel.org, linux-ext4@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, jlayton@redhat.com, stable@vger.kernel.org

On Thu 14-12-17 18:55:27, Yan, Zheng wrote:
> We recently got an Oops report:
> 
> BUG: unable to handle kernel NULL pointer dereference at (null)
> IP: jbd2__journal_start+0x38/0x1a2
> [...]
> Call Trace:
>   ext4_page_mkwrite+0x307/0x52b
>   _ext4_get_block+0xd8/0xd8
>   do_page_mkwrite+0x6e/0xd8
>   handle_mm_fault+0x686/0xf9b
>   mntput_no_expire+0x1f/0x21e
>   __do_page_fault+0x21d/0x465
>   dput+0x4a/0x2f7
>   page_fault+0x22/0x30
>   copy_user_generic_string+0x2c/0x40
>   copy_page_to_iter+0x8c/0x2b8
>   generic_file_read_iter+0x26e/0x845
>   timerqueue_del+0x31/0x90
>   ceph_read_iter+0x697/0xa33 [ceph]
>   hrtimer_cancel+0x23/0x41
>   futex_wait+0x1c8/0x24d
>   get_futex_key+0x32c/0x39a
>   __vfs_read+0xe0/0x130
>   vfs_read.part.1+0x6c/0x123
>   handle_mm_fault+0x831/0xf9b
>   __fget+0x7e/0xbf
>   SyS_read+0x4d/0xb5
> 
> ceph_read_iter() uses current->journal_info to pass context info to
> ceph_readpages(). Because ceph_readpages() needs to know if its caller
> has already gotten capability of using page cache (distinguish read
> from readahead/fadvise). ceph_read_iter() set current->journal_info,
> then calls generic_file_read_iter().
> 
> In above Oops, page fault happened when copying data to userspace.
> Page fault handler called ext4_page_mkwrite(). Ext4 code read
> current->journal_info and assumed it is journal handle.
> 
> I checked other filesystems, btrfs probably suffers similar problem
> for its readpage. (page fault happens when write() copies data from
> userspace memory and the memory is mapped to a file in btrfs.
> verify_parent_transid() can be called during readpage)
> 
> Cc: stable@vger.kernel.org
> Signed-off-by: "Yan, Zheng" <zyan@redhat.com>

I agree with the analysis but the patch is too ugly too live. Ceph just
should not be abusing current->journal_info for passing information between
two random functions or when it does a hackery like this, it should just
make sure the pieces hold together. Poluting generic code to accommodate
this hack in Ceph is not acceptable. Also bear in mind there are likely
other code paths (e.g. memory reclaim) which could recurse into another
filesystem confusing it with non-NULL current->journal_info in the same
way.

In this particular case I'm not sure why does ceph pass 'filp' into
readpage() / readpages() handler when it already gets that pointer as part
of arguments...

								Honza

> diff --git a/mm/memory.c b/mm/memory.c
> index a728bed16c20..db2a50233c49 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -4044,6 +4044,7 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  		unsigned int flags)
>  {
>  	int ret;
> +	void *old_journal_info;
>  
>  	__set_current_state(TASK_RUNNING);
>  
> @@ -4065,11 +4066,24 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
>  	if (flags & FAULT_FLAG_USER)
>  		mem_cgroup_oom_enable();
>  
> +	/*
> +	 * Fault can happen when filesystem A's read_iter()/write_iter()
> +	 * copies data to/from userspace. Filesystem A may have set
> +	 * current->journal_info. If the userspace memory is MAP_SHARED
> +	 * mapped to a file in filesystem B, we later may call filesystem
> +	 * B's vm operation. Filesystem B may also want to read/set
> +	 * current->journal_info.
> +	 */
> +	old_journal_info = current->journal_info;
> +	current->journal_info = NULL;
> +
>  	if (unlikely(is_vm_hugetlb_page(vma)))
>  		ret = hugetlb_fault(vma->vm_mm, vma, address, flags);
>  	else
>  		ret = __handle_mm_fault(vma, address, flags);
>  
> +	current->journal_info = old_journal_info;
> +
>  	if (flags & FAULT_FLAG_USER) {
>  		mem_cgroup_oom_disable();
>  		/*
> -- 
> 2.13.6
> 
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
