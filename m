Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 263BF6B0277
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 04:16:03 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id e139so120811154oib.3
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 01:16:03 -0700 (PDT)
Received: from tyo202.gate.nec.co.jp (TYO202.gate.nec.co.jp. [210.143.35.52])
        by mx.google.com with ESMTPS id m84si2505988oif.160.2016.07.21.01.16.02
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 01:16:02 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
Date: Thu, 21 Jul 2016 08:13:55 +0000
Message-ID: <20160721081355.GB25398@hori1.linux.bs1.fc.nec.co.jp>
References: <578eb28b.YbRUDGz5RloTVlrE%akpm@linux-foundation.org>
 <20160721074340.GA26398@dhcp22.suse.cz>
In-Reply-To: <20160721074340.GA26398@dhcp22.suse.cz>
Content-Language: ja-JP
Content-Type: text/plain; charset="iso-2022-jp"
Content-ID: <88E5DEE804160A42BB58707BBC5A9192@gisp.nec.co.jp>
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "zhongjiang@huawei.com" <zhongjiang@huawei.com>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jul 21, 2016 at 09:43:40AM +0200, Michal Hocko wrote:
> We have further discussed the patch and I believe it is not correct. See =
[1].
> I am proposing the following alternative.
>
> [1] http://lkml.kernel.org/r/20160720132431.GM11249@dhcp22.suse.cz
> ---
> From b1e9b3214f1859fdf7d134cdcb56f5871933539c Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Thu, 21 Jul 2016 09:28:13 +0200
> Subject: [PATCH] mm, hugetlb: fix huge_pte_alloc BUG_ON
>
> Zhong Jiang has reported a BUG_ON from huge_pte_alloc hitting when he
> runs his database load with memory online and offline running in
> parallel. The reason is that huge_pmd_share might detect a shared pmd
> which is currently migrated and so it has migration pte which is
> !pte_huge.
>
> There doesn't seem to be any easy way to prevent from the race and in
> fact seeing the migration swap entry is not harmful. Both callers of
> huge_pte_alloc are prepared to handle them. copy_hugetlb_page_range
> will copy the swap entry and make it COW if needed. hugetlb_fault will
> back off and so the page fault is retries if the page is still under
> migration and waits for its completion in hugetlb_fault.
>
> That means that the BUG_ON is wrong and we should update it. Let's
> simply check that all present ptes are pte_huge instead.
>
> Reported-by: zhongjiang <zhongjiang@huawei.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

In the early days of hugetlb, we had an assumption that !pte_none is
equivalent to pmd_present() because there was no valid non-present entry
on huge_pte. Situation has changed by hugepage migration and/or hwpoison,
so we have to care about the separation of these two, and make sure that
pte_present is true before checking pte_huge.

So I think this change is right. Thank you Zhong, Michal.

Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
