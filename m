Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 843966B02A7
	for <linux-mm@kvack.org>; Sat, 31 Jul 2010 00:21:26 -0400 (EDT)
Received: by qwk4 with SMTP id 4so631671qwk.14
        for <linux-mm@kvack.org>; Fri, 30 Jul 2010 21:21:24 -0700 (PDT)
MIME-Version: 1.0
Date: Sat, 31 Jul 2010 09:51:24 +0530
Message-ID: <AANLkTintdQoSu9cFz2_mCqok+LC7Xtz2MTE4YpnyPFnE@mail.gmail.com>
Subject: mmap()
From: Manu Abraham <abraham.manu@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: npiggin@suse.de, piggin@cyberone.com.au, nickpiggin@yahoo.com.au
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Hi Nick, all,

With mmap() VM operations, with a page fault would it be possible to
allocate/map more than one page ?

I will try to explain a bit more in detail, what I would like to do.

I have a PCIe bridge which can capture frames at very high resolutions
at a very fast rate. Based on the requirements, these chipsets handle
memory in a way slightly different to other frame grabber chipsets.
They have an onchip MMU with a DMA Multiplexer, where the chipset has
to be allocated with all the relevant memory needed for operation at
chip initialization time. The allocated memory is 2MB (512 pages long,
can be contiguous or non-contiguous). There needs to be a minimal of 8
such buffers. ie, total 16MB each.

The user application can read each 2MB buffer (Scatter Gather list) on
an IRQ/MSI event. The buffer to be read from (of the 8 buffers) go
around on a round-robin fashion. I would like to avoid a memcpy of the
buffers in this application, basically due to the bandwidth in use.
Initially, I thought about mmap(), where  2 such buffers (where the
total visible virtual region appears as 4MB long):


1.  Init-> Buffer1 mapped into the first half
2.  Page fault -> Buffer2 mapped into the second half
3.  Page fault-> Buffer1 unmapped; Buffer3 mapped into first half
4.  Page fault-> Buffer2 unmapped; Buffer4 mapped into second half
5.  Page fault-> Buffer3 unmapped; Buffer5 mapped into first half
6.  Page fault-> Buffer4 unmapped; Buffer6 mapped into second half
7.  Page fault-> Buffer5 unmapped; Buffer7 mapped into first half
8.  Page fault-> Buffer6 unmapped; Buffer8 mapped into second half
9.  Page fault-> Buffer7 unmapped; Buffer1 mapped into first half
10. Page fault-> Buffer8 unmapped; Buffer2 mapped into second half


and the cycle goes on. I was wondering whether there's any option to
map the buffers in such a way, rather than to do map/allocate a page
on each page fault ? I really looked many places, but couldn't really
make out something similar and hence my query.

Ideas and thoughts would be much appreciated.

Thanks,
Manu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
