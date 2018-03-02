Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7C7A76B002D
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 14:45:21 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id z14so7050867wrh.1
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 11:45:21 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k16sor3788541wrf.24.2018.03.02.11.45.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 02 Mar 2018 11:45:20 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [RFC PATCH 12/14] khwasan, jbd2: add khwasan annotations
Date: Fri,  2 Mar 2018 20:44:31 +0100
Message-Id: <353cde67d3297b3532ca1407374f3f99de535b7d.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
In-Reply-To: <cover.1520017438.git.andreyknvl@google.com>
References: <cover.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>
Cc: Andrey Konovalov <andreyknvl@google.com>

This patch it not meant to be accepted as is, but I'm including it to
illustrate the case where using the top byte of kernel pointers causes
issues with the current code.

What happens here, is jbd2/journal.c code was written to account for archs
that don't keep high memory mapped all the time, but rather map and unmap
particular pages when needed. Instead of storing a pointer to the kernel
memory, journal code saves the address of the page structure and offset
within that page for later use. Those pages are then mapped and unmapped
with kmap/kunmap when necessary and virt_to_page is used to get the virtual
address of the page. For arm64 (that keeps the high memory mapped all the
time), kmap is turned into a page_address call.

The issue is that with use of the page_address + virt_to_page sequence
the top byte value of the original pointer gets lost. Right now this is
fixed by simply adding annotations to the code, that fix up the top byte
values, but a more generic solution will probably be needed.
---
 fs/jbd2/journal.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/fs/jbd2/journal.c b/fs/jbd2/journal.c
index 3fbf48ec2188..8b65d2c49b61 100644
--- a/fs/jbd2/journal.c
+++ b/fs/jbd2/journal.c
@@ -365,6 +365,7 @@ int jbd2_journal_write_metadata_buffer(transaction_t *transaction,
 	unsigned int new_offset;
 	struct buffer_head *bh_in = jh2bh(jh_in);
 	journal_t *journal = transaction->t_journal;
+	u8 new_page_tag = 0xff;
 
 	/*
 	 * The buffer really shouldn't be locked: only the current committing
@@ -392,12 +393,14 @@ int jbd2_journal_write_metadata_buffer(transaction_t *transaction,
 		done_copy_out = 1;
 		new_page = virt_to_page(jh_in->b_frozen_data);
 		new_offset = offset_in_page(jh_in->b_frozen_data);
+		new_page_tag = khwasan_get_tag(jh_in->b_frozen_data);
 	} else {
 		new_page = jh2bh(jh_in)->b_page;
 		new_offset = offset_in_page(jh2bh(jh_in)->b_data);
 	}
 
 	mapped_data = kmap_atomic(new_page);
+	mapped_data = khwasan_set_tag(mapped_data, new_page_tag);
 	/*
 	 * Fire data frozen trigger if data already wasn't frozen.  Do this
 	 * before checking for escaping, as the trigger may modify the magic
@@ -438,10 +441,12 @@ int jbd2_journal_write_metadata_buffer(transaction_t *transaction,
 
 		jh_in->b_frozen_data = tmp;
 		mapped_data = kmap_atomic(new_page);
+		mapped_data = khwasan_set_tag(mapped_data, new_page_tag);
 		memcpy(tmp, mapped_data + new_offset, bh_in->b_size);
 		kunmap_atomic(mapped_data);
 
 		new_page = virt_to_page(tmp);
+		new_page_tag = khwasan_get_tag(tmp);
 		new_offset = offset_in_page(tmp);
 		done_copy_out = 1;
 
@@ -459,6 +464,7 @@ int jbd2_journal_write_metadata_buffer(transaction_t *transaction,
 	 */
 	if (do_escape) {
 		mapped_data = kmap_atomic(new_page);
+		mapped_data = khwasan_set_tag(mapped_data, new_page_tag);
 		*((unsigned int *)(mapped_data + new_offset)) = 0;
 		kunmap_atomic(mapped_data);
 	}
-- 
2.16.2.395.g2e18187dfd-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
