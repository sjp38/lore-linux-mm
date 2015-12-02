Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f174.google.com (mail-io0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 731E06B0038
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 02:12:38 -0500 (EST)
Received: by iofh3 with SMTP id h3so36534956iof.3
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 23:12:38 -0800 (PST)
Received: from us-alimail-mta2.hst.scl.en.alidc.net (mail113-249.mail.alibaba.com. [205.204.113.249])
        by mx.google.com with ESMTP id hh18si1669539igb.45.2015.12.01.23.12.36
        for <linux-mm@kvack.org>;
        Tue, 01 Dec 2015 23:12:37 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1449024761-11280-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1449024761-11280-1-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [PATCH] mm/hugetlb resv map memory leak for placeholder entries
Date: Wed, 02 Dec 2015 15:12:20 +0800
Message-ID: <04ad01d12cd0$c9bfe070$5d3fa150$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Mike Kravetz' <mike.kravetz@oracle.com>, 'Dmitry Vyukov' <dvyukov@google.com>, 'Andrew Morton' <akpm@linux-foundation.org>, 'Naoya Horiguchi' <n-horiguchi@ah.jp.nec.com>, 'David Rientjes' <rientjes@google.com>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, 'Dave Hansen' <dave.hansen@linux.intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, 'Hugh Dickins' <hughd@google.com>, 'Greg Thelen' <gthelen@google.com>
Cc: 'Kostya Serebryany' <kcc@google.com>, 'Alexander Potapenko' <glider@google.com>, 'Sasha Levin' <sasha.levin@oracle.com>, 'Eric Dumazet' <edumazet@google.com>, 'syzkaller' <syzkaller@googlegroups.com>, "'stable@vger.kernel.org[4.3]'"@kvack.org

> 
> Dmitry Vyukov reported the following memory leak
> 
> unreferenced object 0xffff88002eaafd88 (size 32):
>   comm "a.out", pid 5063, jiffies 4295774645 (age 15.810s)
>   hex dump (first 32 bytes):
>     28 e9 4e 63 00 88 ff ff 28 e9 4e 63 00 88 ff ff  (.Nc....(.Nc....
>     00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
>   backtrace:
>     [<     inline     >] kmalloc include/linux/slab.h:458
>     [<ffffffff815efa64>] region_chg+0x2d4/0x6b0 mm/hugetlb.c:398
>     [<ffffffff815f0c63>] __vma_reservation_common+0x2c3/0x390 mm/hugetlb.c:1791
>     [<     inline     >] vma_needs_reservation mm/hugetlb.c:1813
>     [<ffffffff815f658e>] alloc_huge_page+0x19e/0xc70 mm/hugetlb.c:1845
>     [<     inline     >] hugetlb_no_page mm/hugetlb.c:3543
>     [<ffffffff815fc561>] hugetlb_fault+0x7a1/0x1250 mm/hugetlb.c:3717
>     [<ffffffff815fd349>] follow_hugetlb_page+0x339/0xc70 mm/hugetlb.c:3880
>     [<ffffffff815a2bb2>] __get_user_pages+0x542/0xf30 mm/gup.c:497
>     [<ffffffff815a400e>] populate_vma_page_range+0xde/0x110 mm/gup.c:919
>     [<ffffffff815a4207>] __mm_populate+0x1c7/0x310 mm/gup.c:969
>     [<ffffffff815b74f1>] do_mlock+0x291/0x360 mm/mlock.c:637
>     [<     inline     >] SYSC_mlock2 mm/mlock.c:658
>     [<ffffffff815b7a4b>] SyS_mlock2+0x4b/0x70 mm/mlock.c:648
> 
> Dmitry identified a potential memory leak in the routine region_chg,
> where a region descriptor is not free'ed on an error path.
> 
> However, the root cause for the above memory leak resides in region_del.
> In this specific case, a "placeholder" entry is created in region_chg.  The
> associated page allocation fails, and the placeholder entry is left in the
> reserve map.  This is "by design" as the entry should be deleted when the
> map is released.  The bug is in the region_del routine which is used to
> delete entries within a specific range (and when the map is released).
> region_del did not handle the case where a placeholder entry exactly matched
> the start of the range range to be deleted.  In this case, the entry would
> not be deleted and leaked.  The fix is to take these special placeholder
> entries into account in region_del.
> 
> The region_chg error path leak is also fixed.
> 
> Fixes: feba16e25a57 ("add region_del() to delete a specific range of entries")
> Cc: stable@vger.kernel.org [4.3]
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/hugetlb.c | 12 ++++++++++--
>  1 file changed, 10 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 1101ccd94..ba07014 100644
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -372,8 +372,10 @@ retry_locked:
>  		spin_unlock(&resv->lock);
> 
>  		trg = kmalloc(sizeof(*trg), GFP_KERNEL);
> -		if (!trg)
> +		if (!trg) {
> +			kfree(nrg);
>  			return -ENOMEM;
> +		}
> 
>  		spin_lock(&resv->lock);
>  		list_add(&trg->link, &resv->region_cache);
> @@ -483,7 +485,13 @@ static long region_del(struct resv_map *resv, long f, long t)
>  retry:
>  	spin_lock(&resv->lock);
>  	list_for_each_entry_safe(rg, trg, head, link) {
> -		if (rg->to <= f)
> +		/*
> +		 * file_region ranges are normally of the form [from, to).
> +		 * However, there may be a "placeholder" entry in the map
> +		 * which is of the form (from, to) with from == to.  Check
> +		 * for placeholder entries as well.
> +		 */
> +		if (rg->to <= f && rg->to != rg->from)
>  			continue;
>  		if (rg->from >= t)
>  			break;
> --
> 2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
