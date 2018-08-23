Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id AFD156B2B51
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 13:56:42 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id m71-v6so2458215vke.3
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 10:56:42 -0700 (PDT)
Received: from userp2120.oracle.com (userp2120.oracle.com. [156.151.31.85])
        by mx.google.com with ESMTPS id i189-v6si953559vkc.178.2018.08.23.10.56.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Aug 2018 10:56:41 -0700 (PDT)
Subject: Re: [PATCH v3 1/2] mm: migration: fix migration of huge PMD shared
 pages
From: Mike Kravetz <mike.kravetz@oracle.com>
References: <20180821205902.21223-2-mike.kravetz@oracle.com>
 <201808220831.eM0je51n%fengguang.wu@intel.com>
 <975b740d-26a6-eb3f-c8ca-1a9995d0d343@oracle.com>
 <20180823124855.GI29735@dhcp22.suse.cz>
 <12ea5339-f2b1-62b4-6d37-57d737fac34a@oracle.com>
Message-ID: <df05e2e0-be29-1651-40e7-82dc686919c2@oracle.com>
Date: Thu, 23 Aug 2018 10:56:30 -0700
MIME-Version: 1.0
In-Reply-To: <12ea5339-f2b1-62b4-6d37-57d737fac34a@oracle.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: kbuild test robot <lkp@intel.com>, kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Vlastimil Babka <vbabka@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Davidlohr Bueso <dave@stgolabs.net>, Andrew Morton <akpm@linux-foundation.org>, stable@vger.kernel.org

On 08/23/2018 10:01 AM, Mike Kravetz wrote:
> On 08/23/2018 05:48 AM, Michal Hocko wrote:
>> On Tue 21-08-18 18:10:42, Mike Kravetz wrote:
>> [...]
>>
>> OK, after burning myself when trying to be clever here it seems like
>> your proposed solution is indeed simpler.
>>
>>> +bool huge_pmd_sharing_possible(struct vm_area_struct *vma,
>>> +				unsigned long *start, unsigned long *end)
>>> +{
>>> +	unsigned long check_addr = *start;
>>> +	bool ret = false;
>>> +
>>> +	if (!(vma->vm_flags & VM_MAYSHARE))
>>> +		return ret;
>>> +
>>> +	for (check_addr = *start; check_addr < *end; check_addr += PUD_SIZE) {
>>> +		unsigned long a_start = check_addr & PUD_MASK;
>>> +		unsigned long a_end = a_start + PUD_SIZE;
>>
>> I guess this should be rather in HPAGE_SIZE * PTRS_PER_PTE units as
>> huge_pmd_unshare does.
> 
> Sure, I can do that.

On second thought, this is more similar to vma_shareable() which uses
PUD_MASK and PUD_SIZE.  In fact Kirill asked me to put in a common helper
for this and vma_shareable.  So, I would prefer to leave it as PUD* unless
you feel strongly.

IMO, it would make more sense to change this in huge_pmd_unshare as PMD
sharing is pretty explicitly tied to PUD_SIZE.  But, that is a future cleanup.

-- 
Mike Kravetz
