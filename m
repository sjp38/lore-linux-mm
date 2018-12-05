Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f199.google.com (mail-qt1-f199.google.com [209.85.160.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9006B74E9
	for <linux-mm@kvack.org>; Wed,  5 Dec 2018 10:05:26 -0500 (EST)
Received: by mail-qt1-f199.google.com with SMTP id z6so20845844qtj.21
        for <linux-mm@kvack.org>; Wed, 05 Dec 2018 07:05:26 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id e52si1352334qte.213.2018.12.05.07.05.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Dec 2018 07:05:25 -0800 (PST)
Subject: Re: [PATCH RFC 7/7] mm: better document PG_reserved
References: <20181205122851.5891-1-david@redhat.com>
 <20181205122851.5891-8-david@redhat.com>
 <20181205143510.GA17232@bombadil.infradead.org>
From: David Hildenbrand <david@redhat.com>
Message-ID: <46d0e90f-f0bb-815e-7a5b-4429de1c502a@redhat.com>
Date: Wed, 5 Dec 2018 16:05:12 +0100
MIME-Version: 1.0
In-Reply-To: <20181205143510.GA17232@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-m68k@lists.linux-m68k.org, linuxppc-dev@lists.ozlabs.org, linux-riscv@lists.infradead.org, linux-s390@vger.kernel.org, linux-mediatek@lists.infradead.org, Andrew Morton <akpm@linux-foundation.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Pavel Tatashin <pasha.tatashin@oracle.com>, Michal Hocko <mhocko@suse.com>, Alexander Duyck <alexander.h.duyck@linux.intel.com>, Anthony Yznaga <anthony.yznaga@oracle.com>, Miles Chen <miles.chen@mediatek.com>, yi.z.zhang@linux.intel.com, Dan Williams <dan.j.williams@intel.com>

On 05.12.18 15:35, Matthew Wilcox wrote:
> On Wed, Dec 05, 2018 at 01:28:51PM +0100, David Hildenbrand wrote:
>> I don't see a reason why we have to document "Some of them might not even
>> exist". If there is a user, we should document it. E.g. for balloon
>> drivers we now use PG_offline to indicate that a page might currently
>> not be backed by memory in the hypervisor. And that is independent from
>> PG_reserved.
> 
> I think you're confused by the meaning of "some of them might not even
> exist".  What this means is that there might not be memory there; maybe
> writes to that memory will be discarded, or maybe they'll cause a machine
> check.  Maybe reads will return ~0, or 0, or cause a machine check.
> We just don't know what's there, and we shouldn't try touching the memory.

If there are users, let's document it. And I need more details for that :)

1. machine check: if there is a HW error, we set PG_hwpoison (except
ia64 MCA, see the list)

2. Writes to that memory will be discarded

Who is the user of that? When will we have such pages right now?

3. Reads will return ~0, / 0?

I think this is a special case of e.g. x86? But where do we have that,
are there any user?


In summary: When can we have memory sections that are online but pages
reserved and not accessible? (one example is ballooning I mention here)

(I classify this as dangerous as dump tools will happily dump
PG_reserved pages (unless PG_hwpoison/PG_offline) and that's the right
thing to do).

I want to avoid documenting things that are not actually getting used.

> 
>> +++ b/include/linux/page-flags.h
>> @@ -17,8 +17,22 @@
>>  /*
>>   * Various page->flags bits:
>>   *
>> - * PG_reserved is set for special pages, which can never be swapped out. Some
>> - * of them might not even exist...
>> + * PG_reserved is set for special pages. The "struct page" of such a page
>> + * should in general not be touched (e.g. set dirty) except by their owner.
>> + * Pages marked as PG_reserved include:
>> + * - Kernel image (including vDSO) and similar (e.g. BIOS, initrd)
>> + * - Pages allocated early during boot (bootmem, memblock)
>> + * - Zero pages
>> + * - Pages that have been associated with a zone but are not available for
>> + *   the page allocator (e.g. excluded via online_page_callback())
>> + * - Pages to exclude from the hibernation image (e.g. loaded kexec images)
>> + * - MMIO pages (communicate with a device, special caching strategy needed)
>> + * - MCA pages on ia64 (pages with memory errors)
>> + * - Device memory (e.g. PMEM, DAX, HMM)
>> + * Some architectures don't allow to ioremap pages that are not marked
>> + * PG_reserved (as they might be in use by somebody else who does not respect
>> + * the caching strategy). Consequently, PG_reserved for a page mapped into
>> + * user space can indicate the zero page, the vDSO, MMIO pages or device memory.
> 
> So maybe just add one more option to the list.
> 


-- 

Thanks,

David / dhildenb
