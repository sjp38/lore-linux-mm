Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx137.postini.com [74.125.245.137])
	by kanga.kvack.org (Postfix) with SMTP id ADBAF6B0032
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 04:55:21 -0400 (EDT)
Received: from /spool/local
	by e23smtp06.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Wed, 17 Jul 2013 18:47:35 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 220EF2BB0051
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 18:55:13 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6H8dlfq63307792
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 18:39:48 +1000
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6H8tAab002803
	for <linux-mm@kvack.org>; Wed, 17 Jul 2013 18:55:11 +1000
Date: Wed, 17 Jul 2013 04:55:09 -0400
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 6/9] mm, hugetlb: do not use a page in page cache for cow
 optimization
Message-ID: <20130717085508.GA27397@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1373881967-16153-7-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1373881967-16153-7-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>

On Mon, Jul 15, 2013 at 06:52:44PM +0900, Joonsoo Kim wrote:
>Currently, we use a page with mapped count 1 in page cache for cow
>optimization. If we find this condition, we don't allocate a new
>page and copy contents. Instead, we map this page directly.
>This may introduce a problem that writting to private mapping overwrite
>hugetlb file directly. You can find this situation with following code.
>
>        size = 20 * MB;
>        flag = MAP_SHARED;
>        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
>        if (p == MAP_FAILED) {
>                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>                return -1;
>        }
>        p[0] = 's';
>        fprintf(stdout, "BEFORE STEAL PRIVATE WRITE: %c\n", p[0]);
>        munmap(p, size);
>
>        flag = MAP_PRIVATE;
>        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
>        if (p == MAP_FAILED) {
>                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>        }
>        p[0] = 'c';
>        munmap(p, size);
>
>        flag = MAP_SHARED;
>        p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
>        if (p == MAP_FAILED) {
>                fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>                return -1;
>        }
>        fprintf(stdout, "AFTER STEAL PRIVATE WRITE: %c\n", p[0]);
>        munmap(p, size);
>
>We can see that "AFTER STEAL PRIVATE WRITE: c", not "AFTER STEAL
>PRIVATE WRITE: s". If we turn off this optimization to a page
>in page cache, the problem is disappeared.
>
>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>

Good catch!

Reviewed-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

>diff --git a/mm/hugetlb.c b/mm/hugetlb.c
>index d4a1695..6c1eb9b 100644
>--- a/mm/hugetlb.c
>+++ b/mm/hugetlb.c
>@@ -2512,7 +2512,6 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> {
> 	struct hstate *h = hstate_vma(vma);
> 	struct page *old_page, *new_page;
>-	int avoidcopy;
> 	int outside_reserve = 0;
> 	unsigned long mmun_start;	/* For mmu_notifiers */
> 	unsigned long mmun_end;		/* For mmu_notifiers */
>@@ -2522,10 +2521,8 @@ static int hugetlb_cow(struct mm_struct *mm, struct vm_area_struct *vma,
> retry_avoidcopy:
> 	/* If no-one else is actually using this page, avoid the copy
> 	 * and just make the page writable */
>-	avoidcopy = (page_mapcount(old_page) == 1);
>-	if (avoidcopy) {
>-		if (PageAnon(old_page))
>-			page_move_anon_rmap(old_page, vma, address);
>+	if (page_mapcount(old_page) == 1 && PageAnon(old_page)) {
>+		page_move_anon_rmap(old_page, vma, address);
> 		set_huge_ptep_writable(vma, address, ptep);
> 		return 0;
> 	}
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
