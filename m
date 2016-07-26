Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f197.google.com (mail-ua0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 892556B0253
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 10:08:52 -0400 (EDT)
Received: by mail-ua0-f197.google.com with SMTP id j59so1463462uaj.0
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 07:08:52 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTP id g91si814162otg.204.2016.07.26.07.06.31
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 07:08:51 -0700 (PDT)
Message-ID: <57976DE0.8020809@huawei.com>
Date: Tue, 26 Jul 2016 22:04:16 +0800
From: zhong jiang <zhongjiang@huawei.com>
MIME-Version: 1.0
Subject: Re: + mm-hugetlb-fix-race-when-migrate-pages.patch added to -mm tree
References: <5790C3DB.8000505@huawei.com> <20160721125555.GJ26379@dhcp22.suse.cz> <5790CD52.6050200@huawei.com> <20160721134044.GL26379@dhcp22.suse.cz> <5790D4FF.8070907@huawei.com> <20160721140124.GN26379@dhcp22.suse.cz> <5790D8A3.3090808@huawei.com> <20160721142722.GP26379@dhcp22.suse.cz> <5790DD4B.2060000@huawei.com> <20160722071737.GA3785@hori1.linux.bs1.fc.nec.co.jp> <20160726075847.GG32462@dhcp22.suse.cz>
In-Reply-To: <20160726075847.GG32462@dhcp22.suse.cz>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "qiuxishi@huawei.com" <qiuxishi@huawei.com>, "vbabka@suse.cz" <vbabka@suse.cz>, "mm-commits@vger.kernel.org" <mm-commits@vger.kernel.org>, Mike Kravetz <mike.kravetz@oracle.com>, Mel
 Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 2016/7/26 15:58, Michal Hocko wrote:
> On Fri 22-07-16 07:17:37, Naoya Horiguchi wrote:
> [...]
>> I think that (src_pte != dst_pte) can happen and that's ok if there's no
>> migration entry. 
> We have discussed that with Naoya off-list and couldn't find a scenario
> when parent would have !shared pmd while child would have it. The only
> plausible scenario was that parent created and poppulated mapping smaller
> than 1G and then enlarged it later on so the child would see sharedable
> pud. This doesn't seem to be possible because vma_merge would bail out
> due to VM_SPECIAL check.
  I do not understand that the process must have vm_special flags. if vm_special enable,
 the process must not be expanded.  and   what does it matter about vma_merge ??
>> But even if we have both of normal entry and migration entry
>> for one hugepage, that still looks fine to me because the running migration
>> operation fails (because there remains mapcounts on the source hugepage),
>> and all migration entries are turned back to normal entries pointing to the
>> source hugepage.
    In one case,  try_to_unmap_one is first exec and successfully,  mapcount turn into zero.
   then we get the pte lock,  if src_pte!-dst_pte, it maybe lead to the dst_pte is from migrate pte
    to normal pte, while the normal pte turn into migaret pte,, is right ?
>  
> Agreed.
>
>> Could you try to see and share what happens on your workload with
>> Michal's patch?
> Zhong Jiang did you have chance to retest with the BUG_ON changed?
>
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
