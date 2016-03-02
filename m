Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f48.google.com (mail-vk0-f48.google.com [209.85.213.48])
	by kanga.kvack.org (Postfix) with ESMTP id E45C26B0254
	for <linux-mm@kvack.org>; Wed,  2 Mar 2016 01:20:39 -0500 (EST)
Received: by mail-vk0-f48.google.com with SMTP id e6so191752839vkh.2
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 22:20:39 -0800 (PST)
Received: from mail-vk0-x22f.google.com (mail-vk0-x22f.google.com. [2607:f8b0:400c:c05::22f])
        by mx.google.com with ESMTPS id c137si21494538vkf.95.2016.03.01.22.20.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Mar 2016 22:20:39 -0800 (PST)
Received: by mail-vk0-x22f.google.com with SMTP id k196so192958715vka.0
        for <linux-mm@kvack.org>; Tue, 01 Mar 2016 22:20:39 -0800 (PST)
MIME-Version: 1.0
Date: Wed, 2 Mar 2016 14:20:38 +0800
Message-ID: <CAKQB+ft3q2O2xYG2CTmTM9OCRLCP2FPTfHQ3jvcFSM-FGrjgGA@mail.gmail.com>
Subject: kswapd consumes 100% CPU when highest zone is small
From: Jerry Lee <leisurelysw24@gmail.com>
Content-Type: multipart/alternative; boundary=001a11441386746364052d0ae132
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

--001a11441386746364052d0ae132
Content-Type: text/plain; charset=UTF-8

Hi,

I have a x86_64 system with 2G RAM using linux-3.12.x.  During copying
large
files (e.g. 100GB), kswapd easily consumes 100% CPU until the file is
deleted
or the page cache is dropped.  With setting the min_free_kbytes from 16384
to
65536, the symptom is mitigated but I can't totally get rid of the problem.

After some trial and error, I found that highest zone is always unbalanced
with
order-0 page request so that pgdat_blanaced() continuously return false and
kswapd can't sleep.

Here's the watermarks (min_free_kbytes = 65536) in my system:
Node 0, zone      DMA
  pages free     2167
        min      138
        low      172
        high     207
        scanned  0
        spanned  4095
        present  3996
        managed  3974

Node 0, zone    DMA32
  pages free     215375
        min      16226
        low      20282
        high     24339
        scanned  0
        spanned  1044480
        present  490971
        managed  464223

Node 0, zone   Normal
  pages free     7
        min      18
        low      22
        high     27
        scanned  0
        spanned  1536
        present  1536
        managed  523

Besides, when the kswapd crazily spins, the value of the following entries
in vmstat increases quickly even when I stop copying file:

pgalloc_dma 17719
pgalloc_dma32 3262823
slabs_scanned 937728
kswapd_high_wmark_hit_quickly 54333233
pageoutrun 54333235

Is there anything I could do to totally get rid of the problem?

Thanks

--001a11441386746364052d0ae132
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: base64

PGRpdiBkaXI9Imx0ciI+PGRpdj48ZGl2PjxkaXY+PGRpdj5IaSw8YnI+PGJyPkkgaGF2ZSBhIHg4
Nl82NCBzeXN0ZW0gd2l0aCAyRyBSQU0gdXNpbmcgbGludXgtMy4xMi54LsKgIER1cmluZyBjb3B5
aW5nIGxhcmdlIDxicj5maWxlcyAoZS5nLiAxMDBHQiksIGtzd2FwZCBlYXNpbHkgY29uc3VtZXMg
MTAwJSBDUFUgdW50aWwgdGhlIGZpbGUgaXMgZGVsZXRlZCA8YnI+b3IgdGhlIHBhZ2UgY2FjaGUg
aXMgZHJvcHBlZC7CoCBXaXRoIHNldHRpbmcgdGhlIG1pbl9mcmVlX2tieXRlcyBmcm9tIDE2Mzg0
IHRvIDxicj42NTUzNiwgdGhlIHN5bXB0b20gaXMgbWl0aWdhdGVkIGJ1dCBJIGNhbiYjMzk7dCB0
b3RhbGx5IGdldCByaWQgb2YgdGhlIHByb2JsZW0uPGJyPjxicj48L2Rpdj5BZnRlciBzb21lIHRy
aWFsIGFuZCBlcnJvciwgSSBmb3VuZCB0aGF0IGhpZ2hlc3Qgem9uZSBpcyBhbHdheXMgdW5iYWxh
bmNlZCB3aXRoIDxicj5vcmRlci0wIHBhZ2UgcmVxdWVzdCBzbyB0aGF0IHBnZGF0X2JsYW5hY2Vk
KCkgY29udGludW91c2x5IHJldHVybiBmYWxzZSBhbmQ8YnI+a3N3YXBkIGNhbiYjMzk7dCBzbGVl
cC48YnI+PC9kaXY+PC9kaXY+PGJyPjwvZGl2PkhlcmUmIzM5O3MgdGhlIHdhdGVybWFya3MgKG1p
bl9mcmVlX2tieXRlcyA9IDY1NTM2KSBpbiBteSBzeXN0ZW06PGJyPk5vZGUgMCwgem9uZcKgwqDC
oMKgwqAgRE1BPGJyPsKgIHBhZ2VzIGZyZWXCoMKgwqDCoCAyMTY3PGJyPsKgwqDCoMKgwqDCoMKg
IG1pbsKgwqDCoMKgwqAgMTM4PGJyPsKgwqDCoMKgwqDCoMKgIGxvd8KgwqDCoMKgwqAgMTcyPGJy
PsKgwqDCoMKgwqDCoMKgIGhpZ2jCoMKgwqDCoCAyMDc8YnI+wqDCoMKgwqDCoMKgwqAgc2Nhbm5l
ZMKgIDA8YnI+wqDCoMKgwqDCoMKgwqAgc3Bhbm5lZMKgIDQwOTU8YnI+wqDCoMKgwqDCoMKgwqAg
cHJlc2VudMKgIDM5OTY8YnI+wqDCoMKgwqDCoMKgwqAgbWFuYWdlZMKgIDM5NzQ8YnI+PGJyPk5v
ZGUgMCwgem9uZcKgwqDCoCBETUEzMjxicj7CoCBwYWdlcyBmcmVlwqDCoMKgwqAgMjE1Mzc1PGJy
PsKgwqDCoMKgwqDCoMKgIG1pbsKgwqDCoMKgwqAgMTYyMjY8YnI+wqDCoMKgwqDCoMKgwqAgbG93
wqDCoMKgwqDCoCAyMDI4Mjxicj7CoMKgwqDCoMKgwqDCoCBoaWdowqDCoMKgwqAgMjQzMzk8YnI+
wqDCoMKgwqDCoMKgwqAgc2Nhbm5lZMKgIDA8YnI+wqDCoMKgwqDCoMKgwqAgc3Bhbm5lZMKgIDEw
NDQ0ODA8YnI+wqDCoMKgwqDCoMKgwqAgcHJlc2VudMKgIDQ5MDk3MTxicj7CoMKgwqDCoMKgwqDC
oCBtYW5hZ2VkwqAgNDY0MjIzPGJyPjxicj5Ob2RlIDAsIHpvbmXCoMKgIE5vcm1hbDxicj7CoCBw
YWdlcyBmcmVlwqDCoMKgwqAgNzxicj7CoMKgwqDCoMKgwqDCoCBtaW7CoMKgwqDCoMKgIDE4PGJy
PsKgwqDCoMKgwqDCoMKgIGxvd8KgwqDCoMKgwqAgMjI8YnI+wqDCoMKgwqDCoMKgwqAgaGlnaMKg
wqDCoMKgIDI3PGJyPsKgwqDCoMKgwqDCoMKgIHNjYW5uZWTCoCAwPGJyPsKgwqDCoMKgwqDCoMKg
IHNwYW5uZWTCoCAxNTM2PGJyPsKgwqDCoMKgwqDCoMKgIHByZXNlbnTCoCAxNTM2PGJyPsKgwqDC
oMKgwqDCoMKgIG1hbmFnZWTCoCA1MjM8YnI+PGRpdj48ZGl2PjxkaXY+PGRpdj48YnI+PC9kaXY+
PGRpdj5CZXNpZGVzLCB3aGVuIHRoZSBrc3dhcGQgY3JhemlseSBzcGlucywgdGhlIHZhbHVlIG9m
IHRoZSBmb2xsb3dpbmcgZW50cmllczxicj48L2Rpdj48ZGl2PmluIHZtc3RhdCBpbmNyZWFzZXMg
cXVpY2tseSBldmVuIHdoZW4gSSBzdG9wIGNvcHlpbmcgZmlsZTo8YnI+PGJyPnBnYWxsb2NfZG1h
IDE3NzE5PGJyPnBnYWxsb2NfZG1hMzIgMzI2MjgyMzxicj5zbGFic19zY2FubmVkIDkzNzcyODxi
cj5rc3dhcGRfaGlnaF93bWFya19oaXRfcXVpY2tseSA1NDMzMzIzMzxicj5wYWdlb3V0cnVuIDU0
MzMzMjM1PGJyPjxicj48L2Rpdj48ZGl2PklzIHRoZXJlIGFueXRoaW5nIEkgY291bGQgZG8gdG8g
dG90YWxseSBnZXQgcmlkIG9mIHRoZSBwcm9ibGVtPzxicj48L2Rpdj48ZGl2PjwvZGl2PjxkaXY+
PGJyPjwvZGl2PjxkaXY+VGhhbmtzPGJyPjwvZGl2PjwvZGl2PjwvZGl2PjwvZGl2PjwvZGl2Pg0K
--001a11441386746364052d0ae132--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
