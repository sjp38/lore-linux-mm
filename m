Message-Id: <20080225183308.446028000@polaris-admin.engr.sgi.com>
References: <20080225183308.159770000@polaris-admin.engr.sgi.com>
Date: Mon, 25 Feb 2008 10:33:09 -0800
From: Mike Travis <travis@sgi.com>
Subject: [PATCH 1/1] x86_64: x86_64_cleanup_pda() should use nr_cpu_ids instead of NR_CPUS
Content-Disposition: inline; filename=fold-pda-fix
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Eric Dumazet <dada1@cosmosbay.com>, Ingo Molnar <mingo@elte.hu>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, Jack Steiner <steiner@sgi.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

We allocate an array of nr_cpu_ids pointers, so we should respect its bonds.

Delay change of _cpu_pda after array initialization.

Also take into account that alloc_bootmem_low() :
- calls panic() if not enough memory
- already clears allocated memory

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
Signed-off-by: Mike Travis <travis@sgi.com>

---
 arch/x86/kernel/head64.c |   16 +++++++---------
 1 file changed, 7 insertions(+), 9 deletions(-)

--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -151,18 +151,16 @@ void __init x86_64_start_kernel(char * r
 void __init x86_64_cleanup_pda(void)
 {
 	int i;
+	struct x8664_pda **new_cpu_pda;
 
-	_cpu_pda = alloc_bootmem_low(nr_cpu_ids * sizeof(void *));
+	new_cpu_pda = alloc_bootmem_low(nr_cpu_ids * sizeof(void *));
 
-	if (!_cpu_pda)
-		panic("Cannot allocate cpu pda table\n");
 
+	for (i = 0; i < nr_cpu_ids; i++)
+		if (_cpu_pda_init[i] != &boot_cpu_pda[i])
+			new_cpu_pda[i] = _cpu_pda_init[i];
+	mb();
+	_cpu_pda = new_cpu_pda;
 	/* cpu_pda() now points to allocated cpu_pda_table */
-
-	for (i = 0; i < NR_CPUS; i++)
-		if (_cpu_pda_init[i] == &boot_cpu_pda[i])
-			cpu_pda(i) = NULL;
-		else
-			cpu_pda(i) = _cpu_pda_init[i];
 }
 #endif

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
