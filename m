Message-Id: <6.0.0.20.2.20070918193944.038e2ea0@172.19.0.2>
Date: Tue, 18 Sep 2007 19:41:14 +0900
From: Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>
Subject: Re: [PATCH] mm: use pagevec to rotate reclaimable page
In-Reply-To: <20070913193711.ecc825f7.akpm@linux-foundation.org>
References: <6.0.0.20.2.20070907113025.024dfbb8@172.19.0.2>
 <20070913193711.ecc825f7.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;	boundary="=====================_36019476==_"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=====================_36019476==_
Content-Type: text/plain; charset="us-ascii"; format=flowed
Content-Transfer-Encoding: 7bit

I modified my patch based on your comment.

At 11:37 07/09/14, Andrew Morton wrote:
 >
 >So I do think that for safety and sanity's sake, we should be taking a ref
 >on the pages when they are in a pagevec.  That's going to hurt your nice
 >performance numbers :(
 >

I did ping test again to observe performance deterioration caused by taking 
a ref.

	-2.6.23-rc6-with-modifiedpatch
	--- testmachine ping statistics ---
	3000 packets transmitted, 3000 received, 0% packet loss, time 53386ms
	rtt min/avg/max/mdev = 0.074/0.110/4.716/0.147 ms, pipe 2, ipg/ewma 
17.801/0.129 ms

The result for my original patch is as follows.

	-2.6.23-rc5-with-originalpatch
	--- testmachine ping statistics ---
	3000 packets transmitted, 3000 received, 0% packet loss, time 51924ms
	rtt min/avg/max/mdev = 0.072/0.108/3.884/0.114 ms, pipe 2, ipg/ewma 
17.314/0.091 ms


The influence to response was small.

Thanks.

Signed-off-by :Hisashi Hifumi <hifumi.hisashi@oss.ntt.co.jp>


diff -Nrup linux-2.6.23-rc6.org/include/linux/swap.h 
linux-2.6.23-rc6/include/linux/swap.h
--- linux-2.6.23-rc6.org/include/linux/swap.h	2007-09-14 16:49:57.000000000 +0900
+++ linux-2.6.23-rc6/include/linux/swap.h	2007-09-14 16:58:48.000000000 +0900
@@ -185,6 +185,7 @@ extern void FASTCALL(mark_page_accessed(
  extern void lru_add_drain(void);
  extern int lru_add_drain_all(void);
  extern int rotate_reclaimable_page(struct page *page);
+extern void move_tail_pages(void);
  extern void swap_setup(void);

  /* linux/mm/vmscan.c */
diff -Nrup linux-2.6.23-rc6.org/mm/swap.c linux-2.6.23-rc6/mm/swap.c
--- linux-2.6.23-rc6.org/mm/swap.c	2007-07-09 08:32:17.000000000 +0900
+++ linux-2.6.23-rc6/mm/swap.c	2007-09-18 18:49:07.000000000 +0900
@@ -94,24 +94,62 @@ void put_pages_list(struct list_head *pa
  EXPORT_SYMBOL(put_pages_list);

  /*
+ * pagevec_move_tail() must be called with IRQ disabled.
+ * Otherwise this may cause nasty races.
+ */
+static void pagevec_move_tail(struct pagevec *pvec)
+{
+	int i;
+	int pgmoved = 0;
+	struct zone *zone = NULL;
+	unsigned long flags = 0;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irqrestore(&zone->lru_lock, flags);
+			zone = pagezone;
+			spin_lock_irqsave(&zone->lru_lock, flags);
+		}
+		if (PageLRU(page) && !PageActive(page)) {
+			list_move_tail(&page->lru, &zone->inactive_list);
+			pgmoved++;
+		}
+	}
+	if (zone)
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+	__count_vm_events(PGROTATED, pgmoved);
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+static DEFINE_PER_CPU(struct pagevec, rotate_pvecs) = { 0, };
+
+void move_tail_pages()
+{
+	unsigned long flags;
+	struct pagevec *pvec;
+
+	local_irq_save(flags);
+	pvec = &__get_cpu_var(rotate_pvecs);
+	if (pagevec_count(pvec))
+		pagevec_move_tail(pvec);
+	local_irq_restore(flags);
+}
+
+/*
   * Writeback is about to end against a page which has been marked for immediate
   * reclaim.  If it still appears to be reclaimable, move it to the tail of the
- * inactive list.  The page still has PageWriteback set, which will pin it.
- *
- * We don't expect many pages to come through here, so don't bother batching
- * things up.
- *
- * To avoid placing the page at the tail of the LRU while PG_writeback is still
- * set, this function will clear PG_writeback before performing the page
- * motion.  Do that inside the lru lock because once PG_writeback is cleared
- * we may not touch the page.
+ * inactive list.
   *
   * Returns zero if it cleared PG_writeback.
   */
  int rotate_reclaimable_page(struct page *page)
  {
-	struct zone *zone;
-	unsigned long flags;
+	struct pagevec *pvec;

  	if (PageLocked(page))
  		return 1;
@@ -122,15 +160,15 @@ int rotate_reclaimable_page(struct page
  	if (!PageLRU(page))
  		return 1;

-	zone = page_zone(page);
-	spin_lock_irqsave(&zone->lru_lock, flags);
  	if (PageLRU(page) && !PageActive(page)) {
-		list_move_tail(&page->lru, &zone->inactive_list);
-		__count_vm_event(PGROTATED);
+		page_cache_get(page);
+		pvec = &__get_cpu_var(rotate_pvecs);
+		if (!pagevec_add(pvec, page))
+			pagevec_move_tail(pvec);
  	}
  	if (!test_clear_page_writeback(page))
  		BUG();
-	spin_unlock_irqrestore(&zone->lru_lock, flags);
+
  	return 0;
  }

@@ -495,6 +533,23 @@ static int cpu_swap_callback(struct noti
  	}
  	return NOTIFY_OK;
  }
+
+static int cpu_movetail_callback(struct notifier_block *nfb,
+				 unsigned long action, void *hcpu)
+{
+	unsigned long flags;
+	struct pagevec *pvec;
+
+	if (action == CPU_DEAD || action == CPU_DEAD_FROZEN) {
+		local_irq_save(flags);
+		pvec = &per_cpu(rotate_pvecs, (long)hcpu);
+		if (pagevec_count(pvec))
+			pagevec_move_tail(pvec);
+		local_irq_restore(flags);
+	}
+
+	return NOTIFY_OK;
+}
  #endif /* CONFIG_HOTPLUG_CPU */
  #endif /* CONFIG_SMP */

@@ -516,5 +571,6 @@ void __init swap_setup(void)
  	 */
  #ifdef CONFIG_HOTPLUG_CPU
  	hotcpu_notifier(cpu_swap_callback, 0);
+	hotcpu_notifier(cpu_movetail_callback, 0);
  #endif
  }
diff -Nrup linux-2.6.23-rc6.org/mm/vmscan.c linux-2.6.23-rc6/mm/vmscan.c
--- linux-2.6.23-rc6.org/mm/vmscan.c	2007-09-14 16:49:57.000000000 +0900
+++ linux-2.6.23-rc6/mm/vmscan.c	2007-09-14 16:58:48.000000000 +0900
@@ -792,6 +792,7 @@ static unsigned long shrink_inactive_lis

  	pagevec_init(&pvec, 1);

+	move_tail_pages();
  	lru_add_drain();
  	spin_lock_irq(&zone->lru_lock);
  	do { 

--=====================_36019476==_
Content-Type: application/octet-stream; name="patch2623rc6_pvecrotate.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename="patch2623rc6_pvecrotate.txt"

ZGlmZiAtTnJ1cCBsaW51eC0yLjYuMjMtcmM2Lm9yZy9pbmNsdWRlL2xpbnV4L3N3YXAuaCBsaW51
eC0yLjYuMjMtcmM2L2luY2x1ZGUvbGludXgvc3dhcC5oCi0tLSBsaW51eC0yLjYuMjMtcmM2Lm9y
Zy9pbmNsdWRlL2xpbnV4L3N3YXAuaAkyMDA3LTA5LTE0IDE2OjQ5OjU3LjAwMDAwMDAwMCArMDkw
MAorKysgbGludXgtMi42LjIzLXJjNi9pbmNsdWRlL2xpbnV4L3N3YXAuaAkyMDA3LTA5LTE0IDE2
OjU4OjQ4LjAwMDAwMDAwMCArMDkwMApAQCAtMTg1LDYgKzE4NSw3IEBAIGV4dGVybiB2b2lkIEZB
U1RDQUxMKG1hcmtfcGFnZV9hY2Nlc3NlZCgKIGV4dGVybiB2b2lkIGxydV9hZGRfZHJhaW4odm9p
ZCk7CiBleHRlcm4gaW50IGxydV9hZGRfZHJhaW5fYWxsKHZvaWQpOwogZXh0ZXJuIGludCByb3Rh
dGVfcmVjbGFpbWFibGVfcGFnZShzdHJ1Y3QgcGFnZSAqcGFnZSk7CitleHRlcm4gdm9pZCBtb3Zl
X3RhaWxfcGFnZXModm9pZCk7CiBleHRlcm4gdm9pZCBzd2FwX3NldHVwKHZvaWQpOwogCiAvKiBs
aW51eC9tbS92bXNjYW4uYyAqLwpkaWZmIC1OcnVwIGxpbnV4LTIuNi4yMy1yYzYub3JnL21tL3N3
YXAuYyBsaW51eC0yLjYuMjMtcmM2L21tL3N3YXAuYwotLS0gbGludXgtMi42LjIzLXJjNi5vcmcv
bW0vc3dhcC5jCTIwMDctMDctMDkgMDg6MzI6MTcuMDAwMDAwMDAwICswOTAwCisrKyBsaW51eC0y
LjYuMjMtcmM2L21tL3N3YXAuYwkyMDA3LTA5LTE4IDE4OjQ5OjA3LjAwMDAwMDAwMCArMDkwMApA
QCAtOTQsMjQgKzk0LDYyIEBAIHZvaWQgcHV0X3BhZ2VzX2xpc3Qoc3RydWN0IGxpc3RfaGVhZCAq
cGEKIEVYUE9SVF9TWU1CT0wocHV0X3BhZ2VzX2xpc3QpOwogCiAvKgorICogcGFnZXZlY19tb3Zl
X3RhaWwoKSBtdXN0IGJlIGNhbGxlZCB3aXRoIElSUSBkaXNhYmxlZC4gCisgKiBPdGhlcndpc2Ug
dGhpcyBtYXkgY2F1c2UgbmFzdHkgcmFjZXMuCisgKi8KK3N0YXRpYyB2b2lkIHBhZ2V2ZWNfbW92
ZV90YWlsKHN0cnVjdCBwYWdldmVjICpwdmVjKQoreworCWludCBpOworCWludCBwZ21vdmVkID0g
MDsKKwlzdHJ1Y3Qgem9uZSAqem9uZSA9IE5VTEw7CisJdW5zaWduZWQgbG9uZyBmbGFncyA9IDA7
CisKKwlmb3IgKGkgPSAwOyBpIDwgcGFnZXZlY19jb3VudChwdmVjKTsgaSsrKSB7CisJCXN0cnVj
dCBwYWdlICpwYWdlID0gcHZlYy0+cGFnZXNbaV07CisJCXN0cnVjdCB6b25lICpwYWdlem9uZSA9
IHBhZ2Vfem9uZShwYWdlKTsKKworCQlpZiAocGFnZXpvbmUgIT0gem9uZSkgeworCQkJaWYgKHpv
bmUpCisJCQkJc3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmem9uZS0+bHJ1X2xvY2ssIGZsYWdzKTsK
KwkJCXpvbmUgPSBwYWdlem9uZTsKKwkJCXNwaW5fbG9ja19pcnFzYXZlKCZ6b25lLT5scnVfbG9j
aywgZmxhZ3MpOworCQl9CisJCWlmIChQYWdlTFJVKHBhZ2UpICYmICFQYWdlQWN0aXZlKHBhZ2Up
KSB7CisJCQlsaXN0X21vdmVfdGFpbCgmcGFnZS0+bHJ1LCAmem9uZS0+aW5hY3RpdmVfbGlzdCk7
CisJCQlwZ21vdmVkKys7CisJCX0KKwl9CisJaWYgKHpvbmUpCisJCXNwaW5fdW5sb2NrX2lycXJl
c3RvcmUoJnpvbmUtPmxydV9sb2NrLCBmbGFncyk7CisJX19jb3VudF92bV9ldmVudHMoUEdST1RB
VEVELCBwZ21vdmVkKTsKKwlyZWxlYXNlX3BhZ2VzKHB2ZWMtPnBhZ2VzLCBwdmVjLT5uciwgcHZl
Yy0+Y29sZCk7CisJcGFnZXZlY19yZWluaXQocHZlYyk7Cit9CisKK3N0YXRpYyBERUZJTkVfUEVS
X0NQVShzdHJ1Y3QgcGFnZXZlYywgcm90YXRlX3B2ZWNzKSA9IHsgMCwgfTsKKwordm9pZCBtb3Zl
X3RhaWxfcGFnZXMoKQoreworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7CisJc3RydWN0IHBhZ2V2ZWMg
KnB2ZWM7CisKKwlsb2NhbF9pcnFfc2F2ZShmbGFncyk7CisJcHZlYyA9ICZfX2dldF9jcHVfdmFy
KHJvdGF0ZV9wdmVjcyk7CisJaWYgKHBhZ2V2ZWNfY291bnQocHZlYykpCisJCXBhZ2V2ZWNfbW92
ZV90YWlsKHB2ZWMpOworCWxvY2FsX2lycV9yZXN0b3JlKGZsYWdzKTsKK30KKworLyoKICAqIFdy
aXRlYmFjayBpcyBhYm91dCB0byBlbmQgYWdhaW5zdCBhIHBhZ2Ugd2hpY2ggaGFzIGJlZW4gbWFy
a2VkIGZvciBpbW1lZGlhdGUKICAqIHJlY2xhaW0uICBJZiBpdCBzdGlsbCBhcHBlYXJzIHRvIGJl
IHJlY2xhaW1hYmxlLCBtb3ZlIGl0IHRvIHRoZSB0YWlsIG9mIHRoZQotICogaW5hY3RpdmUgbGlz
dC4gIFRoZSBwYWdlIHN0aWxsIGhhcyBQYWdlV3JpdGViYWNrIHNldCwgd2hpY2ggd2lsbCBwaW4g
aXQuCi0gKgotICogV2UgZG9uJ3QgZXhwZWN0IG1hbnkgcGFnZXMgdG8gY29tZSB0aHJvdWdoIGhl
cmUsIHNvIGRvbid0IGJvdGhlciBiYXRjaGluZwotICogdGhpbmdzIHVwLgotICoKLSAqIFRvIGF2
b2lkIHBsYWNpbmcgdGhlIHBhZ2UgYXQgdGhlIHRhaWwgb2YgdGhlIExSVSB3aGlsZSBQR193cml0
ZWJhY2sgaXMgc3RpbGwKLSAqIHNldCwgdGhpcyBmdW5jdGlvbiB3aWxsIGNsZWFyIFBHX3dyaXRl
YmFjayBiZWZvcmUgcGVyZm9ybWluZyB0aGUgcGFnZQotICogbW90aW9uLiAgRG8gdGhhdCBpbnNp
ZGUgdGhlIGxydSBsb2NrIGJlY2F1c2Ugb25jZSBQR193cml0ZWJhY2sgaXMgY2xlYXJlZAotICog
d2UgbWF5IG5vdCB0b3VjaCB0aGUgcGFnZS4KKyAqIGluYWN0aXZlIGxpc3QuCiAgKgogICogUmV0
dXJucyB6ZXJvIGlmIGl0IGNsZWFyZWQgUEdfd3JpdGViYWNrLgogICovCiBpbnQgcm90YXRlX3Jl
Y2xhaW1hYmxlX3BhZ2Uoc3RydWN0IHBhZ2UgKnBhZ2UpCiB7Ci0Jc3RydWN0IHpvbmUgKnpvbmU7
Ci0JdW5zaWduZWQgbG9uZyBmbGFnczsKKwlzdHJ1Y3QgcGFnZXZlYyAqcHZlYzsKIAogCWlmIChQ
YWdlTG9ja2VkKHBhZ2UpKQogCQlyZXR1cm4gMTsKQEAgLTEyMiwxNSArMTYwLDE1IEBAIGludCBy
b3RhdGVfcmVjbGFpbWFibGVfcGFnZShzdHJ1Y3QgcGFnZSAKIAlpZiAoIVBhZ2VMUlUocGFnZSkp
CiAJCXJldHVybiAxOwogCi0Jem9uZSA9IHBhZ2Vfem9uZShwYWdlKTsKLQlzcGluX2xvY2tfaXJx
c2F2ZSgmem9uZS0+bHJ1X2xvY2ssIGZsYWdzKTsKIAlpZiAoUGFnZUxSVShwYWdlKSAmJiAhUGFn
ZUFjdGl2ZShwYWdlKSkgewotCQlsaXN0X21vdmVfdGFpbCgmcGFnZS0+bHJ1LCAmem9uZS0+aW5h
Y3RpdmVfbGlzdCk7Ci0JCV9fY291bnRfdm1fZXZlbnQoUEdST1RBVEVEKTsKKwkJcGFnZV9jYWNo
ZV9nZXQocGFnZSk7CisJCXB2ZWMgPSAmX19nZXRfY3B1X3Zhcihyb3RhdGVfcHZlY3MpOworCQlp
ZiAoIXBhZ2V2ZWNfYWRkKHB2ZWMsIHBhZ2UpKQorCQkJcGFnZXZlY19tb3ZlX3RhaWwocHZlYyk7
CiAJfQogCWlmICghdGVzdF9jbGVhcl9wYWdlX3dyaXRlYmFjayhwYWdlKSkKIAkJQlVHKCk7Ci0J
c3Bpbl91bmxvY2tfaXJxcmVzdG9yZSgmem9uZS0+bHJ1X2xvY2ssIGZsYWdzKTsKKwogCXJldHVy
biAwOwogfQogCkBAIC00OTUsNiArNTMzLDIzIEBAIHN0YXRpYyBpbnQgY3B1X3N3YXBfY2FsbGJh
Y2soc3RydWN0IG5vdGkKIAl9CiAJcmV0dXJuIE5PVElGWV9PSzsKIH0KKworc3RhdGljIGludCBj
cHVfbW92ZXRhaWxfY2FsbGJhY2soc3RydWN0IG5vdGlmaWVyX2Jsb2NrICpuZmIsCisJCQkJIHVu
c2lnbmVkIGxvbmcgYWN0aW9uLCB2b2lkICpoY3B1KQoreworCXVuc2lnbmVkIGxvbmcgZmxhZ3M7
CisJc3RydWN0IHBhZ2V2ZWMgKnB2ZWM7CisKKwlpZiAoYWN0aW9uID09IENQVV9ERUFEIHx8IGFj
dGlvbiA9PSBDUFVfREVBRF9GUk9aRU4pIHsKKwkJbG9jYWxfaXJxX3NhdmUoZmxhZ3MpOworCQlw
dmVjID0gJnBlcl9jcHUocm90YXRlX3B2ZWNzLCAobG9uZyloY3B1KTsKKwkJaWYgKHBhZ2V2ZWNf
Y291bnQocHZlYykpCisJCQlwYWdldmVjX21vdmVfdGFpbChwdmVjKTsKKwkJbG9jYWxfaXJxX3Jl
c3RvcmUoZmxhZ3MpOworCX0KKworCXJldHVybiBOT1RJRllfT0s7Cit9CiAjZW5kaWYgLyogQ09O
RklHX0hPVFBMVUdfQ1BVICovCiAjZW5kaWYgLyogQ09ORklHX1NNUCAqLwogCkBAIC01MTYsNSAr
NTcxLDYgQEAgdm9pZCBfX2luaXQgc3dhcF9zZXR1cCh2b2lkKQogCSAqLwogI2lmZGVmIENPTkZJ
R19IT1RQTFVHX0NQVQogCWhvdGNwdV9ub3RpZmllcihjcHVfc3dhcF9jYWxsYmFjaywgMCk7CisJ
aG90Y3B1X25vdGlmaWVyKGNwdV9tb3ZldGFpbF9jYWxsYmFjaywgMCk7CiAjZW5kaWYKIH0KZGlm
ZiAtTnJ1cCBsaW51eC0yLjYuMjMtcmM2Lm9yZy9tbS92bXNjYW4uYyBsaW51eC0yLjYuMjMtcmM2
L21tL3Ztc2Nhbi5jCi0tLSBsaW51eC0yLjYuMjMtcmM2Lm9yZy9tbS92bXNjYW4uYwkyMDA3LTA5
LTE0IDE2OjQ5OjU3LjAwMDAwMDAwMCArMDkwMAorKysgbGludXgtMi42LjIzLXJjNi9tbS92bXNj
YW4uYwkyMDA3LTA5LTE0IDE2OjU4OjQ4LjAwMDAwMDAwMCArMDkwMApAQCAtNzkyLDYgKzc5Miw3
IEBAIHN0YXRpYyB1bnNpZ25lZCBsb25nIHNocmlua19pbmFjdGl2ZV9saXMKIAogCXBhZ2V2ZWNf
aW5pdCgmcHZlYywgMSk7CiAKKwltb3ZlX3RhaWxfcGFnZXMoKTsKIAlscnVfYWRkX2RyYWluKCk7
CiAJc3Bpbl9sb2NrX2lycSgmem9uZS0+bHJ1X2xvY2spOwogCWRvIHsK
--=====================_36019476==_--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
