Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED2326B026D
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 20:00:56 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id g6-v6so8189374plq.9
        for <linux-mm@kvack.org>; Fri, 08 Jun 2018 17:00:56 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id t127-v6si8472290pfc.174.2018.06.08.17.00.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Jun 2018 17:00:55 -0700 (PDT)
Subject: [PATCH v4 07/12] x86/mm/pat: Prepare {reserve,
 free}_memtype() for "decoy" addresses
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 08 Jun 2018 16:50:58 -0700
Message-ID: <152850185800.38390.16809919962943041626.stgit@dwillia2-desk3.amr.corp.intel.com>
In-Reply-To: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
References: <152850182079.38390.8280340535691965744.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Tony Luck <tony.luck@intel.com>, Borislav Petkov <bp@alien8.de>, linux-edac@vger.kernel.org, x86@kernel.org, hch@lst.de, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, jack@suse.cz

In preparation for using set_memory_uc() instead set_memory_np() for
isolating poison from speculation, teach the memtype code to sanitize
physical addresses vs __PHYSICAL_MASK.

The motivation for using set_memory_uc() for this case is to allow
ongoing access to persistent memory pages via the pmem-driver +
memcpy_mcsafe() until the poison is repaired.

Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Tony Luck <tony.luck@intel.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: <linux-edac@vger.kernel.org>
Cc: <x86@kernel.org>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---
 arch/x86/mm/pat.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/arch/x86/mm/pat.c b/arch/x86/mm/pat.c
index 1555bd7d3449..6788ffa990f8 100644
--- a/arch/x86/mm/pat.c
+++ b/arch/x86/mm/pat.c
@@ -512,6 +512,17 @@ static int free_ram_pages_type(u64 start, u64 end)
 	return 0;
 }
 
+static u64 sanitize_phys(u64 address)
+{
+	/*
+	 * When changing the memtype for pages containing poison allow
+	 * for a "decoy" virtual address (bit 63 clear) passed to
+	 * set_memory_X(). __pa() on a "decoy" address results in a
+	 * physical address with it 63 set.
+	 */
+	return address & __PHYSICAL_MASK;
+}
+
 /*
  * req_type typically has one of the:
  * - _PAGE_CACHE_MODE_WB
@@ -533,6 +544,8 @@ int reserve_memtype(u64 start, u64 end, enum page_cache_mode req_type,
 	int is_range_ram;
 	int err = 0;
 
+	start = sanitize_phys(start);
+	end = sanitize_phys(end);
 	BUG_ON(start >= end); /* end is exclusive */
 
 	if (!pat_enabled()) {
@@ -609,6 +622,9 @@ int free_memtype(u64 start, u64 end)
 	if (!pat_enabled())
 		return 0;
 
+	start = sanitize_phys(start);
+	end = sanitize_phys(end);
+
 	/* Low ISA region is always mapped WB. No need to track */
 	if (x86_platform.is_untracked_pat_range(start, end))
 		return 0;
