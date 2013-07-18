Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id BAB016B0036
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 22:04:07 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Thu, 18 Jul 2013 11:54:00 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 51BAD2CE802D
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 12:04:01 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6I1mZOg852472
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 11:48:35 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6I23xL0026920
	for <linux-mm@kvack.org>; Thu, 18 Jul 2013 12:04:00 +1000
Date: Wed, 17 Jul 2013 22:03:58 -0400
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 7/9] mm, hugetlb: add VM_NORESERVE check in
 vma_has_reserves()
Message-ID: <20130718020358.GB10133@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1373881967-16153-8-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373881967-16153-8-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Mon, Jul 15, 2013 at 06:52:45PM +0900, Joonsoo Kim wrote:
>If we map the region with MAP_NORESERVE and MAP_SHARED,
>we can skip to check reserve counting and eventually we cannot be ensured
>to allocate a huge page in fault time.
>With following example code, you can easily find this situation.
>
>Assume 2MB, nr_hugepages = 100
>
>        fd = hugetlbfs_unlinked_fd();
>        if (fd < 0)
>                return 1;
>
>        size = 200 * MB;
>        flag = MAP_SHARED;
>        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
>        if (p == MAP_FAILED) {
>                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>                return -1;
>        }
>
>        size = 2 * MB;
>        flag = MAP_ANONYMOUS | MAP_SHARED | MAP_HUGETLB | MAP_NORESERVE;
>        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, -1, 0);
>        if (p == MAP_FAILED) {
>                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>        }
>        p[0] = '0';
>        sleep(10);
>
>During executing sleep(10), run 'cat /proc/meminfo' on another process.
>You'll find a mentioned problem.
>
>Solution is simple. We should check VM_NORESERVE in vma_has_reserves().
>This prevent to use a pre-allocated huge page if free count is under
>the reserve count.
>

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>index 6c1eb9b..f6a7a4e 100644
>--- a/mm/hugetlb.c
>+++ b/mm/hugetlb.c
>@@ -464,6 +464,8 @@ void reset_vma_resv_huge_pages(struct vm_area_struct *vma)
> /* Returns true if the VMA has associated reserve pages */
> static int vma_has_reserves(struct vm_area_struct *vma)
> {
>+	if (vma->vm_flags & VM_NORESERVE)
>+		return 0;
> 	if (vma->vm_flags & VM_MAYSHARE)
> 		return 1;
> 	if (is_vma_resv_set(vma, HPAGE_RESV_OWNER))
>-- 
>1.7.9.5
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
