Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id CD7936B025C
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:34:12 -0500 (EST)
Received: by mail-ig0-f173.google.com with SMTP id z14so6280480igp.0
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:34:12 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id q80si31031090ioe.162.2016.01.30.01.34.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:34:12 -0800 (PST)
Date: Sat, 30 Jan 2016 01:33:11 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-f296f2634920d205b93d878b48d87bb7e0a4c256@git.kernel.org>
Reply-To: torvalds@linux-foundation.org, toshi.kani@hp.com, dyoung@redhat.com,
        dvlasenk@redhat.com, linux-kernel@vger.kernel.org, mnfhuang@gmail.com,
        luto@amacapital.net, mcgrof@suse.com, sfr@canb.auug.org.au,
        hpa@zytor.com, bp@alien8.de, bp@suse.de, toshi.kani@hpe.com,
        joeyli.kernel@gmail.com, akpm@linux-foundation.org,
        viresh.kumar@linaro.org, tglx@linutronix.de,
        indou.takao@jp.fujitsu.com, brgerst@gmail.com, mingo@kernel.org,
        luto@kernel.org, peterz@infradead.org, linux-mm@kvack.org
In-Reply-To: <1453841853-11383-16-git-send-email-bp@alien8.de>
References: <1453841853-11383-16-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] x86/kexec: Remove walk_iomem_res()
  call with GART type
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: hpa@zytor.com, bp@suse.de, bp@alien8.de, akpm@linux-foundation.org, viresh.kumar@linaro.org, joeyli.kernel@gmail.com, toshi.kani@hpe.com, brgerst@gmail.com, indou.takao@jp.fujitsu.com, tglx@linutronix.de, mingo@kernel.org, luto@kernel.org, peterz@infradead.org, linux-mm@kvack.org, toshi.kani@hp.com, torvalds@linux-foundation.org, linux-kernel@vger.kernel.org, dvlasenk@redhat.com, dyoung@redhat.com, mnfhuang@gmail.com, luto@amacapital.net, mcgrof@suse.com, sfr@canb.auug.org.au

Commit-ID:  f296f2634920d205b93d878b48d87bb7e0a4c256
Gitweb:     http://git.kernel.org/tip/f296f2634920d205b93d878b48d87bb7e0a4c256
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:31 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:59 +0100

x86/kexec: Remove walk_iomem_res() call with GART type

There is no longer any driver inserting a "GART" region in the
kernel since

  707d4eefbdb3 ("Revert "[PATCH] Insert GART region into resource map"").

Remove the call to walk_iomem_res() with "GART" type, its
callback function, and GART-specific variables set by the
callback.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Dave Young <dyoung@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Chun-Yi <joeyli.kernel@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Lee, Chun-Yi <joeyli.kernel@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Minfei Huang <mnfhuang@gmail.com>
Cc: Peter Zijlstra (Intel) <peterz@infradead.org>
Cc: Stephen Rothwell <sfr@canb.auug.org.au>
Cc: Takao Indoh <indou.takao@jp.fujitsu.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Viresh Kumar <viresh.kumar@linaro.org>
Cc: kexec@lists.infradead.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Link: http://lkml.kernel.org/r/1453841853-11383-16-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 arch/x86/kernel/crash.c | 37 +------------------------------------
 1 file changed, 1 insertion(+), 36 deletions(-)

diff --git a/arch/x86/kernel/crash.c b/arch/x86/kernel/crash.c
index 35e152e..9ef978d 100644
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
