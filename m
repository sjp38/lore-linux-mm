Date: Wed, 30 Jul 2008 16:59:46 -0700
From: Greg KH <gregkh@suse.de>
Subject: [patch 51/62] x86: fix kernel_physical_mapping_init() for large
	x86 systems
Message-ID: <20080730235946.GY12896@suse.de>
References: <20080730233050.332789722@mini.kroah.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename="x86-fix-kernel_physical_mapping_init-for-large-x86-systems.patch"
In-Reply-To: <20080730234915.GA12426@suse.de>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org, Oliver Pinter <oliver.pntr@gmail.com>
Cc: Justin Forbes <jmforbes@linuxtx.org>, Zwane Mwaikambo <zwane@arm.linux.org.uk>, Theodore Ts'o <tytso@mit.edu>, Randy Dunlap <rdunlap@xenotime.net>, Dave Jones <davej@redhat.com>, Chuck Wolber <chuckw@quantumlinux.com>, Chris Wedgwood <reviews@ml.cw.f00f.org>, Michael Krufky <mkrufky@linuxtv.org>, Chuck Ebbert <cebbert@redhat.com>, Domenico Andreoli <cavokz@gmail.com>, Willy Tarreau <w@1wt.eu>, Rodrigo Rubira Branco <rbranco@la.checkpoint.com>, Jake Edge <jake@lwn.net>, Eugene Teo <eteo@redhat.com>, torvalds@linux-foundation.org, akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk, linux-mm@kvack.org, Jack Steiner <steiner@sgi.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

2.6.26 -stable review patch.  If anyone has any objections, please let
us know.

------------------
From: Ingo Molnar <mingo@elte.hu>

based on e22146e610bb7aed63282148740ab1d1b91e1d90 upstream

Fix bug in kernel_physical_mapping_init() that causes kernel
page table to be built incorrectly for systems with greater
than 512GB of memory.

Signed-off-by: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org
Signed-off-by: Ingo Molnar <mingo@elte.hu>
Cc: Oliver Pinter <oliver.pntr@gmail.com>
Signed-off-by: Ingo Molnar <mingo@elte.hu>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 arch/x86/mm/init_64.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -579,7 +579,7 @@ unsigned long __init_refok init_memory_m
 		else
 			pud = alloc_low_page(&pud_phys);
 
-		next = start + PGDIR_SIZE;
+		next = (start + PGDIR_SIZE) & PGDIR_MASK;
 		if (next > end)
 			next = end;
 		last_map_addr = phys_pud_init(pud, __pa(start), __pa(next));

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
