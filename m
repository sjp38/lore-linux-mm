From: Paul Davies <pauld@gelato.unsw.edu.au>
Date: Sat, 13 Jan 2007 13:48:46 +1100
Message-Id: <20070113024846.29682.42796.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
In-Reply-To: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
References: <20070113024540.29682.27024.sendpatchset@weill.orchestra.cse.unsw.EDU.AU>
Subject: [PATCH 1/12] Alternate page table implementation (GPT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Paul Davies <pauld@gelato.unsw.edu.au>
List-ID: <linux-mm.kvack.org>

PATCH GPT 01
 * The GPT itself is not being commented in these patches, just how
 to fit this page table implementation in under the interface, next
 to the default page table.
   * Any queries regarding GPTs are best directed to 
   awiggins@cse.unsw.edu.au
 * Add GPT option as alternative to the default page table for IA64
 * Create include/asm-ia64/pgtable-gpt.h for GPT specific pgtable.h
 code.

Signed-Off-By: Paul Davies <pauld@gelato.unsw.edu.au>

---

 arch/ia64/Kconfig.debug        |    3 
 include/asm-ia64/pgtable-gpt.h |  157 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 160 insertions(+)
Index: linux-2.6.20-rc4/arch/ia64/Kconfig.debug
===================================================================
--- linux-2.6.20-rc4.orig/arch/ia64/Kconfig.debug	2007-01-11 16:46:47.662747000 +1100
+++ linux-2.6.20-rc4/arch/ia64/Kconfig.debug	2007-01-11 16:58:15.245390000 +1100
@@ -9,6 +9,9 @@
 config  PT_DEFAULT
 	bool "PT_DEFAULT"
 
+config  GPT
+	bool "GPT"
+
 endchoice
 
 choice
Index: linux-2.6.20-rc4/include/asm-ia64/pgtable-gpt.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6.20-rc4/include/asm-ia64/pgtable-gpt.h	2007-01-11 18:57:09.215823000 +1100
@@ -0,0 +1,157 @@
+/**
+ *  include/asm-ia64/pgtable-gpt.h
+ *
+ *  Copyright (C) 2005 - 2006 University of New South Wales, Australia
+ *      Adam 'WeirdArms' Wiggins <awiggins@cse.unsw.edu.au>,
+ */
+
+#ifndef _ASM_IA64_PGTABLE_GPT_H
+#define _ASM_IA64_PGTABLE_GPT_H
+
+#ifndef __ASSEMBLY__
+
+#include <linux/types.h>
+
+#define RGN_MAP_SHIFT 55
+#define ALIGNVAL (1UL << 25)
+
+typedef uint64_t gpt_key_value_t;
+
+typedef struct {
+	uint64_t _pad:    6;
+	uint64_t length:  6;
+	uint64_t value:  52;
+} gpt_key_t;
+
+static inline gpt_key_t
+gpt_key_init(gpt_key_value_t value, int8_t length)
+{
+	gpt_key_t key;
+
+	key.value = value;
+	key.length = length;
+	key._pad = 0;
+
+	return key;
+}
+
+static inline gpt_key_t
+gpt_key_null(void)
+{
+	return gpt_key_init(0, 0);
+}
+
+static inline gpt_key_value_t
+gpt_key_read_value(gpt_key_t key)
+{
+	return key.value;
+}
+
+static inline int8_t
+gpt_key_read_length(gpt_key_t key)
+{
+	return key.length;
+}
+
+static inline gpt_key_value_t
+gpt_key_value_mask(int8_t coverage)
+{
+	return (coverage < GPT_KEY_LENGTH_MAX) ?
+		~(((gpt_key_value_t)1 << coverage) - (gpt_key_value_t)1) : 0;
+}
+
+static inline int
+gpt_key_compare_null(gpt_key_t key)
+{
+	return gpt_key_read_length(key) == 0;
+}
+
+static inline gpt_key_t
+gpt_key_cut_LSB(int8_t length_lsb, gpt_key_t key)
+{
+	int8_t length;
+	gpt_key_value_t value;
+
+	value = gpt_key_read_value(key);
+	length = gpt_key_read_length(key);
+	if(length_lsb > length) {
+		return gpt_key_null();
+	}
+	length -= length_lsb;
+	value >>= length_lsb;
+	return gpt_key_init(value, length);
+}
+
+static inline gpt_key_t
+gpt_key_cut_LSB2(int8_t length_lsb, gpt_key_t* key_u)
+{
+	int8_t length;
+	gpt_key_value_t value;
+
+	value = gpt_key_read_value(*key_u);
+	length = gpt_key_read_length(*key_u);
+	if(length_lsb > length) {
+		length_lsb = length;
+	}
+	length -= length_lsb;
+	*key_u = ((length == 0) ? gpt_key_null() :
+			  gpt_key_init(value >> length_lsb, length));
+	return gpt_key_init(value & ~gpt_key_value_mask(length_lsb),
+			length_lsb);
+}
+
+static inline gpt_key_t
+gpt_keys_merge_MSB(gpt_key_t key_lsb, gpt_key_t key)
+{
+	int8_t length, length_lsb;
+	gpt_key_value_t value;
+
+	value = gpt_key_read_value(key);
+	length = gpt_key_read_length(key);
+	length_lsb = gpt_key_read_length(key_lsb);
+	value = (value << length_lsb) + gpt_key_read_value(key_lsb);
+	length += length_lsb;
+	return gpt_key_init(value, length);
+}
+
+static inline gpt_key_t
+gpt_keys_merge_LSB(gpt_key_t key_msb, gpt_key_t key)
+{
+    int8_t length;
+	gpt_key_value_t value;
+
+	value = gpt_key_read_value(key);
+	length = gpt_key_read_length(key);
+	value = (gpt_key_read_value(key_msb) << length) + value;
+	length += gpt_key_read_length(key_msb);
+	return gpt_key_init(value, length);
+}
+
+static inline int
+gptKeysCompareEqual(gpt_key_t key1, gpt_key_t key2)
+{
+	return ((gpt_key_read_length(key1) == gpt_key_read_length(key2)) &&
+            (gpt_key_read_value(key1) == gpt_key_read_value(key2)));
+}
+
+
+/* awiggins (2006-06-23): Massage in a little better, also optimise for ia64. */
+#define WORD_BIT 64
+static inline size_t
+gpt_ctlz(uint64_t n, int8_t msb)
+{
+	int8_t i;
+
+	if(msb > WORD_BIT) msb = WORD_BIT;
+	for(i = 0; i <= msb; i++) {
+		/* Check most significant bit is zero. */
+		if(n & (uint64_t)1 << msb) break;
+		/* Shift to the next test bit. */
+		n <<= 1;
+	}
+	return i;
+}
+
+#endif /* !__ASSEMBLY__ */
+
+#endif /* !_ASM_PGTABLE_GPT_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
