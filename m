Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f197.google.com (mail-lb0-f197.google.com [209.85.217.197])
	by kanga.kvack.org (Postfix) with ESMTP id 453766B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 06:04:22 -0400 (EDT)
Received: by mail-lb0-f197.google.com with SMTP id j12so21496311lbo.0
        for <linux-mm@kvack.org>; Fri, 27 May 2016 03:04:22 -0700 (PDT)
Received: from mail-lf0-x22d.google.com (mail-lf0-x22d.google.com. [2a00:1450:4010:c07::22d])
        by mx.google.com with ESMTPS id i203si10922841lfd.330.2016.05.27.03.04.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 03:04:20 -0700 (PDT)
Received: by mail-lf0-x22d.google.com with SMTP id k98so43800476lfi.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 03:04:20 -0700 (PDT)
MIME-Version: 1.0
From: Alexander Potapenko <glider@google.com>
Date: Fri, 27 May 2016 12:04:19 +0200
Message-ID: <CAG_fn=UYn=0BBNhqS_O97WF64Dwv2jpuV-bt_CEgWdq_vje25A@mail.gmail.com>
Subject: Value of page->slab_cache in objects allocated from a cache?
Content-Type: multipart/mixed; boundary=001a11410bacc610380533d0071a
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Memory Management List <linux-mm@kvack.org>

--001a11410bacc610380533d0071a
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

Hi everyone,

I'm debugging some crashes in the KASAN quarantine, and I've noticed
that for certain objects something which I assumed to be invariant
does not hold.

In particular, my understanding was that for an object returned by
kmem_cache_zalloc(cache, gfp_flags) the value of
virt_to_page(object)->slab_cache must be always equal to |cache|.

However this isn't true for at least idr_free_cache in lib/idr.c
If I apply the attached patch, build a x86_64 kernel with defconfig,
and run the resulting kernel in QEMU, I get the following log:

[    0.007022] HERE: lib/idr.c:198 allocated ffff88001ddc8008 from
idr_layer_cache
[    0.007478] idr_layer_cache: ffff88001dc0b6c0, slab_cache: ffff88001dc0b=
6c0
[    0.007920] HERE: lib/idr.c:198 allocated ffff88001ddcf1a8 from
idr_layer_cache
[    0.008002] idr_layer_cache: ffff88001dc0b6c0, slab_cache:           (nu=
ll)
[    0.008445] ------------[ cut here ]------------
[    0.008791] kernel BUG at lib/idr.c:200!

Am I misunderstanding the purpose of slab_cache in struct page, or is
there really a bug in initializing it?

Thanks,

--=20
Alexander Potapenko
Software Engineer

Google Germany GmbH
Erika-Mann-Stra=C3=9Fe, 33
80636 M=C3=BCnchen

Gesch=C3=A4ftsf=C3=BChrer: Matthew Scott Sucherman, Paul Terence Manicle
Registergericht und -nummer: Hamburg, HRB 86891
Sitz der Gesellschaft: Hamburg

--001a11410bacc610380533d0071a
Content-Type: text/x-patch; charset=US-ASCII; name="idr.patch"
Content-Disposition: attachment; filename="idr.patch"
Content-Transfer-Encoding: base64
X-Attachment-Id: f_iopk9x1x0

ZGlmZiAtLWdpdCBhL2xpYi9pZHIuYyBiL2xpYi9pZHIuYwppbmRleCA2MDk4MzM2Li43NzY3YWJl
IDEwMDY0NAotLS0gYS9saWIvaWRyLmMKKysrIGIvbGliL2lkci5jCkBAIC0zMCw2ICszMCw3IEBA
CiAjaW5jbHVkZSA8bGludXgvaWRyLmg+CiAjaW5jbHVkZSA8bGludXgvc3BpbmxvY2suaD4KICNp
bmNsdWRlIDxsaW51eC9wZXJjcHUuaD4KKyNpbmNsdWRlIDxsaW51eC9tbS5oPgogCiAjZGVmaW5l
IE1BWF9JRFJfU0hJRlQJCShzaXplb2YoaW50KSAqIDggLSAxKQogI2RlZmluZSBNQVhfSURSX0JJ
VAkJKDFVIDw8IE1BWF9JRFJfU0hJRlQpCkBAIC0xOTQsNiArMTk1LDkgQEAgc3RhdGljIGludCBf
X2lkcl9wcmVfZ2V0KHN0cnVjdCBpZHIgKmlkcCwgZ2ZwX3QgZ2ZwX21hc2spCiAJd2hpbGUgKGlk
cC0+aWRfZnJlZV9jbnQgPCBNQVhfSURSX0ZSRUUpIHsKIAkJc3RydWN0IGlkcl9sYXllciAqbmV3
OwogCQluZXcgPSBrbWVtX2NhY2hlX3phbGxvYyhpZHJfbGF5ZXJfY2FjaGUsIGdmcF9tYXNrKTsK
KwkJcHJfZXJyKCJIRVJFOiAlczolZCBhbGxvY2F0ZWQgJXAgZnJvbSBpZHJfbGF5ZXJfY2FjaGVc
biIsIF9fRklMRV9fLCBfX0xJTkVfXywgbmV3KTsKKwkJcHJfZXJyKCJpZHJfbGF5ZXJfY2FjaGU6
ICVwLCBzbGFiX2NhY2hlOiAlcFxuIiwgaWRyX2xheWVyX2NhY2hlLCB2aXJ0X3RvX3BhZ2UobmV3
KS0+c2xhYl9jYWNoZSk7CisJCUJVR19PTih2aXJ0X3RvX3BhZ2UobmV3KS0+c2xhYl9jYWNoZSAh
PSBpZHJfbGF5ZXJfY2FjaGUpOwogCQlpZiAobmV3ID09IE5VTEwpCiAJCQlyZXR1cm4gKDApOwog
CQltb3ZlX3RvX2ZyZWVfbGlzdChpZHAsIG5ldyk7Cg==
--001a11410bacc610380533d0071a--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
