Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 29E116B0033
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 11:16:48 -0400 (EDT)
Date: Wed, 24 Apr 2013 11:16:39 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1366816599-7fr82iw1-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130424081454.GA13994@cmpxchg.org>
References: <bug-56881-27@https.bugzilla.kernel.org/>
 <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org>
 <20130424081454.GA13994@cmpxchg.org>
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com, Steven Truelove <steven.truelove@utoronto.ca>

On Wed, Apr 24, 2013 at 04:14:54AM -0400, Johannes Weiner wrote:
> On Tue, Apr 23, 2013 at 01:25:22PM -0700, Andrew Morton wrote:
...
> hugetlb_get_unmapped_area() expects a hugepage-aligned size argument.
> Before do_mmap_pgoff() calls it, it does len = PAGE_ALIGN(len), which
> is why the second case works and the first one does not.
> 
> How about this (untested) partial revert of the above patch that keeps
> the shm alignment fix?

I have one comment about the suggested patch.

> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 84e3d85..13a7d51 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -929,9 +929,8 @@ static struct dentry_operations anon_ops = {
>  	.d_dname = hugetlb_dname
>  };
>  
> -struct file *hugetlb_file_setup(const char *name, unsigned long addr,
> -				size_t size, vm_flags_t acctflag,
> -				struct user_struct **user,
> +struct file *hugetlb_file_setup(const char *name, size_t size,
> +				vm_flags_t acctflag, struct user_struct **user,
>  				int creat_flags, int page_size_log)
>  {
>  	struct file *file = ERR_PTR(-ENOMEM);
> @@ -939,8 +938,6 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
>  	struct path path;
>  	struct super_block *sb;
>  	struct qstr quick_string;
> -	struct hstate *hstate;
> -	unsigned long num_pages;
>  	int hstate_idx;
>  
>  	hstate_idx = get_hstate_idx(page_size_log);
> @@ -980,12 +977,10 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
>  	if (!inode)
>  		goto out_dentry;
>  
> -	hstate = hstate_inode(inode);
> -	size += addr & ~huge_page_mask(hstate);
> -	num_pages = ALIGN(size, huge_page_size(hstate)) >>
> -			huge_page_shift(hstate);
>  	file = ERR_PTR(-ENOMEM);
> -	if (hugetlb_reserve_pages(inode, 0, num_pages, NULL, acctflag))
> +	if (hugetlb_reserve_pages(inode, 0,
> +			size >> huge_page_shift(hstate_inode(inode)), NULL,
> +			acctflag))
>  		goto out_inode;
>  
>  	d_instantiate(path.dentry, inode);
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> index 16e4e9a..437875c 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -185,8 +185,7 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
>  
>  extern const struct file_operations hugetlbfs_file_operations;
>  extern const struct vm_operations_struct hugetlb_vm_ops;
> -struct file *hugetlb_file_setup(const char *name, unsigned long addr,
> -				size_t size, vm_flags_t acct,
> +struct file *hugetlb_file_setup(const char *name, size_t size, vm_flags_t acct,
>  				struct user_struct **user, int creat_flags,
>  				int page_size_log);
>  
> @@ -205,9 +204,9 @@ static inline int is_file_hugepages(struct file *file)
>  
>  #define is_file_hugepages(file)			0
>  static inline struct file *
> -hugetlb_file_setup(const char *name, unsigned long addr, size_t size,
> -		vm_flags_t acctflag, struct user_struct **user, int creat_flags,
> -		int page_size_log)
> +hugetlb_file_setup(const char *name, size_t size, vm_flags_t acctflag,
> +		   struct user_struct **user, int creat_flags,
> +		   int page_size_log)
>  {
>  	return ERR_PTR(-ENOSYS);
>  }
> diff --git a/ipc/shm.c b/ipc/shm.c
> index cb858df..c1293d1 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -491,10 +491,13 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>  
>  	sprintf (name, "SYSV%08x", key);
>  	if (shmflg & SHM_HUGETLB) {
> +		unsigned int hugesize;
> +
>  		/* hugetlb_file_setup applies strict accounting */
>  		if (shmflg & SHM_NORESERVE)
>  			acctflag = VM_NORESERVE;
> -		file = hugetlb_file_setup(name, 0, size, acctflag,
> +		hugesize = ALIGN(size, huge_page_size(&default_hstate));
> +		file = hugetlb_file_setup(name, hugesize, acctflag,
>  				  &shp->mlock_user, HUGETLB_SHMFS_INODE,
>  				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK);
>  	} else {

Would it be better to find proper hstate instead of using default_hstate?

> diff --git a/mm/mmap.c b/mm/mmap.c
> index 6466699..36342dd 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1335,7 +1335,8 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  		 * A dummy user value is used because we are not locking
>  		 * memory so no accounting is necessary
>  		 */
> -		file = hugetlb_file_setup(HUGETLB_ANON_FILE, addr, len,
> +		len = ALIGN(len, huge_page_size(&default_hstate));
> +		file = hugetlb_file_setup(HUGETLB_ANON_FILE, len,
>  				VM_NORESERVE,
>  				&user, HUGETLB_ANONHUGE_INODE,
>  				(flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);
> 

ditto.

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
