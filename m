Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8801E8E0002
	for <linux-mm@kvack.org>; Wed,  2 Jan 2019 12:36:18 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id s193so4094491wmd.4
        for <linux-mm@kvack.org>; Wed, 02 Jan 2019 09:36:18 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 201sor25633308wma.0.2019.01.02.09.36.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 Jan 2019 09:36:17 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 2/3] kasan: make tag based mode work with CONFIG_HARDENED_USERCOPY
Date: Wed,  2 Jan 2019 18:36:07 +0100
Message-Id: <21de3c171438760a232d51cea56792c886bc9160.1546450432.git.andreyknvl@google.com>
In-Reply-To: <cover.1546450432.git.andreyknvl@google.com>
References: <cover.1546450432.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Vincenzo Frascino <vincenzo.frascino@arm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

With CONFIG_HARDENED_USERCOPY enabled __check_heap_object() compares and
then subtracts a potentially tagged pointer with a non-tagged address of
the page that this pointer belongs to, which leads to unexpected behavior.

Untag the pointer in __check_heap_object() before doing any of these
operations.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slub.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/slub.c b/mm/slub.c
index 36c0befeebd8..1e3d0ec4e200 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -3846,6 +3846,8 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 	unsigned int offset;
 	size_t object_size;
 
+	ptr = kasan_reset_tag(ptr);
+
 	/* Find object and usable object size. */
 	s = page->slab_cache;
 
-- 
2.20.1.415.g653613c723-goog
