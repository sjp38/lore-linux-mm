Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id D44C36B0005
	for <linux-mm@kvack.org>; Thu, 21 Jul 2016 10:00:25 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id m101so161283025ioi.0
        for <linux-mm@kvack.org>; Thu, 21 Jul 2016 07:00:25 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id h68si3842795otb.174.2016.07.21.07.00.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 21 Jul 2016 07:00:24 -0700 (PDT)
Message-ID: <5790D4FF.8070907@huawei.com>
Date: Thu, 21 Jul 2016 21:58:23 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
References: <578eb28b.YbRUDGz5RloTVlrE%akpm@linux-foundation.org> <20160721074340.GA26398@dhcp22.suse.cz> <5790A9D1.6060304@huawei.com> <20160721112754.GH26379@dhcp22.suse.cz> <5790BCB1.4020800@huawei.com> <20160721123001.GI26379@dhcp22.suse.cz> <5790C3DB.8000505@huawei.com> <20160721125555.GJ26379@dhcp22.suse.cz> <5790CD52.6050200@huawei.com> <20160721134044.GL26379@dhcp22.suse.cz>
In-Reply-To: <20160721134044.GL26379@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, akpm@linux-foundation.org, qiuxishi@huawei.com, vbabka@suse.cz, mm-commits@vger.kernel.org, Mike
 Kravetz <mike.kravetz@oracle.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On 2016/7/21 21:40, Michal Hocko wrote:
> On Thu 21-07-16 21:25:38, zhong jiang wrote:
>> On 2016/7/21 20:55, Michal Hocko wrote:
> [...]
>>> OK, now I understand what you mean. So you mean that a different process
>>> initiates the migration while this path copies to pte. That is certainly
>>> possible but I still fail to see what is the problem about that.
>>> huge_pte_alloc will return the identical pte whether it is regular or
>>> migration one. So what exactly is the problem?
>>>
>> copy_hugetlb_page_range obtain the shared dst_pte, it may be not equal
>> to the src_pte.  The dst_pte can come from other process sharing the
>> mapping.
> So you mean that the parent doesn't have the shared pte while the child
> would get one?
>  
   no,  parent must have the shared pte because the the child copy the parent.  but parent is
  not the only source pte we can get.  when we scan the maping->i_mmap, firstly ,it can obtain
  a shared pte from other process.   but I am not sure.
>> 		/* If the pagetables are shared don't copy or take references */
>> 		if (dst_pte == src_pte)
>> 			continue;
>>  
>> Even it do the fork path, we scan the i_mmap to find same pte. I think
>> that dst_pte may come from other process. It is not the parent. it
>> will lead to the dst_pte is not equal to the src_pte from the parent.
> Let's say this would be possible (I am not really sure but for the sake
> of argumentation), if the src is not shared while dst is shared and the
> page is under migration then all the page table should be marked as
> swap migrate entries no? If they are not and copy_hugetlb_page_range
> cannot handle with that then it is a bug in copy_hugetlb_page_range
> which doesn't have anything to do with the BUG_ON in  huge_pte_alloc.
> So I would argue that if the problem exists at all it is a separate
> issue IMHO.
  yes,  it is a separate issule.
> Naoya, could you comment on that please?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
