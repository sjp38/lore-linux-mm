From: Christoph Lameter <cl@linux-foundation.org>
Subject: [patch 4/4] cpu alloc: Use cpu allocator instead of the builtin modules per cpu allocator
Date: Fri, 19 Sep 2008 07:59:03 -0700
Message-ID: <20080919145929.681434789@quilx.com>
References: <20080919145859.062069850@quilx.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755463AbYISPBx@vger.kernel.org>
Content-Disposition: inline; filename=cpu_alloc_replace_modules_per_cpu_allocator
Sender: linux-kernel-owner@vger.kernel.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, jeremy@goop.org, ebiederm@xmission.com, travis@sgi.com, herbert@gondor.apana.org.au, xemul@openvz.org, penberg@cs.helsinki.fi
List-Id: linux-mm.kvack.org

Remove the builtin per cpu allocator from modules.c and use cpu_alloc instead.

Signed-off-by: Christoph Lameter <cl@linux-foundation.org>

---
 include/linux/module.h |    1 
 kernel/module.c        |  178 ++++---------------------------------------------
 2 files changed, 17 insertions(+), 162 deletions(-)

Index: linux-2.6/kernel/module.c
===================================================================
--- linux-2.6.orig/kernel/module.c	2008-09-19 08:12:10.000000000 -0500
+++ linux-2.6/kernel/module.c	2008-09-19 08:16:04.000000000 -0500
@@ -337,121 +337,6 @@
 	return NULL;
 }
 
-#ifdef CONFIG_SMP
-/* Number of blocks used and allocated. */
-static unsigned int pcpu_num_used, pcpu_num_allocated;
-/* Size of each block.  -ve means used. */
-static int *pcpu_size;
-
-static int split_block(unsigned int i, unsigned short size)
-{
-	/* Reallocation required? */
-	if (pcpu_num_used + 1 > pcpu_num_allocated) {
-		int *new;
-
-		new = krealloc(pcpu_size, sizeof(new[0])*pcpu_num_allocated*2,
-			       GFP_KERNEL);
-		if (!new)
-			return 0;
-
-		pcpu_num_allocated *= 2;
-		pcpu_size = new;
-	}
-
-	/* Insert a new subblock */
-	memmove(&pcpu_size[i+1], &pcpu_size[i],
-		sizeof(pcpu_size[0]) * (pcpu_num_used - i));
-	pcpu_num_used++;
-
-	pcpu_size[i+1] -= size;
-	pcpu_size[i] = size;
-	return 1;
-}
-
-static inline unsigned int block_size(int val)
-{
-	if (val < 0)
-		return -val;
-	return val;
-}
-
-static void *percpu_modalloc(unsigned long size, unsigned long align,
-			     const char *name)
-{
-	unsigned long extra;
-	unsigned int i;
-	void *ptr;
-
-	if (align > PAGE_SIZE) {
-		printk(KERN_WARNING "%s: per-cpu alignment %li > %li\n",
-		       name, align, PAGE_SIZE);
-		align = PAGE_SIZE;
-	}
-
-	ptr = __per_cpu_start;
-	for (i = 0; i < pcpu_num_used; ptr += block_size(pcpu_size[i]), i++) {
-		/* Extra for alignment requirement. */
-		extra = ALIGN((unsigned long)ptr, align) - (unsigned long)ptr;
-		BUG_ON(i == 0 && extra != 0);
-
-		if (pcpu_size[i] < 0 || pcpu_size[i] < extra + size)
-			continue;
-
-		/* Transfer extra to previous block. */
-		if (pcpu_size[i-1] < 0)
-			pcpu_size[i-1] -= extra;
-		else
-			pcpu_size[i-1] += extra;
-		pcpu_size[i] -= extra;
-		ptr += extra;
-
-		/* Split block if warranted */
-		if (pcpu_size[i] - size > sizeof(unsigned long))
-			if (!split_block(i, size))
-				return NULL;
-
-		/* Mark allocated */
-		pcpu_size[i] = -pcpu_size[i];
-		return ptr;
-	}
-
-	printk(KERN_WARNING "Could not allocate %lu bytes percpu data\n",
-	       size);
-	return NULL;
-}
-
-static void percpu_modfree(void *freeme)
-{
-	unsigned int i;
-	void *ptr = __per_cpu_start + block_size(pcpu_size[0]);
-
-	/* First entry is core kernel percpu data. */
-	for (i = 1; i < pcpu_num_used; ptr += block_size(pcpu_size[i]), i++) {
-		if (ptr == freeme) {
-			pcpu_size[i] = -pcpu_size[i];
-			goto free;
-		}
-	}
-	BUG();
-
- free:
-	/* Merge with previous? */
-	if (pcpu_size[i-1] >= 0) {
-		pcpu_size[i-1] += pcpu_size[i];
-		pcpu_num_used--;
-		memmove(&pcpu_size[i], &pcpu_size[i+1],
-			(pcpu_num_used - i) * sizeof(pcpu_size[0]));
-		i--;
-	}
-	/* Merge with next? */
-	if (i+1 < pcpu_num_used && pcpu_size[i+1] >= 0) {
-		pcpu_size[i] += pcpu_size[i+1];
-		pcpu_num_used--;
-		memmove(&pcpu_size[i+1], &pcpu_size[i+2],
-			(pcpu_num_used - (i+1)) * sizeof(pcpu_size[0]));
-	}
-}
-
 static unsigned int find_pcpusec(Elf_Ehdr *hdr,
 				 Elf_Shdr *sechdrs,
 				 const char *secstrings)
@@ -467,48 +352,6 @@
 		memcpy(pcpudest + per_cpu_offset(cpu), from, size);
 }
 
-static int percpu_modinit(void)
-{
-	pcpu_num_used = 2;
-	pcpu_num_allocated = 2;
-	pcpu_size = kmalloc(sizeof(pcpu_size[0]) * pcpu_num_allocated,
-			    GFP_KERNEL);
-	/* Static in-kernel percpu data (used). */
-	pcpu_size[0] = -(__per_cpu_end-__per_cpu_start);
-	/* Free room. */
-	pcpu_size[1] = PERCPU_AREA_SIZE + pcpu_size[0];
-	if (pcpu_size[1] < 0) {
-		printk(KERN_ERR "No per-cpu room for modules.\n");
-		pcpu_num_used = 1;
-	}
-
-	return 0;
-}
-__initcall(percpu_modinit);
-#else /* ... !CONFIG_SMP */
-static inline void *percpu_modalloc(unsigned long size, unsigned long align,
-				    const char *name)
-{
-	return NULL;
-}
-static inline void percpu_modfree(void *pcpuptr)
-{
-	BUG();
-}
-static inline unsigned int find_pcpusec(Elf_Ehdr *hdr,
-					Elf_Shdr *sechdrs,
-					const char *secstrings)
-{
-	return 0;
-}
-static inline void percpu_modcopy(void *pcpudst, const void *src,
-				  unsigned long size)
-{
-	/* pcpusec should be 0, and size of that section should be 0. */
-	BUG_ON(size != 0);
-}
-#endif /* CONFIG_SMP */
-
 #define MODINFO_ATTR(field)	\
 static void setup_modinfo_##field(struct module *mod, const char *s)  \
 {                                                                     \
@@ -1433,7 +1276,7 @@
 	module_free(mod, mod->module_init);
 	kfree(mod->args);
 	if (mod->percpu)
-		percpu_modfree(mod->percpu);
+		cpu_free(mod->percpu, mod->percpu_size);
 
 	/* Free lock-classes: */
 	lockdep_free_key_range(mod->module_core, mod->core_size);
@@ -1833,6 +1676,7 @@
 	unsigned int markersstringsindex;
 	struct module *mod;
 	long err = 0;
+	unsigned long percpu_size = 0;
 	void *percpu = NULL, *ptr = NULL; /* Stops spurious gcc warning */
 	struct exception_table_entry *extable;
 	mm_segment_t old_fs;
@@ -1981,15 +1825,20 @@
 
 	if (pcpuindex) {
 		/* We have a special allocation for this section. */
-		percpu = percpu_modalloc(sechdrs[pcpuindex].sh_size,
-					 sechdrs[pcpuindex].sh_addralign,
-					 mod->name);
+		unsigned long align = sechdrs[pcpuindex].sh_addralign;
+
+		percpu_size = sechdrs[pcpuindex].sh_size;
+		percpu = cpu_alloc(percpu_size, GFP_KERNEL|__GFP_ZERO, align);
+		if (!percpu)
+			printk(KERN_WARNING "Could not allocate %lu bytes percpu data\n",
+	      							percpu_size);
 		if (!percpu) {
 			err = -ENOMEM;
 			goto free_mod;
 		}
 		sechdrs[pcpuindex].sh_flags &= ~(unsigned long)SHF_ALLOC;
 		mod->percpu = percpu;
+		mod->percpu_size = percpu_size;
 	}
 
 	/* Determine total sizes, and put offsets in sh_entsize.  For now
@@ -2243,7 +2092,7 @@
 	module_free(mod, mod->module_core);
  free_percpu:
 	if (percpu)
-		percpu_modfree(percpu);
+		cpu_free(percpu, percpu_size);
  free_mod:
 	kfree(args);
  free_hdr:
Index: linux-2.6/include/linux/module.h
===================================================================
--- linux-2.6.orig/include/linux/module.h	2008-09-19 08:12:07.000000000 -0500
+++ linux-2.6/include/linux/module.h	2008-09-19 08:12:10.000000000 -0500
@@ -323,6 +323,7 @@
 
 	/* Per-cpu data. */
 	void *percpu;
+	int percpu_size;
 
 	/* The command line arguments (may be mangled).  People like
 	   keeping pointers to this stuff */

-- 
