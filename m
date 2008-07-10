Date: Thu, 10 Jul 2008 18:39:54 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [RFC PATCH 3/4] hugetlb: hang off of /sys/kernel/mm rather than /sys/kernel
Message-ID: <20080710173954.GG6664@csn.ul.ie>
References: <20080708180348.GB14908@us.ibm.com> <20080708180542.GC14908@us.ibm.com> <20080708180644.GD14908@us.ibm.com> <20080708180751.GE14908@us.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20080708180751.GE14908@us.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nishanth Aravamudan <nacc@us.ibm.com>
Cc: npiggin@suse.de, agl@us.ibm.com, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On (08/07/08 11:07), Nishanth Aravamudan didst pronounce:
> To keep /sys/kernel uncluttered, use the newly created /sys/kernel/mm as
> the parent for the hugepage-controlling directories/files. Update the
> ABI file and redirect the user to the more complete vm/hugetlbpage.txt
> for details on hugepage usage.
> 
> Signed-off-by: Nishanth Aravamudan <nacc@us.ibm.com>
> 

Acked-by: Mel Gorman <mel@csn.ul.ie>

> ---
> Given the somewhat discombobulated state of hugetlbpage.txt, my next
> step will be to clean it up and reorganize the information therein.
> 
> diff --git a/Documentation/ABI/testing/sysfs-kernel-hugepages b/Documentation/ABI/testing/sysfs-kernel-hugepages
> deleted file mode 100644
> index 3457747..0000000
> --- a/Documentation/ABI/testing/sysfs-kernel-hugepages
> +++ /dev/null
> @@ -1,14 +0,0 @@
> -What:		/sys/kernel/hugepages/
> -Date:		June 2008
> -Contact:	Nishanth Aravamudan <nacc@us.ibm.com>, hugetlb maintainers
> -Description:
> -		/sys/kernel/hugepages/ contains a number of subdirectories
> -		of the form hugepages-<size>kb, where <size> is the page size
> -		of the hugepages supported by the kernel/CPU combination.
> -
> -		Under these directories are a number of files:
> -		nr_hugepages - minimum number of hugepages reserved
> -		nr_overcommit_hugepages - maximum number that can be allocated
> -		free_hugepages - number of hugepages free
> -		surplus_hugepages -
> -		resv_hugepages -
> diff --git a/Documentation/ABI/testing/sysfs-kernel-mm-hugepages b/Documentation/ABI/testing/sysfs-kernel-mm-hugepages
> new file mode 100644
> index 0000000..e21c005
> --- /dev/null
> +++ b/Documentation/ABI/testing/sysfs-kernel-mm-hugepages
> @@ -0,0 +1,15 @@
> +What:		/sys/kernel/mm/hugepages/
> +Date:		June 2008
> +Contact:	Nishanth Aravamudan <nacc@us.ibm.com>, hugetlb maintainers
> +Description:
> +		/sys/kernel/mm/hugepages/ contains a number of subdirectories
> +		of the form hugepages-<size>kB, where <size> is the page size
> +		of the hugepages supported by the kernel/CPU combination.
> +
> +		Under these directories are a number of files:
> +			nr_hugepages
> +			nr_overcommit_hugepages
> +			free_hugepages
> +			surplus_hugepages
> +			resv_hugepages
> +		See Documentation/vm/hugetlbpage.txt for details.
> diff --git a/Documentation/vm/hugetlbpage.txt b/Documentation/vm/hugetlbpage.txt
> index 899b343..ea8714f 100644
> --- a/Documentation/vm/hugetlbpage.txt
> +++ b/Documentation/vm/hugetlbpage.txt
> @@ -95,6 +95,29 @@ this condition holds, however, no more surplus huge pages will be
>  allowed on the system until one of the two sysctls are increased
>  sufficiently, or the surplus huge pages go out of use and are freed.
>  
> +With support for multiple hugepage pools at run-time available, much of
> +the hugepage userspace interface has been duplicated in sysfs. The above
> +information applies to the default hugepage size (which will be
> +controlled by the proc interfaces for backwards compatibility). The root
> +hugepage control directory is
> +
> +	/sys/kernel/mm/hugepages
> +
> +For each hugepage size supported by the running kernel, a subdirectory
> +will exist, of the form
> +
> +	hugepages-${size}kB
> +
> +Inside each of these directories, the same set of files will exist:
> +
> +	nr_hugepages
> +	nr_overcommit_hugepages
> +	free_hugepages
> +	resv_hugepages
> +	surplus_hugepages
> +
> +which function as described above for the default hugepage-sized case.
> +
>  If the user applications are going to request hugepages using mmap system
>  call, then it is required that system administrator mount a file system of
>  type hugetlbfs:
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 14bfe17..9c24f8f 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1258,7 +1258,7 @@ static void __init hugetlb_sysfs_init(void)
>  	struct hstate *h;
>  	int err;
>  
> -	hugepages_kobj = kobject_create_and_add("hugepages", kernel_kobj);
> +	hugepages_kobj = kobject_create_and_add("hugepages", mm_kobj);
>  	if (!hugepages_kobj)
>  		return;
>  
> -- 
> Nishanth Aravamudan <nacc@us.ibm.com>
> IBM Linux Technology Center
> 

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
