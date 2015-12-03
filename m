Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 71AAA6B0038
	for <linux-mm@kvack.org>; Thu,  3 Dec 2015 02:00:28 -0500 (EST)
Received: by pfu207 with SMTP id 207so5440113pfu.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 23:00:28 -0800 (PST)
Received: from out21.biz.mail.alibaba.com (out114-136.biz.mail.alibaba.com. [205.204.114.136])
        by mx.google.com with ESMTP id q62si10121424pfq.5.2015.12.02.23.00.26
        for <linux-mm@kvack.org>;
        Wed, 02 Dec 2015 23:00:27 -0800 (PST)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1449087238-12754-1-git-send-email-mike.kravetz@oracle.com>
In-Reply-To: <1449087238-12754-1-git-send-email-mike.kravetz@oracle.com>
Subject: Re: [PATCH V2] mm/hugetlb resv map memory leak for placeholder entries
Date: Thu, 03 Dec 2015 15:00:01 +0800
Message-ID: <05cd01d12d98$3bbcc180$b3364480$@alibaba-inc.com>
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
> V2: The original version of the patch did not correctly handle placeholder
>     entries before the range to be deleted.  The new check is more specific
>     and only matches placeholders at the start of range.
> 
> Fixes: feba16e25a57 ("add region_del() to delete a specific range of entries")
> Cc: stable@vger.kernel.org [4.3]
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> Reported-by: Dmitry Vyukov <dvyukov@google.com>
> ---

Acked-by: Hillf Danton <hillf.zj@alibaba-inc.com>

>  mm/hugetlb.c | 14 ++++++++++++--
>  1 file changed, 12 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> index 1101ccd94..c895ab9 100644
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
> @@ -483,8 +485,16 @@ static long region_del(struct resv_map *resv, long f, long t)
>  retry:
>  	spin_lock(&resv->lock);
>  	list_for_each_entry_safe(rg, trg, head, link) {
> -		if (rg->to <= f)
> +		/*
> +		 * Skip regions before the range to be deleted.  file_region
> +		 * ranges are normally of the form [from, to).  However, there
> +		 * may be a "placeholder" entry in the map which is of the form
> +		 * (from, to) with from == to.  Check for placeholder entries
> +		 * at the beginning of the range to be deleted.
> +		 */
> +		if (rg->to <= f && (rg->to != rg->from || rg->to != f))
>  			continue;
> +
>  		if (rg->from >= t)
>  			break;
> 
> --
> 2.4.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
