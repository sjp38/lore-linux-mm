Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 3BE016B0038
	for <linux-mm@kvack.org>; Wed,  9 Nov 2016 16:29:17 -0500 (EST)
Received: by mail-pa0-f69.google.com with SMTP id r13so80880355pag.1
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 13:29:17 -0800 (PST)
Received: from mail-pf0-x242.google.com (mail-pf0-x242.google.com. [2607:f8b0:400e:c00::242])
        by mx.google.com with ESMTPS id j130si1227746pgc.172.2016.11.09.13.29.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Nov 2016 13:29:16 -0800 (PST)
Received: by mail-pf0-x242.google.com with SMTP id y68so1509509pfb.1
        for <linux-mm@kvack.org>; Wed, 09 Nov 2016 13:29:16 -0800 (PST)
Subject: Re: [PATCH v2 00/12] mm: page migration enhancement for thp
References: <1478561517-4317-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <ee20300d-0367-5b2c-71f2-f86bce3d6b90@gmail.com>
 <20161109045926.GB7770@hori1.linux.bs1.fc.nec.co.jp>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <db645410-c8ad-8cbb-9124-35e484775986@gmail.com>
Date: Thu, 10 Nov 2016 08:28:54 +1100
MIME-Version: 1.0
In-Reply-To: <20161109045926.GB7770@hori1.linux.bs1.fc.nec.co.jp>
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Pavel Emelyanov <xemul@parallels.com>, Zi Yan <zi.yan@cs.rutgers.edu>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>



On 09/11/16 15:59, Naoya Horiguchi wrote:
> On Wed, Nov 09, 2016 at 01:32:04PM +1100, Balbir Singh wrote:
>> On 08/11/16 10:31, Naoya Horiguchi wrote:
>>> Hi everyone,
>>>
>>> I've updated thp migration patches for v4.9-rc2-mmotm-2016-10-27-18-27
>>> with feedbacks for ver.1.
>>>
>>> General description (no change since ver.1)
>>> ===========================================
>>>
>>> This patchset enhances page migration functionality to handle thp migration
>>> for various page migration's callers:
>>>  - mbind(2)
>>>  - move_pages(2)
>>>  - migrate_pages(2)
>>>  - cgroup/cpuset migration
>>>  - memory hotremove
>>>  - soft offline
>>>
>>> The main benefit is that we can avoid unnecessary thp splits, which helps us
>>> avoid performance decrease when your applications handles NUMA optimization on
>>> their own.
>>>
>>> The implementation is similar to that of normal page migration, the key point
>>> is that we modify a pmd to a pmd migration entry in swap-entry like format.
>>>
>>> Changes / Notes
>>> ===============
>>>
>>> - pmd_present() in x86 checks _PAGE_PRESENT, _PAGE_PROTNONE and _PAGE_PSE
>>>   bits together, which makes implementing thp migration a bit hard because
>>>   _PAGE_PSE bit is currently used by soft-dirty in swap-entry format.
>>>   I was advised to dropping _PAGE_PSE in pmd_present(), but I don't think
>>>   of the justification, so I keep it in this version. Instead, my approach
>>>   is to move _PAGE_SWP_SOFT_DIRTY to bit 6 (unused) and reserve bit 7 for
>>>   pmd non-present cases.
>>
>> Thanks, IIRC
>>
>> pmd_present = _PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE
>>
>> AutoNUMA balancing would change it to
>>
>> pmd_present = _PAGE_PROTNONE | _PAGE_PSE
>>
>> and PMD_SWP_SOFT_DIRTY would make it
>>
>> pmd_present = _PAGE_PSE
>>
>> What you seem to be suggesting in your comment is that
>>
>> pmd_present should be _PAGE_PRESENT | _PAGE_PROTNONE
> 
> This (no _PAGE_PSE) was a possibile solution, and as I described I gave up
> this solution, because I noticed that what I actually wanted was that
> pmd_present() certainly returns false during thp migration and that's done
> by moving _PAGE_SWP_SOFT_DIRTY. So
> 
>   pmd_present = _PAGE_PRESENT | _PAGE_PROTNONE | _PAGE_PSE
> 
> is still correct in this patchset.
> 

Thanks, I was wondering if there is any advantage or you felt its
safer not to change pmd_present().

>>
>> Isn't that good enough?
>>
>> For THP migration I guess we use
>>
>> _PAGE_PRESENT | _PAGE_PROTNONE | is_migration_entry(pmd)
> 
> Though I might misread your notations, I hope that the following code
> seems describe itself well.
> 
>   static inline int is_pmd_migration_entry(pmd_t pmd)                            
>   {                                                                              
>           return !pmd_present(pmd) && is_migration_entry(pmd_to_swp_entry(pmd)); 
>   }                                                                              
> 

Thanks, yes my notation is not the best.



Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
