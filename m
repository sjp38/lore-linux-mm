Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 91EFF6B0033
	for <linux-mm@kvack.org>; Sat,  4 Feb 2017 08:53:03 -0500 (EST)
Received: by mail-io0-f199.google.com with SMTP id 101so44351908iom.7
        for <linux-mm@kvack.org>; Sat, 04 Feb 2017 05:53:03 -0800 (PST)
Received: from nm6-vm4.bullet.mail.ne1.yahoo.com (nm6-vm4.bullet.mail.ne1.yahoo.com. [98.138.91.166])
        by mx.google.com with ESMTPS id o204si990619itb.59.2017.02.04.05.53.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 04 Feb 2017 05:53:02 -0800 (PST)
Date: Sat, 4 Feb 2017 13:53:01 +0000 (UTC)
From: Shantanu Goel <sgoel01@yahoo.com>
Reply-To: Shantanu Goel <sgoel01@yahoo.com>
Message-ID: <1837390276.846271.1486216381871@mail.yahoo.com>
Subject: [PATCH] vmscan: Skip slab scan when LRU size is zero
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_846270_2097412131.1486216381871"
References: <1837390276.846271.1486216381871.ref@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

------=_Part_846270_2097412131.1486216381871
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi,

I am running 4.9.7 and noticed the slab was being scanned very aggressively (200K objects scanned for 1K LRU pages).  Turning on tracing in do_shrink_slab() revealed it was sometimes being called with a LRU size of zero causing the LRU scan ratio to be very large.  The attached patch skips shrinking the slab when the LRU size is zero.  After applying the patch the slab size I no longer see the extremely large object scan values.


Trace output when LRU size is 0:


kswapd0-93    [005] .... 49736.760169: mm_shrink_slab_start: scan_shadow_nodes+0x0/0x50 ffffffff94e6e460: nid: 0 objects to shrink 59291940 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 0 cache items 20 delta 1280 total_scan 40
kswapd0-93    [005] .... 49736.760207: mm_shrink_slab_start: super_cache_scan+0x0/0x1a0 ffff9d79ce488cc0: nid: 0 objects to shrink 22740669 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 0 cache items 1 delta 64 total_scan 2
kswapd0-93    [005] .... 49736.760216: mm_shrink_slab_start: super_cache_scan+0x0/0x1a0 ffff9d79db59ecc0: nid: 0 objects to shrink 79098834 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 0 cache items 642 delta 41088 total_scan 1284
kswapd0-93    [005] .... 49736.760769: mm_shrink_slab_start: super_cache_scan+0x0/0x1a0 ffff9d79ce488cc0: nid: 0 objects to shrink 22740729 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 0 cache items 1 delta 64 total_scan 2
kswapd0-93    [005] .... 49736.766125: mm_shrink_slab_start: scan_shadow_nodes+0x0/0x50 ffffffff94e6e460: nid: 0 objects to shrink 59293180 gfp_flags GFP_KERNEL pgs_scanned 32 lru_pgs 0 cache items 32 delta 2048 total_scan 64

Thanks,
Shantanu
------=_Part_846270_2097412131.1486216381871
Content-Type: text/x-patch
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="0001-vmscan-do-not-shrink-slab-if-LRU-size-is-0.patch"
Content-ID: <048b8230-d3c2-0ddd-f122-83d2649820e2@yahoo.com>

RnJvbSA5NzgxN2ZjNzFlMWZkMGU4ZmUzZjM4NWIwMGRkMTZlZDY0ZjY1NWFiIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTaGFudGFudSBHb2VsIDxzZ29lbDAxQHlhaG9vLmNvbT4KRGF0
ZTogRnJpLCAzIEZlYiAyMDE3IDE1OjA1OjU3IC0wNTAwClN1YmplY3Q6IFtQQVRDSF0gdm1zY2Fu
OiBkbyBub3Qgc2hyaW5rIHNsYWIgaWYgTFJVIHNpemUgaXMgMAoKU29tZSBtZW1jZydzIG1heSBu
b3QgaGF2ZSBhbnkgTFJVIHBhZ2VzIGluIHRoZW0gc28Kc2hyaW5rX3NsYWIgaW5jb3JyZWN0bHkg
ZW5kcyB1cCBmcmVlJ2luZyBhIGh1Z2UgcG9ydGlvbgpvZiB0aGUgc2xhYi4KClNpZ25lZC1vZmYt
Ynk6IFNoYW50YW51IEdvZWwgPHNnb2VsMDFAeWFob28uY29tPgotLS0KIG1tL3Ztc2Nhbi5jIHwg
MyArKysKIDEgZmlsZSBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKykKCmRpZmYgLS1naXQgYS9tbS92
bXNjYW4uYyBiL21tL3Ztc2Nhbi5jCmluZGV4IDQyMDViM2UuLjc2ODI0NjkgMTAwNjQ0Ci0tLSBh
L21tL3Ztc2Nhbi5jCisrKyBiL21tL3Ztc2Nhbi5jCkBAIC00NDUsNiArNDQ1LDkgQEAgc3RhdGlj
IHVuc2lnbmVkIGxvbmcgc2hyaW5rX3NsYWIoZ2ZwX3QgZ2ZwX21hc2ssIGludCBuaWQsCiAJaWYg
KG1lbWNnICYmICghbWVtY2dfa21lbV9lbmFibGVkKCkgfHwgIW1lbV9jZ3JvdXBfb25saW5lKG1l
bWNnKSkpCiAJCXJldHVybiAwOwogCisJaWYgKG5yX2VsaWdpYmxlID09IDApCisJCXJldHVybiAw
OworCiAJaWYgKG5yX3NjYW5uZWQgPT0gMCkKIAkJbnJfc2Nhbm5lZCA9IFNXQVBfQ0xVU1RFUl9N
QVg7CiAKLS0gCjIuNy40Cgo=

------=_Part_846270_2097412131.1486216381871--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
