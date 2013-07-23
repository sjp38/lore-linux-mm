Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 0448A6B0031
	for <linux-mm@kvack.org>; Tue, 23 Jul 2013 09:23:07 -0400 (EDT)
Date: Tue, 23 Jul 2013 15:23:02 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v2 08/10] mm, hugetlb: add VM_NORESERVE check in
 vma_has_reserves()
Message-ID: <20130723132302.GC8677@dhcp22.suse.cz>
References: <1374482191-3500-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1374482191-3500-9-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1374482191-3500-9-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Mon 22-07-13 17:36:29, Joonsoo Kim wrote:
> If we map the region with MAP_NORESERVE and MAP_SHARED,
> we can skip to check reserve counting and eventually we cannot be ensured
> to allocate a huge page in fault time.
> With following example code, you can easily find this situation.
> 
> Assume 2MB, nr_hugepages = 100
> 
>         fd = hugetlbfs_unlinked_fd();
>         if (fd < 0)
>                 return 1;
> 
>         size = 200 * MB;
>         flag = MAP_SHARED;
>         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
>         if (p == MAP_FAILED) {
>                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>                 return -1;
>         }
> 
>         size = 2 * MB;
>         flag = MAP_ANONYMOUS | MAP_SHARED | MAP_HUGETLB | MAP_NORESERVE;
>         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, -1, 0);
>         if (p == MAP_FAILED) {
>                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>         }
>         p[0] = '0';
>         sleep(10);
> 
> During executing sleep(10), run 'cat /proc/meminfo' on another process.
> You'll find a mentioned problem.
> 
> non reserved shared mapping should not eat into reserve space. So
> return error when we don't find enough free space.

I guess I undestand what you are trying to tell but the changelog is
really hard to read. Please be explicit about what is the expected
result of the test and what is the fix doing. The reservation code is
quite complex already.
 
> Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 8a61638..87e73bd 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -464,6 +464,8 @@ void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
>  /* Returns true if the VMA has associated reserve pages */
>  static int vma_has_reserves(struct vm_area_struct *vma)
>  {
> +	if (vma->vm_flags & VM_NORESERVE)
> +		return 0;
>  	if (vma->vm_flags & VM_MAYSHARE)
>  		return 1;
>  	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
> -- 
> 1.7.9.5
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
