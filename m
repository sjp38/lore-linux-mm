Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id D2DC46B0081
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 02:34:51 -0400 (EDT)
Subject: [PATCH] futex: bugfix for futex-key conflict when futex use hugepage
MIME-Version: 1.0
Message-ID: <OF297FCC94.0296B080-ON48257B47.002183F6-48257B47.00241D40@zte.com.cn>
From: jiang.biao2@zte.com.cn
Date: Mon, 8 Apr 2013 14:34:06 +0800
Content-Type: multipart/alternative; boundary="=_alternative 00241D3E48257B47_="
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Zhang Yi <zhang.yi20@zte.com.cn>, Ma Chenggong <ma.chenggong@zte.com.cn>, Liu Dong <liu.dong3@zte.com.cn>, Cui Yunfeng <cui.yunfeng@zte.com.cn>, Lu Zhongjun <lu.zhongjun@zte.com.cn>, Jiang Biao <jiang.biao2@zte.com.cn>

This is a multipart message in MIME format.

--=_alternative 00241D3E48257B47_=
Content-Type: text/plain; charset="US-ASCII"

From: Zhang Yi <zhang.yi20@zte.com.cn>

The futex-keys of processes share futex determined by page-offset, 
mapping-host, and 
mapping-index of the user space address.
User appications using hugepage for futex may lead to futex-key conflict. 
Assume there 
are two or more futexes in diffrent normal pages of the hugepage, and each 
futex has 
the same offset in its normal page, causing all the futexes have the same 
futex-key. 
In that case, futex may not work well.

This patch adds the normal page index in the compound page into the offset 
of futex-key.

Steps to reproduce the bug:
1. The 1st thread map a file of hugetlbfs, and use the return address as 
the 1st mutex's 
address, and use the return address with PAGE_SIZE added as the 2nd 
mutex's address;
2. The 1st thread initialize the two mutexes with pshared attribute, and 
lock the two mutexes.
3. The 1st thread create the 2nd thread, and the 2nd thread block on the 
1st mutex.
4. The 1st thread create the 3rd thread, and the 3rd thread block on the 
2nd mutex.
5. The 1st thread unlock the 2nd mutex, the 3rd thread can not take the 
2nd mutex, and 
may block forever.

Signed-off-by: Zhang Yi <zhang.yi20@zte.com.cn>
Tested-by: Ma Chenggong <ma.chenggong@zte.com.cn>
Reviewed-by: Liu Dong <liu.dong3@zte.com.cn>
Reviewed-by: Cui Yunfeng <cui.yunfeng@zte.com.cn>
Reviewed-by: Lu Zhongjun <lu.zhongjun@zte.com.cn>
Reviewed-by: Jiang Biao <jiang.biao2@zte.com.cn>

diff -uprN orig/linux-3.9-rc5/include/linux/mm.h 
new/linux-3.9-rc5/include/linux/mm.h
--- orig/linux-3.9-rc5/include/linux/mm.h       2013-03-31 
22:12:43.000000000 +0000
+++ new/linux-3.9-rc5/include/linux/mm.h        2013-04-03 
11:01:19.671403000 +0000
@@ -502,6 +502,20 @@ static inline void set_compound_order(st
        page[1].lru.prev = (void *)order;
 }
 
+static inline void set_page_compound_index(struct page *page, int index)
+{
+       if (PageHead(page))
+               return;
+       page->index = index;
+}
+
+static inline int get_page_compound_index(struct page *page)
+{
+       if (PageHead(page))
+               return 0;
+       return page->index;
+}
+
 #ifdef CONFIG_MMU
 /*
  * Do pte_mkwrite, but only if the vma says VM_WRITE.  We do this when
diff -uprN orig/linux-3.9-rc5/kernel/futex.c 
new/linux-3.9-rc5/kernel/futex.c
--- orig/linux-3.9-rc5/kernel/futex.c   2013-03-31 22:12:43.000000000 
+0000
+++ new/linux-3.9-rc5/kernel/futex.c    2013-04-03 11:03:42.168663000 
+0000
@@ -239,7 +239,7 @@ get_futex_key(u32 __user *uaddr, int fsh
        unsigned long address = (unsigned long)uaddr;
        struct mm_struct *mm = current->mm;
        struct page *page, *page_head;
-       int err, ro = 0;
+       int err, ro = 0, compound_index = 0;
 
        /*
         * The futex address must be "naturally" aligned.
@@ -299,6 +299,7 @@ again:
                         * freed from under us.
                         */
                        if (page != page_head) {
+                               compound_index = 
get_page_compound_index(page);
                                get_page(page_head);
                                put_page(page);
                        }
@@ -311,6 +312,7 @@ again:
 #else
        page_head = compound_head(page);
        if (page != page_head) {
+               compound_index = get_page_compound_index(page);
                get_page(page_head);
                put_page(page);
        }
@@ -363,7 +365,7 @@ again:
                key->private.mm = mm;
                key->private.address = address;
        } else {
-               key->both.offset |= FUT_OFF_INODE; /* inode-based key */
+               key->both.offset |= (compound_index << PAGE_SHIFT) | 
FUT_OFF_INODE; /* inode-based key */
                key->shared.inode = page_head->mapping->host;
                key->shared.pgoff = page_head->index;
        }
diff -uprN orig/linux-3.9-rc5/mm/hugetlb.c new/linux-3.9-rc5/mm/hugetlb.c
--- orig/linux-3.9-rc5/mm/hugetlb.c     2013-03-31 22:12:43.000000000 
+0000
+++ new/linux-3.9-rc5/mm/hugetlb.c      2013-04-03 11:02:10.556132000 
+0000
@@ -667,6 +667,7 @@ static void prep_compound_gigantic_page(
        for (i = 1; i < nr_pages; i++, p = mem_map_next(p, page, i)) {
                __SetPageTail(p);
                set_page_count(p, 0);
+               set_page_compound_index(p, i);
                p->first_page = page;
        }
 }
diff -uprN orig/linux-3.9-rc5/mm/page_alloc.c 
new/linux-3.9-rc5/mm/page_alloc.c
--- orig/linux-3.9-rc5/mm/page_alloc.c  2013-03-31 22:12:43.000000000 
+0000
+++ new/linux-3.9-rc5/mm/page_alloc.c   2013-04-03 11:01:47.933353000 
+0000
@@ -361,6 +361,7 @@ void prep_compound_page(struct page *pag
                struct page *p = page + i;
                __SetPageTail(p);
                set_page_count(p, 0);
+               set_page_compound_index(p, i);
                p->first_page = page;
        }
 }
--------------------------------------------------------
ZTE Information Security Notice: The information contained in this mail (and any attachment transmitted herewith) is privileged and confidential and is intended for the exclusive use of the addressee(s).  If you are not an intended recipient, any disclosure, reproduction, distribution or other dissemination or use of the information contained is strictly prohibited.  If you have received this mail in error, please delete it and notify us immediately.

--=_alternative 00241D3E48257B47_=
Content-Type: text/html; charset="GB2312"
Content-Transfer-Encoding: base64

DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9IsvOzOUiPkZyb206IFpoYW5nIFlpICZsdDt6aGFuZy55
aTIwQHp0ZS5jb20uY24mZ3Q7PC9mb250Pg0KPGJyPg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJz
YW5zLXNlcmlmIj5UaGUgZnV0ZXgta2V5cyBvZiBwcm9jZXNzZXMgc2hhcmUgZnV0ZXgNCmRldGVy
bWluZWQgYnkgcGFnZS1vZmZzZXQsIG1hcHBpbmctaG9zdCwgYW5kIDwvZm9udD4NCjxicj48Zm9u
dCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+bWFwcGluZy1pbmRleCBvZiB0aGUgdXNlciBzcGFj
ZSBhZGRyZXNzLjwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+VXNl
ciBhcHBpY2F0aW9ucyB1c2luZyBodWdlcGFnZSBmb3INCmZ1dGV4IG1heSBsZWFkIHRvIGZ1dGV4
LWtleSBjb25mbGljdC4gQXNzdW1lIHRoZXJlIDwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFj
ZT0ic2Fucy1zZXJpZiI+YXJlIHR3byBvciBtb3JlIGZ1dGV4ZXMgaW4gZGlmZnJlbnQNCm5vcm1h
bCBwYWdlcyBvZiB0aGUgaHVnZXBhZ2UsIGFuZCBlYWNoIGZ1dGV4IGhhcyA8L2ZvbnQ+DQo8YnI+
PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPnRoZSBzYW1lIG9mZnNldCBpbiBpdHMgbm9y
bWFsIHBhZ2UsDQpjYXVzaW5nIGFsbCB0aGUgZnV0ZXhlcyBoYXZlIHRoZSBzYW1lIGZ1dGV4LWtl
eS4gPC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj5JbiB0aGF0IGNh
c2UsIGZ1dGV4IG1heSBub3Qgd29yayB3ZWxsLjwvZm9udD4NCjxicj4NCjxicj48Zm9udCBzaXpl
PTIgZmFjZT0ic2Fucy1zZXJpZiI+VGhpcyBwYXRjaCBhZGRzIHRoZSBub3JtYWwgcGFnZSBpbmRl
eA0KaW4gdGhlIGNvbXBvdW5kIHBhZ2UgaW50byB0aGUgb2Zmc2V0IG9mIGZ1dGV4LWtleS48L2Zv
bnQ+DQo8YnI+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPlN0ZXBzIHRvIHJl
cHJvZHVjZSB0aGUgYnVnOjwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJp
ZiI+MS4gVGhlIDFzdCB0aHJlYWQgbWFwIGEgZmlsZSBvZiBodWdldGxiZnMsDQphbmQgdXNlIHRo
ZSByZXR1cm4gYWRkcmVzcyBhcyB0aGUgMXN0IG11dGV4J3MgPC9mb250Pg0KPGJyPjxmb250IHNp
emU9MiBmYWNlPSJzYW5zLXNlcmlmIj5hZGRyZXNzLCBhbmQgdXNlIHRoZSByZXR1cm4gYWRkcmVz
cw0Kd2l0aCBQQUdFX1NJWkUgYWRkZWQgYXMgdGhlIDJuZCBtdXRleCdzIGFkZHJlc3M7PC9mb250
Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4yLiBUaGUgMXN0IHRocmVhZCBp
bml0aWFsaXplIHRoZSB0d28NCm11dGV4ZXMgd2l0aCBwc2hhcmVkIGF0dHJpYnV0ZSwgYW5kIGxv
Y2sgdGhlIHR3byBtdXRleGVzLjwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1z
ZXJpZiI+My4gVGhlIDFzdCB0aHJlYWQgY3JlYXRlIHRoZSAybmQgdGhyZWFkLA0KYW5kIHRoZSAy
bmQgdGhyZWFkIGJsb2NrIG9uIHRoZSAxc3QgbXV0ZXguPC9mb250Pg0KPGJyPjxmb250IHNpemU9
MiBmYWNlPSJzYW5zLXNlcmlmIj40LiBUaGUgMXN0IHRocmVhZCBjcmVhdGUgdGhlIDNyZCB0aHJl
YWQsDQphbmQgdGhlIDNyZCB0aHJlYWQgYmxvY2sgb24gdGhlIDJuZCBtdXRleC48L2ZvbnQ+DQo8
YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPjUuIFRoZSAxc3QgdGhyZWFkIHVubG9j
ayB0aGUgMm5kIG11dGV4LA0KdGhlIDNyZCB0aHJlYWQgY2FuIG5vdCB0YWtlIHRoZSAybmQgbXV0
ZXgsIGFuZCA8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPm1heSBi
bG9jayBmb3JldmVyLjwvZm9udD4NCjxicj4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0iy87M5SI+
U2lnbmVkLW9mZi1ieTogWmhhbmcgWWkgJmx0O3poYW5nLnlpMjBAenRlLmNvbS5jbiZndDs8L2Zv
bnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9IsvOzOUiPlRlc3RlZC1ieTogTWEgQ2hlbmdnb25n
ICZsdDttYS5jaGVuZ2dvbmdAenRlLmNvbS5jbiZndDs8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0y
IGZhY2U9IsvOzOUiPlJldmlld2VkLWJ5OiBMaXUgRG9uZyAmbHQ7bGl1LmRvbmczQHp0ZS5jb20u
Y24mZ3Q7PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSLLzszlIj5SZXZpZXdlZC1ieTog
Q3VpIFl1bmZlbmcgJmx0O2N1aS55dW5mZW5nQHp0ZS5jb20uY24mZ3Q7PC9mb250Pg0KPGJyPjxm
b250IHNpemU9MiBmYWNlPSLLzszlIj5SZXZpZXdlZC1ieTogTHUgWmhvbmdqdW4gJmx0O2x1Lnpo
b25nanVuQHp0ZS5jb20uY24mZ3Q7PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSLLzszl
Ij5SZXZpZXdlZC1ieTogSmlhbmcgQmlhbyAmbHQ7amlhbmcuYmlhbzJAenRlLmNvbS5jbiZndDs8
L2ZvbnQ+DQo8YnI+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPmRpZmYgLXVw
ck4gb3JpZy9saW51eC0zLjktcmM1L2luY2x1ZGUvbGludXgvbW0uaA0KbmV3L2xpbnV4LTMuOS1y
YzUvaW5jbHVkZS9saW51eC9tbS5oPC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5z
LXNlcmlmIj4tLS0gb3JpZy9saW51eC0zLjktcmM1L2luY2x1ZGUvbGludXgvbW0uaA0KJm5ic3A7
ICZuYnNwOyAmbmJzcDsgJm5ic3A7MjAxMy0wMy0zMSAyMjoxMjo0My4wMDAwMDAwMDAgKzAwMDA8
L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPisrKyBuZXcvbGludXgt
My45LXJjNS9pbmNsdWRlL2xpbnV4L21tLmgNCiZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOzIw
MTMtMDQtMDMgMTE6MDE6MTkuNjcxNDAzMDAwICswMDAwPC9mb250Pg0KPGJyPjxmb250IHNpemU9
MiBmYWNlPSJzYW5zLXNlcmlmIj5AQCAtNTAyLDYgKzUwMiwyMCBAQCBzdGF0aWMgaW5saW5lIHZv
aWQNCnNldF9jb21wb3VuZF9vcmRlcihzdDwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0i
c2Fucy1zZXJpZiI+Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwO3BhZ2VbMV0ubHJ1
LnByZXYNCj0gKHZvaWQgKilvcmRlcjs8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNh
bnMtc2VyaWYiPiZuYnNwO308L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2Vy
aWYiPiZuYnNwOzwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+K3N0
YXRpYyBpbmxpbmUgdm9pZCBzZXRfcGFnZV9jb21wb3VuZF9pbmRleChzdHJ1Y3QNCnBhZ2UgKnBh
Z2UsIGludCBpbmRleCk8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYi
Pit7PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4rICZuYnNwOyAm
bmJzcDsgJm5ic3A7ICZuYnNwO2lmDQooUGFnZUhlYWQocGFnZSkpPC9mb250Pg0KPGJyPjxmb250
IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4rICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOw0K
Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7cmV0dXJuOzwvZm9udD4NCjxicj48Zm9udCBzaXpl
PTIgZmFjZT0ic2Fucy1zZXJpZiI+KyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDtwYWdlLSZn
dDtpbmRleA0KPSBpbmRleDs8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2Vy
aWYiPit9PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4rPC9mb250
Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4rc3RhdGljIGlubGluZSBpbnQg
Z2V0X3BhZ2VfY29tcG91bmRfaW5kZXgoc3RydWN0DQpwYWdlICpwYWdlKTwvZm9udD4NCjxicj48
Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+K3s8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0y
IGZhY2U9InNhbnMtc2VyaWYiPisgJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7aWYNCihQYWdl
SGVhZChwYWdlKSk8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPisg
Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7DQombmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDty
ZXR1cm4gMDs8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPisgJm5i
c3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7cmV0dXJuDQpwYWdlLSZndDtpbmRleDs8L2ZvbnQ+DQo8
YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPit9PC9mb250Pg0KPGJyPjxmb250IHNp
emU9MiBmYWNlPSJzYW5zLXNlcmlmIj4rPC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJz
YW5zLXNlcmlmIj4mbmJzcDsjaWZkZWYgQ09ORklHX01NVTwvZm9udD4NCjxicj48Zm9udCBzaXpl
PTIgZmFjZT0ic2Fucy1zZXJpZiI+Jm5ic3A7Lyo8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZh
Y2U9InNhbnMtc2VyaWYiPiZuYnNwOyAqIERvIHB0ZV9ta3dyaXRlLCBidXQgb25seSBpZg0KdGhl
IHZtYSBzYXlzIFZNX1dSSVRFLiAmbmJzcDtXZSBkbyB0aGlzIHdoZW48L2ZvbnQ+DQo8YnI+PGZv
bnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPmRpZmYgLXVwck4gb3JpZy9saW51eC0zLjktcmM1
L2tlcm5lbC9mdXRleC5jDQpuZXcvbGludXgtMy45LXJjNS9rZXJuZWwvZnV0ZXguYzwvZm9udD4N
Cjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+LS0tIG9yaWcvbGludXgtMy45LXJj
NS9rZXJuZWwvZnV0ZXguYw0KJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7MjAxMy0wMy0zMSAy
MjoxMjo0My4wMDAwMDAwMDAgKzAwMDA8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNh
bnMtc2VyaWYiPisrKyBuZXcvbGludXgtMy45LXJjNS9rZXJuZWwvZnV0ZXguYw0KJm5ic3A7ICZu
YnNwOyAmbmJzcDsgJm5ic3A7MjAxMy0wNC0wMyAxMTowMzo0Mi4xNjg2NjMwMDAgKzAwMDA8L2Zv
bnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPkBAIC0yMzksNyArMjM5LDcg
QEAgZ2V0X2Z1dGV4X2tleSh1MzINCl9fdXNlciAqdWFkZHIsIGludCBmc2g8L2ZvbnQ+DQo8YnI+
PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPiZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNw
OyAmbmJzcDt1bnNpZ25lZA0KbG9uZyBhZGRyZXNzID0gKHVuc2lnbmVkIGxvbmcpdWFkZHI7PC9m
b250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4mbmJzcDsgJm5ic3A7ICZu
YnNwOyAmbmJzcDsgJm5ic3A7c3RydWN0DQptbV9zdHJ1Y3QgKm1tID0gY3VycmVudC0mZ3Q7bW07
PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4mbmJzcDsgJm5ic3A7
ICZuYnNwOyAmbmJzcDsgJm5ic3A7c3RydWN0DQpwYWdlICpwYWdlLCAqcGFnZV9oZWFkOzwvZm9u
dD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+LSAmbmJzcDsgJm5ic3A7ICZu
YnNwOyAmbmJzcDtpbnQNCmVyciwgcm8gPSAwOzwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFj
ZT0ic2Fucy1zZXJpZiI+KyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDtpbnQNCmVyciwgcm8g
PSAwLCBjb21wb3VuZF9pbmRleCA9IDA7PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJz
YW5zLXNlcmlmIj4mbmJzcDs8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2Vy
aWYiPiZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsvKjwvZm9udD4NCjxicj48Zm9u
dCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZu
YnNwOw0KKiBUaGUgZnV0ZXggYWRkcmVzcyBtdXN0IGJlICZxdW90O25hdHVyYWxseSZxdW90OyBh
bGlnbmVkLjwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+QEAgLTI5
OSw2ICsyOTksNyBAQCBhZ2Fpbjo8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMt
c2VyaWYiPiZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsNCiZuYnNwOyAmbmJzcDsg
Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsNCiogZnJlZWQgZnJvbSB1
bmRlciB1cy48L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPiZuYnNw
OyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsNCiZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNw
OyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsNCiovPC9mb250Pg0KPGJyPjxmb250IHNpemU9
MiBmYWNlPSJzYW5zLXNlcmlmIj4mbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7DQom
bmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7aWYN
CihwYWdlICE9IHBhZ2VfaGVhZCkgezwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fu
cy1zZXJpZiI+KyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsNCiZuYnNwOyAmbmJzcDsgJm5i
c3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsNCiZuYnNwOyAmbmJzcDsgJm5i
c3A7ICZuYnNwO2NvbXBvdW5kX2luZGV4ID0gZ2V0X3BhZ2VfY29tcG91bmRfaW5kZXgocGFnZSk7
PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4mbmJzcDsgJm5ic3A7
ICZuYnNwOyAmbmJzcDsgJm5ic3A7DQombmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7
ICZuYnNwOyAmbmJzcDsgJm5ic3A7DQombmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDtnZXRfcGFn
ZShwYWdlX2hlYWQpOzwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+
Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOw0KJm5ic3A7ICZuYnNwOyAmbmJzcDsg
Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOw0KJm5ic3A7ICZuYnNwOyAmbmJzcDsg
Jm5ic3A7cHV0X3BhZ2UocGFnZSk7PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5z
LXNlcmlmIj4mbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7DQombmJzcDsgJm5ic3A7
ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7fTwvZm9udD4NCjxicj48
Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+QEAgLTMxMSw2ICszMTIsNyBAQCBhZ2Fpbjo8
L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPiZuYnNwOyNlbHNlPC9m
b250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4mbmJzcDsgJm5ic3A7ICZu
YnNwOyAmbmJzcDsgJm5ic3A7cGFnZV9oZWFkDQo9IGNvbXBvdW5kX2hlYWQocGFnZSk7PC9mb250
Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4mbmJzcDsgJm5ic3A7ICZuYnNw
OyAmbmJzcDsgJm5ic3A7aWYNCihwYWdlICE9IHBhZ2VfaGVhZCkgezwvZm9udD4NCjxicj48Zm9u
dCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+KyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsN
CiZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwO2NvbXBvdW5kX2luZGV4ID0gZ2V0X3BhZ2VfY29t
cG91bmRfaW5kZXgocGFnZSk7PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNl
cmlmIj4mbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7DQombmJzcDsgJm5ic3A7ICZu
YnNwOyAmbmJzcDtnZXRfcGFnZShwYWdlX2hlYWQpOzwvZm9udD4NCjxicj48Zm9udCBzaXplPTIg
ZmFjZT0ic2Fucy1zZXJpZiI+Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOw0KJm5i
c3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7cHV0X3BhZ2UocGFnZSk7PC9mb250Pg0KPGJyPjxmb250
IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4mbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5i
c3A7fTwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+QEAgLTM2Myw3
ICszNjUsNyBAQCBhZ2Fpbjo8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2Vy
aWYiPiZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsNCiZuYnNwOyAmbmJzcDsgJm5i
c3A7ICZuYnNwO2tleS0mZ3Q7cHJpdmF0ZS5tbSA9IG1tOzwvZm9udD4NCjxicj48Zm9udCBzaXpl
PTIgZmFjZT0ic2Fucy1zZXJpZiI+Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOw0K
Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7a2V5LSZndDtwcml2YXRlLmFkZHJlc3MgPSBhZGRy
ZXNzOzwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+Jm5ic3A7ICZu
YnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwO30NCmVsc2UgezwvZm9udD4NCjxicj48Zm9udCBzaXpl
PTIgZmFjZT0ic2Fucy1zZXJpZiI+LSAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsNCiZuYnNw
OyAmbmJzcDsgJm5ic3A7ICZuYnNwO2tleS0mZ3Q7Ym90aC5vZmZzZXQgfD0gRlVUX09GRl9JTk9E
RTsNCi8qIGlub2RlLWJhc2VkIGtleSAqLzwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0i
c2Fucy1zZXJpZiI+KyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsNCiZuYnNwOyAmbmJzcDsg
Jm5ic3A7ICZuYnNwO2tleS0mZ3Q7Ym90aC5vZmZzZXQgfD0gKGNvbXBvdW5kX2luZGV4DQombHQ7
Jmx0OyBQQUdFX1NISUZUKSB8IEZVVF9PRkZfSU5PREU7IC8qIGlub2RlLWJhc2VkIGtleSAqLzwv
Zm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+Jm5ic3A7ICZuYnNwOyAm
bmJzcDsgJm5ic3A7ICZuYnNwOw0KJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7a2V5LSZndDtz
aGFyZWQuaW5vZGUgPSBwYWdlX2hlYWQtJmd0O21hcHBpbmctJmd0O2hvc3Q7PC9mb250Pg0KPGJy
Pjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4mbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJz
cDsgJm5ic3A7DQombmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDtrZXktJmd0O3NoYXJlZC5wZ29m
ZiA9IHBhZ2VfaGVhZC0mZ3Q7aW5kZXg7PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJz
YW5zLXNlcmlmIj4mbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7fTwvZm9udD4NCjxi
cj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+ZGlmZiAtdXByTiBvcmlnL2xpbnV4LTMu
OS1yYzUvbW0vaHVnZXRsYi5jDQpuZXcvbGludXgtMy45LXJjNS9tbS9odWdldGxiLmM8L2ZvbnQ+
DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPi0tLSBvcmlnL2xpbnV4LTMuOS1y
YzUvbW0vaHVnZXRsYi5jDQombmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsyMDEzLTAzLTMxIDIy
OjEyOjQzLjAwMDAwMDAwMCArMDAwMDwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fu
cy1zZXJpZiI+KysrIG5ldy9saW51eC0zLjktcmM1L21tL2h1Z2V0bGIuYyAmbmJzcDsNCiZuYnNw
OyAmbmJzcDsgJm5ic3A7MjAxMy0wNC0wMyAxMTowMjoxMC41NTYxMzIwMDAgKzAwMDA8L2ZvbnQ+
DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPkBAIC02NjcsNiArNjY3LDcgQEAg
c3RhdGljIHZvaWQgcHJlcF9jb21wb3VuZF9naWdhbnRpY19wYWdlKDwvZm9udD4NCjxicj48Zm9u
dCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZu
YnNwO2Zvcg0KKGkgPSAxOyBpICZsdDsgbnJfcGFnZXM7IGkrKywgcCA9IG1lbV9tYXBfbmV4dChw
LCBwYWdlLCBpKSkgezwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+
Jm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOw0KJm5ic3A7ICZuYnNwOyAmbmJzcDsg
Jm5ic3A7X19TZXRQYWdlVGFpbChwKTs8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNh
bnMtc2VyaWYiPiZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsNCiZuYnNwOyAmbmJz
cDsgJm5ic3A7ICZuYnNwO3NldF9wYWdlX2NvdW50KHAsIDApOzwvZm9udD4NCjxicj48Zm9udCBz
aXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+KyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsNCiZu
YnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwO3NldF9wYWdlX2NvbXBvdW5kX2luZGV4KHAsIGkpOzwv
Zm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+Jm5ic3A7ICZuYnNwOyAm
bmJzcDsgJm5ic3A7ICZuYnNwOw0KJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7cC0mZ3Q7Zmly
c3RfcGFnZSA9IHBhZ2U7PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlm
Ij4mbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7fTwvZm9udD4NCjxicj48Zm9udCBz
aXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+Jm5ic3A7fTwvZm9udD4NCjxicj48Zm9udCBzaXplPTIg
ZmFjZT0ic2Fucy1zZXJpZiI+ZGlmZiAtdXByTiBvcmlnL2xpbnV4LTMuOS1yYzUvbW0vcGFnZV9h
bGxvYy5jDQpuZXcvbGludXgtMy45LXJjNS9tbS9wYWdlX2FsbG9jLmM8L2ZvbnQ+DQo8YnI+PGZv
bnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPi0tLSBvcmlnL2xpbnV4LTMuOS1yYzUvbW0vcGFn
ZV9hbGxvYy5jDQombmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsyMDEzLTAzLTMxIDIyOjEyOjQz
LjAwMDAwMDAwMCArMDAwMDwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJp
ZiI+KysrIG5ldy9saW51eC0zLjktcmM1L21tL3BhZ2VfYWxsb2MuYw0KJm5ic3A7ICZuYnNwOyAm
bmJzcDsgJm5ic3A7MjAxMy0wNC0wMyAxMTowMTo0Ny45MzMzNTMwMDAgKzAwMDA8L2ZvbnQ+DQo8
YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPkBAIC0zNjEsNiArMzYxLDcgQEAgdm9p
ZCBwcmVwX2NvbXBvdW5kX3BhZ2Uoc3RydWN0DQpwYWdlICpwYWc8L2ZvbnQ+DQo8YnI+PGZvbnQg
c2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPiZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJz
cDsNCiZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwO3N0cnVjdCBwYWdlICpwID0gcGFnZSArIGk7
PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4mbmJzcDsgJm5ic3A7
ICZuYnNwOyAmbmJzcDsgJm5ic3A7DQombmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDtfX1NldFBh
Z2VUYWlsKHApOzwvZm9udD4NCjxicj48Zm9udCBzaXplPTIgZmFjZT0ic2Fucy1zZXJpZiI+Jm5i
c3A7ICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOw0KJm5ic3A7ICZuYnNwOyAmbmJzcDsgJm5i
c3A7c2V0X3BhZ2VfY291bnQocCwgMCk7PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJz
YW5zLXNlcmlmIj4rICZuYnNwOyAmbmJzcDsgJm5ic3A7ICZuYnNwOw0KJm5ic3A7ICZuYnNwOyAm
bmJzcDsgJm5ic3A7c2V0X3BhZ2VfY29tcG91bmRfaW5kZXgocCwgaSk7PC9mb250Pg0KPGJyPjxm
b250IHNpemU9MiBmYWNlPSJzYW5zLXNlcmlmIj4mbmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDsg
Jm5ic3A7DQombmJzcDsgJm5ic3A7ICZuYnNwOyAmbmJzcDtwLSZndDtmaXJzdF9wYWdlID0gcGFn
ZTs8L2ZvbnQ+DQo8YnI+PGZvbnQgc2l6ZT0yIGZhY2U9InNhbnMtc2VyaWYiPiZuYnNwOyAmbmJz
cDsgJm5ic3A7ICZuYnNwOyAmbmJzcDt9PC9mb250Pg0KPGJyPjxmb250IHNpemU9MiBmYWNlPSJz
YW5zLXNlcmlmIj4mbmJzcDt9PC9mb250Pg0KDQo8YnI+PHByZT48Zm9udCBjb2xvcj0iYmx1ZSI+
DQotLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0t
LQ0KWlRFIEluZm9ybWF0aW9uIFNlY3VyaXR5IE5vdGljZTogVGhlIGluZm9ybWF0aW9uIGNvbnRh
aW5lZCBpbiB0aGlzIG1haWwgKGFuZCBhbnkgYXR0YWNobWVudCB0cmFuc21pdHRlZCBoZXJld2l0
aCkgaXMgcHJpdmlsZWdlZCBhbmQgY29uZmlkZW50aWFsIGFuZCBpcyBpbnRlbmRlZCBmb3IgdGhl
IGV4Y2x1c2l2ZSB1c2Ugb2YgdGhlIGFkZHJlc3NlZShzKS4gIElmIHlvdSBhcmUgbm90IGFuIGlu
dGVuZGVkIHJlY2lwaWVudCwgYW55IGRpc2Nsb3N1cmUsIHJlcHJvZHVjdGlvbiwgZGlzdHJpYnV0
aW9uIG9yIG90aGVyIGRpc3NlbWluYXRpb24gb3IgdXNlIG9mIHRoZSBpbmZvcm1hdGlvbiBjb250
YWluZWQgaXMgc3RyaWN0bHkgcHJvaGliaXRlZC4gIElmIHlvdSBoYXZlIHJlY2VpdmVkIHRoaXMg
bWFpbCBpbiBlcnJvciwgcGxlYXNlIGRlbGV0ZSBpdCBhbmQgbm90aWZ5IHVzIGltbWVkaWF0ZWx5
Lg0KDQo8L2ZvbnQ+PC9wcmU+PGJyPg0K

--=_alternative 00241D3E48257B47_=--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
