Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 7D42D828F2
	for <linux-mm@kvack.org>; Fri,  8 Jan 2016 00:30:30 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id ho8so15320974pac.2
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 21:30:30 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id u89si2382308pfi.92.2016.01.07.21.30.29
        for <linux-mm@kvack.org>;
        Thu, 07 Jan 2016 21:30:29 -0800 (PST)
Date: Thu, 7 Jan 2016 21:30:29 -0800
From: "Luck, Tony" <tony.luck@intel.com>
Subject: Re: [PATCH v7 1/3] x86: Add classes to exception tables
Message-ID: <20160108053028.GA1833@agluck-desk.sc.intel.com>
References: <cover.1451952351.git.tony.luck@intel.com>
 <b5dc7a1ee68f48dc61c10959b2209851f6eb6aab.1451952351.git.tony.luck@intel.com>
 <20160106123346.GC19507@pd.tnic>
 <CALCETrVXD5YB_1UzR4LnSOCgV+ZzhDi9JRZrcxhMAjbvSzO6MQ@mail.gmail.com>
 <20160106175948.GA16647@pd.tnic>
 <CALCETrXsC9eiQ8yF555-8G88pYEms4bDsS060e24FoadAOK+kw@mail.gmail.com>
 <20160106194222.GC16647@pd.tnic>
 <20160107121131.GB23768@pd.tnic>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160107121131.GB23768@pd.tnic>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Borislav Petkov <bp@alien8.de>
Cc: Andy Lutomirski <luto@amacapital.net>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dan Williams <dan.j.williams@intel.com>, Robert <elliott@hpe.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-nvdimm <linux-nvdimm@ml01.01.org>, X86 ML <x86@kernel.org>

Also need some comment and Documentation/ changes:


diff --git a/Documentation/x86/exception-tables.txt b/Documentation/x86/exception-tables.txt
index 32901aa36f0a..ae47b9f64b8a 100644
--- a/Documentation/x86/exception-tables.txt
+++ b/Documentation/x86/exception-tables.txt
@@ -290,3 +290,37 @@ Due to the way that the exception table is built and needs to be ordered,
 only use exceptions for code in the .text section.  Any other section
 will cause the exception table to not be sorted correctly, and the
 exceptions will fail.
+
+Things changed when 64-bit support was added to x86 Linux. Rather than
+double the size of the exception table by expanding the two entries
+from 32-bits to 64 bits, a clever trick was used to store addreesses
+as relative offsets from the table itself. The assembly code changed
+from:
+	.long 1b,3b
+to:
+        .long (from) - .
+        .long (to) - .
+and the C-code that uses these values converts back to absolute addresses
+like this:
+	ex_insn_addr(const struct exception_table_entry *x)
+	{
+		return (unsigned long)&x->insn + x->insn;
+	}
+
+In v4.5 the exception table entry was given a new field "handler".
+This is also 32-bits wide and contains a table entry relative address
+of a handler function that can perform specific operations in addition
+to re-writing the instruction pointer to jump to the fixup location.
+Initially there are three such functions:
+
+1) int ex_handler_default(const struct exception_table_entry *fixup,
+   This is legacy case that just jumps to the fixup code
+2) int ex_handler_fault(const struct exception_table_entry *fixup,
+   This case provides the fault number of the trap that occured at
+   entry->insn. It is used to distinguish page faults from machine
+   check.
+3) int ex_handler_ext(const struct exception_table_entry *fixup,
+   This case is used to for uaccess_err ... we need to set a flag
+   in the task structure. Before the handler functions existed this
+   case was handled by adding a large offset to the fixup to tag
+   it as special.
diff --git a/arch/x86/include/asm/uaccess.h b/arch/x86/include/asm/uaccess.h
index b8f6f7545679..563443870915 100644
--- a/arch/x86/include/asm/uaccess.h
+++ b/arch/x86/include/asm/uaccess.h
@@ -90,12 +90,12 @@ static inline bool __chk_range_not_ok(unsigned long addr, unsigned long size, un
 	likely(!__range_not_ok(addr, size, user_addr_max()))
 
 /*
- * The exception table consists of pairs of addresses relative to the
+ * The exception table consists of triples of addresses relative to the
  * exception table enty itself: the first is the address of an
- * instruction that is allowed to fault, and the second is the address
- * at which the program should continue.  No registers are modified,
- * so it is entirely up to the continuation code to figure out what to
- * do.
+ * instruction that is allowed to fault, the second is the address
+ * at which the program should continue, the last is the address of
+ * a handler function to deal with the fault referenced by the instruction
+ * in the first field.
  *
  * All the routines below use bits of fixup code that are out of line
  * with the main instruction path.  This means when everything is well,
diff --git a/arch/x86/lib/memcpy_64.S b/arch/x86/lib/memcpy_64.S
index f057718d8d15..195ff0144152 100644
--- a/arch/x86/lib/memcpy_64.S
+++ b/arch/x86/lib/memcpy_64.S
@@ -310,4 +310,3 @@ ENTRY(__mcsafe_copy)
 	_ASM_EXTABLE_FAULT(12b,38b)
 	_ASM_EXTABLE_FAULT(18b,39b)
 	_ASM_EXTABLE_FAULT(21b,40b)
-#endif

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
