Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx133.postini.com [74.125.245.133])
	by kanga.kvack.org (Postfix) with SMTP id 5B0EB6B0044
	for <linux-mm@kvack.org>; Tue,  9 Oct 2012 18:19:09 -0400 (EDT)
Date: Tue, 9 Oct 2012 15:19:07 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB
 v3
Message-Id: <20121009151907.3f61ebca.akpm@linux-foundation.org>
In-Reply-To: <1349303063-12766-2-git-send-email-andi@firstfloor.org>
References: <1349303063-12766-1-git-send-email-andi@firstfloor.org>
	<1349303063-12766-2-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andi Kleen <ak@linux.intel.com>, Michael Kerrisk <mtk.manpages@gmail.com>

On Wed,  3 Oct 2012 15:24:23 -0700
Andi Kleen <andi@firstfloor.org> wrote:

> From: Andi Kleen <ak@linux.intel.com>
> 
> There was some desire in large applications using MAP_HUGETLB/SHM_HUGETLB
> to use 1GB huge pages on some mappings, and stay with 2MB on others. This
> is useful together with NUMA policy: use 2MB interleaving on some mappings,
> but 1GB on local mappings.
> 
> This patch extends the IPC/SHM syscall interfaces slightly to allow specifying
> the page size.
> 
> It borrows some upper bits in the existing flag arguments and allows encoding
> the log of the desired page size in addition to the *_HUGETLB flag.
> When 0 is specified the default size is used, this makes the change fully
> compatible.
> 
> Extending the internal hugetlb code to handle this is straight forward. Instead
> of a single mount it just keeps an array of them and selects the right
> mount based on the specified page size.
> 
> I also exported the new flags to the user headers
> (they were previously under __KERNEL__). Right now only symbols
> for x86 and some other architecture for 1GB and 2MB are defined.
> The interface should already work for all other architectures
> though.

So some manpages need updating.  I'm not sure which - mmap(2) surely,
but which for the IPC change?

> v2: Port to new tree. Fix unmount.
> v3: Ported to latest tree.
> Acked-by: Rik van Riel <riel@redhat.com>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Andi Kleen <ak@linux.intel.com>
> ---
>  arch/x86/include/asm/mman.h |    3 ++
>  fs/hugetlbfs/inode.c        |   63 ++++++++++++++++++++++++++++++++++---------
>  include/asm-generic/mman.h  |   13 +++++++++
>  include/linux/hugetlb.h     |   12 +++++++-
>  include/linux/shm.h         |   19 +++++++++++++
>  ipc/shm.c                   |    3 +-
>  mm/mmap.c                   |    5 ++-

Alas, include/asm-generic/mman.h doesn't exist now.

Does this change touch all the hugetlb-capable architectures?

z:/usr/src/linux-3.6> grep -rl MAP_HUGETLB arch
arch/alpha/include/asm/mman.h
arch/xtensa/include/asm/mman.h
arch/parisc/include/asm/mman.h
arch/tile/include/asm/mman.h
arch/sparc/include/asm/mman.h
arch/powerpc/include/asm/mman.h
arch/mips/include/asm/mman.h

>
> ...
>
> @@ -933,9 +933,22 @@ static int can_do_hugetlb_shm(void)
>  	return capable(CAP_IPC_LOCK) || in_group_p(shm_group);
>  }
>  
> +static int get_hstate_idx(int page_size_log)

nitlet: "page_size_order" would be more kernely.  Or just "page_order".

> +{
> +	struct hstate *h;
> +
> +	if (!page_size_log)
> +		return default_hstate_idx;
> +	h = size_to_hstate(1 << page_size_log);
> +	if (!h)
> +		return -1;
> +	return h - hstates;
> +}
>
> ...
>
>  static int __init init_hugetlbfs_fs(void)
>  {
> +	struct hstate *h;
>  	int error;
> -	struct vfsmount *vfsmount;
> +	int i;
>  
>  	error = bdi_init(&hugetlbfs_backing_dev_info);
>  	if (error)
> @@ -1030,14 +1049,26 @@ static int __init init_hugetlbfs_fs(void)
>  	if (error)
>  		goto out;
>  
> -	vfsmount = kern_mount(&hugetlbfs_fs_type);
> +	i = 0;
> +	for_each_hstate (h) {
> +		char buf[50];
> +		unsigned ps_kb = 1U << (h->order + PAGE_SHIFT - 10);
>  
> -	if (!IS_ERR(vfsmount)) {
> -		hugetlbfs_vfsmount = vfsmount;
> -		return 0;
> -	}
> +		snprintf(buf, sizeof buf, "pagesize=%uK", ps_kb);
> +		hugetlbfs_vfsmount[i] = kern_mount_data(&hugetlbfs_fs_type,
> +							buf);
>  
> -	error = PTR_ERR(vfsmount);
> +		if (IS_ERR(hugetlbfs_vfsmount[i])) {
> +				pr_err(
> +			"hugetlb: Cannot mount internal hugetlbfs for page size %uK",
> +			       ps_kb);
> +			error = PTR_ERR(hugetlbfs_vfsmount[i]);
> +		}
> +		i++;
> +	}
> +	/* Non default hstates are optional */
> +	if (hugetlbfs_vfsmount[default_hstate_idx])
> +		return 0;

hm, so if I'm understanding this, the patch mounts hugetlbfs N times,
once for each page size.  And presumably the shm code somehow selects
one of these mounts, based on incoming flags.  And presumably if those
flags are all-zero, the behaviour is unaltered.

Please update the changelog to describe all this - the overview of how
the patch actually operates.

Also, all this affects the /proc/mounts contents, yes?  Let's changelog
that very-slightly-non-back-compatible user-visible change as well.

There's some overhead to doing all those additional mounts.  Can we
quantify it?

>
> ...
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
