Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 8F7B86B0032
	for <linux-mm@kvack.org>; Wed, 24 Apr 2013 23:03:27 -0400 (EDT)
Message-ID: <51789CE3.6020709@huawei.com>
Date: Thu, 25 Apr 2013 11:02:59 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [Bug 56881] New: MAP_HUGETLB mmap fails for certain sizes
References: <bug-56881-27@https.bugzilla.kernel.org/> <20130423132522.042fa8d27668bbca6a410a92@linux-foundation.org> <20130424081454.GA13994@cmpxchg.org> <1366816599-7fr82iw1-mutt-n-horiguchi@ah.jp.nec.com> <20130424153951.GQ2018@cmpxchg.org> <1366844735-kqynvvnu-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <1366844735-kqynvvnu-mutt-n-horiguchi@ah.jp.nec.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org, iceman_dvd@yahoo.com, Steven Truelove <steven.truelove@utoronto.ca>

On 2013/4/25 7:05, Naoya Horiguchi wrote:

> On Wed, Apr 24, 2013 at 11:39:51AM -0400, Johannes Weiner wrote:
>> On Wed, Apr 24, 2013 at 11:16:39AM -0400, Naoya Horiguchi wrote:
>>> On Wed, Apr 24, 2013 at 04:14:54AM -0400, Johannes Weiner wrote:
>>>> @@ -491,10 +491,13 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>>>>  
>>>>  	sprintf (name, "SYSV%08x", key);
>>>>  	if (shmflg & SHM_HUGETLB) {
>>>> +		unsigned int hugesize;
>>>> +
>>>>  		/* hugetlb_file_setup applies strict accounting */
>>>>  		if (shmflg & SHM_NORESERVE)
>>>>  			acctflag = VM_NORESERVE;
>>>> -		file = hugetlb_file_setup(name, 0, size, acctflag,
>>>> +		hugesize = ALIGN(size, huge_page_size(&default_hstate));
>>>> +		file = hugetlb_file_setup(name, hugesize, acctflag,
>>>>  				  &shp->mlock_user, HUGETLB_SHMFS_INODE,
>>>>  				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK);
>>>>  	} else {
>>>
>>> Would it be better to find proper hstate instead of using default_hstate?
>>
>> You are probably right, I guess we can't assume default_hstate anymore
>> after page_size_log can be passed in.
>>
>> Can we have hugetlb_file_setup() return an adjusted length, or an
>> alignment requirement?
> 
> Yes, it's possible if callers pass the pointer of size (length) to
> hugetlb_file_setup() and make it adjusted inside the function.
> And as for alignment, I think it's not a hugetlb_file_setup's job,
> so we don't have to do it in this function.
> 
>> Or pull the hstate lookup into the callsites (since they pass in
>> page_size_log to begin with)?
> 
> This is also a possible solution, where we might need to define and
> export a function converting hugepage order to hstate.
> 
> I like the former one, so wrote a patch like below.
> # I added your Signed-off-by: because this's based on your draft patch.
> # if you don't like it, please let me know.
> 
> Thanks,
> Naoya Horiguchi
> ---
> From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Date: Wed, 24 Apr 2013 16:44:19 -0400
> Subject: [PATCH] hugetlbfs: fix mmap failure in unaligned size request
> 
> As reported in https://bugzilla.kernel.org/show_bug.cgi?id=56881, current
> kernel returns -EINVAL unless a given mmap length is "almost" hugepage
> aligned. This is because in sys_mmap_pgoff() the given length is passed to
> vm_mmap_pgoff() as it is without being aligned with hugepage boundary.
> 
> This is a regression introduced in commit 40716e29243d "hugetlbfs: fix
> alignment of huge page requests", where alignment code is pushed into
> hugetlb_file_setup() and the variable len in caller side is not changed.
> 
> To fix this, this patch partially reverts that commit, and changes
> the type of parameter size from size_t to (size_t *) in order to
> align the size in caller side.
> 

Hi Naoya,

This patch only fix anonymous hugetlb mmap case, should also fix hugetlbfs file mmap case?

diff --git a/mm/mmap.c b/mm/mmap.c
index 0db0de1..5ed9561 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -1327,6 +1327,8 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
 		file = fget(fd);
 		if (!file)
 			goto out;
+		else if (is_file_hugepages(file))
+			len = ALIGN(len, huge_page_size(hstate_file(file)));
 	} else if (flags & MAP_HUGETLB) {
 		struct user_struct *user = NULL;
 		/*

Thanks,
Jianguo Wu

> Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
>  fs/hugetlbfs/inode.c    | 20 ++++++++++----------
>  include/linux/hugetlb.h |  7 +++----
>  ipc/shm.c               |  2 +-
>  mm/mmap.c               |  2 +-
>  4 files changed, 15 insertions(+), 16 deletions(-)
> 
> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
> index 523464e..7adbd7b 100644
> --- a/fs/hugetlbfs/inode.c
> +++ b/fs/hugetlbfs/inode.c
> @@ -929,9 +929,8 @@ static struct dentry_operations anon_ops = {
>  	.d_dname = hugetlb_dname
>  };
>  
> -struct file *hugetlb_file_setup(const char *name, unsigned long addr,
> -				size_t size, vm_flags_t acctflag,
> -				struct user_struct **user,
> +struct file *hugetlb_file_setup(const char *name, size_t *sizeptr,
> +				vm_flags_t acctflag, struct user_struct **user,
>  				int creat_flags, int page_size_log)
>  {
>  	struct file *file = ERR_PTR(-ENOMEM);
> @@ -939,9 +938,8 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
>  	struct path path;
>  	struct super_block *sb;
>  	struct qstr quick_string;
> -	struct hstate *hstate;
> -	unsigned long num_pages;
>  	int hstate_idx;
> +	size_t size;
>  
>  	hstate_idx = get_hstate_idx(page_size_log);
>  	if (hstate_idx < 0)
> @@ -951,6 +949,10 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
>  	if (!hugetlbfs_vfsmount[hstate_idx])
>  		return ERR_PTR(-ENOENT);
>  
> +	size = 1 << hstate_index_to_shift(hstate_idx);
> +	if (sizeptr)
> +		*sizeptr = ALIGN(*sizeptr, size);
> +
>  	if (creat_flags == HUGETLB_SHMFS_INODE && !can_do_hugetlb_shm()) {
>  		*user = current_user();
>  		if (user_shm_lock(size, *user)) {
> @@ -980,12 +982,10 @@ struct file *hugetlb_file_setup(const char *name, unsigned long addr,
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
> index 8220a8a..ca67d42 100644
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -193,8 +193,7 @@ static inline struct hugetlbfs_sb_info *HUGETLBFS_SB(struct super_block *sb)
>  
>  extern const struct file_operations hugetlbfs_file_operations;
>  extern const struct vm_operations_struct hugetlb_vm_ops;
> -struct file *hugetlb_file_setup(const char *name, unsigned long addr,
> -				size_t size, vm_flags_t acct,
> +struct file *hugetlb_file_setup(const char *name, size_t *size, vm_flags_t acct,
>  				struct user_struct **user, int creat_flags,
>  				int page_size_log);
>  
> @@ -213,8 +212,8 @@ static inline int is_file_hugepages(struct file *file)
>  
>  #define is_file_hugepages(file)			0
>  static inline struct file *
> -hugetlb_file_setup(const char *name, unsigned long addr, size_t size,
> -		vm_flags_t acctflag, struct user_struct **user, int creat_flags,
> +hugetlb_file_setup(const char *name, size_t *size, vm_flags_t acctflag,
> +		struct user_struct **user, int creat_flags,
>  		int page_size_log)
>  {
>  	return ERR_PTR(-ENOSYS);
> diff --git a/ipc/shm.c b/ipc/shm.c
> index cb858df..e2cb809 100644
> --- a/ipc/shm.c
> +++ b/ipc/shm.c
> @@ -494,7 +494,7 @@ static int newseg(struct ipc_namespace *ns, struct ipc_params *params)
>  		/* hugetlb_file_setup applies strict accounting */
>  		if (shmflg & SHM_NORESERVE)
>  			acctflag = VM_NORESERVE;
> -		file = hugetlb_file_setup(name, 0, size, acctflag,
> +		file = hugetlb_file_setup(name, NULL, acctflag,
>  				  &shp->mlock_user, HUGETLB_SHMFS_INODE,
>  				(shmflg >> SHM_HUGE_SHIFT) & SHM_HUGE_MASK);
>  	} else {
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 2664a47..d03a541 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1333,7 +1333,7 @@ SYSCALL_DEFINE6(mmap_pgoff, unsigned long, addr, unsigned long, len,
>  		 * A dummy user value is used because we are not locking
>  		 * memory so no accounting is necessary
>  		 */
> -		file = hugetlb_file_setup(HUGETLB_ANON_FILE, addr, len,
> +		file = hugetlb_file_setup(HUGETLB_ANON_FILE, &len,
>  				VM_NORESERVE,
>  				&user, HUGETLB_ANONHUGE_INODE,
>  				(flags >> MAP_HUGE_SHIFT) & MAP_HUGE_MASK);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
