Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9DA526B04C2
	for <linux-mm@kvack.org>; Wed,  7 Nov 2018 02:02:59 -0500 (EST)
Received: by mail-lf1-f71.google.com with SMTP id w13-v6so1960253lfe.6
        for <linux-mm@kvack.org>; Tue, 06 Nov 2018 23:02:59 -0800 (PST)
Received: from forwardcorp1j.cmail.yandex.net (forwardcorp1j.cmail.yandex.net. [5.255.227.105])
        by mx.google.com with ESMTPS id d202si25855865lfe.126.2018.11.06.23.02.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Nov 2018 23:02:57 -0800 (PST)
Subject: Re: [PATCH v1 0/4]mm: convert totalram_pages, totalhigh_pages and
 managed pages to atomic
References: <1540551662-26458-1-git-send-email-arunks@codeaurora.org>
 <9b210d4cc9925caf291412d7d45f16d7@codeaurora.org>
 <63d9f48c-e39f-d345-0fb6-2f04afe769a2@yandex-team.ru>
 <08a61c003eed0280fd82f6200debcbca@codeaurora.org>
 <10c88df6-dbb1-7490-628c-055d59b5ad8e@yandex-team.ru>
 <22fa2222012341a54f6b0b6aea341aa2@codeaurora.org>
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Message-ID: <c3b0edf9-e6a2-c1ab-8490-d94b9830c8ae@yandex-team.ru>
Date: Wed, 7 Nov 2018 10:02:55 +0300
MIME-Version: 1.0
In-Reply-To: <22fa2222012341a54f6b0b6aea341aa2@codeaurora.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arun KS <arunks@codeaurora.org>
Cc: keescook@chromium.org, minchan@kernel.org, getarunks@gmail.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, mhocko@kernel.org, vbabka@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, julia.lawall@lip6.fr

On 06.11.2018 11:43, Arun KS wrote:
> On 2018-11-06 14:07, Konstantin Khlebnikov wrote:
>> On 06.11.2018 11:30, Arun KS wrote:
>>> On 2018-11-06 13:47, Konstantin Khlebnikov wrote:
>>>> On 06.11.2018 8:38, Arun KS wrote:
>>>>> Any comments?
>>>>
>>>> Looks good.
>>>> Except unclear motivation behind this change.
>>>> This should be in comment of one of patch.
>>>
>>> totalram_pages, zone->managed_pages and totalhigh_pages are sometimes modified outside managed_page_count_lock. Hence convert these 
>>> variable to atomic to avoid readers potentially seeing a store tear.
>>
>> So, this is just theoretical issue or splat from sanitizer.
>> After boot memory online\offline are strictly serialized by rw-semaphore.
> 
> Few instances which can race with hot add. Please see below,
> https://patchwork.kernel.org/patch/10627521/
Could you point what exactly are you fixing with this set?

from v2:

 > totalram_pages, zone->managed_pages and totalhigh_pages updates
 > are protected by managed_page_count_lock, but readers never care
 > about it. Convert these variables to atomic to avoid readers
 > potentially seeing a store tear.

This?


Aligned unsigned long almost always stored at once.

To make it completely correct you could replace

a += b;

with

WRITE_ONCE(a, a + b);

> 
> Regards,
> Arun
> 
>>
>>>
>>> Will update the comment.
>>>
>>> Regards,
>>> Arun
>>>
>>>>
>>>> Reviewed-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>>>>
>>>>>
>>>>> Regards,
>>>>> Arun
>>>>>
>>>>> On 2018-10-26 16:30, Arun KS wrote:
>>>>>> This series convert totalram_pages, totalhigh_pages and
>>>>>> zone->managed_pages to atomic variables.
>>>>>>
>>>>>> The patch was comiple tested on x86(x86_64_defconfig & i386_defconfig)
>>>>>> on tip of linux-mmotm. And memory hotplug tested on arm64, but on an
>>>>>> older version of kernel.
>>>>>>
>>>>>> Arun KS (4):
>>>>>> A  mm: Fix multiple evaluvations of totalram_pages and managed_pages
>>>>>> A  mm: Convert zone->managed_pages to atomic variable
>>>>>> A  mm: convert totalram_pages and totalhigh_pages variables to atomic
>>>>>> A  mm: Remove managed_page_count spinlock
>>>>>>
>>>>>> A arch/csky/mm/init.cA A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>>>>>> A arch/powerpc/platforms/pseries/cmm.cA A A A A A A A A  | 10 ++--
>>>>>> A arch/s390/mm/init.cA A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A arch/um/kernel/mem.cA A A A A A A A A A A A A A A A A A A A A A A A A  |A  3 +-
>>>>>> A arch/x86/kernel/cpu/microcode/core.cA A A A A A A A A  |A  5 +-
>>>>>> A drivers/char/agp/backend.cA A A A A A A A A A A A A A A A A A A  |A  4 +-
>>>>>> A drivers/gpu/drm/amd/amdkfd/kfd_crat.cA A A A A A A A  |A  2 +-
>>>>>> A drivers/gpu/drm/i915/i915_gem.cA A A A A A A A A A A A A A  |A  2 +-
>>>>>> A drivers/gpu/drm/i915/selftests/i915_gem_gtt.c |A  4 +-
>>>>>> A drivers/hv/hv_balloon.cA A A A A A A A A A A A A A A A A A A A A A  | 19 +++----
>>>>>> A drivers/md/dm-bufio.cA A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A drivers/md/dm-crypt.cA A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A drivers/md/dm-integrity.cA A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A drivers/md/dm-stats.cA A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A drivers/media/platform/mtk-vpu/mtk_vpu.cA A A A A  |A  2 +-
>>>>>> A drivers/misc/vmw_balloon.cA A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A drivers/parisc/ccio-dma.cA A A A A A A A A A A A A A A A A A A A  |A  4 +-
>>>>>> A drivers/parisc/sba_iommu.cA A A A A A A A A A A A A A A A A A A  |A  4 +-
>>>>>> A drivers/staging/android/ion/ion_system_heap.c |A  2 +-
>>>>>> A drivers/xen/xen-selfballoon.cA A A A A A A A A A A A A A A A  |A  6 +--
>>>>>> A fs/ceph/super.hA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A fs/file_table.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  7 +--
>>>>>> A fs/fuse/inode.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A fs/nfs/write.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A fs/nfsd/nfscache.cA A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A fs/ntfs/malloc.hA A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A fs/proc/base.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A include/linux/highmem.hA A A A A A A A A A A A A A A A A A A A A A  | 28 ++++++++++-
>>>>>> A include/linux/mm.hA A A A A A A A A A A A A A A A A A A A A A A A A A A  | 27 +++++++++-
>>>>>> A include/linux/mmzone.hA A A A A A A A A A A A A A A A A A A A A A A  | 15 +++---
>>>>>> A include/linux/swap.hA A A A A A A A A A A A A A A A A A A A A A A A A  |A  1 -
>>>>>> A kernel/fork.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  5 +-
>>>>>> A kernel/kexec_core.cA A A A A A A A A A A A A A A A A A A A A A A A A A  |A  5 +-
>>>>>> A kernel/power/snapshot.cA A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A lib/show_mem.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A mm/highmem.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>>>>>> A mm/huge_memory.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A mm/kasan/quarantine.cA A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A mm/memblock.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  6 +--
>>>>>> A mm/memory_hotplug.cA A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>>>>>> A mm/mm_init.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A mm/oom_kill.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A mm/page_alloc.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  | 71 +++++++++++++--------------
>>>>>> A mm/shmem.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  7 +--
>>>>>> A mm/slab.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A mm/swap.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A mm/util.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A mm/vmalloc.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>>>>>> A mm/vmstat.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>>>>>> A mm/workingset.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A mm/zswap.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  4 +-
>>>>>> A net/dccp/proto.cA A A A A A A A A A A A A A A A A A A A A A A A A A A A A  |A  7 +--
>>>>>> A net/decnet/dn_route.cA A A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A net/ipv4/tcp_metrics.cA A A A A A A A A A A A A A A A A A A A A A A  |A  2 +-
>>>>>> A net/netfilter/nf_conntrack_core.cA A A A A A A A A A A A  |A  7 +--
>>>>>> A net/netfilter/xt_hashlimit.cA A A A A A A A A A A A A A A A A  |A  5 +-
>>>>>> A net/sctp/protocol.cA A A A A A A A A A A A A A A A A A A A A A A A A A  |A  7 +--
>>>>>> A security/integrity/ima/ima_kexec.cA A A A A A A A A A A  |A  2 +-
>>>>>> A 58 files changed, 195 insertions(+), 144 deletions(-)
