Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 34DC86B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 09:40:50 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l89so52512628lfi.3
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 06:40:50 -0700 (PDT)
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com. [74.125.82.46])
        by mx.google.com with ESMTPS id h5si4559124lfb.19.2016.07.21.06.40.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jul 2016 06:40:47 -0700 (PDT)
Received: by mail-wm0-f46.google.com with SMTP id f65so22438475wmi.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 06:40:47 -0700 (PDT)
Date: Thu, 21 Jul 2016 15:40:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
Message-ID: <20160721134044.GL26379@dhcp22.suse.cz>
References: <578eb28b.YbRUDGz5RloTVlrE%akpm@linux-foundation.org>
 <20160721074340.GA26398@dhcp22.suse.cz>
 <5790A9D1.6060304@huawei.com>
 <20160721112754.GH26379@dhcp22.suse.cz>
 <5790BCB1.4020800@huawei.com>
 <20160721123001.GI26379@dhcp22.suse.cz>
 <5790C3DB.8000505@huawei.com>
 <20160721125555.GJ26379@dhcp22.suse.cz>
 <5790CD52.6050200@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5790CD52.6050200@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, zhong jiang <zhongjiang@huawei.com>
Cc: akpm@linux-foundation.org, qiuxishi@huawei.com, vbabka@suse.cz, mm-commits@vger.kernel.org, Mike Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On Thu 21-07-16 21:25:38, zhong jiang wrote:
> On 2016/7/21 20:55, Michal Hocko wrote:
[...]
> > OK, now I understand what you mean. So you mean that a different process
> > initiates the migration while this path copies to pte. That is certainly
> > possible but I still fail to see what is the problem about that.
> > huge_pte_alloc will return the identical pte whether it is regular or
> > migration one. So what exactly is the problem?
> >
> copy_hugetlb_page_range obtain the shared dst_pte, it may be not equal
> to the src_pte.  The dst_pte can come from other process sharing the
> mapping.

So you mean that the parent doesn't have the shared pte while the child
would get one?
 
> 		/* If the pagetables are shared don't copy or take references */
> 		if (dst_pte == src_pte)
> 			continue;
>  
> Even it do the fork path, we scan the i_mmap to find same pte. I think
> that dst_pte may come from other process. It is not the parent. it
> will lead to the dst_pte is not equal to the src_pte from the parent.

Let's say this would be possible (I am not really sure but for the sake
of argumentation), if the src is not shared while dst is shared and the
page is under migration then all the page table should be marked as
swap migrate entries no? If they are not and copy_hugetlb_page_range
cannot handle with that then it is a bug in copy_hugetlb_page_range
which doesn't have anything to do with the BUG_ON in  huge_pte_alloc.
So I would argue that if the problem exists at all it is a separate
issue IMHO.

Naoya, could you comment on that please?
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
