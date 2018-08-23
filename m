Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 42A406B2B1D
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 13:02:16 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id a15-v6so5260205qtj.15
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 10:02:16 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id l16-v6si4727842qtf.21.2018.08.23.10.02.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 10:02:14 -0700 (PDT)
Subject: Re: [PATCH v3 1/2] mm: migration: fix migration of huge PMD shared
 pages
References: <20180821205902.21223-2-mike.kravetz@oracle.com>
 <201808220831.eM0je51n%fengguang.wu@intel.com>
 <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
 <20180823124855.GI29735@dhcp22.suse.cz>
From: Mike Kravetz <mike.kravetz@oracle.com>
Message-ID: <12ea5339-f2b1-62b4-6d37-57d737fac34a@oracle.com>
Date: Thu, 23 Aug 2018 10:01:55 -0700
MIME-Version: 1.0
In-Reply-To: <20180823124855.GI29735@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 08/23/2018 05:48 AM, Michal Hocko wrote:
> On Tue 21-08-18 18:10:42, Mike Kravetz wrote:
> [...]
> 
> OK, after burning myself when trying to be clever here it seems like
> your proposed solution is indeed simpler.
> 
>> +bool huge_pmd_sharing_possible(struct vm_area_struct *vma,
>> +				unsigned long *start, unsigned long *end)
>> +{
>> +	unsigned long check_addr = *start;
>> +	bool ret = false;
>> +
>> +	if (!(vma->vm_flags & VM_MAYSHARE))
>> +		return ret;
>> +
>> +	for (check_addr = *start; check_addr < *end; check_addr += PUD_SIZE) {
>> +		unsigned long a_start = check_addr & PUD_MASK;
>> +		unsigned long a_end = a_start + PUD_SIZE;
> 
> I guess this should be rather in HPAGE_SIZE * PTRS_PER_PTE units as
> huge_pmd_unshare does.

Sure, I can do that.

However, I consider the statement making that calculation in huge_pmd_unshare
to be VERY ugly and confusing code.

	*addr = ALIGN(*addr, HPAGE_SIZE * PTRS_PER_PTE) - HPAGE_SIZE;

Note that it is adjusting the value of passed argument 'unsigned long *addr'.
This argument/value is part of a loop condition in all current callers of
huge_pmd_unshare.  For instance:

	for (; address < end; address += huge_page_size(h)) {

So, that calculation in huge_pmd_unshare gets the calling loop back to
the starting address of the unmapped range.  It even takes the loop increment
'huge_page_size(h)' into account.  That is why that ' - HPAGE_SIZE' is at
the end of the calculation.

ugly and confusing!  And on my list of things to clean up.
-- 
Mike Kravetz
