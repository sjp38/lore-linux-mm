From: Borislav Petkov <bp@alien8.de>
Subject: [PATCH 15/17] x86/kexec: Remove walk_iomem_res() call with GART type
Date: Tue, 26 Jan 2016 21:57:31 +0100
Message-ID: <1453841853-11383-16-git-send-email-bp@alien8.de>
References: <1453841853-11383-1-git-send-email-bp@alien8.de>
Return-path: <linux-arch-owner@vger.kernel.org>
In-Reply-To: <1453841853-11383-1-git-send-email-bp@alien8.de>
Sender: linux-arch-owner@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, kexec@lists.infradead.org, "Lee, Chun-Yi" <joeyli.kernel@gmail.com>, linux-arch@vger.kernel.org, linux-mm <linux-mm@kvack.org>, Minfei Huang <mnfhuang@gmail.com>, "Peter Zijlstra (Intel)" <peterz@infradead.org>, Stephen Rothwell <sfr@canb.auug.org.au>, Takao Indoh <indou.takao@jp.fujitsu.com>, Thomas Gleixner <tglx@linutronix.de>, Viresh Kumar <viresh.kumar@linaro.org>, x86-ml <x86@kernel.org>
List-Id: linux-mm.kvack.org

From: Toshi Kani <toshi.kani@hpe.com>

There is no longer any driver inserting a "GART" region in the kernel
since

  707d4eefbdb3 ("Revert "[PATCH] Insert GART region into resource map"").

Remove the call to walk_iomem_res() with "GART" type, its callback
function, and GART-specific variables set by the callback.

Reviewed-by: Dave Young <dyoung@redhat.com>
Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: kexec@lists.infradead.org
Cc: "Lee, Chun-Yi" <joeyli.kernel@gmail.com>
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Cc: Minfei Huang <mnfhuang@gmail.com>
Cc: "Peter Zijlstra (Intel)" <peterz@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Takao Indoh <indou.takao@jp.fujitsu.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Viresh Kumar <viresh.kumar@linaro.org>
Cc: x86-ml <x86@kernel.org>
Link: http://lkml.kernel.org/r/20160104110427.GA2965@dhcp-128-65.nay.redhat.com
Link: http://lkml.kernel.org/r/1452020081-26534-15-git-send-email-toshi.kani@hpe.com
Signed-off-by: Borislav Petkov <bp@suse.de>
---
 arch/x86/kernel/crash.c | 37 +------------------------------------
 1 file changed, 1 insertion(+), 36 deletions(-)

diff --git a/arch/x86/kernel/crash.c b/arch/x86/kernel/crash.c
index 35e152eeb6e0..9ef978d69c22 100644
--- a/arch/x86/kernel/crash.c
+++ b/arch/x86/kernel/crash.c
@@ -57,10 +57,9 @@ struct crash_elf_data {
 	struct kimage *image;
 	/*
 	 * Total number of ram ranges we have after various adjustments for
-	 * GART, crash reserved region etc.
+	 * crash reserved region, etc.
 	 */
 	unsigned int max_nr_ranges;
-	unsigned long gart_start, gart_end;
 
 	/* Pointer to elf header */
 	void *ehdr;
@@ -201,17 +200,6 @@ static int get_nr_ram_ranges_callback(u64 start, u64 end, void *arg)
 	return 0;
 }
 
-static int get_gart_ranges_callback(u64 start, u64 end, void *arg)
-{
-	struct crash_elf_data *ced = arg;
-
-	ced->gart_start = start;
-	ced->gart_end = end;
-
-	/* Not expecting more than 1 gart aperture */
-	return 1;
-}
-
 
 /* Gather all the required information to prepare elf headers for ram regions */
 static void fill_up_crash_elf_data(struct crash_elf_data *ced,
@@ -226,22 +214,6 @@ static void fill_up_crash_elf_data(struct crash_elf_data *ced,
 
 	ced->max_nr_ranges = nr_ranges;
 
-	/*
-	 * We don't create ELF headers for GART aperture as an attempt
-	 * to dump this memory in second kernel leads to hang/crash.
-	 * If gart aperture is present, one needs to exclude that region
-	 * and that could lead to need of extra phdr.
-	 */
-	walk_iomem_res("GART", IORESOURCE_MEM, 0, -1,
-				ced, get_gart_ranges_callback);
-
-	/*
-	 * If we have gart region, excluding that could potentially split
-	 * a memory range, resulting in extra header. Account for  that.
-	 */
-	if (ced->gart_end)
-		ced->max_nr_ranges++;
-
 	/* Exclusion of crash region could split memory ranges */
 	ced->max_nr_ranges++;
 
@@ -350,13 +322,6 @@ static int elf_header_exclude_ranges(struct crash_elf_data *ced,
 			return ret;
 	}
 
-	/* Exclude GART region */
-	if (ced->gart_end) {
-		ret = exclude_mem_range(cmem, ced->gart_start, ced->gart_end);
-		if (ret)
-			return ret;
-	}
-
 	return ret;
 }
 
-- 
2.3.5
