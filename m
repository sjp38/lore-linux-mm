Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 306246B0032
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 01:47:35 -0400 (EDT)
Received: from /spool/local
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 16 Jul 2013 15:35:16 +1000
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [9.190.234.120])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id DA6AF3578053
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 15:47:28 +1000 (EST)
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6G5WDak12714028
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 15:32:14 +1000
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6G5lQUn029483
	for <linux-mm@kvack.org>; Tue, 16 Jul 2013 15:47:27 +1000
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [PATCH 7/9] mm, hugetlb: add VM_NORESERVE check in vma_has_reserves()
In-Reply-To: <20130716021245.GI2430@lge.com>
References: <1373881967-16153-1-git-send-email-iamjoonsoo.kim@lge.com> <1373881967-16153-8-git-send-email-iamjoonsoo.kim@lge.com> <87li57j1tb.fsf@linux.vnet.ibm.com> <20130716021245.GI2430@lge.com>
Date: Tue, 16 Jul 2013 11:17:23 +0530
Message-ID: <874nbvhx90.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, David Gibson <david@gibson.dropbear.id.au>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:

> On Mon, Jul 15, 2013 at 08:41:12PM +0530, Aneesh Kumar K.V wrote:
>> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
>> 
>> > If we map the region with MAP_NORESERVE and MAP_SHARED,
>> > we can skip to check reserve counting and eventually we cannot be ensured
>> > to allocate a huge page in fault time.
>> > With following example code, you can easily find this situation.
>> >
>> > Assume 2MB, nr_hugepages = 100
>> >
>> >         fd = hugetlbfs_unlinked_fd();
>> >         if (fd < 0)
>> >                 return 1;
>> >
>> >         size = 200 * MB;
>> >         flag = MAP_SHARED;
>> >         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, fd, 0);
>> >         if (p == MAP_FAILED) {
>> >                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>> >                 return -1;
>> >         }
>> >
>> >         size = 2 * MB;
>> >         flag = MAP_ANONYMOUS | MAP_SHARED | MAP_HUGETLB | MAP_NORESERVE;
>> >         p = mmap(NULL, size, PROT_READ|PROT_WRITE, flag, -1, 0);
>> >         if (p == MAP_FAILED) {
>> >                 fprintf(stderr, "mmap() failed: %s\n", strerror(errno));
>> >         }
>> >         p[0] = '0';
>> >         sleep(10);
>> >
>> > During executing sleep(10), run 'cat /proc/meminfo' on another process.
>> > You'll find a mentioned problem.
>> >
>> > Solution is simple. We should check VM_NORESERVE in vma_has_reserves().
>> > This prevent to use a pre-allocated huge page if free count is under
>> > the reserve count.
>> 
>> You have a problem with this patch, which i guess you are fixing in
>> patch 9. Consider two process
>> 
>> a) MAP_SHARED  on fd
>> b) MAP_SHARED | MAP_NORESERVE on fd
>> 
>> We should allow the (b) to access the page even if VM_NORESERVE is set
>> and we are out of reserve space .
>
> I can't get your point.
> Please elaborate more on this.


One process mmap with MAP_SHARED and another one with MAP_SHARED | MAP_NORESERVE
Now the first process will result in reserving the pages from the hugtlb
pool. Now if the second process try to dequeue huge page and we don't
have free space we will fail because

vma_has_reservers will now return zero because VM_NORESERVE is set 
and we can have (h->free_huge_pages - h->resv_huge_pages) == 0;

The below hunk in your patch 9 handles that

 +	if (vma->vm_flags & VM_NORESERVE) {
 +		/*
 +		 * This address is already reserved by other process(chg == 0),
 +		 * so, we should decreament reserved count. Without
 +		 * decreamenting, reserve count is remained after releasing
 +		 * inode, because this allocated page will go into page cache
 +		 * and is regarded as coming from reserved pool in releasing
 +		 * step. Currently, we don't have any other solution to deal
 +		 * with this situation properly, so add work-around here.
 +		 */
 +		if (vma->vm_flags & VM_MAYSHARE && chg == 0)
 +			return 1;
 +		else
 +			return 0;
 +	}

so may be both of these should be folded ?

-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
