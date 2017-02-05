Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1D99D6B0033
	for <linux-mm@kvack.org>; Sun,  5 Feb 2017 07:46:23 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m98so60548367iod.2
        for <linux-mm@kvack.org>; Sun, 05 Feb 2017 04:46:23 -0800 (PST)
Received: from nm17-vm0.bullet.mail.ne1.yahoo.com (nm17-vm0.bullet.mail.ne1.yahoo.com. [98.138.91.58])
        by mx.google.com with ESMTPS id r201si7164938iod.168.2017.02.05.04.46.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 05 Feb 2017 04:46:22 -0800 (PST)
Date: Sun, 5 Feb 2017 12:46:20 +0000 (UTC)
From: Shantanu Goel <sgoel01@yahoo.com>
Reply-To: Shantanu Goel <sgoel01@yahoo.com>
Message-ID: <719282122.1183240.1486298780546@mail.yahoo.com>
Subject: [PATCH] vmscan: fix zone balance check in prepare_kswapd_sleep
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_1183239_971597884.1486298780546"
References: <719282122.1183240.1486298780546.ref@mail.yahoo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>

------=_Part_1183239_971597884.1486298780546
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit

Hi,

On 4.9.7 kswapd is failing to wake up kcompactd due to a mismatch in the zone balance check between balance_pgdat() and prepare_kswapd_sleep().  balance_pgdat() returns as soon as a single zone satisfies the allocation but prepare_kswapd_sleep() requires all zones to do the same.  This causes prepare_kswapd_sleep() to never succeed except in the order == 0 case and consequently, wakeup_kcompactd() is never called.  On my machine prior to apply this patch, the state of compaction from /proc/vmstat looked this way after a day and a half of uptime:

compact_migrate_scanned 240496
compact_free_scanned 76238632
compact_isolated 123472
compact_stall 1791
compact_fail 29
compact_success 1762
compact_daemon_wake 0


After applying the patch and about 10 hours of uptime the state looks like this:

compact_migrate_scanned 59927299
compact_free_scanned 2021075136
compact_isolated 640926
compact_stall 4
compact_fail 2
compact_success 2
compact_daemon_wake 5160


Thanks,
Shantanu

------=_Part_1183239_971597884.1486298780546
Content-Type: text/x-patch
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="0001-vmscan-match-zone-balance-check-in-prepare_kswapd_sl.patch"
Content-ID: <67e8c24b-b144-9cfb-e2b3-d7cdb27dcb86@yahoo.com>

RnJvbSA0NmYyZTRiMDJhYzI2M2JmNTBkNjljZGFiM2JjYmQ3YmNkZWE3NDE1IE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBTaGFudGFudSBHb2VsIDxzZ29lbDAxQHlhaG9vLmNvbT4KRGF0
ZTogU2F0LCA0IEZlYiAyMDE3IDE5OjA3OjUzIC0wNTAwClN1YmplY3Q6IFtQQVRDSF0gdm1zY2Fu
OiBmaXggem9uZSBiYWxhbmNlIGNoZWNrIGluIHByZXBhcmVfa3N3YXBkX3NsZWVwCgpUaGUgY2hl
Y2sgaW4gcHJlcGFyZV9rc3dhcGRfc2xlZXAgbmVlZHMgdG8gbWF0Y2ggdGhlIG9uZSBpbiBiYWxh
bmNlX3BnZGF0CnNpbmNlIHRoZSBsYXR0ZXIgd2lsbCByZXR1cm4gYXMgc29vbiBhcyBhbnkgb25l
IG9mIHRoZSB6b25lcyBpbiB0aGUKY2xhc3N6b25lIGlzIGFib3ZlIHRoZSB3YXRlcm1hcmsuICBU
aGlzIGlzIHNwZWNpYWxseSBpbXBvcnRhbnQgZm9yCmhpZ2hlciBvcmRlciBhbGxvY2F0aW9ucyBz
aW5jZSBiYWxhbmNlX3BnZGF0IHdpbGwgdHlwaWNhbGx5IHJlc2V0CnRoZSBvcmRlciB0byB6ZXJv
IHJlbHlpbmcgb24gY29tcGFjdGlvbiB0byBjcmVhdGUgdGhlIGhpZ2hlciBvcmRlcgpwYWdlcy4g
IFdpdGhvdXQgdGhpcyBwYXRjaCwgcHJlcGFyZV9rc3dhcGRfc2xlZXAgZmFpbHMgdG8gd2FrZSB1
cAprY29tcGFjdGQgc2luY2UgdGhlIHpvbmUgYmFsYW5jZSBjaGVjayBmYWlscy4KClNpZ25lZC1v
ZmYtYnk6IFNoYW50YW51IEdvZWwgPHNnb2VsMDFAeWFob28uY29tPgotLS0KIG1tL3Ztc2Nhbi5j
IHwgNiArKystLS0KIDEgZmlsZSBjaGFuZ2VkLCAzIGluc2VydGlvbnMoKyksIDMgZGVsZXRpb25z
KC0pCgpkaWZmIC0tZ2l0IGEvbW0vdm1zY2FuLmMgYi9tbS92bXNjYW4uYwppbmRleCA3NjgyNDY5
Li4xMTg5OWZmIDEwMDY0NAotLS0gYS9tbS92bXNjYW4uYworKysgYi9tbS92bXNjYW4uYwpAQCAt
MzE0MiwxMSArMzE0MiwxMSBAQCBzdGF0aWMgYm9vbCBwcmVwYXJlX2tzd2FwZF9zbGVlcChwZ19k
YXRhX3QgKnBnZGF0LCBpbnQgb3JkZXIsIGludCBjbGFzc3pvbmVfaWR4KQogCQlpZiAoIW1hbmFn
ZWRfem9uZSh6b25lKSkKIAkJCWNvbnRpbnVlOwogCi0JCWlmICghem9uZV9iYWxhbmNlZCh6b25l
LCBvcmRlciwgY2xhc3N6b25lX2lkeCkpCi0JCQlyZXR1cm4gZmFsc2U7CisJCWlmICh6b25lX2Jh
bGFuY2VkKHpvbmUsIG9yZGVyLCBjbGFzc3pvbmVfaWR4KSkKKwkJCXJldHVybiB0cnVlOwogCX0K
IAotCXJldHVybiB0cnVlOworCXJldHVybiBmYWxzZTsKIH0KIAogLyoKLS0gCjIuNy40Cgo=

------=_Part_1183239_971597884.1486298780546--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
