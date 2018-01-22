Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C47EB800D8
	for <linux-mm@kvack.org>; Mon, 22 Jan 2018 00:59:55 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id v17so6465077pgb.18
        for <linux-mm@kvack.org>; Sun, 21 Jan 2018 21:59:55 -0800 (PST)
Received: from smtp.codeaurora.org (smtp.codeaurora.org. [198.145.29.96])
        by mx.google.com with ESMTPS id u64si13160690pgc.567.2018.01.21.21.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 21 Jan 2018 21:59:54 -0800 (PST)
Subject: Re: [PATCH v2] mm: make faultaround produce old ptes
References: <1516280210-5678-1-git-send-email-vinmenon@codeaurora.org>
 <20180119142454.wa4gtkabrliyd6d6@node.shutemov.name>
From: Vinayak Menon <vinmenon@codeaurora.org>
Message-ID: <5519894f-d5fc-fc9c-e6b7-be783bd38a21@codeaurora.org>
Date: Mon, 22 Jan 2018 11:29:46 +0530
MIME-Version: 1.0
In-Reply-To: <20180119142454.wa4gtkabrliyd6d6@node.shutemov.name>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com, ying.huang@intel.com, riel@redhat.com, dave.hansen@linux.intel.com, mgorman@suse.de, torvalds@linux-foundation.org, jack@suse.cz

On 1/19/2018 7:54 PM, Kirill A. Shutemov wrote:
> On Thu, Jan 18, 2018 at 06:26:50PM +0530, Vinayak Menon wrote:
>> Based on Kirill's patch [1].
>>
>> Currently, faultaround code produces young pte.  This can screw up
>> vmscan behaviour[2], as it makes vmscan think that these pages are hot
>> and not push them out on first round.
>>
>> During sparse file access faultaround gets more pages mapped and all of
>> them are young. Under memory pressure, this makes vmscan swap out anon
>> pages instead, or to drop other page cache pages which otherwise stay
>> resident.
>>
>> Modify faultaround to produce old ptes if sysctl 'want_old_faultaround_pte'
>> is set, so they can easily be reclaimed under memory pressure.
>>
>> This can to some extend defeat the purpose of faultaround on machines
>> without hardware accessed bit as it will not help us with reducing the
>> number of minor page faults.
>>
>> Making the faultaround ptes old results in a unixbench regression for some
>> architectures [3][4]. But on some architectures like arm64 it is not found
>> to cause any regression.
>>
>> unixbench shell8 scores on arm64 v8.2 hardware with CONFIG_ARM64_HW_AFDBM
>> enabled  (5 runs min, max, avg):
>> Base: (741,748,744)
>> With this patch: (739,748,743)
>>
>> So by default produce young ptes and provide a sysctl option to make the
>> ptes old.
>>
>> [1] http://lkml.kernel.org/r/1463488366-47723-1-git-send-email-kirill.shutemov@linux.intel.com
>> [2] https://lkml.kernel.org/r/1460992636-711-1-git-send-email-vinmenon@codeaurora.org
>> [3] https://marc.info/?l=linux-kernel&m=146582237922378&w=2
>> [4] https://marc.info/?l=linux-mm&m=146589376909424&w=2
>>
>> Signed-off-by: Vinayak Menon <vinmenon@codeaurora.org>
>> ---
>>
>> V2:
>> 1. Removed the arch hook and want_old_faultaround_pte is made a sysctl
>> 2. Renamed FAULT_FLAG_MKOLD to FAULT_FLAG_PREFAULT_OLD (suggested by Jan Kara)
>> 3. Removed the saved fault address from vmf (suggested by Jan Kara)
>>
>>  Documentation/sysctl/vm.txt | 22 ++++++++++++++++++++++
>>  include/linux/mm.h          |  3 +++
>>  kernel/sysctl.c             |  9 +++++++++
>>  mm/filemap.c                | 10 ++++++++++
>>  mm/memory.c                 |  4 ++++
>>  5 files changed, 48 insertions(+)
>>
>> diff --git a/Documentation/sysctl/vm.txt b/Documentation/sysctl/vm.txt
>> index 17256f2..e015940 100644
>> --- a/Documentation/sysctl/vm.txt
>> +++ b/Documentation/sysctl/vm.txt
>> @@ -63,6 +63,7 @@ Currently, these files are in /proc/sys/vm:
>>  - vfs_cache_pressure
>>  - watermark_scale_factor
>>  - zone_reclaim_mode
>> +- want_old_faultaround_pte
>>  
>>  ==============================================================
>>  
>> @@ -887,4 +888,25 @@ Allowing regular swap effectively restricts allocations to the local
>>  node unless explicitly overridden by memory policies or cpuset
>>  configurations.
>>  
>> +=============================================================
>> +
>> +want_old_faultaround_pte:
>> +
>> +By default faultaround code produces young pte. When want_old_faultaround_pte is
>> +set to 1, faultaround produces old ptes.
>> +
>> +During sparse file access faultaround gets more pages mapped and when all of
>> +them are young (default), under memory pressure, this makes vmscan swap out anon
>> +pages instead, or to drop other page cache pages which otherwise stay resident.
>> +Setting want_old_faultaround_pte to 1 avoids this.
>> +
>> +Making the faultaround ptes old can result in performance regression on some
>> +architectures. This is due to cycles spent in micro-fault for TLB lookup of old
>> +entry.
> It's not for TLB lookup. Micro-fault would take page walk to set young bit in
> the pte.


Fixed it in v3. Thanks Kirill.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
