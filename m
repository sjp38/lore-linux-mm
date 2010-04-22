Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 668C96B01F3
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:43:49 -0400 (EDT)
Date: Thu, 22 Apr 2010 06:42:49 -0700
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: Frontswap [PATCH 0/4] (was Transcendent Memory): overview
Message-ID: <20100422134249.GA2963@ca-server1.us.oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jeremy@goop.org, hugh.dickins@tiscali.co.uk, ngupta@vflare.org, JBeulich@novell.com, chris.mason@oracle.com, kurt.hackel@oracle.com, dave.mccracken@oracle.com, npiggin@suse.de, akpm@linux-foundation.org, riel@redhat.com
List-ID: <linux-mm.kvack.org>

Frontswap [PATCH 0/4] (was Transcendent Memory): overview

Patch applies to 2.6.34-rc5

In previous patch postings, frontswap was part of the Transcendent
Memory ("tmem") patchset.  This patchset refocuses not on the underlying
technology (tmem) but instead on the useful functionality provided for Linux,
and provides a clean API so that frontswap can provide this very useful
functionality via a Xen tmem driver OR completely independent of tmem.
For example: Nitin Gupta (of compcache and ramzswap fame) is implementing
an in-kernel compression "backend" for frontswap; some believe
frontswap will be a very nice interface for building RAM-like functionality
for pseudo-RAM devices such as SSD or phase-change memory; and a Pune
University team is looking at a backend for virtio (see OLS'2010).

A more complete description of frontswap can be found in the introductory
comment in mm/frontswap.c (in PATCH 2/4) which is included below
for convenience.

Note that an earlier version of this patch is now shipping in OpenSuSE 11.2
and will soon ship in a release of Oracle Enterprise Linux.  Underlying
tmem technology is now shipping in Oracle VM 2.2 and was just released
in Xen 4.0 on April 15, 2010.  (Search news.google.com for Transcedent
Memory)

Signed-off-by: Dan Magenheimer <dan.magenheimer@oracle.com>
Reviewed-by: Jeremy Fitzhardinge <jeremy@goop.org>

 include/linux/frontswap.h |   98 ++++++++++++++
 include/linux/swap.h      |    2 
 include/linux/swapfile.h  |   13 +
 mm/Kconfig                |   16 ++
 mm/Makefile               |    1 
 mm/frontswap.c            |  301 ++++++++++++++++++++++++++++++++++++++++++++++
 mm/page_io.c              |   12 +
 mm/swap.c                 |    4 
 mm/swapfile.c             |   58 +++++++-
 9 files changed, 496 insertions(+), 9 deletions(-)

Frontswap is so named because it can be thought of as the opposite of
a "backing" store for a swap device.  The storage is assumed to be
a synchronous concurrency-safe page-oriented pseudo-RAM device (such as
Xen's Transcendent Memory, aka "tmem", or in-kernel compressed memory,
aka "zmem", or other RAM-like devices) which is not directly accessible
or addressable by the kernel and is of unknown and possibly time-varying
size.  This pseudo-RAM device links itself to frontswap by setting the
frontswap_ops pointer appropriately and the functions it provides must
conform to certain policies as follows:

An "init" prepares the pseudo-RAM to receive frontswap pages and returns
a non-negative pool id, used for all swap device numbers (aka "type").
A "put_page" will copy the page to pseudo-RAM and associate it with
the type and offset associated with the page. A "get_page" will copy the
page, if found, from pseudo-RAM into kernel memory, but will NOT remove
the page from pseudo-RAM.  A "flush_page" will remove the page from
pseudo-RAM and a "flush_area" will remove ALL pages associated with the
swap type (e.g., like swapoff) and notify the pseudo-RAM device to refuse
further puts with that swap type.

Once a page is successfully put, a matching get on the page will always
succeed.  So when the kernel finds itself in a situation where it needs
to swap out a page, it first attempts to use frontswap.  If the put returns
non-zero, the data has been successfully saved to pseudo-RAM and
a disk write and, if the data is later read back, a disk read are avoided.
If a put returns zero, pseudo-RAM has rejected the data, and the page can
be written to swap as usual.

Note that if a page is put and the page already exists in pseudo-RAM
(a "duplicate" put), either the put succeeds and the data is overwritten,
or the put fails AND the page is flushed.  This ensures stale data may
never be obtained from pseudo-RAM.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
