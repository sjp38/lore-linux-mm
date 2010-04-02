Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id E9C516B020B
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 23:51:38 -0400 (EDT)
Received: from il06vts01.mot.com (il06vts01.mot.com [129.188.137.141])
	by mdgate1.mot.com (8.14.3/8.14.3) with SMTP id o323ppxW029495
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 21:51:51 -0600 (MDT)
Received: from mail-iw0-f184.google.com (mail-iw0-f184.google.com [209.85.223.184])
	by mdgate1.mot.com (8.14.3/8.14.3) with ESMTP id o323l8PO028790
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=OK)
	for <linux-mm@kvack.org>; Thu, 1 Apr 2010 21:51:50 -0600 (MDT)
Received: by mail-iw0-f184.google.com with SMTP id 14so254835iwn.22
        for <linux-mm@kvack.org>; Thu, 01 Apr 2010 20:51:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
References: <i2i5f4a33681003312105m4cd42e9ayfe35cc0988c401b6@mail.gmail.com>
Date: Fri, 2 Apr 2010 11:51:33 +0800
Message-ID: <g2g5f4a33681004012051wedea9538w9da89e210b731422@mail.gmail.com>
Subject: Re: [Question] race condition in mm/page_alloc.c regarding page->lru?
From: TAO HU <tghk48@motorola.com>
Content-Type: multipart/mixed; boundary=001636cd737f2f8f39048338e541
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, "Ye Yuan.Bo-A22116" <yuan-bo.ye@motorola.com>, Chang Qing-A21550 <Qing.Chang@motorola.com>, linux-arm-kernel@lists.infradead.org
List-ID: <linux-mm.kvack.org>

--001636cd737f2f8f39048338e541
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

2 patches related to page_alloc.c were applied.
Does anyone see a connection between the 2 patches and the panic?
NOTE: the full patches are attached.

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index a596bfd..34a29e2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2551,6 +2551,20 @@ static inline unsigned long
wait_table_bits(unsigned long size)
 #define LONG_ALIGN(x) (((x)+(sizeof(long))-1)&~((sizeof(long))-1))

 /*
+ * Check if a pageblock contains reserved pages
+ */
+static int pageblock_is_reserved(unsigned long start_pfn)
+{
+	unsigned long end_pfn =3D start_pfn + pageblock_nr_pages;
+	unsigned long pfn;
+
+	for (pfn =3D start_pfn; pfn < end_pfn; pfn++)
+		if (PageReserved(pfn_to_page(pfn)))
+			return 1;
+	return 0;
+}
+
+/*
  * Mark a number of pageblocks as MIGRATE_RESERVE. The number
  * of blocks reserved is based on zone->pages_min. The memory within the
  * reserve will tend to store contiguous free pages. Setting min_free_kbyt=
es
@@ -2579,7 +2593,7 @@ static void setup_zone_migrate_reserve(struct zone *z=
one)
 			continue;

 		/* Blocks with reserved pages will never free, skip them. */
-		if (PageReserved(page))
+		if (pageblock_is_reserved(pfn))
 			continue;

 		block_migratetype =3D get_pageblock_migratetype(page);
--=20
1.5.4.3

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 5c44ed4..a596bfd 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -119,6 +119,7 @@ static char * const zone_names[MAX_NR_ZONES] =3D {
 };

 int min_free_kbytes =3D 1024;
+int min_free_order_shift =3D 1;

 unsigned long __meminitdata nr_kernel_pages;
 unsigned long __meminitdata nr_all_pages;
@@ -1256,7 +1257,7 @@ int zone_watermark_ok(struct zone *z, int order,
unsigned long mark,
 		free_pages -=3D z->free_area[o].nr_free << o;

 		/* Require fewer higher order pages to be free */
-		min >>=3D 1;
+		min >>=3D min_free_order_shift;

 		if (free_pages <=3D min)
 			return 0;
--=20


On Thu, Apr 1, 2010 at 12:05 PM, TAO HU <tghk48@motorola.com> wrote:
> Hi, all
>
> We got a panic on our ARM (OMAP) based HW.
> Our code is based on 2.6.29 kernel (last commit for mm/page_alloc.c is
> cc2559bccc72767cb446f79b071d96c30c26439b)
>
> It appears to crash while going through pcp->list in
> buffered_rmqueue() of mm/page_alloc.c after checking vmlinux.
> "00100100" implies LIST_POISON1 that suggests a race condition between
> list_add() and list_del() in my personal view.
> However we not yet figure out locking problem regarding page.lru.
>
> Any known issues about race condition in mm/page_alloc.c?
> And other hints are highly appreciated.
>
> =A0/* Find a page of the appropriate migrate type */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (cold) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ... ...
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0list_for_each_entry(page, =
&pcp->list, lru)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (page_p=
rivate(page) =3D=3D migratetype)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> <1>[120898.805267] Unable to handle kernel paging request at virtual
> address 00100100
> <1>[120898.805633] pgd =3D c1560000
> <1>[120898.805786] [00100100] *pgd=3D897b3031, *pte=3D00000000, *ppte=3D0=
0000000
> <4>[120898.806457] Internal error: Oops: 17 [#1] PREEMPT
> ... ...
> <4>[120898.807861] CPU: 0 =A0 =A0Not tainted =A0(2.6.29-omap1 #1)
> <4>[120898.808044] PC is at get_page_from_freelist+0x1d0/0x4b0
> <4>[120898.808227] LR is at get_page_from_freelist+0xc8/0x4b0
> <4>[120898.808563] pc : [<c00a600c>] =A0 =A0lr : [<c00a5f04>] =A0 =A0psr:=
 800000d3
> <4>[120898.808563] sp : c49fbd18 =A0ip : 00000000 =A0fp : c49fbd74
> <4>[120898.809020] r10: 00000000 =A0r9 : 001000e8 =A0r8 : 00000002
> <4>[120898.809204] r7 : 001200d2 =A0r6 : 60000053 =A0r5 : c0507c4c =A0r4 =
: c49fa000
> <4>[120898.809509] r3 : 001000e8 =A0r2 : 00100100 =A0r1 : c0507c6c =A0r0 =
: 00000001
> <4>[120898.809844] Flags: Nzcv =A0IRQs off =A0FIQs off =A0Mode SVC_32 =A0=
ISA
> ARM =A0Segment kernel
> <4>[120898.810028] Control: 10c5387d =A0Table: 82160019 =A0DAC: 00000017
> <4>[120898.948425] Backtrace:
> <4>[120898.948760] [<c00a5e3c>] (get_page_from_freelist+0x0/0x4b0)
> from [<c00a6398>] (__alloc_pages_internal+0xac/0x3e8)
> <4>[120898.949554] [<c00a62ec>] (__alloc_pages_internal+0x0/0x3e8)
> from [<c00b461c>] (handle_mm_fault+0x16c/0xbac)
> <4>[120898.950347] [<c00b44b0>] (handle_mm_fault+0x0/0xbac) from
> [<c00b51d0>] (__get_user_pages+0x174/0x2b4)
> <4>[120898.951019] [<c00b505c>] (__get_user_pages+0x0/0x2b4) from
> [<c00b534c>] (get_user_pages+0x3c/0x44)
> <4>[120898.951812] [<c00b5310>] (get_user_pages+0x0/0x44) from
> [<c00caf9c>] (get_arg_page+0x50/0xa4)
> <4>[120898.952636] [<c00caf4c>] (get_arg_page+0x0/0xa4) from
> [<c00cb1ec>] (copy_strings+0x108/0x210)
> <4>[120898.953430] =A0r7:beffffe4 r6:00000ffc r5:00000000 r4:00000018
> <4>[120898.954223] [<c00cb0e4>] (copy_strings+0x0/0x210) from
> [<c00cb330>] (copy_strings_kernel+0x3c/0x74)
> <4>[120898.955047] [<c00cb2f4>] (copy_strings_kernel+0x0/0x74) from
> [<c00cc778>] (do_execve+0x18c/0x2b0)
> <4>[120898.955841] =A0r5:0001e240 r4:0001e224
> <4>[120898.956329] [<c00cc5ec>] (do_execve+0x0/0x2b0) from
> [<c00400e4>] (sys_execve+0x3c/0x5c)
> <4>[120898.957153] [<c00400a8>] (sys_execve+0x0/0x5c) from
> [<c003ce80>] (ret_fast_syscall+0x0/0x2c)
> <4>[120898.957946] =A0r7:0000000b r6:0001e270 r5:00000000 r4:0001d580
> <4>[120898.958740] Code: e1530008 0a000006 e2429018 e1a03009 (e5b32018)
>
>
>
> --
> Best Regards
> Hu Tao
>

--001636cd737f2f8f39048338e541
Content-Type: application/octet-stream;
	name="0001-mm-Add-min_free_order_shift-tunable.patch"
Content-Disposition: attachment;
	filename="0001-mm-Add-min_free_order_shift-tunable.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g7igdsiu0

RnJvbSBkNjIwZjY5NTI5MGU0ZmZiMTU4NjQyMGJhMWRiYmI1YjJjOGMwNzVkIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiA9P3V0Zi04P3E/QXJ2ZT0yMEhqPUMzPUI4bm5ldj1DMz1BNWc/
PSA8YXJ2ZUBhbmRyb2lkLmNvbT4KRGF0ZTogVHVlLCAxNyBGZWIgMjAwOSAxNDo1MTowMiAtMDgw
MApTdWJqZWN0OiBbUEFUQ0hdIG1tOiBBZGQgbWluX2ZyZWVfb3JkZXJfc2hpZnQgdHVuYWJsZS4K
TUlNRS1WZXJzaW9uOiAxLjAKQ29udGVudC1UeXBlOiB0ZXh0L3BsYWluOyBjaGFyc2V0PXV0Zi04
CkNvbnRlbnQtVHJhbnNmZXItRW5jb2Rpbmc6IDhiaXQKCkJ5IGRlZmF1bHQgdGhlIGtlcm5lbCB0
cmllcyB0byBrZWVwIGhhbGYgYXMgbXVjaCBtZW1vcnkgZnJlZSBhdCBlYWNoCm9yZGVyIGFzIGl0
IGRvZXMgZm9yIG9uZSBvcmRlciBiZWxvdy4gVGhpcyBjYW4gYmUgdG9vIGFncmVzc2l2ZSB3aGVu
CnJ1bm5pbmcgd2l0aG91dCBzd2FwLgoKU2lnbmVkLW9mZi1ieTogQXJ2ZSBIasO4bm5ldsOlZyA8
YXJ2ZUBhbmRyb2lkLmNvbT4KLS0tCiBrZXJuZWwvc3lzY3RsLmMgfCAgICA5ICsrKysrKysrKwog
bW0vcGFnZV9hbGxvYy5jIHwgICAgMyArKy0KIDIgZmlsZXMgY2hhbmdlZCwgMTEgaW5zZXJ0aW9u
cygrKSwgMSBkZWxldGlvbnMoLSkKCmRpZmYgLS1naXQgYS9rZXJuZWwvc3lzY3RsLmMgYi9rZXJu
ZWwvc3lzY3RsLmMKaW5kZXggYzVlZjQ0Zi4uMGUzZDlhYSAxMDA2NDQKLS0tIGEva2VybmVsL3N5
c2N0bC5jCisrKyBiL2tlcm5lbC9zeXNjdGwuYwpAQCAtNzYsNiArNzYsNyBAQCBleHRlcm4gaW50
IHN1aWRfZHVtcGFibGU7CiBleHRlcm4gY2hhciBjb3JlX3BhdHRlcm5bXTsKIGV4dGVybiBpbnQg
cGlkX21heDsKIGV4dGVybiBpbnQgbWluX2ZyZWVfa2J5dGVzOworZXh0ZXJuIGludCBtaW5fZnJl
ZV9vcmRlcl9zaGlmdDsKIGV4dGVybiBpbnQgcGlkX21heF9taW4sIHBpZF9tYXhfbWF4OwogZXh0
ZXJuIGludCBzeXNjdGxfZHJvcF9jYWNoZXM7CiBleHRlcm4gaW50IHBlcmNwdV9wYWdlbGlzdF9m
cmFjdGlvbjsKQEAgLTEwOTcsNiArMTA5OCwxNCBAQCBzdGF0aWMgc3RydWN0IGN0bF90YWJsZSB2
bV90YWJsZVtdID0gewogCQkuZXh0cmExCQk9ICZ6ZXJvLAogCX0sCiAJeworCQkuY3RsX25hbWUJ
PSBDVExfVU5OVU1CRVJFRCwKKwkJLnByb2NuYW1lCT0gIm1pbl9mcmVlX29yZGVyX3NoaWZ0IiwK
KwkJLmRhdGEJCT0gJm1pbl9mcmVlX29yZGVyX3NoaWZ0LAorCQkubWF4bGVuCQk9IHNpemVvZiht
aW5fZnJlZV9vcmRlcl9zaGlmdCksCisJCS5tb2RlCQk9IDA2NDQsCisJCS5wcm9jX2hhbmRsZXIJ
PSAmcHJvY19kb2ludHZlYworCX0sCisJewogCQkuY3RsX25hbWUJPSBWTV9QRVJDUFVfUEFHRUxJ
U1RfRlJBQ1RJT04sCiAJCS5wcm9jbmFtZQk9ICJwZXJjcHVfcGFnZWxpc3RfZnJhY3Rpb24iLAog
CQkuZGF0YQkJPSAmcGVyY3B1X3BhZ2VsaXN0X2ZyYWN0aW9uLApkaWZmIC0tZ2l0IGEvbW0vcGFn
ZV9hbGxvYy5jIGIvbW0vcGFnZV9hbGxvYy5jCmluZGV4IDVjNDRlZDQuLmE1OTZiZmQgMTAwNjQ0
Ci0tLSBhL21tL3BhZ2VfYWxsb2MuYworKysgYi9tbS9wYWdlX2FsbG9jLmMKQEAgLTExOSw2ICsx
MTksNyBAQCBzdGF0aWMgY2hhciAqIGNvbnN0IHpvbmVfbmFtZXNbTUFYX05SX1pPTkVTXSA9IHsK
IH07CiAKIGludCBtaW5fZnJlZV9rYnl0ZXMgPSAxMDI0OworaW50IG1pbl9mcmVlX29yZGVyX3No
aWZ0ID0gMTsKIAogdW5zaWduZWQgbG9uZyBfX21lbWluaXRkYXRhIG5yX2tlcm5lbF9wYWdlczsK
IHVuc2lnbmVkIGxvbmcgX19tZW1pbml0ZGF0YSBucl9hbGxfcGFnZXM7CkBAIC0xMjU2LDcgKzEy
NTcsNyBAQCBpbnQgem9uZV93YXRlcm1hcmtfb2soc3RydWN0IHpvbmUgKnosIGludCBvcmRlciwg
dW5zaWduZWQgbG9uZyBtYXJrLAogCQlmcmVlX3BhZ2VzIC09IHotPmZyZWVfYXJlYVtvXS5ucl9m
cmVlIDw8IG87CiAKIAkJLyogUmVxdWlyZSBmZXdlciBoaWdoZXIgb3JkZXIgcGFnZXMgdG8gYmUg
ZnJlZSAqLwotCQltaW4gPj49IDE7CisJCW1pbiA+Pj0gbWluX2ZyZWVfb3JkZXJfc2hpZnQ7CiAK
IAkJaWYgKGZyZWVfcGFnZXMgPD0gbWluKQogCQkJcmV0dXJuIDA7Ci0tIAoxLjUuNC4zCgo=
--001636cd737f2f8f39048338e541
Content-Type: application/octet-stream;
	name="0002-mm-Check-if-any-page-in-a-pageblock-is-reserved-bef.patch"
Content-Disposition: attachment;
	filename="0002-mm-Check-if-any-page-in-a-pageblock-is-reserved-bef.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_g7iged1u1

RnJvbSBhNGViMjA0YTgwMjkzMjBjMmRkNzQ4ZGFmNGY1MWZkNDhkMzM3YzNkIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiA9P3V0Zi04P3E/QXJ2ZT0yMEhqPUMzPUI4bm5ldj1DMz1BNWc/
PSA8YXJ2ZUBhbmRyb2lkLmNvbT4KRGF0ZTogV2VkLCAxOCBNYXIgMjAwOSAxNzoyNzozMSAtMDcw
MApTdWJqZWN0OiBbUEFUQ0hdIG1tOiBDaGVjayBpZiBhbnkgcGFnZSBpbiBhIHBhZ2VibG9jayBp
cyByZXNlcnZlZCBiZWZvcmUgbWFya2luZyBpdCBNSUdSQVRFX1JFU0VSVkUKClRoaXMgZml4ZXMg
YSBwcm9ibGVtIHdoZXJlIHRoZSBmaXJzdCBwYWdlYmxvY2sgZ290IG1hcmtlZCBNSUdSQVRFX1JF
U0VSVkUgZXZlbgp0aG91Z2ggaXQgb25seSBoYWQgYSBmZXcgZnJlZSBwYWdlcy4gVGhpcyBpbiB0
dXJuIGNhdXNlZCBubyBjb250aWd1b3VzIG1lbW9yeQp0byBiZSByZXNlcnZlZCBhbmQgZnJlcXVl
bnQga3N3YXBkIHdha2V1cHMgdGhhdCBlbXB0aWVkIHRoZSBjYWNoZXMgdG8gZ2V0IG1vcmUKY29u
dGlndW91cyBtZW1vcnkuCi0tLQogbW0vcGFnZV9hbGxvYy5jIHwgICAxNiArKysrKysrKysrKysr
KystCiAxIGZpbGVzIGNoYW5nZWQsIDE1IGluc2VydGlvbnMoKyksIDEgZGVsZXRpb25zKC0pCgpk
aWZmIC0tZ2l0IGEvbW0vcGFnZV9hbGxvYy5jIGIvbW0vcGFnZV9hbGxvYy5jCmluZGV4IGE1OTZi
ZmQuLjM0YTI5ZTIgMTAwNjQ0Ci0tLSBhL21tL3BhZ2VfYWxsb2MuYworKysgYi9tbS9wYWdlX2Fs
bG9jLmMKQEAgLTI1NTEsNiArMjU1MSwyMCBAQCBzdGF0aWMgaW5saW5lIHVuc2lnbmVkIGxvbmcg
d2FpdF90YWJsZV9iaXRzKHVuc2lnbmVkIGxvbmcgc2l6ZSkKICNkZWZpbmUgTE9OR19BTElHTih4
KSAoKCh4KSsoc2l6ZW9mKGxvbmcpKS0xKSZ+KChzaXplb2YobG9uZykpLTEpKQogCiAvKgorICog
Q2hlY2sgaWYgYSBwYWdlYmxvY2sgY29udGFpbnMgcmVzZXJ2ZWQgcGFnZXMKKyAqLworc3RhdGlj
IGludCBwYWdlYmxvY2tfaXNfcmVzZXJ2ZWQodW5zaWduZWQgbG9uZyBzdGFydF9wZm4pCit7CisJ
dW5zaWduZWQgbG9uZyBlbmRfcGZuID0gc3RhcnRfcGZuICsgcGFnZWJsb2NrX25yX3BhZ2VzOwor
CXVuc2lnbmVkIGxvbmcgcGZuOworCisJZm9yIChwZm4gPSBzdGFydF9wZm47IHBmbiA8IGVuZF9w
Zm47IHBmbisrKQorCQlpZiAoUGFnZVJlc2VydmVkKHBmbl90b19wYWdlKHBmbikpKQorCQkJcmV0
dXJuIDE7CisJcmV0dXJuIDA7Cit9CisKKy8qCiAgKiBNYXJrIGEgbnVtYmVyIG9mIHBhZ2VibG9j
a3MgYXMgTUlHUkFURV9SRVNFUlZFLiBUaGUgbnVtYmVyCiAgKiBvZiBibG9ja3MgcmVzZXJ2ZWQg
aXMgYmFzZWQgb24gem9uZS0+cGFnZXNfbWluLiBUaGUgbWVtb3J5IHdpdGhpbiB0aGUKICAqIHJl
c2VydmUgd2lsbCB0ZW5kIHRvIHN0b3JlIGNvbnRpZ3VvdXMgZnJlZSBwYWdlcy4gU2V0dGluZyBt
aW5fZnJlZV9rYnl0ZXMKQEAgLTI1NzksNyArMjU5Myw3IEBAIHN0YXRpYyB2b2lkIHNldHVwX3pv
bmVfbWlncmF0ZV9yZXNlcnZlKHN0cnVjdCB6b25lICp6b25lKQogCQkJY29udGludWU7CiAKIAkJ
LyogQmxvY2tzIHdpdGggcmVzZXJ2ZWQgcGFnZXMgd2lsbCBuZXZlciBmcmVlLCBza2lwIHRoZW0u
ICovCi0JCWlmIChQYWdlUmVzZXJ2ZWQocGFnZSkpCisJCWlmIChwYWdlYmxvY2tfaXNfcmVzZXJ2
ZWQocGZuKSkKIAkJCWNvbnRpbnVlOwogCiAJCWJsb2NrX21pZ3JhdGV0eXBlID0gZ2V0X3BhZ2Vi
bG9ja19taWdyYXRldHlwZShwYWdlKTsKLS0gCjEuNS40LjMKCg==
--001636cd737f2f8f39048338e541--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
