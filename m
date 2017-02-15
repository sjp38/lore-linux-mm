Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 82DAB4405BD
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 16:26:44 -0500 (EST)
Received: by mail-ot0-f200.google.com with SMTP id 19so92561490oti.0
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 13:26:44 -0800 (PST)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id y94si2350732ota.15.2017.02.15.13.26.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 13:26:43 -0800 (PST)
Received: by mail-oi0-x233.google.com with SMTP id w204so93613837oiw.0
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 13:26:43 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20170215131023.02186e970498eca080c8d456@linux-foundation.org>
References: <20170215205826.13356-1-nicstange@gmail.com> <20170215131023.02186e970498eca080c8d456@linux-foundation.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 15 Feb 2017 13:26:43 -0800
Message-ID: <CAPcyv4gAUCsJ9HcSyAK6j4YDHPkJsb06ZX=uJsYBMDCNMFsNmQ@mail.gmail.com>
Subject: Re: [RFC 0/3] Regressions due to 7b79d10a2d64 ("mm: convert
 kmalloc_section_memmap() to populate_section_memmap()") and Kasan
 initialization on
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nicolai Stange <nicstange@gmail.com>, Linux MM <linux-mm@kvack.org>

On Wed, Feb 15, 2017 at 1:10 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Wed, 15 Feb 2017 21:58:23 +0100 Nicolai Stange <nicstange@gmail.com> wrote:
>
>> Hi Dan,
>>
>> your recent commit 7b79d10a2d64 ("mm: convert kmalloc_section_memmap() to
>> populate_section_memmap()") seems to cause some issues with respect to
>> Kasan initialization on x86.
>>
>> This is because Kasan's initialization (ab)uses the arch provided
>> vmemmap_populate().
>>
>> The first one is a boot failure, see [1/3]. The commit before the
>> aforementioned one works fine.
>>
>> The second one, i.e. [2/3], is something that hit my eye while browsing
>> the source and I verified that this is indeed an issue by printk'ing and
>> dumping the page tables.
>>
>> The third one are excessive warnings from vmemmap_verify() due to Kasan's
>> NUMA_NO_NODE page populations.
>
> urggggh.
>
> That means these two series:
>
> mm-fix-type-width-of-section-to-from-pfn-conversion-macros.patch
> mm-devm_memremap_pages-use-multi-order-radix-for-zone_device-lookups.patch
> mm-introduce-struct-mem_section_usage-to-track-partial-population-of-a-section.patch
> mm-introduce-common-definitions-for-the-size-and-mask-of-a-section.patch
> mm-cleanup-sparse_init_one_section-return-value.patch
> mm-track-active-portions-of-a-section-at-boot.patch
> mm-track-active-portions-of-a-section-at-boot-fix.patch
> mm-track-active-portions-of-a-section-at-boot-fix-fix.patch
> mm-fix-register_new_memory-zone-type-detection.patch
> mm-convert-kmalloc_section_memmap-to-populate_section_memmap.patch
> mm-prepare-for-hot-add-remove-of-sub-section-ranges.patch
> mm-support-section-unaligned-zone_device-memory-ranges.patch
> mm-support-section-unaligned-zone_device-memory-ranges-fix.patch
> mm-support-section-unaligned-zone_device-memory-ranges-fix-2.patch
> mm-enable-section-unaligned-devm_memremap_pages.patch
> libnvdimm-pfn-dax-stop-padding-pmem-namespaces-to-section-alignment.patch
>

Yes, let's drop these and try again for 4.12. Thanks for the report
and the debug Nicolai!

> and
>
> mm-devm_memremap_pages-hold-device_hotplug-lock-over-mem_hotplug_begin-done.patch
> mm-validate-device_hotplug-is-held-for-memory-hotplug.patch

No, these are separate and are still valid for the merge window.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
