Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AC8224405BD
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 16:10:25 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id z67so194540888pgb.0
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 13:10:25 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t7si4818849pfi.147.2017.02.15.13.10.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 13:10:24 -0800 (PST)
Date: Wed, 15 Feb 2017 13:10:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [RFC 0/3] Regressions due to 7b79d10a2d64
 ("mm: convert kmalloc_section_memmap() to populate_section_memmap()") and
 Kasan initialization on
Message-Id: <20170215131023.02186e970498eca080c8d456@linux-foundation.org>
In-Reply-To: <20170215205826.13356-1-nicstange@gmail.com>
References: <20170215205826.13356-1-nicstange@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolai Stange <nicstange@gmail.com>
Cc: Dan Williams <dan.j.williams@intel.com>, linux-mm@kvack.org

On Wed, 15 Feb 2017 21:58:23 +0100 Nicolai Stange <nicstange@gmail.com> wrote:

> Hi Dan,
> 
> your recent commit 7b79d10a2d64 ("mm: convert kmalloc_section_memmap() to
> populate_section_memmap()") seems to cause some issues with respect to
> Kasan initialization on x86.
> 
> This is because Kasan's initialization (ab)uses the arch provided
> vmemmap_populate().
> 
> The first one is a boot failure, see [1/3]. The commit before the
> aforementioned one works fine.
> 
> The second one, i.e. [2/3], is something that hit my eye while browsing
> the source and I verified that this is indeed an issue by printk'ing and
> dumping the page tables.
> 
> The third one are excessive warnings from vmemmap_verify() due to Kasan's
> NUMA_NO_NODE page populations.

urggggh.

That means these two series:

mm-fix-type-width-of-section-to-from-pfn-conversion-macros.patch
mm-devm_memremap_pages-use-multi-order-radix-for-zone_device-lookups.patch
mm-introduce-struct-mem_section_usage-to-track-partial-population-of-a-section.patch
mm-introduce-common-definitions-for-the-size-and-mask-of-a-section.patch
mm-cleanup-sparse_init_one_section-return-value.patch
mm-track-active-portions-of-a-section-at-boot.patch
mm-track-active-portions-of-a-section-at-boot-fix.patch
mm-track-active-portions-of-a-section-at-boot-fix-fix.patch
mm-fix-register_new_memory-zone-type-detection.patch
mm-convert-kmalloc_section_memmap-to-populate_section_memmap.patch
mm-prepare-for-hot-add-remove-of-sub-section-ranges.patch
mm-support-section-unaligned-zone_device-memory-ranges.patch
mm-support-section-unaligned-zone_device-memory-ranges-fix.patch
mm-support-section-unaligned-zone_device-memory-ranges-fix-2.patch
mm-enable-section-unaligned-devm_memremap_pages.patch
libnvdimm-pfn-dax-stop-padding-pmem-namespaces-to-section-alignment.patch

and

mm-devm_memremap_pages-hold-device_hotplug-lock-over-mem_hotplug_begin-done.patch
mm-validate-device_hotplug-is-held-for-memory-hotplug.patch

aren't mergable into 4.10 and presumably won't be fixed in time.  I
think I'll drop all the above.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
