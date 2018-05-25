Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0761D6B026C
	for <linux-mm@kvack.org>; Fri, 25 May 2018 10:41:08 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e1-v6so3443716wma.3
        for <linux-mm@kvack.org>; Fri, 25 May 2018 07:41:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y33-v6sor8986624wrd.59.2018.05.25.07.41.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 25 May 2018 07:41:06 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 12/16] khwasan: add bug reporting routines
Date: Fri, 25 May 2018 16:40:28 +0200
Message-Id: <c5f7de3ce24fc8104816973f50d57d24b355249a.1527259068.git.andreyknvl@google.com>
In-Reply-To: <cover.1527259068.git.andreyknvl@google.com>
References: <cover.1527259068.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Yury Norov <ynorov@caviumnetworks.com>, Marc Zyngier <marc.zyngier@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, James Morse <james.morse@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Julien Thierry <julien.thierry@arm.com>, Tyler Baicar <tbaicar@codeaurora.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Kees Cook <keescook@chromium.org>, Sandipan Das <sandipan@linux.vnet.ibm.com>, David Woodhouse <dwmw@amazon.co.uk>, Paul Lawrence <paullawrence@google.com>, Herbert Xu <herbert@gondor.apana.org.au>, Josh Poimboeuf <jpoimboe@redhat.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Tom Lendacky <thomas.lendacky@amd.com>, Arnd Bergmann <arnd@arndb.de>, Dan Williams <dan.j.williams@intel.com>, Michal Hocko <mhocko@suse.com>, Jan Kara <jack@suse.cz>, Ross Zwisler <ross.zwisler@linux.intel.com>, =?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>, Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Souptick Joarder <jrdr.linux@gmail.com>, Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Kate Stewart <kstewart@linuxfoundation.org>, Laura Abbott <labbott@redhat.com>, Boris Brezillon <boris.brezillon@bootlin.com>, Vlastimil Babka <vbabka@suse.cz>, Pintu Agarwal <pintu.ping@gmail.com>, Doug Berger <opendmb@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Mel Gorman <mgorman@suse.de>, Pavel Tatashin <pasha.tatashin@oracle.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

This commit adds rountines, that print KHWASAN error reports. Those are
quite similar to KASAN, the difference is:

1. The way KHWASAN finds the first bad shadow cell (with a mismatching
   tag). KHWASAN compares memory tags from the shadow memory to the pointer
   tag.

2. KHWASAN reports all bugs with the "KASAN: invalid-access" header. This
   is done, so various external tools that already parse the kernel logs
   looking for KASAN reports wouldn't need to be changed.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 include/linux/kasan.h     |  3 +++
 mm/kasan/kasan_report.c   |  7 ++---
 mm/kasan/khwasan_report.c | 21 +++++++++++++++
 mm/kasan/report.c         | 57 +++++++++++++++++++++------------------
 4 files changed, 57 insertions(+), 31 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index d7624b879d86..e209027f3b52 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -161,6 +161,9 @@ void *khwasan_set_tag(const void *addr, u8 tag);
 u8 khwasan_get_tag(const void *addr);
 void *khwasan_reset_tag(const void *ptr);
 
+void kasan_report(unsigned long addr, size_t size,
+			bool write, unsigned long ip);
+
 #else /* CONFIG_KASAN_HW */
 
 static inline void khwasan_init(void) { }
diff --git a/mm/kasan/kasan_report.c b/mm/kasan/kasan_report.c
index 2d8decbecbd5..fdf2d77e3125 100644
--- a/mm/kasan/kasan_report.c
+++ b/mm/kasan/kasan_report.c
@@ -33,10 +33,10 @@
 #include "kasan.h"
 #include "../slab.h"
 
-static const void *find_first_bad_addr(const void *addr, size_t size)
+void *find_first_bad_addr(void *addr, size_t size)
 {
 	u8 shadow_val = *(u8 *)kasan_mem_to_shadow(addr);
-	const void *first_bad_addr = addr;
+	void *first_bad_addr = addr;
 
 	while (!shadow_val && first_bad_addr < addr + size) {
 		first_bad_addr += KASAN_SHADOW_SCALE_SIZE;
@@ -50,9 +50,6 @@ static const char *get_shadow_bug_type(struct kasan_access_info *info)
 	const char *bug_type = "unknown-crash";
 	u8 *shadow_addr;
 
-	info->first_bad_addr = find_first_bad_addr(info->access_addr,
-						info->access_size);
-
 	shadow_addr = (u8 *)kasan_mem_to_shadow(info->first_bad_addr);
 
 	/*
diff --git a/mm/kasan/khwasan_report.c b/mm/kasan/khwasan_report.c
index 2edbc3c76be5..51238b404b08 100644
--- a/mm/kasan/khwasan_report.c
+++ b/mm/kasan/khwasan_report.c
@@ -37,3 +37,24 @@ const char *get_bug_type(struct kasan_access_info *info)
 {
 	return "invalid-access";
 }
+
+void *find_first_bad_addr(void *addr, size_t size)
+{
+	u8 tag = get_tag(addr);
+	void *untagged_addr = reset_tag(addr);
+	u8 *shadow = (u8 *)kasan_mem_to_shadow(untagged_addr);
+	void *first_bad_addr = untagged_addr;
+
+	while (*shadow == tag && first_bad_addr < untagged_addr + size) {
+		first_bad_addr += KASAN_SHADOW_SCALE_SIZE;
+		shadow = (u8 *)kasan_mem_to_shadow(first_bad_addr);
+	}
+	return first_bad_addr;
+}
+
+void print_tags(u8 addr_tag, const void *addr)
+{
+	u8 *shadow = (u8 *)kasan_mem_to_shadow(addr);
+
+	pr_err("Pointer tag: [%02x], memory tag: [%02x]\n", addr_tag, *shadow);
+}
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 155247a6f8a8..e031c78f2e52 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -64,11 +64,10 @@ static int __init kasan_set_multi_shot(char *str)
 }
 __setup("kasan_multi_shot", kasan_set_multi_shot);
 
-static void print_error_description(struct kasan_access_info *info,
-					const char *bug_type)
+static void print_error_description(struct kasan_access_info *info)
 {
 	pr_err("BUG: KASAN: %s in %pS\n",
-		bug_type, (void *)info->ip);
+		get_bug_type(info), (void *)info->ip);
 	pr_err("%s of size %zu at addr %px by task %s/%d\n",
 		info->is_write ? "Write" : "Read", info->access_size,
 		info->access_addr, current->comm, task_pid_nr(current));
@@ -272,6 +271,8 @@ void kasan_report_invalid_free(void *object, unsigned long ip)
 
 	start_report(&flags);
 	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", (void *)ip);
+	print_tags(get_tag(object), reset_tag(object));
+	object = reset_tag(object);
 	pr_err("\n");
 	print_address_description(object);
 	pr_err("\n");
@@ -279,41 +280,45 @@ void kasan_report_invalid_free(void *object, unsigned long ip)
 	end_report(&flags);
 }
 
-static void kasan_report_error(struct kasan_access_info *info)
-{
-	unsigned long flags;
-
-	start_report(&flags);
-
-	print_error_description(info, get_bug_type(info));
-	pr_err("\n");
-
-	if (!addr_has_shadow(info->access_addr)) {
-		dump_stack();
-	} else {
-		print_address_description((void *)info->access_addr);
-		pr_err("\n");
-		print_shadow_for_address(info->first_bad_addr);
-	}
-
-	end_report(&flags);
-}
-
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip)
 {
 	struct kasan_access_info info;
+	void *tagged_addr;
+	void *untagged_addr;
+	unsigned long flags;
 
 	if (likely(!report_enabled()))
 		return;
 
 	disable_trace_on_warning();
 
-	info.access_addr = (void *)addr;
-	info.first_bad_addr = (void *)addr;
+	tagged_addr = (void *)addr;
+	untagged_addr = reset_tag(tagged_addr);
+
+	info.access_addr = tagged_addr;
+	if (addr_has_shadow(untagged_addr))
+		info.first_bad_addr = find_first_bad_addr(tagged_addr, size);
+	else
+		info.first_bad_addr = untagged_addr;
 	info.access_size = size;
 	info.is_write = is_write;
 	info.ip = ip;
 
-	kasan_report_error(&info);
+	start_report(&flags);
+
+	print_error_description(&info);
+	if (addr_has_shadow(untagged_addr))
+		print_tags(get_tag(tagged_addr), info.first_bad_addr);
+	pr_err("\n");
+
+	if (addr_has_shadow(untagged_addr)) {
+		print_address_description(untagged_addr);
+		pr_err("\n");
+		print_shadow_for_address(info.first_bad_addr);
+	} else {
+		dump_stack();
+	}
+
+	end_report(&flags);
 }
-- 
2.17.0.921.gf22659ad46-goog
