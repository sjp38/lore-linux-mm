Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 6F9BB6B0002
	for <linux-mm@kvack.org>; Tue, 12 Feb 2013 13:25:11 -0500 (EST)
From: Mitchel Humpherys <mitchelh@codeaurora.org>
Subject: Support for high-order pages on ARM
Date: Tue, 12 Feb 2013 10:25:10 -0800
Message-ID: <vnkw4nhh75kp.fsf@mitchelh-linux.qualcomm.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linaro-mm-sig@lists.linaro.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

Hi,

While working with high-order page allocations (using `alloc_pages') I've
encountered some issues* with certain APIs and wanted to get a better
understanding of support for those APIs with high-order pages on ARM. In
short, I'm trying to give userspace access to those pages by using
`vm_insert_page' in an mmap handler. Without further ado, some
questions:

  o vm_insert_page doesn't seem to work with high-order pages (it
    eventually calls __flush_dcache_page which assumes pages of size
    PAGE_SIZE). Is this analysis correct or am I missing something?
    Things work fine if I use `remap_pfn_range' instead of
    `vm_insert_page'. Things also seem to work if I use `vm_insert_page'
    with an array of struct page * of size PAGE_SIZE (derived from the
    high-order pages by picking out the PAGE_SIZE pages with
    nth_page)...

  o There's a comment in __dma_alloc (dma-alloc.c) to the effect that
    __GFP_COMP is not supported on ARM. Is this true? The commit that
    introduced this comment (ea2e7057) was actually ported from avr32
    (3611553ef) so I'm curious about the basis for this claim...


I've tried pages of order 8 and order 4. The gfp flags I'm passing to
`alloc_pages' are (GFP_KERNEL | __GFP_HIGHMEM | __GFP_COMP).

Thanks!

* Some issues = in userspace mmap the buffer whose underlying mmap
  handler is the one mentioned above, memset that to something and then
  immediately check that the bytes are equal to whatever we just memset.
  (With huge pages and vm_insert_page this test fails).

-- 
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum,
hosted by The Linux Foundation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
