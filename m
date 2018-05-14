Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id BB2586B000A
	for <linux-mm@kvack.org>; Mon, 14 May 2018 05:09:53 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id w10-v6so14837359otj.14
        for <linux-mm@kvack.org>; Mon, 14 May 2018 02:09:53 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i205-v6si2846818oia.460.2018.05.14.02.09.52
        for <linux-mm@kvack.org>;
        Mon, 14 May 2018 02:09:52 -0700 (PDT)
Subject: Re: [PATCH v2] mm/ksm: ignore STABLE_FLAG of rmap_item->address in
 rmap_walk_ksm
References: <20180503124415.3f9d38aa@p-imbrenda.boeblingen.de.ibm.com>
 <1525403506-6750-1-git-send-email-hejianet@gmail.com>
 <20180509163101.02f23de1842a822c61fc68ff@linux-foundation.org>
 <80070c0b-aecf-0dcf-2b36-fa6110ed8ad5@gmail.com>
From: Suzuki K Poulose <Suzuki.Poulose@arm.com>
Message-ID: <c3b3dba3-b7ec-1554-a1f7-5847d372f2b5@arm.com>
Date: Mon, 14 May 2018 10:09:47 +0100
MIME-Version: 1.0
In-Reply-To: <80070c0b-aecf-0dcf-2b36-fa6110ed8ad5@gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan@kernel.org>, Claudio Imbrenda <imbrenda@linux.vnet.ibm.com>, Arvind Yadav <arvind.yadav.cs@gmail.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jia.he@hxt-semitech.com, Hugh Dickins <hughd@google.com>, Marc Zyngier <Marc.Zyngier@arm.com>

On 10/05/18 02:26, Jia He wrote:
> Hi Andrew
> 
> 
> On 5/10/2018 7:31 AM, Andrew Morton Wrote:
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
>> I assumed you wanted this patch to be committed as
>> From:jia.he@hxt-semitech.com rather than From:hejianet@gmail.com, so I
>> made that change.A  Please let me know if this was inappropriate.
> Thanks, because there is still some issues in our company's mail server.
> I have to use my gmail mailbox.
>>
>> You can do this yourself by adding an explicit From: line to the very
>> start of the patch's email text.
>>
>> Also, a storm of WARN_ONs is pretty poor behaviour.A  Is that the only
>> misbehaviour which this bug causes?A  Do you think the fix should be
>> backported into earlier kernels?
> IMO, it should be backported to stable tree, seems that I missed CC to stable tree ;-)
> the stom of WARN_ONs is very easy for me to reproduce.
> More than that, I watched a panic (not reproducible) as follows:


> [35380.805825] page:ffff7fe003742d80 count:-4871 mapcount:-2126053375 mapping:A A A A A A A A A  (null) index:0x0
> [35380.815024] flags: 0x1fffc00000000000()
> [35380.818845] raw: 1fffc00000000000 0000000000000000 0000000000000000 ffffecf981470000
> [35380.826569] raw: dead000000000100 dead000000000200 ffff8017c001c000 0000000000000000
> [35380.834294] page dumped because: nonzero _refcount

> [35380.908341] CPU: 29 PID: 18323 Comm: qemu-kvm Tainted: G W 4.14.15-5.hxt.aarch64 #1
> [35380.917107] Hardware name: <snip for confidential issues>
> [35380.930909] Call trace:
> [35380.933345] [<ffff000008088f00>] dump_backtrace+0x0/0x22c
> [35380.938723] [<ffff000008089150>] show_stack+0x24/0x2c
> [35380.943759] [<ffff00000893c078>] dump_stack+0x8c/0xb0
> [35380.948794] [<ffff00000820ab50>] bad_page+0xf4/0x154
> [35380.953740] [<ffff000008211ce8>] free_pages_check_bad+0x90/0x9c
> [35380.959642] [<ffff00000820c430>] free_pcppages_bulk+0x464/0x518
> [35380.965545] [<ffff00000820db98>] free_hot_cold_page+0x22c/0x300
> [35380.971448] [<ffff0000082176fc>] __put_page+0x54/0x60
> [35380.976484] [<ffff0000080b1164>] unmap_stage2_range+0x170/0x2b4
> [35380.982385] [<ffff0000080b12d8>] kvm_unmap_hva_handler+0x30/0x40
> [35380.988375] [<ffff0000080b0104>] handle_hva_to_gpa+0xb0/0xec
> [35380.994016] [<ffff0000080b2644>] kvm_unmap_hva_range+0x5c/0xd0
> [35380.999833] [<ffff0000080a8054>] kvm_mmu_notifier_invalidate_range_start+0x60/0xb0
> [35381.007387] [<ffff000008271f44>] __mmu_notifier_invalidate_range_start+0x64/0x8c
> [35381.014765] [<ffff0000082547c8>] try_to_unmap_one+0x78c/0x7a4
> [35381.020493] [<ffff000008276d04>] rmap_walk_ksm+0x124/0x1a0
> [35381.025961] [<ffff0000082551b4>] rmap_walk+0x94/0x98
> [35381.030909] [<ffff0000082555e4>] try_to_unmap+0x100/0x124
> [35381.036293] [<ffff00000828243c>] unmap_and_move+0x480/0x6fc
> [35381.041847] [<ffff000008282b6c>] migrate_pages+0x10c/0x288
> [35381.047318] [<ffff00000823c164>] compact_zone+0x238/0x954
> [35381.052697] [<ffff00000823c944>] compact_zone_order+0xc4/0xe8
> [35381.058427] [<ffff00000823d25c>] try_to_compact_pages+0x160/0x294
> [35381.064503] [<ffff00000820f074>] __alloc_pages_direct_compact+0x68/0x194
> [35381.071187] [<ffff000008210138>] __alloc_pages_nodemask+0xc20/0xf7c
> [35381.077437] [<ffff0000082709e4>] alloc_pages_vma+0x1a4/0x1c0
> [35381.083080] [<ffff000008285b68>] do_huge_pmd_anonymous_page+0x128/0x324
> [35381.089677] [<ffff000008248a24>] __handle_mm_fault+0x71c/0x7e8
> [35381.095492] [<ffff000008248be8>] handle_mm_fault+0xf8/0x194
> [35381.101049] [<ffff000008240dcc>] __get_user_pages+0x124/0x34c
> [35381.106777] [<ffff000008241870>] populate_vma_page_range+0x90/0x9c
> [35381.112941] [<ffff000008241940>] __mm_populate+0xc4/0x15c
> [35381.118322] [<ffff00000824b294>] SyS_mlockall+0x100/0x164
> [35381.123705] Exception stack(0xffff800dce5f3ec0 to 0xffff800dce5f4000)
> [35381.130128] 3ec0: 0000000000000003 d6e6024cc9b87e00 0000aaaabe94f000 0000000000000000
> [35381.137940] 3ee0: 0000000000000002 0000000000000000 0000000000000000 0000aaaacf6fc3c0
> [35381.145753] 3f00: 00000000000000e6 0000aaaacf6fc490 0000ffffeeeab0f0 d6e6024cc9b87e00
> [35381.153565] 3f20: 0000000000000000 0000aaaabe81b3c0 0000000000000020 00009e53eff806b5
> [35381.161379] 3f40: 0000aaaabe94de48 0000ffffa7c269b0 0000000000000011 0000ffffeeeabf68
> [35381.169190] 3f60: 0000aaaaceacfe60 0000aaaabe94f000 0000aaaabe9ba358 0000aaaabe7ffb80
> [35381.177003] 3f80: 0000aaaabe9ba000 0000aaaabe959f64 0000000000000000 0000aaaabe94f000
> [35381.184815] 3fa0: 0000000000000000 0000ffffeeeabdb0 0000aaaabe5f3bf8 0000ffffeeeabdb0
> [35381.192628] 3fc0: 0000ffffa7c269b8 0000000060000000 0000000000000003 00000000000000e6
> [35381.200440] 3fe0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
> [35381.208254] [<ffff00000808339c>] __sys_trace_return+0x0/0x4
> [35381.213809] Disabling lock debugging due to kernel taint
> 
> I ever injected a fault on purpose in kvm_unmap_hva_range by set size=size-0x200, the call trace is similar
> as above. Thus, I thought the panic is similarly caused by the root cause of WARN_ON


Please could you share your "changes" (that injected the fault) that triggered this Panic
and the steps that triggered this ?

The only reason we should get there is by trying to put a page that is not owned by the KVM
Stage 2 page table either:

1) It was free'd already ? - We has some race conditions there which were
fixed.
2) The code tries to access something that doesn't belong there. - If this happens
that doesn't look good for a simple change you mentioned. So we would like to
know better about the situation to see if there is something we need to address.

Suzuki
