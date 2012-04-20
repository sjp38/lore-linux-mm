Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx118.postini.com [74.125.245.118])
	by kanga.kvack.org (Postfix) with SMTP id 25CFE6B004D
	for <linux-mm@kvack.org>; Fri, 20 Apr 2012 17:49:21 -0400 (EDT)
From: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Subject: [RFC PATCH] frontswap (v15). +--------+ |zsmalloc| +--------+ +---------+    +------------+          | | swap    +--->| frontswap  +          v +---------+    +------------|      +--------+  +----->| zcache | +--------+
Date: Fri, 20 Apr 2012 17:44:09 -0400
Message-Id: <1334958255-6612-1-git-send-email-konrad.wilk@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, ngupta@vflare.org, sjenning@linux.vnet.ibm.com, rcj@linux.vnet.ibm.com, aarcange@redhat.com, dhowells@redhat.com, riel@redhat.com, JBeulich@novell.com

[Example usage, others are tmem, ramster, and RFC KVM]

Frontswap provides a "transcendent memory" interface for swap pages.
In some environments, dramatic performance savings may be obtained because
swapped pages are saved in RAM (or a RAM-like device) instead of a swap disk.
A nice overview of it is visible at: http://lwn.net/Articles/454795/

The backends, such as zcache provides compression of pages resulting
in speed up [https://lkml.org/lkml/2012/3/22/383]. If the backends
are not enabled and CONFIG_FRONTSWAP is compiled there is no adverse
performance hit (details further down).

Patches are also at:
git://git.kernel.org/pub/scm/linux/kernel/git/konrad/mm.git  stable/frontswap.v15.squashed

The last time these patches were posted [https://lkml.org/lkml/2011/10/27/206]
the discussion got very technical - and the feeling I got was that:
 - The API is too simple. The hard decisions (what to do when memory
   is low and the pages are mlocked, disk is faster than the CPU compression,
   need some way to shed pages when OOM conditions are close by, which pages
   to compress) are left to the backends. Adding VM pressure hooks could solve 
   some (if not all) of these issues? Dan is working on figuring this out for
   zcache.
 - the backends - like zcache - are tied in how this API is used. This means
   that to get zcache out of staging need to think of the frontswap and
   zcache (and also the other backends).

So to rehash, I think the core issues were with the backends [note, I 
ommitted some here - that is not b/c I choose to ignore them - it just that 
there were some many and I believe many of them got resolved in the discussion?]
 - IRQ latency of zcache. Code needs to be rewritten in zcache a bit.
 - VM pressure - need to be able to influence the backends (or the
   frontswap API as a whole)
 - backends need to handle batched requests.
 - backend needs to fix glaring atrocities (casting of 'struct page *' to
   'char *' and then back).

frontswap API:
 - perhaps make it a device driver and stack it (similar to loopback)? So
   frontswap_ioctl /dev/sda3 /dev/frontswap1 [bind it]
   swapon /dev/frontswap1

   The work required here means more invasive patches in the swap code and
   block code to deal with a dynamic sized disk.
 - only do it on recently activate pages [https://lkml.org/lkml/2012/1/26/520]


Compared to the last posting [https://lkml.org/lkml/2011/10/27/206]
 - a writethrough option. Meaning hat every swap page gets written
   to both frontswap AND to the swap disk. The backend can choose to tell frontswap
   to stop sending pages to it. This would allow the backend to react to memory pressure
   or to shut down if it is taking too much time compressing and pages end up in
   proper swap.
 - change the put/get to a different name: store/load
 - make the return values be bool instead of the int - it was getting confusing
 - seperate the CONFIG_DEBUGFS options out

Documentation/vm/frontswap.txt        |  278 +++++++++++++++++++++++++++++
 MAINTAINERS                           |    7 +
 drivers/staging/ramster/zcache-main.c |    8 +-
 drivers/staging/zcache/zcache-main.c  |   10 +-
 drivers/xen/tmem.c                    |    8 +-
 include/linux/frontswap.h             |  127 +++++++++++++
 include/linux/swap.h                  |    4 +
 include/linux/swapfile.h              |   13 ++
 mm/Kconfig                            |   17 ++
 mm/Makefile                           |    1 +
 mm/frontswap.c                        |  314 +++++++++++++++++++++++++++++++++
 mm/page_io.c                          |   12 ++
 mm/swapfile.c                         |   54 +++++--
 13 files changed, 827 insertions(+), 26 deletions(-)
Dan Magenheimer (4):
      mm: frontswap: add frontswap header file
      mm: frontswap: core swap subsystem hooks and headers
      mm: frontswap: core frontswap functionality
      mm: frontswap: config and doc files

Konrad Rzeszutek Wilk (2):
      MAINTAINER: Add myself for the frontswap API
      frontswap: s/put_page/store/g s/get_page/load

Benchmarks:

James asked about if compiled in but not used (so FRONTSWAP=y but no 'zcache' on
the Linux comnand line argument). Dan did some work in this and found that the
that CONFIG_FRONTSWAP=y is faster... or actually realistically just well within any
measureable noise. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
