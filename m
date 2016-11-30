Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 86B276B0253
	for <linux-mm@kvack.org>; Wed, 30 Nov 2016 18:45:55 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 17so328597655pfy.2
        for <linux-mm@kvack.org>; Wed, 30 Nov 2016 15:45:55 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id n11si37788461plg.331.2016.11.30.15.45.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 30 Nov 2016 15:45:54 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH v2 1/6] tracing: add __print_flags_u64()
Date: Wed, 30 Nov 2016 16:45:28 -0700
Message-Id: <1480549533-29038-2-git-send-email-ross.zwisler@linux.intel.com>
In-Reply-To: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
References: <1480549533-29038-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Ingo Molnar <mingo@redhat.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, Steven Rostedt <rostedt@goodmis.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Add __print_flags_u64() and the helper trace_print_flags_seq_u64() in the
same spirit as __print_symbolic_u64() and trace_print_symbols_seq_u64().
These functions allow us to print symbols associated with flags that are 64
bits wide even on 32 bit machines.

These will be used by the DAX code so that we can print the flags set in a
pfn_t such as PFN_SG_CHAIN, PFN_SG_LAST, PFN_DEV and PFN_MAP.

Without this new function I was getting errors like the following when
compiling for i386:

./include/linux/pfn_t.h:13:22: warning: large integer implicitly truncated
to unsigned type [-Woverflow]
 #define PFN_SG_CHAIN (1ULL << (BITS_PER_LONG_LONG - 1))
  ^

Signed-off-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 include/linux/trace_events.h |  4 ++++
 include/trace/trace_events.h | 11 +++++++++++
 kernel/trace/trace_output.c  | 38 ++++++++++++++++++++++++++++++++++++++
 3 files changed, 53 insertions(+)

diff --git a/include/linux/trace_events.h b/include/linux/trace_events.h
index be00761..db2c3ba 100644
--- a/include/linux/trace_events.h
+++ b/include/linux/trace_events.h
@@ -23,6 +23,10 @@ const char *trace_print_symbols_seq(struct trace_seq *p, unsigned long val,
 				    const struct trace_print_flags *symbol_array);
 
 #if BITS_PER_LONG == 32
+const char *trace_print_flags_seq_u64(struct trace_seq *p, const char *delim,
+		      unsigned long long flags,
+		      const struct trace_print_flags_u64 *flag_array);
+
 const char *trace_print_symbols_seq_u64(struct trace_seq *p,
 					unsigned long long val,
 					const struct trace_print_flags_u64
diff --git a/include/trace/trace_events.h b/include/trace/trace_events.h
index 467e12f..c6e9f72 100644
--- a/include/trace/trace_events.h
+++ b/include/trace/trace_events.h
@@ -283,8 +283,16 @@ TRACE_MAKE_SYSTEM_STR();
 		trace_print_symbols_seq(p, value, symbols);		\
 	})
 
+#undef __print_flags_u64
 #undef __print_symbolic_u64
 #if BITS_PER_LONG == 32
+#define __print_flags_u64(flag, delim, flag_array...)			\
+	({								\
+		static const struct trace_print_flags_u64 __flags[] =	\
+			{ flag_array, { -1, NULL } };			\
+		trace_print_flags_seq_u64(p, delim, flag, __flags);	\
+	})
+
 #define __print_symbolic_u64(value, symbol_array...)			\
 	({								\
 		static const struct trace_print_flags_u64 symbols[] =	\
@@ -292,6 +300,9 @@ TRACE_MAKE_SYSTEM_STR();
 		trace_print_symbols_seq_u64(p, value, symbols);	\
 	})
 #else
+#define __print_flags_u64(flag, delim, flag_array...)			\
+			__print_flags(flag, delim, flag_array)
+
 #define __print_symbolic_u64(value, symbol_array...)			\
 			__print_symbolic(value, symbol_array)
 #endif
diff --git a/kernel/trace/trace_output.c b/kernel/trace/trace_output.c
index 3fc2042..ed4398f 100644
--- a/kernel/trace/trace_output.c
+++ b/kernel/trace/trace_output.c
@@ -124,6 +124,44 @@ EXPORT_SYMBOL(trace_print_symbols_seq);
 
 #if BITS_PER_LONG == 32
 const char *
+trace_print_flags_seq_u64(struct trace_seq *p, const char *delim,
+		      unsigned long long flags,
+		      const struct trace_print_flags_u64 *flag_array)
+{
+	unsigned long mask;
+	const char *str;
+	const char *ret = trace_seq_buffer_ptr(p);
+	int i, first = 1;
+
+	for (i = 0;  flag_array[i].name && flags; i++) {
+
+		mask = flag_array[i].mask;
+		if ((flags & mask) != mask)
+			continue;
+
+		str = flag_array[i].name;
+		flags &= ~mask;
+		if (!first && delim)
+			trace_seq_puts(p, delim);
+		else
+			first = 0;
+		trace_seq_puts(p, str);
+	}
+
+	/* check for left over flags */
+	if (flags) {
+		if (!first && delim)
+			trace_seq_puts(p, delim);
+		trace_seq_printf(p, "0x%llx", flags);
+	}
+
+	trace_seq_putc(p, 0);
+
+	return ret;
+}
+EXPORT_SYMBOL(trace_print_flags_seq_u64);
+
+const char *
 trace_print_symbols_seq_u64(struct trace_seq *p, unsigned long long val,
 			 const struct trace_print_flags_u64 *symbol_array)
 {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
