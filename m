Date: Thu, 8 Nov 2007 11:58:58 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Some interesting observations when trying to optimize vmstat handling
Message-ID: <Pine.LNX.4.64.0711081141180.9694@schroedinger.engr.sgi.com>
MIME-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1700579579-463682288-1194551938=:9694"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, ak@suse.de, Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
List-ID: <linux-mm.kvack.org>

---1700579579-463682288-1194551938=:9694
Content-Type: TEXT/PLAIN; charset=US-ASCII

I looked into getting rid of the interrupt enable/disable when updating vm 
statistics in vmstat.c. The SLUB removal of the interrupt enable/disable 
doubled the performance of the fast path so maybe we can do the same to
vm statistics.

Measurements were done on an 8p SMP system (dual quad core Intel Xeon)

Some numbers:

inc_zone_page_state	Includes interrupt enable/disable
__dec_zone_page_state	Does not perform interrupt enable/disable
count_vm_event 		Simple increment with preempt disable/enable

Base 2.6.24-rc2

10000 x inc_zone_page_state		60 cycles per call
10000 x __dec_zone_page_state		12 cycles per call
10000 x count_vm_event			 6 cycles per call

There is an interrupt enable overhead of 48 cycles that would be good to 
be able to eliminate (Kernel code usually moves counter increments into
a neighboring interrupt disable section so that __ function can be used).

cmpxchg_local
-------------

The first approach was to simply use cmpxchg_local like in SLUB (see 
attached patch):

10000 x inc_zone_page_state		93 cycles per call
10000 x __dec_zone_page_state		96 cycles
10000 x count_vm_event			 6 cycles per call

The processing of the counters got too complex. The problem with 
cmpxchg_local here is that the differential has to be read before we 
execute the cmpxchg_local. So the cacheline is acquired first in read mode 
and then made exclusive on executing the cmpxchg_local.

This is not helping.

local inc
---------

I build some custom assembly code to perform local_inc on a vmstat 
differential byte in order to avoid acquiring the cacheline in read node 
first (code has still an unresolved very unlikely race):

10000 x inc_zone_page_state		14 cycles per call
10000 x __dec_zone_page_state		12 cycles per call
10000 x count_vm_event			6 cycles per call

inc_zone_page_state simply calls __inc_zone_page_state and disables
preemption before doing so. So the simple function call costs 2 cycles.

__dec_zone_page_state now has equal performance.

Solution is likely also not acceptable due to:

1. There is still an race with interrupts that could in lead to
   counter overflow if an interrupt occurs during inc_zone_page_state
   which then is interrupted again when we execute on the tail end of
   the interrupt and that tail code is  interrupt again. If this happens
   > 5 - 100 times then a counter overflow can occur.

2. There is the need to add a local_inc for bytes to the local_t 
   operations.

Raw patch for local inc follows:


---
 mm/vmstat.c |  139 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 132 insertions(+), 7 deletions(-)

Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2007-11-07 21:14:05.997039421 -0800
+++ linux-2.6/mm/vmstat.c	2007-11-07 23:28:10.625617837 -0800
@@ -153,8 +153,126 @@ static void refresh_zone_stat_thresholds
 	}
 }
 
+#ifdef CONFIG_FAST_CMPXCHG_LOCAL
+void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
+				int delta)
+{
+	if (delta == 1)
+		__inc_zone_state(zone, item);
+	else if (delta == -1)
+		__dec_zone_state(zone, item);
+	else
+		zone_page_state_add(delta, zone, item);
+}
+EXPORT_SYMBOL(__mod_zone_page_state);
+
+void mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
+					int delta)
+{
+	preempt_disable();
+	__mod_zone_page_state(zone, item, delta);
+	preempt_enable();
+}
+EXPORT_SYMBOL(mod_zone_page_state);
+
+static inline void inc_diff(s8 *p)
+{
+	__asm__ __volatile__(
+		"incb %0;"
+			: "=m" (p)
+			: "m" (p));
+}
+
+static inline void dec_diff(s8 *p)
+{
+	__asm__ __volatile__(
+		"decb %0;"
+			: "=m" (p)
+			: "m" (p));
+
+}
+
+static inline void sync_diff(struct zone *zone, s8 *p,
+		int i, int offset)
+{
+	/*
+	 * xchg_local() would be useful here but that does not exist.
+	 */
+	zone_page_state_add(xchg(p, offset) - offset, zone, i);
+}
+
+/*
+ * Optimized increment and decrement functions implemented using
+ * cmpxchg_local. These do not require interrupts to be disabled
+ * and enabled.
+ */
+void __inc_zone_state(struct zone *zone, enum zone_stat_item item)
+{
+	struct per_cpu_pageset *pcp = THIS_CPU(zone->pageset);
+	s8 t = pcp->stat_threshold;
+	s8 *p = pcp->vm_stat_diff + item;
+
+	inc_diff(p);
+	if (unlikely(*p >= t))
+		/*
+		 * There is a race here. An interrupt may occur
+		 * and increment the same differential. However, the
+		 * interrupt will then also end up here and call
+		 * sync_diff. After we return from the interrupt
+		 * the sync_diff here will have no effect since
+		 * p is going to be zero.
+		 */
+		sync_diff(zone, p, item, -(t / 2));
+}
+
+void __inc_zone_page_state(struct page *page, enum zone_stat_item item)
+{
+	__inc_zone_state(page_zone(page), item);
+}
+EXPORT_SYMBOL(__inc_zone_page_state);
+
+void __dec_zone_state(struct zone *zone, enum zone_stat_item item)
+{
+	struct per_cpu_pageset *pcp = THIS_CPU(zone->pageset);
+	s8 t = pcp->stat_threshold;
+	s8 *p = pcp->vm_stat_diff + item;
+
+	dec_diff(p);
+	if (unlikely(*p <= -t))
+		sync_diff(zone, p, item, t / 2);
+}
+
+void __dec_zone_page_state(struct page *page, enum zone_stat_item item)
+{
+	__dec_zone_state(page_zone(page), item);
+}
+EXPORT_SYMBOL(__dec_zone_page_state);
+
+void inc_zone_state(struct zone *zone, enum zone_stat_item item)
+{
+	preempt_disable();
+	__inc_zone_state(zone, item);
+	preempt_enable();
+}
+
+void inc_zone_page_state(struct page *page, enum zone_stat_item item)
+{
+	inc_zone_state(page_zone(page), item);
+}
+EXPORT_SYMBOL(inc_zone_page_state);
+
+void dec_zone_page_state(struct page *page, enum zone_stat_item item)
+{
+	preempt_disable();
+	__dec_zone_page_state(page, item);
+	preempt_enable();
+}
+EXPORT_SYMBOL(dec_zone_page_state);
+
+#else /* CONFIG_FAST_CMPXCHG_LOCAL */
+
 /*
- * For use when we know that interrupts are disabled.
+ * Functions that do not rely on cmpxchg_local
  */
 void __mod_zone_page_state(struct zone *zone, enum zone_stat_item item,
 				int delta)
@@ -284,6 +402,17 @@ void dec_zone_page_state(struct page *pa
 }
 EXPORT_SYMBOL(dec_zone_page_state);
 
+static inline void sync_diff(struct zone *zone, struct per_cpu_pageset *p, int i)
+{
+	unsigned long flags;
+
+	local_irq_save(flags);
+	zone_page_state_add(p->vm_stat_diff[i], zone, i);
+	p->vm_stat_diff[i] = 0;
+	local_irq_restore(flags);
+}
+#endif /* !CONFIG_FAST_CMPXCHG_LOCAL */
+
 /*
  * Update the zone counters for one cpu.
  *
@@ -302,7 +431,6 @@ void refresh_cpu_vm_stats(int cpu)
 {
 	struct zone *zone;
 	int i;
-	unsigned long flags;
 
 	for_each_zone(zone) {
 		struct per_cpu_pageset *p;
@@ -314,15 +442,12 @@ void refresh_cpu_vm_stats(int cpu)
 
 		for (i = 0; i < NR_VM_ZONE_STAT_ITEMS; i++)
 			if (p->vm_stat_diff[i]) {
-				local_irq_save(flags);
-				zone_page_state_add(p->vm_stat_diff[i],
-					zone, i);
-				p->vm_stat_diff[i] = 0;
+				sync_diff(zone, &p->vm_stat_diff[i], i, 0);
+
 #ifdef CONFIG_NUMA
 				/* 3 seconds idle till flush */
 				p->expire = 3;
 #endif
-				local_irq_restore(flags);
 			}
 #ifdef CONFIG_NUMA
 		/*



---1700579579-463682288-1194551938=:9694
Content-Type: TEXT/PLAIN; charset=US-ASCII; name=vmstat_fast_cmpxchg
Content-Transfer-Encoding: BASE64
Content-ID: <Pine.LNX.4.64.0711081158580.9694@schroedinger.engr.sgi.com>
Content-Description: Fast cmpxchg
Content-Disposition: attachment; filename=vmstat_fast_cmpxchg

LS0tDQogaW5jbHVkZS9saW51eC92bXN0YXQuaCB8ICAgMTcgKysrKy0tDQog
bW0vdm1zdGF0LmMgICAgICAgICAgICB8ICAxMjIgKysrKysrKysrKysrKysr
KysrKysrKysrKysrKysrKysrKysrKysrKysrKysrKy0tLQ0KIDIgZmlsZXMg
Y2hhbmdlZCwgMTI3IGluc2VydGlvbnMoKyksIDEyIGRlbGV0aW9ucygtKQ0K
DQpJbmRleDogbGludXgtMi42L2luY2x1ZGUvbGludXgvdm1zdGF0LmgNCj09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT0NCi0tLSBsaW51eC0yLjYub3JpZy9pbmNs
dWRlL2xpbnV4L3Ztc3RhdC5oCTIwMDctMTEtMDcgMTY6NDk6MzkuOTg1NzAx
MzMyIC0wODAwDQorKysgbGludXgtMi42L2luY2x1ZGUvbGludXgvdm1zdGF0
LmgJMjAwNy0xMS0wNyAxOTo1NTo1Mi40MzE2MTcyNjkgLTA4MDANCkBAIC0y
MDIsMTUgKzIwMiwyMiBAQCBleHRlcm4gdm9pZCBpbmNfem9uZV9zdGF0ZShz
dHJ1Y3Qgem9uZSAqDQogdm9pZCBfX21vZF96b25lX3BhZ2Vfc3RhdGUoc3Ry
dWN0IHpvbmUgKiwgZW51bSB6b25lX3N0YXRfaXRlbSBpdGVtLCBpbnQpOw0K
IHZvaWQgX19pbmNfem9uZV9wYWdlX3N0YXRlKHN0cnVjdCBwYWdlICosIGVu
dW0gem9uZV9zdGF0X2l0ZW0pOw0KIHZvaWQgX19kZWNfem9uZV9wYWdlX3N0
YXRlKHN0cnVjdCBwYWdlICosIGVudW0gem9uZV9zdGF0X2l0ZW0pOw0KK3Zv
aWQgX19pbmNfem9uZV9zdGF0ZShzdHJ1Y3Qgem9uZSAqLCBlbnVtIHpvbmVf
c3RhdF9pdGVtKTsNCit2b2lkIF9fZGVjX3pvbmVfc3RhdGUoc3RydWN0IHpv
bmUgKiwgZW51bSB6b25lX3N0YXRfaXRlbSk7DQogDQorI2lmZGVmIENPTkZJ
R19GQVNUX0NNUFhDSEdfTE9DQUwNCisjZGVmaW5lIGluY196b25lX3BhZ2Vf
c3RhdGUgX19pbmNfem9uZV9wYWdlX3N0YXRlDQorI2RlZmluZSBkZWNfem9u
ZV9wYWdlX3N0YXRlIF9fZGVjX3pvbmVfcGFnZV9zdGF0ZQ0KKyNkZWZpbmUg
bW9kX3pvbmVfcGFnZV9zdGF0ZSBfX21vZF96b25lX3BhZ2Vfc3RhdGUNCisj
ZGVmaW5lIGluY196b25lX3N0YXRlIF9faW5jX3pvbmVfc3RhdGUNCisjZGVm
aW5lIGRlY196b25lX3N0YXRlIF9fZGVjX3pvbmVfc3RhdGUNCisjZWxzZQ0K
IHZvaWQgbW9kX3pvbmVfcGFnZV9zdGF0ZShzdHJ1Y3Qgem9uZSAqLCBlbnVt
IHpvbmVfc3RhdF9pdGVtLCBpbnQpOw0KIHZvaWQgaW5jX3pvbmVfcGFnZV9z
dGF0ZShzdHJ1Y3QgcGFnZSAqLCBlbnVtIHpvbmVfc3RhdF9pdGVtKTsNCiB2
b2lkIGRlY196b25lX3BhZ2Vfc3RhdGUoc3RydWN0IHBhZ2UgKiwgZW51bSB6
b25lX3N0YXRfaXRlbSk7DQotDQotZXh0ZXJuIHZvaWQgaW5jX3pvbmVfc3Rh
dGUoc3RydWN0IHpvbmUgKiwgZW51bSB6b25lX3N0YXRfaXRlbSk7DQotZXh0
ZXJuIHZvaWQgX19pbmNfem9uZV9zdGF0ZShzdHJ1Y3Qgem9uZSAqLCBlbnVt
IHpvbmVfc3RhdF9pdGVtKTsNCi1leHRlcm4gdm9pZCBkZWNfem9uZV9zdGF0
ZShzdHJ1Y3Qgem9uZSAqLCBlbnVtIHpvbmVfc3RhdF9pdGVtKTsNCi1leHRl
cm4gdm9pZCBfX2RlY196b25lX3N0YXRlKHN0cnVjdCB6b25lICosIGVudW0g
em9uZV9zdGF0X2l0ZW0pOw0KK3ZvaWQgaW5jX3pvbmVfc3RhdGUoc3RydWN0
IHpvbmUgKiwgZW51bSB6b25lX3N0YXRfaXRlbSk7DQordm9pZCBkZWNfem9u
ZV9zdGF0ZShzdHJ1Y3Qgem9uZSAqLCBlbnVtIHpvbmVfc3RhdF9pdGVtKTsN
CisjZW5kaWYNCiANCiB2b2lkIHJlZnJlc2hfY3B1X3ZtX3N0YXRzKGludCk7
DQogI2Vsc2UgLyogQ09ORklHX1NNUCAqLw0KSW5kZXg6IGxpbnV4LTIuNi9t
bS92bXN0YXQuYw0KPT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09
PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PT09PQ0KLS0tIGxpbnV4
LTIuNi5vcmlnL21tL3Ztc3RhdC5jCTIwMDctMTEtMDcgMTY6NDk6NDAuMDk3
NzAxMjUzIC0wODAwDQorKysgbGludXgtMi42L21tL3Ztc3RhdC5jCTIwMDct
MTEtMDcgMTk6NTk6MDcuMzkxMDgxNjMzIC0wODAwDQpAQCAtMTUzLDggKzE1
MywxMDkgQEAgc3RhdGljIHZvaWQgcmVmcmVzaF96b25lX3N0YXRfdGhyZXNo
b2xkcw0KIAl9DQogfQ0KIA0KKyNpZmRlZiBDT05GSUdfRkFTVF9DTVBYQ0hH
X0xPQ0FMDQordm9pZCBfX21vZF96b25lX3BhZ2Vfc3RhdGUoc3RydWN0IHpv
bmUgKnpvbmUsIGVudW0gem9uZV9zdGF0X2l0ZW0gaXRlbSwNCisJCQkJaW50
IGRlbHRhKQ0KK3sNCisJc3RydWN0IHBlcl9jcHVfcGFnZXNldCAqcGNwID0g
VEhJU19DUFUoem9uZS0+cGFnZXNldCk7DQorCXM4ICpwID0gcGNwLT52bV9z
dGF0X2RpZmYgKyBpdGVtOw0KKwlzOCBvbGQ7DQorCXVuc2lnbmVkIGxvbmcg
bmV3Ow0KKwl1bnNpZ25lZCBsb25nIGFkZDsNCisNCisJZG8gew0KKwkJYWRk
ID0gMDsNCisJCW9sZCA9ICpwOw0KKwkJbmV3ID0gb2xkICsgZGVsdGE7DQor
DQorCQlpZiAodW5saWtlbHkobmV3ID4gcGNwLT5zdGF0X3RocmVzaG9sZCB8
fA0KKwkJCQluZXcgPCAtcGNwLT5zdGF0X3RocmVzaG9sZCkpIHsNCisJCQlh
ZGQgPSBuZXc7DQorCQkJbmV3ID0gMDsNCisJCX0NCisNCisJfSB3aGlsZSAo
Y21weGNoZ19sb2NhbChwLCBvbGQsIG5ldykgIT0gb2xkKTsNCisNCisJaWYg
KGFkZCkNCisJCXpvbmVfcGFnZV9zdGF0ZV9hZGQoYWRkLCB6b25lLCBpdGVt
KTsNCit9DQorRVhQT1JUX1NZTUJPTChfX21vZF96b25lX3BhZ2Vfc3RhdGUp
Ow0KKw0KKy8qDQorICogT3B0aW1pemVkIGluY3JlbWVudCBhbmQgZGVjcmVt
ZW50IGZ1bmN0aW9ucyBpbXBsZW1lbnRlZCB1c2luZw0KKyAqIGNtcHhjaGdf
bG9jYWwuIFRoZXNlIGRvIG5vdCByZXF1aXJlIGludGVycnVwdHMgdG8gYmUg
ZGlzYWJsZWQNCisgKiBhbmQgZW5hYmxlZC4NCisgKi8NCit2b2lkIF9faW5j
X3pvbmVfc3RhdGUoc3RydWN0IHpvbmUgKnpvbmUsIGVudW0gem9uZV9zdGF0
X2l0ZW0gaXRlbSkNCit7DQorCXN0cnVjdCBwZXJfY3B1X3BhZ2VzZXQgKnBj
cCA9IFRISVNfQ1BVKHpvbmUtPnBhZ2VzZXQpOw0KKwlzOCAqcCA9IHBjcC0+
dm1fc3RhdF9kaWZmICsgaXRlbTsNCisJaW50IGFkZDsNCisJdW5zaWduZWQg
bG9uZyBvbGQ7DQorCXVuc2lnbmVkIGxvbmcgbmV3Ow0KKw0KKwlkbyB7DQor
CQlhZGQgPSAwOw0KKwkJb2xkID0gKnA7DQorCQluZXcgPSBvbGQgKyAxOw0K
Kw0KKwkJaWYgKHVubGlrZWx5KG5ldyA+IHBjcC0+c3RhdF90aHJlc2hvbGQp
KSB7DQorCQkJYWRkID0gbmV3ICsgcGNwLT5zdGF0X3RocmVzaG9sZCAvIDI7
DQorCQkJbmV3ID0gLShwY3AtPnN0YXRfdGhyZXNob2xkIC8gMik7DQorCQl9
DQorCX0gd2hpbGUgKGNtcHhjaGdfbG9jYWwocCwgb2xkLCBuZXcpICE9IG9s
ZCk7DQorDQorCWlmIChhZGQpDQorCQl6b25lX3BhZ2Vfc3RhdGVfYWRkKGFk
ZCwgem9uZSwgaXRlbSk7DQorfQ0KKw0KK3ZvaWQgX19pbmNfem9uZV9wYWdl
X3N0YXRlKHN0cnVjdCBwYWdlICpwYWdlLCBlbnVtIHpvbmVfc3RhdF9pdGVt
IGl0ZW0pDQorew0KKwlfX2luY196b25lX3N0YXRlKHBhZ2Vfem9uZShwYWdl
KSwgaXRlbSk7DQorfQ0KK0VYUE9SVF9TWU1CT0woX19pbmNfem9uZV9wYWdl
X3N0YXRlKTsNCisNCit2b2lkIF9fZGVjX3pvbmVfc3RhdGUoc3RydWN0IHpv
bmUgKnpvbmUsIGVudW0gem9uZV9zdGF0X2l0ZW0gaXRlbSkNCit7DQorCXN0
cnVjdCBwZXJfY3B1X3BhZ2VzZXQgKnBjcCA9IFRISVNfQ1BVKHpvbmUtPnBh
Z2VzZXQpOw0KKwlzOCAqcCA9IHBjcC0+dm1fc3RhdF9kaWZmICsgaXRlbTsN
CisJaW50IHN1YjsNCisJdW5zaWduZWQgbG9uZyBvbGQ7DQorCXVuc2lnbmVk
IGxvbmcgbmV3Ow0KKw0KKwlkbyB7DQorCQlzdWIgPSAwOw0KKwkJb2xkID0g
KnA7DQorCQluZXcgPSBvbGQgLSAxOw0KKw0KKwkJaWYgKHVubGlrZWx5KG5l
dyA8IC0gcGNwLT5zdGF0X3RocmVzaG9sZCkpIHsNCisJCQlzdWIgPSBuZXcg
LSBwY3AtPnN0YXRfdGhyZXNob2xkIC8gMjsNCisJCQluZXcgPSBwY3AtPnN0
YXRfdGhyZXNob2xkIC8gMjsNCisJCX0NCisJfSB3aGlsZSAoY21weGNoZ19s
b2NhbChwLCBvbGQsIG5ldykgIT0gb2xkKTsNCisNCisJaWYgKHN1YikNCisJ
CXpvbmVfcGFnZV9zdGF0ZV9hZGQoc3ViLCB6b25lLCBpdGVtKTsNCit9DQor
DQordm9pZCBfX2RlY196b25lX3BhZ2Vfc3RhdGUoc3RydWN0IHBhZ2UgKnBh
Z2UsIGVudW0gem9uZV9zdGF0X2l0ZW0gaXRlbSkNCit7DQorCV9fZGVjX3pv
bmVfc3RhdGUocGFnZV96b25lKHBhZ2UpLCBpdGVtKTsNCit9DQorRVhQT1JU
X1NZTUJPTChfX2RlY196b25lX3BhZ2Vfc3RhdGUpOw0KKw0KK3N0YXRpYyBp
bmxpbmUgdm9pZCBzeW5jX2RpZmYoc3RydWN0IHpvbmUgKnpvbmUsIHN0cnVj
dCBwZXJfY3B1X3BhZ2VzZXQgKnAsIGludCBpKQ0KK3sNCisJLyoNCisJICog
eGNoZ19sb2NhbCgpIHdvdWxkIGJlIHVzZWZ1bCBoZXJlIGJ1dCB0aGF0IGRv
ZXMgbm90IGV4aXN0Lg0KKwkgKi8NCisJem9uZV9wYWdlX3N0YXRlX2FkZCh4
Y2hnKCZwLT52bV9zdGF0X2RpZmZbaV0sIDApLCB6b25lLCBpKTsNCit9DQor
DQorI2Vsc2UgLyogQ09ORklHX0ZBU1RfQ01QWENIR19MT0NBTCAqLw0KKw0K
IC8qDQotICogRm9yIHVzZSB3aGVuIHdlIGtub3cgdGhhdCBpbnRlcnJ1cHRz
IGFyZSBkaXNhYmxlZC4NCisgKiBGdW5jdGlvbnMgdGhhdCBkbyBub3QgcmVs
eSBvbiBjbXB4Y2hnX2xvY2FsDQogICovDQogdm9pZCBfX21vZF96b25lX3Bh
Z2Vfc3RhdGUoc3RydWN0IHpvbmUgKnpvbmUsIGVudW0gem9uZV9zdGF0X2l0
ZW0gaXRlbSwNCiAJCQkJaW50IGRlbHRhKQ0KQEAgLTI4NCw2ICszODUsMTcg
QEAgdm9pZCBkZWNfem9uZV9wYWdlX3N0YXRlKHN0cnVjdCBwYWdlICpwYQ0K
IH0NCiBFWFBPUlRfU1lNQk9MKGRlY196b25lX3BhZ2Vfc3RhdGUpOw0KIA0K
K3N0YXRpYyBpbmxpbmUgdm9pZCBzeW5jX2RpZmYoc3RydWN0IHpvbmUgKnpv
bmUsIHN0cnVjdCBwZXJfY3B1X3BhZ2VzZXQgKnAsIGludCBpKQ0KK3sNCisJ
dW5zaWduZWQgbG9uZyBmbGFnczsNCisNCisJbG9jYWxfaXJxX3NhdmUoZmxh
Z3MpOw0KKwl6b25lX3BhZ2Vfc3RhdGVfYWRkKHAtPnZtX3N0YXRfZGlmZltp
XSwgem9uZSwgaSk7DQorCXAtPnZtX3N0YXRfZGlmZltpXSA9IDA7DQorCWxv
Y2FsX2lycV9yZXN0b3JlKGZsYWdzKTsNCit9DQorI2VuZGlmIC8qICFDT05G
SUdfRkFTVF9DTVBYQ0hHX0xPQ0FMICovDQorDQogLyoNCiAgKiBVcGRhdGUg
dGhlIHpvbmUgY291bnRlcnMgZm9yIG9uZSBjcHUuDQogICoNCkBAIC0zMDIs
NyArNDE0LDYgQEAgdm9pZCByZWZyZXNoX2NwdV92bV9zdGF0cyhpbnQgY3B1
KQ0KIHsNCiAJc3RydWN0IHpvbmUgKnpvbmU7DQogCWludCBpOw0KLQl1bnNp
Z25lZCBsb25nIGZsYWdzOw0KIA0KIAlmb3JfZWFjaF96b25lKHpvbmUpIHsN
CiAJCXN0cnVjdCBwZXJfY3B1X3BhZ2VzZXQgKnA7DQpAQCAtMzE0LDE1ICs0
MjUsMTIgQEAgdm9pZCByZWZyZXNoX2NwdV92bV9zdGF0cyhpbnQgY3B1KQ0K
IA0KIAkJZm9yIChpID0gMDsgaSA8IE5SX1ZNX1pPTkVfU1RBVF9JVEVNUzsg
aSsrKQ0KIAkJCWlmIChwLT52bV9zdGF0X2RpZmZbaV0pIHsNCi0JCQkJbG9j
YWxfaXJxX3NhdmUoZmxhZ3MpOw0KLQkJCQl6b25lX3BhZ2Vfc3RhdGVfYWRk
KHAtPnZtX3N0YXRfZGlmZltpXSwNCi0JCQkJCXpvbmUsIGkpOw0KLQkJCQlw
LT52bV9zdGF0X2RpZmZbaV0gPSAwOw0KKwkJCQlzeW5jX2RpZmYoem9uZSwg
cCwgaSk7DQorDQogI2lmZGVmIENPTkZJR19OVU1BDQogCQkJCS8qIDMgc2Vj
b25kcyBpZGxlIHRpbGwgZmx1c2ggKi8NCiAJCQkJcC0+ZXhwaXJlID0gMzsN
CiAjZW5kaWYNCi0JCQkJbG9jYWxfaXJxX3Jlc3RvcmUoZmxhZ3MpOw0KIAkJ
CX0NCiAjaWZkZWYgQ09ORklHX05VTUENCiAJCS8qDQo=

---1700579579-463682288-1194551938=:9694--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
