Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3DB126B0007
	for <linux-mm@kvack.org>; Thu, 24 May 2018 04:44:23 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id k13-v6so519815oiw.3
        for <linux-mm@kvack.org>; Thu, 24 May 2018 01:44:23 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t22-v6si7469085oth.323.2018.05.24.01.44.20
        for <linux-mm@kvack.org>;
        Thu, 24 May 2018 01:44:20 -0700 (PDT)
Subject: Re: [PATCH v2] mm/ksm: ignore STABLE_FLAG of rmap_item->address in
 rmap_walk_ksm
From: Suzuki K Poulose <Suzuki.Poulose@arm.com>
References: <20180503124415.3f9d38aa@p-imbrenda.boeblingen.de.ibm.com>
 <1525403506-6750-1-git-send-email-hejianet@gmail.com>
 <20180509163101.02f23de1842a822c61fc68ff@linux-foundation.org>
 <2cd6b39b-1496-bbd5-9e31-5e3dcb31feda@arm.com>
Message-ID: <6c417ab1-a808-72ea-9618-3d76ec203684@arm.com>
Date: Thu, 24 May 2018 09:44:16 +0100
MIME-Version: 1.0
In-Reply-To: <2cd6b39b-1496-bbd5-9e31-5e3dcb31feda@arm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jia He <hejianet@gmail.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com, Hugh Dickins <hughd@google.com>

On 14/05/18 10:45, Suzuki K Poulose wrote:
> On 10/05/18 00:31, Andrew Morton wrote:
>> On Fri,A  4 May 2018 11:11:46 +0800 Jia He <hejianet@gmail.com> wrote:
>>
>>> In our armv8a server(QDF2400), I noticed lots of WARN_ON caused by PAGE_SIZE
>>> unaligned for rmap_item->address under memory pressure tests(start 20 guests
>>> and run memhog in the host).
>>>
>>> ...
>>>
>>> In rmap_walk_ksm, the rmap_item->address might still have the STABLE_FLAG,
>>> then the start and end in handle_hva_to_gpa might not be PAGE_SIZE aligned.
>>> Thus it will cause exceptions in handle_hva_to_gpa on arm64.
>>>
>>> This patch fixes it by ignoring(not removing) the low bits of address when
>>> doing rmap_walk_ksm.
>>>
>>> Signed-off-by: jia.he@hxt-semitech.com
>>
>> I assumed you wanted this patch to be committed as
>> From:jia.he@hxt-semitech.com rather than From:hejianet@gmail.com, so I
>> made that change.A  Please let me know if this was inappropriate.
>>
>> You can do this yourself by adding an explicit From: line to the very
>> start of the patch's email text.
>>
>> Also, a storm of WARN_ONs is pretty poor behaviour.A  Is that the only
>> misbehaviour which this bug causes?A  Do you think the fix should be
>> backported into earlier kernels?
>>


Jia, Andrew,

What is the status of this patch ?

Suzuki

> 
> I think its just not the WARN_ON(). We do more than what is probably
> intended with an unaligned address. i.e, We could be modifying the
> flags for other pages that were not affected.
> 
> e.g :
> 
> In the original report [0], the trace looked like :
> 
> 
> [A  800.511498] [<ffff0000080b4f2c>] kvm_age_hva_handler+0xcc/0xd4
> [A  800.517324] [<ffff0000080b4838>] handle_hva_to_gpa+0xec/0x15c
> [A  800.523063] [<ffff0000080b6c5c>] kvm_age_hva+0x5c/0xcc
> [A  800.528194] [<ffff0000080a7c3c>] kvm_mmu_notifier_clear_flush_young+0x54/0x90
> [A  800.535324] [<ffff00000827a0e8>] __mmu_notifier_clear_flush_young+0x6c/0xa8
> [A  800.542279] [<ffff00000825a644>] page_referenced_one+0x1e0/0x1fc
> [A  800.548279] [<ffff00000827e8f8>] rmap_walk_ksm+0x124/0x1a0
> [A  800.553759] [<ffff00000825c974>] rmap_walk+0x94/0x98
> [A  800.558717] [<ffff00000825ca98>] page_referenced+0x120/0x180
> [A  800.564369] [<ffff000008228c58>] shrink_active_list+0x218/0x4a4
> [A  800.570281] [<ffff000008229470>] shrink_node_memcg+0x58c/0x6fc
> [A  800.576107] [<ffff0000082296c4>] shrink_node+0xe4/0x328
> [A  800.581325] [<ffff000008229c9c>] do_try_to_free_pages+0xe4/0x3b8
> [A  800.587324] [<ffff00000822a094>] try_to_free_pages+0x124/0x234
> [A  800.593150] [<ffff000008216aa0>] __alloc_pages_nodemask+0x564/0xf7c
> [A  800.599412] [<ffff000008292814>] khugepaged_alloc_page+0x38/0xb8
> [A  800.605411] [<ffff0000082933bc>] collapse_huge_page+0x74/0xd70
> [A  800.611238] [<ffff00000829470c>] khugepaged_scan_mm_slot+0x654/0xa98
> [A  800.617585] [<ffff000008294e0c>] khugepaged+0x2bc/0x49c
> [A  800.622803] [<ffff0000080ffb70>] kthread+0x124/0x150
> [A  800.627762] [<ffff0000080849f0>] ret_from_fork+0x10/0x1c
> [A  800.633066] ---[ end trace 944c130b5252fb01 ]---
> 
> Now, the ksm wants to mark *a page* as referenced via page_referenced_one(),
> passing it an unaligned address. This could eventually turn out to be
> one of :
> 
> ptep_clear_flush_young_notify(address, address + PAGE_SIZE)
> 
> or
> 
> pmdp_clear_flush_young_notify(address, address + PMD_SIZE)
> 
> which now spans two pages/pmds and the notifier consumer might
> take an action on the second page as well, which is not something
> intended. So, I do think that old behavior is wrong and has other
> side effects as mentioned above.
> 
> [0] https://lkml.kernel.org/r/1525244911-5519-1-git-send-email-hejianet@gmail.com
> 
> Suzuki
