Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A66C6B02D0
	for <linux-mm@kvack.org>; Tue,  8 May 2018 13:21:33 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id e74so3519707wmg.5
        for <linux-mm@kvack.org>; Tue, 08 May 2018 10:21:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w16-v6sor11799477wrc.60.2018.05.08.10.21.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 10:21:32 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v1 10/16] khwasan, mm: perform untagged pointers comparison in krealloc
Date: Tue,  8 May 2018 19:20:56 +0200
Message-Id: <94f6719e7e696977de00354f8201581a8f9108d3.1525798754.git.andreyknvl@google.com>
In-Reply-To: <cover.1525798753.git.andreyknvl@google.com>
References: <cover.1525798753.git.andreyknvl@google.com>
In-Reply-To: <cover.1525798753.git.andreyknvl@google.com>
References: <cover.1525798753.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

The krealloc function checks where the same buffer was reused or a new one
allocated by comparing kernel pointers. KHWASAN changes memory tag on the
krealloc'ed chunk of memory and therefore also changes the pointer tag of
the returned pointer. Therefore we need to perform comparison on untagged
(with tags reset) pointers to check whether it's the same memory region or
not.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/slab_common.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/slab_common.c b/mm/slab_common.c
index 0582004351c4..451b094b8c5b 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -1478,7 +1478,7 @@ void *krealloc(const void *p, size_t new_size, gfp_t flags)
 	}
 
 	ret = __do_krealloc(p, new_size, flags);
-	if (ret && p != ret)
+	if (ret && khwasan_reset_tag(p) != khwasan_reset_tag(ret))
 		kfree(p);
 
 	return ret;
-- 
2.17.0.441.gb46fe60e1d-goog
