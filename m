Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6DB9D6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 10:25:13 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id l66so51867342pfl.7
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 07:25:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id u89si31842108pfg.283.2016.11.07.07.25.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 07:25:12 -0800 (PST)
Received: from pps.filterd (m0098394.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id uA7FNWjP057124
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 10:25:12 -0500
Received: from e06smtp11.uk.ibm.com (e06smtp11.uk.ibm.com [195.75.94.107])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26jpfkc2nj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 07 Nov 2016 10:25:10 -0500
Received: from localhost
	by e06smtp11.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <gerald.schaefer@de.ibm.com>;
	Mon, 7 Nov 2016 15:25:08 -0000
Received: from b06cxnps4075.portsmouth.uk.ibm.com (d06relay12.portsmouth.uk.ibm.com [9.149.109.197])
	by d06dlp03.portsmouth.uk.ibm.com (Postfix) with ESMTP id 203501B08067
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 15:27:19 +0000 (GMT)
Received: from d06av01.portsmouth.uk.ibm.com (d06av01.portsmouth.uk.ibm.com [9.149.37.212])
	by b06cxnps4075.portsmouth.uk.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id uA7FP7Ta6422800
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 15:25:07 GMT
Received: from d06av01.portsmouth.uk.ibm.com (localhost [127.0.0.1])
	by d06av01.portsmouth.uk.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id uA7FP60a013839
	for <linux-mm@kvack.org>; Mon, 7 Nov 2016 08:25:06 -0700
Date: Mon, 7 Nov 2016 16:25:04 +0100
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Subject: Re: [PATCH 2/2] mm: hugetlb: support gigantic surplus pages
In-Reply-To: <1478141499-13825-3-git-send-email-shijie.huang@arm.com>
References: <1478141499-13825-1-git-send-email-shijie.huang@arm.com>
	<1478141499-13825-3-git-send-email-shijie.huang@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Message-Id: <20161107162504.17591806@thinkpad>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Huang Shijie <shijie.huang@arm.com>
Cc: akpm@linux-foundation.org, catalin.marinas@arm.com, n-horiguchi@ah.jp.nec.com, mhocko@suse.com, kirill.shutemov@linux.intel.com, aneesh.kumar@linux.vnet.ibm.com, mike.kravetz@oracle.com, linux-mm@kvack.org, will.deacon@arm.com, steve.capper@arm.com, kaly.xin@arm.com, nd@arm.com, linux-arm-kernel@lists.infradead.org

On Thu, 3 Nov 2016 10:51:38 +0800
Huang Shijie <shijie.huang@arm.com> wrote:

> When testing the gigantic page whose order is too large for the buddy
> allocator, the libhugetlbfs test case "counter.sh" will fail.
> 
> The failure is caused by:
>  1) kernel fails to allocate a gigantic page for the surplus case.
>     And the gather_surplus_pages() will return NULL in the end.
> 
>  2) The condition checks for "over-commit" is wrong.
> 
> This patch adds code to allocate the gigantic page in the
> __alloc_huge_page(). After this patch, gather_surplus_pages()
> can return a gigantic page for the surplus case.
> 
> This patch also changes the condition checks for:
>      return_unused_surplus_pages()
>      nr_overcommit_hugepages_store()
> 
> After this patch, the counter.sh can pass for the gigantic page.
> 
> Acked-by: Steve Capper <steve.capper@arm.com>
> Signed-off-by: Huang Shijie <shijie.huang@arm.com>
> ---
>  mm/hugetlb.c | 15 ++++++++++-----
>  1 file changed, 10 insertions(+), 5 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 0bf4444..2b67aff 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -1574,7 +1574,7 @@ static struct page *__alloc_huge_page(struct hstate *h,
>  	struct page *page;
>  	unsigned int r_nid;
> 
> -	if (hstate_is_gigantic(h))
> +	if (hstate_is_gigantic(h) && !gigantic_page_supported())
>  		return NULL;

Is it really possible to stumble over gigantic pages w/o having
gigantic_page_supported()?

Also, I've just tried this on s390 and counter.sh still fails after these
patches, and it should fail on all archs as long as you use the gigantic
hugepage size as default hugepage size. This is because you only changed
nr_overcommit_hugepages_store(), which handles nr_overcommit_hugepages
in sysfs, and missed hugetlb_overcommit_handler() which handles
/proc/sys/vm/nr_overcommit_hugepages for the default sized hugepages.

However, changing hugetlb_overcommit_handler() in a similar way
produces a lockdep warning, see below, and counters.sh now results in
FAIL	mmap failed: Cannot allocate memory
So I guess this needs more thinking (or just a proper annotation, as
suggested, didn't really look into it):

[  129.595054] INFO: trying to register non-static key.
[  129.595060] the code is fine but needs lockdep annotation.
[  129.595062] turning off the locking correctness validator.
[  129.595066] CPU: 4 PID: 1108 Comm: counters Not tainted 4.9.0-rc3-00261-g577f12c-dirty #12
[  129.595067] Hardware name: IBM              2964 N96              704              (LPAR)
[  129.595069] Stack:
[  129.595070]        00000003b4833688 00000003b4833718 0000000000000003 0000000000000000
[  129.595075]        00000003b48337b8 00000003b4833730 00000003b4833730 0000000000000020
[  129.595078]        0000000000000000 0000000000000020 000000000000000a 000000000000000a
[  129.595082]        000000000000000c 00000003b4833780 0000000000000000 00000003b4830000
[  129.595086]        0000000000000000 0000000000112d90 00000003b4833718 00000003b4833770
[  129.595089] Call Trace:
[  129.595095] ([<0000000000112c6a>] show_trace+0x8a/0xe0)
[  129.595098]  [<0000000000112d40>] show_stack+0x80/0xd8 
[  129.595103]  [<0000000000744eec>] dump_stack+0x9c/0xe0 
[  129.595106]  [<00000000001b0760>] register_lock_class+0x1a8/0x530 
[  129.595109]  [<00000000001b59fa>] __lock_acquire+0x10a/0x7f0 
[  129.595110]  [<00000000001b69b8>] lock_acquire+0x2e0/0x330 
[  129.595115]  [<0000000000a44920>] _raw_spin_lock_irqsave+0x70/0xb8 
[  129.595118]  [<000000000031cdce>] alloc_gigantic_page+0x8e/0x2c8 
[  129.595120]  [<000000000031e95a>] __alloc_huge_page+0xea/0x4d8 
[  129.595122]  [<000000000031f4c6>] hugetlb_acct_memory+0xa6/0x418 
[  129.595125]  [<0000000000323b32>] hugetlb_reserve_pages+0x132/0x240 
[  129.595152]  [<000000000048be62>] hugetlbfs_file_mmap+0xd2/0x130 
[  129.595155]  [<0000000000303918>] mmap_region+0x368/0x6e0 
[  129.595157]  [<0000000000303fb8>] do_mmap+0x328/0x400 
[  129.595160]  [<00000000002dc1aa>] vm_mmap_pgoff+0x9a/0xe8 
[  129.595162]  [<00000000003016dc>] SyS_mmap_pgoff+0x23c/0x288 
[  129.595164]  [<00000000003017b6>] SyS_old_mmap+0x8e/0xb0 
[  129.595166]  [<0000000000a45b06>] system_call+0xd6/0x270 
[  129.595167] INFO: lockdep is turned off.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
