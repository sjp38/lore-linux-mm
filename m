Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9F7186B02F4
	for <linux-mm@kvack.org>; Wed, 14 Jun 2017 13:02:35 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id g66so1794043vki.0
        for <linux-mm@kvack.org>; Wed, 14 Jun 2017 10:02:35 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id t29si254989uaa.241.2017.06.14.10.02.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Jun 2017 10:02:34 -0700 (PDT)
Subject: Re: [PATCH] mm/hugetlb: Warn the user when issues arise on boot due
 to hugepages
References: <20170606054917.GA1189@dhcp22.suse.cz>
 <20170606060147.GB1189@dhcp22.suse.cz>
 <20170612172829.bzjfmm7navnobh4t@oracle.com>
 <20170612174911.GA23493@dhcp22.suse.cz>
 <20170612183717.qgcusdfvdfcj7zr7@oracle.com>
 <20170612185208.GC23493@dhcp22.suse.cz>
 <20170613013516.7fcmvmoltwhxmtmp@oracle.com>
 <20170613054204.GB5363@dhcp22.suse.cz>
 <20170613152501.w27r2q2agy4sue5x@oracle.com>
 <a855a155-c952-ac6b-04b9-aa7869403c52@oracle.com>
 <20170614072725.GH6045@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <045d8438-0cb1-8346-b911-3475d6799709@oracle.com>
Date: Wed, 14 Jun 2017 10:02:20 -0700
MIME-Version: 1.0
In-Reply-To: <20170614072725.GH6045@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.com>
Cc: "Liam R. Howlett" <Liam.Howlett@oracle.com>, linux-mm@kvack.org, akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com, aneesh.kumar@linux.vnet.ibm.com, gerald.schaefer@de.ibm.com, zhongjiang@huawei.com, aarcange@redhat.com, kirill.shutemov@linux.intel.com

On 06/14/2017 12:27 AM, Michal Hocko wrote:
> On Tue 13-06-17 09:26:15, Mike Kravetz wrote:
>> A thought somewhat related to this discussion:
>>
>> I noticed that huge pages specified on the kernel command line are allocated
>> via 'subsys_initcall'.  This is before 'fs_initcall', even though these huge
>> pages are only used by hugetlbfs.  Was just thinking that it might be better
>> to move huge page allocations to later in the init process.  At least make
>> them part of fs_initcall if not late_initcall?
>>
>> Only reason for doing this is because huge page allocations are fairly
>> tolerant of allocation failure.
> 
> I am not really familiar with the initcall hierarchy to be honest. I
> even do not understand what relattion does fs_initcall have to
> allocation failures. Could you be more specific?

The short answer is never mind.  We can not easily change where huge pages
are allocated as pointed out here:
https://patchwork.kernel.org/patch/7837381/

The longer explanation of my thoughts on moving location of allocations:
Liam was saying that someone was getting OOMs because they allocated too
many huge pages.  It also seems that this happened during boot.  I may be
reading too much into his comments.

My thought is that this 'may' not happen if huge pages were allocated
later in the boot process.  If they were allocated after boot, this would
not even be an issue.  So, I started looking at where they were allocated
in the initcall hierarchy.  huge pages are allocated via subsys_initcall
which (IIUC) happens before fs_initcall.  It seems to me that perhaps
huge page allocation belongs in fs_initcall as the pre-allocated pages
are only used by hugetlbfs.

Moving huge page allocation from subsys_initcall to fs_initcall is unlikely
to have any impact on the OOMs that Liam was trying to flag.  In fact
it may not have an impact on any such issues.  But, in a way it does seem
'more correct'.  Nobody in the init process should be depending on huge
page allocation (I think), so what if we moved it all the way to the end
of initcall processing: late_initcall.  Then perhaps it might have an 
impact on such issues.

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
