Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 677A06B0072
	for <linux-mm@kvack.org>; Tue, 19 Nov 2013 15:06:40 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id r10so5657333pdi.10
        for <linux-mm@kvack.org>; Tue, 19 Nov 2013 12:06:40 -0800 (PST)
Received: from psmtp.com ([74.125.245.129])
        by mx.google.com with SMTP id oy2si12365185pbc.219.2013.11.19.12.06.37
        for <linux-mm@kvack.org>;
        Tue, 19 Nov 2013 12:06:38 -0800 (PST)
From: Thomas Hellstrom <thellstrom@vmware.com>
Subject: [PATCH RFC 0/3] Add dirty-tracking infrastructure for non-page-backed address spaces
Date: Tue, 19 Nov 2013 12:06:13 -0800
Message-Id: <1384891576-7851-1-git-send-email-thellstrom@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: linux-graphics-maintainer@vmware.com

Hi!

Before going any further with this I'd like to check whether this is an
acceptable way to go.
Background:
GPU buffer objects in general and vmware svga GPU buffers in
particular are mapped by user-space using MIXEDMAP or PFNMAP. Sometimes the
address space is backed by a set of pages, sometimes it's backed by PCI memory.
In the latter case in particular, there is no way to track dirty regions
using page_mkwrite() and page_mkclean(), other than allocating a bounce
buffer and perform dirty tracking on it, and then copy data to the real GPU
buffer. This comes with a big memory- and performance overhead.

So I'd like to add the following infrastructure with a callback pfn_mkwrite()
and a function mkclean_mapping_range(). Typically we will be cleaning a range
of ptes rather than random ptes in a vma.
This comes with the extra benefit of being usable when the backing memory of
the GPU buffer is not coherent with the GPU itself, and where we either need
to flush caches or move data to synchronize.

So this is a RFC for
1) The API. Is it acceptable? Any other suggestions if not?
2) Modifying apply_to_page_range(). Better to make a standalone
non-populating version?
3) tlb- mmu- and cache-flushing calls. I've looked at unmap_mapping_range()
and page_mkclean_one() to try to get it right, but still unsure.

Thanks,
Thomas HellstrA?m

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
