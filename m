Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f51.google.com (mail-qg0-f51.google.com [209.85.192.51])
	by kanga.kvack.org (Postfix) with ESMTP id 354F06B007E
	for <linux-mm@kvack.org>; Thu, 31 Mar 2016 12:45:32 -0400 (EDT)
Received: by mail-qg0-f51.google.com with SMTP id y89so69835734qge.2
        for <linux-mm@kvack.org>; Thu, 31 Mar 2016 09:45:32 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id b124si8391968qhd.126.2016.03.31.09.45.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 Mar 2016 09:45:31 -0700 (PDT)
Subject: Re: [RFC PATCH 1/2] mm/hugetlbfs: Attempt PUD_SIZE mapping alignment
 if PMD sharing enabled
References: <1459213970-17957-1-git-send-email-mike.kravetz@oracle.com>
 <1459213970-17957-2-git-send-email-mike.kravetz@oracle.com>
 <20160331021850.GA4079@hori1.linux.bs1.fc.nec.co.jp>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <56FD541B.4040002@oracle.com>
Date: Thu, 31 Mar 2016 09:45:15 -0700
MIME-Version: 1.0
In-Reply-To: <20160331021850.GA4079@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, Hugh Dickins <hughd@google.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Rientjes <rientjes@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Steve Capper <steve.capper@linaro.org>, Andrew Morton <akpm@linux-foundation.org>

On 03/30/2016 07:18 PM, Naoya Horiguchi wrote:
> On Mon, Mar 28, 2016 at 06:12:49PM -0700, Mike Kravetz wrote:
>> When creating a hugetlb mapping, attempt PUD_SIZE alignment if the
>> following conditions are met:
>> - Address passed to mmap or shmat is NULL
>> - The mapping is flaged as shared
>> - The mapping is at least PUD_SIZE in length
>> If a PUD_SIZE aligned mapping can not be created, then fall back to a
>> huge page size mapping.
> 
> It would be kinder if the patch description includes why this change.
> Simply "to facilitate pmd sharing" is helpful for someone who read
> "git log".

Ok, will do.

> 
>>
>> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
>> ---
>>  fs/hugetlbfs/inode.c | 29 +++++++++++++++++++++++++++--
>>  1 file changed, 27 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/hugetlbfs/inode.c b/fs/hugetlbfs/inode.c
>> index 540ddc9..22b2e38 100644
>> --- a/fs/hugetlbfs/inode.c
>> +++ b/fs/hugetlbfs/inode.c
>> @@ -175,6 +175,17 @@ hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
>>  	struct vm_area_struct *vma;
>>  	struct hstate *h = hstate_file(file);
>>  	struct vm_unmapped_area_info info;
>> +	bool pud_size_align = false;
>> +	unsigned long ret_addr;
>> +
>> +	/*
>> +	 * If PMD sharing is enabled, align to PUD_SIZE to facilitate
>> +	 * sharing.  Only attempt alignment if no address was passed in,
>> +	 * flags indicate sharing and size is big enough.
>> +	 */
>> +	if (IS_ENABLED(CONFIG_ARCH_WANT_HUGE_PMD_SHARE) &&
>> +	    !addr && flags & MAP_SHARED && len >= PUD_SIZE)
>> +		pud_size_align = true;
> 
> This code will have duplicates in the next patch, so how about checking
> this in a separate check routine?

Good suggestion,  thanks
-- 
Mike Kravetz

> 
> Thanks,
> Naoya Horiguchi
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
