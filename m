Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9BD1A6B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 07:58:49 -0500 (EST)
Received: from relay2.suse.de (mail2.suse.de [195.135.221.8])
	by mx2.suse.de (Postfix) with ESMTP id 3C2CA79727
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:58:47 +0100 (CET)
Subject: CONFIG_STRICT_DEVMEM broken
From: Petr Tesarik <ptesarik@suse.cz>
Content-Type: text/plain
Date: Fri, 06 Nov 2009 13:58:46 +0100
Message-Id: <1257512326.6288.91.camel@nathan.suse.cz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I found a problem with /dev/mem mappings. Both mmap() and mmap2() can be
given a value for offset which is beyond the physical range supported by
the architecture. The value is then passed down to remap_pte_range(),
and depending on the implementation of pfn_pte(), the layout of the page
table entry itself and other arch-specific details, the PTE can map to
an existing page.

On non-PAE i386 the PFN can overflow the 32-bit PTE, so the highest bits
are ignored.
On ia64, the PTE is 64-bit, but bits 53-63 of the PTE are ignored by the
CPU, so it is also possible to wrap around the physical range.
On x86_64, it is possible to set the reserved bits 40-51, causing a Page
Fault. You can also modify the available bits 52-62, or the NX bit.
On s/390 (31-bit), it's possible to set bit 31. I can't remember what
that does, and I don't currently have an s/390 which I could crash, but
this bit should be always 0.

This can become a problem on x86 with PAT enabled, where we cannot
tolerate cache aliasing, but it's still possible create aliases by using
a large enough PFN.

IMO the root cause is that pfn_pte() assumes that the PFN is valid, but
in the case of /dev/mem it originates directly from user-space, so the
assumption may be wrong.

I'm not sure how to fix this. It would be nice to return -EINVAL in
mmap_mem() and read_mem() if the physical range is not available on the
architecture, but:

1. There doesn't seem to be a per-arch macro that could be used to
   determine the allowed range.
2. Some architectures seem not to have a fixed limit.
3. You may argue that this is "broken by design", and the application
   should never map such areas from /dev/mem.

Any comments?
Petr Tesarik


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
