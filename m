Date: Sat, 21 Sep 2002 14:55:36 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Reply-To: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: [PATCH] relocate lmem_maps for i386 discontigmem onto their own nodes
Message-ID: <8826642.1032620136@[10.10.2.3]>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==========08832411=========="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-mm mailing list <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--==========08832411==========
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

This patch remaps the lmem_map (struct page) arrays for each node
onto their own nodes. This is non-trivial, since all of ZONE_NORMAL,
and hence permanently mapped KVA resides on node 0.

Very early in the boot sequence, it calculates the size of the 
lmem_map arrays (rounding up to the nearest large page size), 
and reserves a suitable amount of permanent KVA by shifting down 
max_low_pfn to create a gap between max_low_pfn and highstart_pfn
(both of which are normally about 896Mb).

It then uses the new set_pmd_pfn function to set up the pmds 
correctly so that the large pages point at the physical addresses
reserved from the remote nodes.

Tested on NUMA-Q and some ratty old i386 PC kicking around under
my desk (on 2.5.36-mm1). Was good for a 20% improvement in system
time on kernel compile when I initially benchmarked it against 
2.5.32 or something - due to a reduction in inter-node traffic,
better interconnect cache usage and locality. Should have no effect
on any system other than i386 NUMA systems.

M.

diff -urN -X /home/mbligh/.diff.exclude 11-numafixes2/arch/i386/mm/discontig.c 20-numamap/arch/i386/mm/discontig.c
--- 11-numafixes2/arch/i386/mm/discontig.c	Wed Sep 18 20:41:11 2002
+++ 20-numamap/arch/i386/mm/discontig.c	Thu Sep 19 16:07:10 2002
@@ -1,5 +1,6 @@
 /*
- * Written by: Patricia Gaughen, IBM Corporation
+ * Written by: Patricia Gaughen <gone@us.ibm.com>, IBM Corporation
+ * August 2002: added remote node KVA remap - Martin J. Bligh 
  *
  * Copyright (C) 2002, IBM Corp.
  *
@@ -19,8 +20,6 @@
  * You should have received a copy of the GNU General Public License
  * along with this program; if not, write to the Free Software
  * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
- *
- * Send feedback to <gone@us.ibm.com>
  */
 

#include <linux/config.h>
@@ -113,35 +112,98 @@
 	}
 }
 
+#define LARGE_PAGE_BYTES (PTRS_PER_PTE * PAGE_SIZE)
+
+unsigned long node_remap_start_pfn[MAX_NUMNODES];
+unsigned long node_remap_size[MAX_NUMNODES];
+unsigned long node_remap_offset[MAX_NUMNODES];
+void *node_remap_start_vaddr[MAX_NUMNODES];
+extern void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags);
+
+void __init remap_numa_kva(void)
+{
+	void *vaddr;
+	unsigned long pfn;
+	int node;
+
+	for (node = 1; node < numnodes; ++node) {
+		for (pfn=0; pfn < node_remap_size[node]; pfn += PTRS_PER_PTE) {
+			vaddr = node_remap_start_vaddr[node]+(pfn<<PAGE_SHIFT);
+			set_pmd_pfn((ulong) vaddr, 
+				node_remap_start_pfn[node] + pfn, 
+				PAGE_KERNEL_LARGE);
+		}
+	}
+}
+

+static unsigned long calculate_numa_remap_pages(void)
+{
+	int nid;
+	unsigned long size, reserve_pages = 0;
+
+	for (nid = 1; nid < numnodes; nid++) {
+		/* calculate the size of the mem_map needed in bytes */
+		size = (node_end_pfn[nid] - node_start_pfn[nid] + 1) 
+			* sizeof(struct page);
+		/* convert size to large (pmd size) pages, rounding up */
+		size = (size + LARGE_PAGE_BYTES - 1) / LARGE_PAGE_BYTES;
+		/* now the roundup is correct, convert to PAGE_SIZE pages */
+		size = size * PTRS_PER_PTE;
+		printk("Reserving %ld pages of KVA for lmem_map of node %d\n",
+				size, nid);
+		node_remap_size[nid] = size;
+		reserve_pages += size;
+		node_remap_offset[nid] = reserve_pages;
+		printk("Shrinking node %d from %ld pages to %ld pages\n",
+
			nid, node_end_pfn[nid], node_end_pfn[nid] - size);
+		node_end_pfn[nid] -= size;
+		node_remap_start_pfn[nid] = node_end_pfn[nid];
+	}
+	printk("Reserving total of %ld pages for numa KVA remap\n",
+			reserve_pages);
+	return reserve_pages;
+}
+
 unsigned long __init setup_memory(void)
 {
 	int nid;
 	unsigned long bootmap_size, system_start_pfn, system_max_low_pfn;
+	unsigned long reserve_pages;
 
 	get_memcfg_numa();
+	reserve_pages = calculate_numa_remap_pages();
 
-	/*
-	 * partially used pages are not usable - thus
-	 * we are rounding upwards:
-	 */
+	/* partially used pages are not usable - thus round upwards */
 	system_start_pfn = min_low_pfn = PFN_UP(__pa(&_end));
 
 	find_max_pfn();
 	system_max_low_pfn = max_low_pfn =
find_max_low_pfn();
-
 #ifdef CONFIG_HIGHMEM
-		highstart_pfn = highend_pfn = max_pfn;
-		if (max_pfn > system_max_low_pfn) {
-			highstart_pfn = system_max_low_pfn;
-		}
-		printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
-		       pages_to_mb(highend_pfn - highstart_pfn));
+	highstart_pfn = highend_pfn = max_pfn;
+	if (max_pfn > system_max_low_pfn)
+		highstart_pfn = system_max_low_pfn;
+	printk(KERN_NOTICE "%ldMB HIGHMEM available.\n",
+	       pages_to_mb(highend_pfn - highstart_pfn));
 #endif
+	system_max_low_pfn = max_low_pfn = max_low_pfn - reserve_pages;
 	printk(KERN_NOTICE "%ldMB LOWMEM available.\n",
 			pages_to_mb(system_max_low_pfn));
-	
-	for (nid = 0; nid < numnodes; nid++)
+	printk("min_low_pfn = %ld, max_low_pfn = %ld,
highstart_pfn = %ld\n", 
+			min_low_pfn, max_low_pfn, highstart_pfn);
+
+	printk("Low memory ends at vaddr %08lx\n",
+			(ulong) pfn_to_kaddr(max_low_pfn));
+	for (nid = 0; nid < numnodes; nid++) {
 		allocate_pgdat(nid);
+		node_remap_start_vaddr[nid] = pfn_to_kaddr(
+			highstart_pfn - node_remap_offset[nid]);
+		printk ("node %d will remap to vaddr %08lx - %08lx\n", nid,
+			(ulong) node_remap_start_vaddr[nid],
+			(ulong) pfn_to_kaddr(highstart_pfn
+			    - node_remap_offset[nid] + node_remap_size[nid]));
+	}
+	printk("High memory starts at vaddr %08lx\n",
+			(ulong) pfn_to_kaddr(highstart_pfn));
 	for (nid = 0; nid < numnodes; nid++)
 		find_max_pfn_node(nid);
 
@@ -244,7 +306,18 @@
 #endif
 			}
 		}
-		free_area_init_node(nid,
NODE_DATA(nid), 0, zones_size, start, 0);
+		/*
+		 * We let the lmem_map for node 0 be allocated from the
+		 * normal bootmem allocator, but other nodes come from the
+		 * remapped KVA area - mbligh
+		 */
+		if (nid)
+			free_area_init_node(nid, NODE_DATA(nid), 
+				node_remap_start_vaddr[nid], zones_size, 
+				start, 0);
+		else
+			free_area_init_node(nid, NODE_DATA(nid), 0, 
+				zones_size, start, 0);
 	}
 	return;
 }
diff -urN -X /home/mbligh/.diff.exclude 11-numafixes2/arch/i386/mm/init.c 20-numamap/arch/i386/mm/init.c
--- 11-numafixes2/arch/i386/mm/init.c	Wed Sep 18 20:41:11 2002
+++ 20-numamap/arch/i386/mm/init.c	Thu Sep 19 16:07:10 2002
@@ -245,6 +245,12 @@
 
 unsigned long __PAGE_KERNEL = _PAGE_KERNEL;
 
+#ifndef CONFIG_DISCONTIGMEM

+#define remap_numa_kva() do {} while (0)
+#else
+extern void __init remap_numa_kva(void);
+#endif
+
 static void __init pagetable_init (void)
 {
 	unsigned long vaddr;
@@ -269,6 +275,7 @@
 	}
 
 	kernel_physical_mapping_init(pgd_base);
+	remap_numa_kva();
 
 	/*
 	 * Fixed mappings, only the page table structure has to be
@@ -449,7 +456,11 @@
 
 	set_max_mapnr_init();
 
+#ifdef CONFIG_HIGHMEM
+	high_memory = (void *) __va(highstart_pfn * PAGE_SIZE);
+#else
 	high_memory = (void *) __va(max_low_pfn * PAGE_SIZE);
+#endif
 
 	/* clear the zero-page */
 	memset(empty_zero_page, 0, PAGE_SIZE);
diff -urN -X /home/mbligh/.diff.exclude 11-numafixes2/arch/i386/mm/pgtable.c 20-numamap/arch/i386/mm/pgtable.c
--- 11-numafixes2/arch/i386/mm/pgtable.c	Wed Sep
18 20:41:11 2002
+++ 20-numamap/arch/i386/mm/pgtable.c	Thu Sep 19 16:07:10 2002
@@ -84,6 +84,39 @@
 	__flush_tlb_one(vaddr);
 }
 
+/*
+ * Associate a large virtual page frame with a given physical page frame 
+ * and protection flags for that frame. pfn is for the base of the page,
+ * vaddr is what the page gets mapped to - both must be properly aligned. 
+ * The pmd must already be instantiated. Assumes PAE mode.
+ */ 
+void set_pmd_pfn(unsigned long vaddr, unsigned long pfn, pgprot_t flags)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+
+	if (vaddr & (PMD_SIZE-1)) {		/* vaddr is misaligned */
+		printk ("set_pmd_pfn: vaddr misaligned\n");
+		return; /* BUG(); */
+	}
+	if (pfn & (PTRS_PER_PTE-1)) {		/* pfn is misaligned */
+		printk ("set_pmd_pfn: pfn
misaligned\n");
+		return; /* BUG(); */
+	}
+	pgd = swapper_pg_dir + __pgd_offset(vaddr);
+	if (pgd_none(*pgd)) {
+		printk ("set_pmd_pfn: pgd_none\n");
+		return; /* BUG(); */
+	}
+	pmd = pmd_offset(pgd, vaddr);
+	set_pmd(pmd, pfn_pmd(pfn, flags));
+	/*
+	 * It's enough to flush this one mapping.
+	 * (PGE mappings get flushed as well)
+	 */
+	__flush_tlb_one(vaddr);
+}
+
 void __set_fixmap (enum fixed_addresses idx, unsigned long phys, pgprot_t flags)
 {
 	unsigned long address = __fix_to_virt(idx);
diff -urN -X /home/mbligh/.diff.exclude 11-numafixes2/include/asm-i386/page.h 20-numamap/include/asm-i386/page.h
--- 11-numafixes2/include/asm-i386/page.h	Wed Sep 18 20:41:12 2002
+++ 20-numamap/include/asm-i386/page.h	Thu Sep 19 16:07:10 2002
@@
-142,6 +142,7 @@
 #define MAXMEM			((unsigned long)(-PAGE_OFFSET-VMALLOC_RESERVE))
 #define __pa(x)			((unsigned long)(x)-PAGE_OFFSET)
 #define __va(x)			((void *)((unsigned long)(x)+PAGE_OFFSET))
+#define pfn_to_kaddr(pfn)      __va((pfn) << PAGE_SHIFT)
 #ifndef CONFIG_DISCONTIGMEM
 #define pfn_to_page(pfn)	(mem_map + (pfn))
 #define page_to_pfn(page)	((unsigned long)((page) - mem_map))

--==========08832411==========
Content-Type: application/octet-stream; name=20-numamap
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=20-numamap; size=7918

ZGlmZiAtdXJOIC1YIC9ob21lL21ibGlnaC8uZGlmZi5leGNsdWRlIDExLW51bWFmaXhlczIvYXJj
aC9pMzg2L21tL2Rpc2NvbnRpZy5jIDIwLW51bWFtYXAvYXJjaC9pMzg2L21tL2Rpc2NvbnRpZy5j
Ci0tLSAxMS1udW1hZml4ZXMyL2FyY2gvaTM4Ni9tbS9kaXNjb250aWcuYwlXZWQgU2VwIDE4IDIw
OjQxOjExIDIwMDIKKysrIDIwLW51bWFtYXAvYXJjaC9pMzg2L21tL2Rpc2NvbnRpZy5jCVRodSBT
ZXAgMTkgMTY6MDc6MTAgMjAwMgpAQCAtMSw1ICsxLDYgQEAKIC8qCi0gKiBXcml0dGVuIGJ5OiBQ
YXRyaWNpYSBHYXVnaGVuLCBJQk0gQ29ycG9yYXRpb24KKyAqIFdyaXR0ZW4gYnk6IFBhdHJpY2lh
IEdhdWdoZW4gPGdvbmVAdXMuaWJtLmNvbT4sIElCTSBDb3Jwb3JhdGlvbgorICogQXVndXN0IDIw
MDI6IGFkZGVkIHJlbW90ZSBub2RlIEtWQSByZW1hcCAtIE1hcnRpbiBKLiBCbGlnaCAKICAqCiAg
KiBDb3B5cmlnaHQgKEMpIDIwMDIsIElCTSBDb3JwLgogICoKQEAgLTE5LDggKzIwLDYgQEAKICAq
IFlvdSBzaG91bGQgaGF2ZSByZWNlaXZlZCBhIGNvcHkgb2YgdGhlIEdOVSBHZW5lcmFsIFB1Ymxp
YyBMaWNlbnNlCiAgKiBhbG9uZyB3aXRoIHRoaXMgcHJvZ3JhbTsgaWYgbm90LCB3cml0ZSB0byB0
aGUgRnJlZSBTb2Z0d2FyZQogICogRm91bmRhdGlvbiwgSW5jLiwgNjc1IE1hc3MgQXZlLCBDYW1i
cmlkZ2UsIE1BIDAyMTM5LCBVU0EuCi0gKgotICogU2VuZCBmZWVkYmFjayB0byA8Z29uZUB1cy5p
Ym0uY29tPgogICovCiAKICNpbmNsdWRlIDxsaW51eC9jb25maWcuaD4KQEAgLTExMywzNSArMTEy
LDk4IEBACiAJfQogfQogCisjZGVmaW5lIExBUkdFX1BBR0VfQllURVMgKFBUUlNfUEVSX1BURSAq
IFBBR0VfU0laRSkKKwordW5zaWduZWQgbG9uZyBub2RlX3JlbWFwX3N0YXJ0X3BmbltNQVhfTlVN
Tk9ERVNdOwordW5zaWduZWQgbG9uZyBub2RlX3JlbWFwX3NpemVbTUFYX05VTU5PREVTXTsKK3Vu
c2lnbmVkIGxvbmcgbm9kZV9yZW1hcF9vZmZzZXRbTUFYX05VTU5PREVTXTsKK3ZvaWQgKm5vZGVf
cmVtYXBfc3RhcnRfdmFkZHJbTUFYX05VTU5PREVTXTsKK2V4dGVybiB2b2lkIHNldF9wbWRfcGZu
KHVuc2lnbmVkIGxvbmcgdmFkZHIsIHVuc2lnbmVkIGxvbmcgcGZuLCBwZ3Byb3RfdCBmbGFncyk7
CisKK3ZvaWQgX19pbml0IHJlbWFwX251bWFfa3ZhKHZvaWQpCit7CisJdm9pZCAqdmFkZHI7CisJ
dW5zaWduZWQgbG9uZyBwZm47CisJaW50IG5vZGU7CisKKwlmb3IgKG5vZGUgPSAxOyBub2RlIDwg
bnVtbm9kZXM7ICsrbm9kZSkgeworCQlmb3IgKHBmbj0wOyBwZm4gPCBub2RlX3JlbWFwX3NpemVb
bm9kZV07IHBmbiArPSBQVFJTX1BFUl9QVEUpIHsKKwkJCXZhZGRyID0gbm9kZV9yZW1hcF9zdGFy
dF92YWRkcltub2RlXSsocGZuPDxQQUdFX1NISUZUKTsKKwkJCXNldF9wbWRfcGZuKCh1bG9uZykg
dmFkZHIsIAorCQkJCW5vZGVfcmVtYXBfc3RhcnRfcGZuW25vZGVdICsgcGZuLCAKKwkJCQlQQUdF
X0tFUk5FTF9MQVJHRSk7CisJCX0KKwl9Cit9CisKK3N0YXRpYyB1bnNpZ25lZCBsb25nIGNhbGN1
bGF0ZV9udW1hX3JlbWFwX3BhZ2VzKHZvaWQpCit7CisJaW50IG5pZDsKKwl1bnNpZ25lZCBsb25n
IHNpemUsIHJlc2VydmVfcGFnZXMgPSAwOworCisJZm9yIChuaWQgPSAxOyBuaWQgPCBudW1ub2Rl
czsgbmlkKyspIHsKKwkJLyogY2FsY3VsYXRlIHRoZSBzaXplIG9mIHRoZSBtZW1fbWFwIG5lZWRl
ZCBpbiBieXRlcyAqLworCQlzaXplID0gKG5vZGVfZW5kX3BmbltuaWRdIC0gbm9kZV9zdGFydF9w
Zm5bbmlkXSArIDEpIAorCQkJKiBzaXplb2Yoc3RydWN0IHBhZ2UpOworCQkvKiBjb252ZXJ0IHNp
emUgdG8gbGFyZ2UgKHBtZCBzaXplKSBwYWdlcywgcm91bmRpbmcgdXAgKi8KKwkJc2l6ZSA9IChz
aXplICsgTEFSR0VfUEFHRV9CWVRFUyAtIDEpIC8gTEFSR0VfUEFHRV9CWVRFUzsKKwkJLyogbm93
IHRoZSByb3VuZHVwIGlzIGNvcnJlY3QsIGNvbnZlcnQgdG8gUEFHRV9TSVpFIHBhZ2VzICovCisJ
CXNpemUgPSBzaXplICogUFRSU19QRVJfUFRFOworCQlwcmludGsoIlJlc2VydmluZyAlbGQgcGFn
ZXMgb2YgS1ZBIGZvciBsbWVtX21hcCBvZiBub2RlICVkXG4iLAorCQkJCXNpemUsIG5pZCk7CisJ
CW5vZGVfcmVtYXBfc2l6ZVtuaWRdID0gc2l6ZTsKKwkJcmVzZXJ2ZV9wYWdlcyArPSBzaXplOwor
CQlub2RlX3JlbWFwX29mZnNldFtuaWRdID0gcmVzZXJ2ZV9wYWdlczsKKwkJcHJpbnRrKCJTaHJp
bmtpbmcgbm9kZSAlZCBmcm9tICVsZCBwYWdlcyB0byAlbGQgcGFnZXNcbiIsCisJCQluaWQsIG5v
ZGVfZW5kX3BmbltuaWRdLCBub2RlX2VuZF9wZm5bbmlkXSAtIHNpemUpOworCQlub2RlX2VuZF9w
Zm5bbmlkXSAtPSBzaXplOworCQlub2RlX3JlbWFwX3N0YXJ0X3BmbltuaWRdID0gbm9kZV9lbmRf
cGZuW25pZF07CisJfQorCXByaW50aygiUmVzZXJ2aW5nIHRvdGFsIG9mICVsZCBwYWdlcyBmb3Ig
bnVtYSBLVkEgcmVtYXBcbiIsCisJCQlyZXNlcnZlX3BhZ2VzKTsKKwlyZXR1cm4gcmVzZXJ2ZV9w
YWdlczsKK30KKwogdW5zaWduZWQgbG9uZyBfX2luaXQgc2V0dXBfbWVtb3J5KHZvaWQpCiB7CiAJ
aW50IG5pZDsKIAl1bnNpZ25lZCBsb25nIGJvb3RtYXBfc2l6ZSwgc3lzdGVtX3N0YXJ0X3Bmbiwg
c3lzdGVtX21heF9sb3dfcGZuOworCXVuc2lnbmVkIGxvbmcgcmVzZXJ2ZV9wYWdlczsKIAogCWdl
dF9tZW1jZmdfbnVtYSgpOworCXJlc2VydmVfcGFnZXMgPSBjYWxjdWxhdGVfbnVtYV9yZW1hcF9w
YWdlcygpOwogCi0JLyoKLQkgKiBwYXJ0aWFsbHkgdXNlZCBwYWdlcyBhcmUgbm90IHVzYWJsZSAt
IHRodXMKLQkgKiB3ZSBhcmUgcm91bmRpbmcgdXB3YXJkczoKLQkgKi8KKwkvKiBwYXJ0aWFsbHkg
dXNlZCBwYWdlcyBhcmUgbm90IHVzYWJsZSAtIHRodXMgcm91bmQgdXB3YXJkcyAqLwogCXN5c3Rl
bV9zdGFydF9wZm4gPSBtaW5fbG93X3BmbiA9IFBGTl9VUChfX3BhKCZfZW5kKSk7CiAKIAlmaW5k
X21heF9wZm4oKTsKIAlzeXN0ZW1fbWF4X2xvd19wZm4gPSBtYXhfbG93X3BmbiA9IGZpbmRfbWF4
X2xvd19wZm4oKTsKLQogI2lmZGVmIENPTkZJR19ISUdITUVNCi0JCWhpZ2hzdGFydF9wZm4gPSBo
aWdoZW5kX3BmbiA9IG1heF9wZm47Ci0JCWlmIChtYXhfcGZuID4gc3lzdGVtX21heF9sb3dfcGZu
KSB7Ci0JCQloaWdoc3RhcnRfcGZuID0gc3lzdGVtX21heF9sb3dfcGZuOwotCQl9Ci0JCXByaW50
ayhLRVJOX05PVElDRSAiJWxkTUIgSElHSE1FTSBhdmFpbGFibGUuXG4iLAotCQkgICAgICAgcGFn
ZXNfdG9fbWIoaGlnaGVuZF9wZm4gLSBoaWdoc3RhcnRfcGZuKSk7CisJaGlnaHN0YXJ0X3BmbiA9
IGhpZ2hlbmRfcGZuID0gbWF4X3BmbjsKKwlpZiAobWF4X3BmbiA+IHN5c3RlbV9tYXhfbG93X3Bm
bikKKwkJaGlnaHN0YXJ0X3BmbiA9IHN5c3RlbV9tYXhfbG93X3BmbjsKKwlwcmludGsoS0VSTl9O
T1RJQ0UgIiVsZE1CIEhJR0hNRU0gYXZhaWxhYmxlLlxuIiwKKwkgICAgICAgcGFnZXNfdG9fbWIo
aGlnaGVuZF9wZm4gLSBoaWdoc3RhcnRfcGZuKSk7CiAjZW5kaWYKKwlzeXN0ZW1fbWF4X2xvd19w
Zm4gPSBtYXhfbG93X3BmbiA9IG1heF9sb3dfcGZuIC0gcmVzZXJ2ZV9wYWdlczsKIAlwcmludGso
S0VSTl9OT1RJQ0UgIiVsZE1CIExPV01FTSBhdmFpbGFibGUuXG4iLAogCQkJcGFnZXNfdG9fbWIo
c3lzdGVtX21heF9sb3dfcGZuKSk7Ci0JCi0JZm9yIChuaWQgPSAwOyBuaWQgPCBudW1ub2Rlczsg
bmlkKyspCisJcHJpbnRrKCJtaW5fbG93X3BmbiA9ICVsZCwgbWF4X2xvd19wZm4gPSAlbGQsIGhp
Z2hzdGFydF9wZm4gPSAlbGRcbiIsIAorCQkJbWluX2xvd19wZm4sIG1heF9sb3dfcGZuLCBoaWdo
c3RhcnRfcGZuKTsKKworCXByaW50aygiTG93IG1lbW9yeSBlbmRzIGF0IHZhZGRyICUwOGx4XG4i
LAorCQkJKHVsb25nKSBwZm5fdG9fa2FkZHIobWF4X2xvd19wZm4pKTsKKwlmb3IgKG5pZCA9IDA7
IG5pZCA8IG51bW5vZGVzOyBuaWQrKykgewogCQlhbGxvY2F0ZV9wZ2RhdChuaWQpOworCQlub2Rl
X3JlbWFwX3N0YXJ0X3ZhZGRyW25pZF0gPSBwZm5fdG9fa2FkZHIoCisJCQloaWdoc3RhcnRfcGZu
IC0gbm9kZV9yZW1hcF9vZmZzZXRbbmlkXSk7CisJCXByaW50ayAoIm5vZGUgJWQgd2lsbCByZW1h
cCB0byB2YWRkciAlMDhseCAtICUwOGx4XG4iLCBuaWQsCisJCQkodWxvbmcpIG5vZGVfcmVtYXBf
c3RhcnRfdmFkZHJbbmlkXSwKKwkJCSh1bG9uZykgcGZuX3RvX2thZGRyKGhpZ2hzdGFydF9wZm4K
KwkJCSAgICAtIG5vZGVfcmVtYXBfb2Zmc2V0W25pZF0gKyBub2RlX3JlbWFwX3NpemVbbmlkXSkp
OworCX0KKwlwcmludGsoIkhpZ2ggbWVtb3J5IHN0YXJ0cyBhdCB2YWRkciAlMDhseFxuIiwKKwkJ
CSh1bG9uZykgcGZuX3RvX2thZGRyKGhpZ2hzdGFydF9wZm4pKTsKIAlmb3IgKG5pZCA9IDA7IG5p
ZCA8IG51bW5vZGVzOyBuaWQrKykKIAkJZmluZF9tYXhfcGZuX25vZGUobmlkKTsKIApAQCAtMjQ0
LDcgKzMwNiwxOCBAQAogI2VuZGlmCiAJCQl9CiAJCX0KLQkJZnJlZV9hcmVhX2luaXRfbm9kZShu
aWQsIE5PREVfREFUQShuaWQpLCAwLCB6b25lc19zaXplLCBzdGFydCwgMCk7CisJCS8qCisJCSAq
IFdlIGxldCB0aGUgbG1lbV9tYXAgZm9yIG5vZGUgMCBiZSBhbGxvY2F0ZWQgZnJvbSB0aGUKKwkJ
ICogbm9ybWFsIGJvb3RtZW0gYWxsb2NhdG9yLCBidXQgb3RoZXIgbm9kZXMgY29tZSBmcm9tIHRo
ZQorCQkgKiByZW1hcHBlZCBLVkEgYXJlYSAtIG1ibGlnaAorCQkgKi8KKwkJaWYgKG5pZCkKKwkJ
CWZyZWVfYXJlYV9pbml0X25vZGUobmlkLCBOT0RFX0RBVEEobmlkKSwgCisJCQkJbm9kZV9yZW1h
cF9zdGFydF92YWRkcltuaWRdLCB6b25lc19zaXplLCAKKwkJCQlzdGFydCwgMCk7CisJCWVsc2UK
KwkJCWZyZWVfYXJlYV9pbml0X25vZGUobmlkLCBOT0RFX0RBVEEobmlkKSwgMCwgCisJCQkJem9u
ZXNfc2l6ZSwgc3RhcnQsIDApOwogCX0KIAlyZXR1cm47CiB9CmRpZmYgLXVyTiAtWCAvaG9tZS9t
YmxpZ2gvLmRpZmYuZXhjbHVkZSAxMS1udW1hZml4ZXMyL2FyY2gvaTM4Ni9tbS9pbml0LmMgMjAt
bnVtYW1hcC9hcmNoL2kzODYvbW0vaW5pdC5jCi0tLSAxMS1udW1hZml4ZXMyL2FyY2gvaTM4Ni9t
bS9pbml0LmMJV2VkIFNlcCAxOCAyMDo0MToxMSAyMDAyCisrKyAyMC1udW1hbWFwL2FyY2gvaTM4
Ni9tbS9pbml0LmMJVGh1IFNlcCAxOSAxNjowNzoxMCAyMDAyCkBAIC0yNDUsNiArMjQ1LDEyIEBA
CiAKIHVuc2lnbmVkIGxvbmcgX19QQUdFX0tFUk5FTCA9IF9QQUdFX0tFUk5FTDsKIAorI2lmbmRl
ZiBDT05GSUdfRElTQ09OVElHTUVNCisjZGVmaW5lIHJlbWFwX251bWFfa3ZhKCkgZG8ge30gd2hp
bGUgKDApCisjZWxzZQorZXh0ZXJuIHZvaWQgX19pbml0IHJlbWFwX251bWFfa3ZhKHZvaWQpOwor
I2VuZGlmCisKIHN0YXRpYyB2b2lkIF9faW5pdCBwYWdldGFibGVfaW5pdCAodm9pZCkKIHsKIAl1
bnNpZ25lZCBsb25nIHZhZGRyOwpAQCAtMjY5LDYgKzI3NSw3IEBACiAJfQogCiAJa2VybmVsX3Bo
eXNpY2FsX21hcHBpbmdfaW5pdChwZ2RfYmFzZSk7CisJcmVtYXBfbnVtYV9rdmEoKTsKIAogCS8q
CiAJICogRml4ZWQgbWFwcGluZ3MsIG9ubHkgdGhlIHBhZ2UgdGFibGUgc3RydWN0dXJlIGhhcyB0
byBiZQpAQCAtNDQ5LDcgKzQ1NiwxMSBAQAogCiAJc2V0X21heF9tYXBucl9pbml0KCk7CiAKKyNp
ZmRlZiBDT05GSUdfSElHSE1FTQorCWhpZ2hfbWVtb3J5ID0gKHZvaWQgKikgX192YShoaWdoc3Rh
cnRfcGZuICogUEFHRV9TSVpFKTsKKyNlbHNlCiAJaGlnaF9tZW1vcnkgPSAodm9pZCAqKSBfX3Zh
KG1heF9sb3dfcGZuICogUEFHRV9TSVpFKTsKKyNlbmRpZgogCiAJLyogY2xlYXIgdGhlIHplcm8t
cGFnZSAqLwogCW1lbXNldChlbXB0eV96ZXJvX3BhZ2UsIDAsIFBBR0VfU0laRSk7CmRpZmYgLXVy
TiAtWCAvaG9tZS9tYmxpZ2gvLmRpZmYuZXhjbHVkZSAxMS1udW1hZml4ZXMyL2FyY2gvaTM4Ni9t
bS9wZ3RhYmxlLmMgMjAtbnVtYW1hcC9hcmNoL2kzODYvbW0vcGd0YWJsZS5jCi0tLSAxMS1udW1h
Zml4ZXMyL2FyY2gvaTM4Ni9tbS9wZ3RhYmxlLmMJV2VkIFNlcCAxOCAyMDo0MToxMSAyMDAyCisr
KyAyMC1udW1hbWFwL2FyY2gvaTM4Ni9tbS9wZ3RhYmxlLmMJVGh1IFNlcCAxOSAxNjowNzoxMCAy
MDAyCkBAIC04NCw2ICs4NCwzOSBAQAogCV9fZmx1c2hfdGxiX29uZSh2YWRkcik7CiB9CiAKKy8q
CisgKiBBc3NvY2lhdGUgYSBsYXJnZSB2aXJ0dWFsIHBhZ2UgZnJhbWUgd2l0aCBhIGdpdmVuIHBo
eXNpY2FsIHBhZ2UgZnJhbWUgCisgKiBhbmQgcHJvdGVjdGlvbiBmbGFncyBmb3IgdGhhdCBmcmFt
ZS4gcGZuIGlzIGZvciB0aGUgYmFzZSBvZiB0aGUgcGFnZSwKKyAqIHZhZGRyIGlzIHdoYXQgdGhl
IHBhZ2UgZ2V0cyBtYXBwZWQgdG8gLSBib3RoIG11c3QgYmUgcHJvcGVybHkgYWxpZ25lZC4gCisg
KiBUaGUgcG1kIG11c3QgYWxyZWFkeSBiZSBpbnN0YW50aWF0ZWQuIEFzc3VtZXMgUEFFIG1vZGUu
CisgKi8gCit2b2lkIHNldF9wbWRfcGZuKHVuc2lnbmVkIGxvbmcgdmFkZHIsIHVuc2lnbmVkIGxv
bmcgcGZuLCBwZ3Byb3RfdCBmbGFncykKK3sKKwlwZ2RfdCAqcGdkOworCXBtZF90ICpwbWQ7CisK
KwlpZiAodmFkZHIgJiAoUE1EX1NJWkUtMSkpIHsJCS8qIHZhZGRyIGlzIG1pc2FsaWduZWQgKi8K
KwkJcHJpbnRrICgic2V0X3BtZF9wZm46IHZhZGRyIG1pc2FsaWduZWRcbiIpOworCQlyZXR1cm47
IC8qIEJVRygpOyAqLworCX0KKwlpZiAocGZuICYgKFBUUlNfUEVSX1BURS0xKSkgewkJLyogcGZu
IGlzIG1pc2FsaWduZWQgKi8KKwkJcHJpbnRrICgic2V0X3BtZF9wZm46IHBmbiBtaXNhbGlnbmVk
XG4iKTsKKwkJcmV0dXJuOyAvKiBCVUcoKTsgKi8KKwl9CisJcGdkID0gc3dhcHBlcl9wZ19kaXIg
KyBfX3BnZF9vZmZzZXQodmFkZHIpOworCWlmIChwZ2Rfbm9uZSgqcGdkKSkgeworCQlwcmludGsg
KCJzZXRfcG1kX3BmbjogcGdkX25vbmVcbiIpOworCQlyZXR1cm47IC8qIEJVRygpOyAqLworCX0K
KwlwbWQgPSBwbWRfb2Zmc2V0KHBnZCwgdmFkZHIpOworCXNldF9wbWQocG1kLCBwZm5fcG1kKHBm
biwgZmxhZ3MpKTsKKwkvKgorCSAqIEl0J3MgZW5vdWdoIHRvIGZsdXNoIHRoaXMgb25lIG1hcHBp
bmcuCisJICogKFBHRSBtYXBwaW5ncyBnZXQgZmx1c2hlZCBhcyB3ZWxsKQorCSAqLworCV9fZmx1
c2hfdGxiX29uZSh2YWRkcik7Cit9CisKIHZvaWQgX19zZXRfZml4bWFwIChlbnVtIGZpeGVkX2Fk
ZHJlc3NlcyBpZHgsIHVuc2lnbmVkIGxvbmcgcGh5cywgcGdwcm90X3QgZmxhZ3MpCiB7CiAJdW5z
aWduZWQgbG9uZyBhZGRyZXNzID0gX19maXhfdG9fdmlydChpZHgpOwpkaWZmIC11ck4gLVggL2hv
bWUvbWJsaWdoLy5kaWZmLmV4Y2x1ZGUgMTEtbnVtYWZpeGVzMi9pbmNsdWRlL2FzbS1pMzg2L3Bh
Z2UuaCAyMC1udW1hbWFwL2luY2x1ZGUvYXNtLWkzODYvcGFnZS5oCi0tLSAxMS1udW1hZml4ZXMy
L2luY2x1ZGUvYXNtLWkzODYvcGFnZS5oCVdlZCBTZXAgMTggMjA6NDE6MTIgMjAwMgorKysgMjAt
bnVtYW1hcC9pbmNsdWRlL2FzbS1pMzg2L3BhZ2UuaAlUaHUgU2VwIDE5IDE2OjA3OjEwIDIwMDIK
QEAgLTE0Miw2ICsxNDIsNyBAQAogI2RlZmluZSBNQVhNRU0JCQkoKHVuc2lnbmVkIGxvbmcpKC1Q
QUdFX09GRlNFVC1WTUFMTE9DX1JFU0VSVkUpKQogI2RlZmluZSBfX3BhKHgpCQkJKCh1bnNpZ25l
ZCBsb25nKSh4KS1QQUdFX09GRlNFVCkKICNkZWZpbmUgX192YSh4KQkJCSgodm9pZCAqKSgodW5z
aWduZWQgbG9uZykoeCkrUEFHRV9PRkZTRVQpKQorI2RlZmluZSBwZm5fdG9fa2FkZHIocGZuKSAg
ICAgIF9fdmEoKHBmbikgPDwgUEFHRV9TSElGVCkKICNpZm5kZWYgQ09ORklHX0RJU0NPTlRJR01F
TQogI2RlZmluZSBwZm5fdG9fcGFnZShwZm4pCShtZW1fbWFwICsgKHBmbikpCiAjZGVmaW5lIHBh
Z2VfdG9fcGZuKHBhZ2UpCSgodW5zaWduZWQgbG9uZykoKHBhZ2UpIC0gbWVtX21hcCkpCg==

--==========08832411==========--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
