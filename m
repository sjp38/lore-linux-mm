Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f173.google.com (mail-pf0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 460086B025F
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:34:57 -0500 (EST)
Received: by mail-pf0-f173.google.com with SMTP id 65so55525479pfd.2
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:34:57 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id pw5si8256639pab.18.2016.01.30.01.34.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:34:56 -0800 (PST)
Date: Sat, 30 Jan 2016 01:33:54 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-4650bac1fc45d64aef62ab99aa4db93d41dedbd9@git.kernel.org>
Reply-To: bp@suse.de, akpm@linux-foundation.org, vishal.l.verma@intel.com,
        toshi.kani@hpe.com, mcgrof@suse.com, torvalds@linux-foundation.org,
        toshi.kani@hp.com, brgerst@gmail.com, tony.luck@intel.com,
        hpa@zytor.com, dan.j.williams@intel.com, luto@amacapital.net,
        rjw@rjwysocki.net, linux-kernel@vger.kernel.org, lenb@kernel.org,
        linux-mm@kvack.org, bp@alien8.de, mingo@kernel.org,
        peterz@infradead.org, tglx@linutronix.de, dvlasenk@redhat.com,
        jarkko.nikula@linux.intel.com
In-Reply-To: <1453841853-11383-18-git-send-email-bp@alien8.de>
References: <1453841853-11383-18-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] ACPI/EINJ:
  Allow memory error injection to NVDIMM
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: lenb@kernel.org, linux-kernel@vger.kernel.org, luto@amacapital.net, rjw@rjwysocki.net, dan.j.williams@intel.com, jarkko.nikula@linux.intel.com, dvlasenk@redhat.com, peterz@infradead.org, tglx@linutronix.de, mingo@kernel.org, bp@alien8.de, linux-mm@kvack.org, mcgrof@suse.com, toshi.kani@hpe.com, vishal.l.verma@intel.com, bp@suse.de, akpm@linux-foundation.org, brgerst@gmail.com, tony.luck@intel.com, hpa@zytor.com, toshi.kani@hp.com, torvalds@linux-foundation.org

Commit-ID:  4650bac1fc45d64aef62ab99aa4db93d41dedbd9
Gitweb:     http://git.kernel.org/tip/4650bac1fc45d64aef62ab99aa4db93d41dedbd9
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:33 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:50:00 +0100

ACPI/EINJ: Allow memory error injection to NVDIMM

In the case of memory error injection, einj_error_inject()
checks if a target address is System RAM. Change this check to
allow injecting a memory error into NVDIMM memory by calling
region_intersects() with IORES_DESC_PERSISTENT_MEMORY. This
enables memory error testing on both System RAM and NVDIMM.

In addition, page_is_ram() is replaced with region_intersects()
with IORESOURCE_SYSTEM_RAM, so that it can verify a target
address range with the requested size.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Dan Williams <dan.j.williams@intel.com>
Acked-by: Tony Luck <tony.luck@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Jarkko Nikula <jarkko.nikula@linux.intel.com>
Cc: Len Brown <lenb@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rafael J. Wysocki <rjw@rjwysocki.net>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Vishal Verma <vishal.l.verma@intel.com>
Cc: linux-acpi@vger.kernel.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: linux-nvdimm@lists.01.org
Link: http://lkml.kernel.org/r/1453841853-11383-18-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 drivers/acpi/apei/einj.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/acpi/apei/einj.c b/drivers/acpi/apei/einj.c
index 0431883..559c117 100644
--- a/drivers/acpi/apei/einj.c
+++ b/drivers/acpi/apei/einj.c
@@ -519,7 +519,7 @@ static int einj_error_inject(u32 type, u32 flags, u64 param1, u64 param2,
 			     u64 param3, u64 param4)
 {
 	int rc;
-	unsigned long pfn;
+	u64 base_addr, size;
 
 	/* If user manually set "flags", make sure it is legal */
 	if (flags && (flags &
@@ -545,10 +545,17 @@ static int einj_error_inject(u32 type, u32 flags, u64 param1, u64 param2,
 	/*
 	 * Disallow crazy address masks that give BIOS leeway to pick
 	 * injection address almost anywhere. Insist on page or
-	 * better granularity and that target address is normal RAM.
+	 * better granularity and that target address is normal RAM or
+	 * NVDIMM.
 	 */
-	pfn = PFN_DOWN(param1 & param2);
-	if (!page_is_ram(pfn) || ((param2 & PAGE_MASK) != PAGE_MASK))
+	base_addr = param1 & param2;
+	size = ~param2 + 1;
+
+	if (((param2 & PAGE_MASK) != PAGE_MASK) ||
+	    ((region_intersects(base_addr, size, IORESOURCE_SYSTEM_RAM, IORES_DESC_NONE)
+				!= REGION_INTERSECTS) &&
+	     (region_intersects(base_addr, size, IORESOURCE_MEM, IORES_DESC_PERSISTENT_MEMORY)
+				!= REGION_INTERSECTS)))
 		return -EINVAL;
 
 inject:

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
