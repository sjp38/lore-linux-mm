Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.12.11/8.12.11) with ESMTP id j9IDkeUD031462
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 09:46:40 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VERS6.7) with ESMTP id j9IDkea2081554
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 09:46:40 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.13.3) with ESMTP id j9IDkeZJ030086
	for <linux-mm@kvack.org>; Tue, 18 Oct 2005 09:46:40 -0400
Message-ID: <4354FCCB.8080207@de.ibm.com>
Date: Tue, 18 Oct 2005 15:46:51 +0200
From: Carsten Otte <cotte@de.ibm.com>
Reply-To: carsteno@de.ibm.com
MIME-Version: 1.0
Subject: Re: What were your needs for do_no_page calling a driver for a pfn?
References: <20051018114506.GB20231@lnx-holt.americas.sgi.com>
In-Reply-To: <20051018114506.GB20231@lnx-holt.americas.sgi.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Robin Holt <holt@sgi.com>
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Nick Piggin <nickpiggin@yahoo.com.au>
List-ID: <linux-mm.kvack.org>

Robin Holt wrote:
> Can you give me a heads up on your need?
The idea originated from Hugh Dickins. Nick Piggin
and Hugh ran into my xip code [see mm/filemap_xip.c
and fs/ext2/xip.*] because it does use PG_RESERVED
at the moment. While the xip code now works fine
even without PG_RESERVED, Hugh inspired me to think
about getting rid of [struct page] entries in
mem_map for my DCSS segments, because the new core
memory management leaves the mem_map entries alone
once VM_RESERVED is set for the VMA.
During my analysis, I ran into various issues that
I need to solve in order to do that:
- nopage() does return a struct page. It needs to
  be replaced by a new aop that returns a page frame
  number (nopfn).
- flush_dcache_page() takes struct page as argument.
  For the nine architectures that have it, I need to
  create a replacement (flush_dcache_pfn).
  Given that flush_dcache_page is used in many device
  drivers and filesystems, and because
  flush_dcache_page does avoid cache flushes with a
  page flag indicating that subject page needs to be
  flushed from cache once it is accessible to userland
  again, I do think that flush_dcache_page should not
  be replaced - flush_dcache_pfn would be an
  alternative function for situations where you don't
  have struct page.
- the filemap actors do use struct page as argument.
  I need to rework that to have actors take a page
  frame number as argument instead.
- my get_xip_page aop needs to be replaced by one
  that does deliver a page frame number
- last but not least, I do need Hugh's
  implementation of copy-on-write for VM_RESERVED
  VMAs (do_wp_reserved). That one does not need the
  struct page entry in order to do C-O-W.

Above does provide a major benefit for many small
servers on z/VM:
When all (userland) libraries and binaries reside in
an execute in place filesystem, and the kernel binary
is shared xip, then each server has quite small
memory requirement. But with an entire server distro
on that xip filesystem, the mem_map array for the
filesystem really occupies about 30% of the general
purpose memory.
Thus we could run about 30% more servers when
getting rid of the struct page.

The shiny new memory management in -mm really is a
major step that gets us closer to that goal. As of
today, Hugh dislikes his proof-of-concept
do_wp_reserved. He wants things to settle down and
integrate things into mainline rather then
introduce more features for now. I respect that
and don't push to get do_wp_reserved.

If we are lucky, other uses for do_wp_reserved will
come up. If that happens, I will be happy to work on
the other issues in above list.
--

Carsten Otte
IBM Linux technology center
ARCH=s390

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
