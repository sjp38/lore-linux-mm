Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id EE2F66B0003
	for <linux-mm@kvack.org>; Sat,  9 Jun 2018 13:22:40 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id y26-v6so7909442pfn.14
        for <linux-mm@kvack.org>; Sat, 09 Jun 2018 10:22:40 -0700 (PDT)
Received: from mga18.intel.com (mga18.intel.com. [134.134.136.126])
        by mx.google.com with ESMTPS id q137-v6si22344473pfc.164.2018.06.09.10.22.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jun 2018 10:22:39 -0700 (PDT)
Subject: [PATCH] mm: Fix devmem_is_allowed() for sub-page System RAM
 intersections
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 09 Jun 2018 10:12:41 -0700
Message-ID: <152856436164.18127.2847888121707136898.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <bug-199999-27@https.bugzilla.kernel.org/>
References: <bug-199999-27@https.bugzilla.kernel.org/>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: stable@vger.kernel.org, Christoph Hellwig <hch@lst.de>, Hussam Al-Tayeb <me@hussam.eu.org>, linux-mm@kvack.org, bugzilla-daemon@bugzilla.kernel.org

Hussam reports:

    I was poking around and for no real reason, I did cat /dev/mem and
    strings /dev/mem.  Then I saw the following warning in dmesg. I saved it
    and rebooted immediately.

     memremap attempted on mixed range 0x000000000009c000 size: 0x1000
     ------------[ cut here ]------------
     WARNING: CPU: 0 PID: 11810 at kernel/memremap.c:98 memremap+0x104/0x170
     [..]
     Call Trace:
      xlate_dev_mem_ptr+0x25/0x40
      read_mem+0x89/0x1a0
      __vfs_read+0x36/0x170

The memremap() implementation checks for attempts to remap System RAM
with MEMREMAP_WB and instead redirects those mapping attempts to the
linear map. However, that only works if the physical address range being
remapped is page aligned. In low memory we have situations like the
following:

    00000000-00000fff : Reserved
    00001000-0009fbff : System RAM
    0009fc00-0009ffff : Reserved

...where System RAM intersects Reserved ranges on a sub-page page
granularity.

Given that devmem_is_allowed() special cases any attempt to map System
RAM in the first 1MB of memory, replace page_is_ram() with the more
precise region_intersects() to trap attempts to map disallowed ranges.

Link: https://bugzilla.kernel.org/show_bug.cgi?id=199999
Fixes: 92281dee825f ("arch: introduce memremap()")
Cc: <stable@vger.kernel.org>
Cc: Christoph Hellwig <hch@lst.de>
Reported-by: Hussam Al-Tayeb <me@hussam.eu.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/init.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index fec82b577c18..cee58a972cb2 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -706,7 +706,9 @@ void __init init_mem_mapping(void)
  */
 int devmem_is_allowed(unsigned long pagenr)
 {
-	if (page_is_ram(pagenr)) {
+	if (region_intersects(PFN_PHYS(pagenr), PAGE_SIZE,
+				IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE)
+			!= REGION_DISJOINT) {
 		/*
 		 * For disallowed memory regions in the low 1MB range,
 		 * request that the page be shown as all zeros.
