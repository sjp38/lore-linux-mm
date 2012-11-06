Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id E7AEF6B0044
	for <linux-mm@kvack.org>; Tue,  6 Nov 2012 16:27:38 -0500 (EST)
Date: Tue, 6 Nov 2012 13:27:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] MM: Support more pagesizes for MAP_HUGETLB/SHM_HUGETLB
 v7
Message-Id: <20121106132737.c2aa3c47.akpm@linux-foundation.org>
In-Reply-To: <1352157848-29473-2-git-send-email-andi@firstfloor.org>
References: <1352157848-29473-1-git-send-email-andi@firstfloor.org>
	<1352157848-29473-2-git-send-email-andi@firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mtk.manpages@gmail.com, Andi Kleen <ak@linux.intel.com>, Hillf Danton <dhillf@gmail.com>

On Mon,  5 Nov 2012 15:24:08 -0800
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
> mount based on the specified page size. When no page size is specified
> it uses the mount of the default page size.
> 
> The change is not visible in /proc/mounts because internal mounts
> don't appear there. It also has very little overhead: the additional
> mounts just consume a super block, but not more memory when not used.
> 
> I also exported the new flags to the user headers
> (they were previously under __KERNEL__). Right now only symbols
> for x86 and some other architecture for 1GB and 2MB are defined.
> The interface should already work for all other architectures
> though.  Only architectures that define multiple hugetlb sizes
> actually need it (that is currently x86, tile, powerpc). However
> tile and powerpc have user configurable hugetlb sizes, so it's
> not easy to add defines. A program on those architectures would
> need to query sysfs and use the appropiate log2.

I can't say the userspace interface is a thing of beauty, but I guess
we'll live.

Did you have a test app?  If so, can we get it into
tools/testing/selftests and point the arch maintainers at it?

>
> ...
>
> @@ -1011,8 +1029,9 @@ out_shm_unlock:
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
> @@ -1029,14 +1048,27 @@ static int __init init_hugetlbfs_fs(void)
>  	if (error)
>  		goto out;
>  
> -	vfsmount = kern_mount(&hugetlbfs_fs_type);
> -
> -	if (!IS_ERR(vfsmount)) {
> -		hugetlbfs_vfsmount = vfsmount;
> -		return 0;
> +	i = 0;
> +	for_each_hstate (h) {
> +		char buf[50];
> +		unsigned ps_kb = 1U << (h->order + PAGE_SHIFT - 10);
> +
> +		snprintf(buf, sizeof buf, "pagesize=%uK", ps_kb);
> +		hugetlbfs_vfsmount[i] = kern_mount_data(&hugetlbfs_fs_type,
> +							buf);
> +
> +		if (IS_ERR(hugetlbfs_vfsmount[i])) {
> +				pr_err(
> +			"hugetlb: Cannot mount internal hugetlbfs for page size %uK",
> +			       ps_kb);
> +			error = PTR_ERR(hugetlbfs_vfsmount[i]);
> +			hugetlbfs_vfsmount[i] = NULL;
> +		}
> +		i++;
>  	}

hm, that's a bit messed up.

--- a/fs/hugetlbfs/inode.c~mm-support-more-pagesizes-for-map_hugetlb-shm_hugetlb-v7-fix
+++ a/fs/hugetlbfs/inode.c
@@ -1049,7 +1049,7 @@ static int __init init_hugetlbfs_fs(void
 		goto out;
 
 	i = 0;
-	for_each_hstate (h) {
+	for_each_hstate(h) {
 		char buf[50];
 		unsigned ps_kb = 1U << (h->order + PAGE_SHIFT - 10);
 
@@ -1058,9 +1058,8 @@ static int __init init_hugetlbfs_fs(void
 							buf);
 
 		if (IS_ERR(hugetlbfs_vfsmount[i])) {
-				pr_err(
-			"hugetlb: Cannot mount internal hugetlbfs for page size %uK",
-			       ps_kb);
+			pr_err("hugetlb: Cannot mount internal hugetlbfs for "
+				"page size %uK", ps_kb);
 			error = PTR_ERR(hugetlbfs_vfsmount[i]);
 			hugetlbfs_vfsmount[i] = NULL;
 		}
@@ -1090,7 +1089,7 @@ static void __exit exit_hugetlbfs_fs(voi
 	rcu_barrier();
 	kmem_cache_destroy(hugetlbfs_inode_cachep);
 	i = 0;
-	for_each_hstate (h)
+	for_each_hstate(h)
 		kern_unmount(hugetlbfs_vfsmount[i++]);
 	unregister_filesystem(&hugetlbfs_fs_type);
 	bdi_destroy(&hugetlbfs_backing_dev_info);

(we're not supposed to split strings like that, but screw 'em!)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
