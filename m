Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f199.google.com (mail-lb0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 700716B025E
	for <linux-mm@kvack.org>; Mon, 30 May 2016 19:24:53 -0400 (EDT)
Received: by mail-lb0-f199.google.com with SMTP id q17so90593634lbn.3
        for <linux-mm@kvack.org>; Mon, 30 May 2016 16:24:53 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id n124si33325288wma.8.2016.05.30.16.24.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 May 2016 16:24:51 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id e3so27035177wme.2
        for <linux-mm@kvack.org>; Mon, 30 May 2016 16:24:51 -0700 (PDT)
Date: Tue, 31 May 2016 01:31:45 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: [PATCH v2 1/3] Add the latent_entropy gcc plugin
Message-Id: <20160531013145.612696c12f2ef744af739803@gmail.com>
In-Reply-To: <20160531013029.4c5db8b570d86527b0b53fe4@gmail.com>
References: <20160531013029.4c5db8b570d86527b0b53fe4@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: kernel-hardening@lists.openwall.com
Cc: pageexec@freemail.hu, spender@grsecurity.net, mmarek@suse.com, keescook@chromium.org, linux-kernel@vger.kernel.org, yamada.masahiro@socionext.com, linux-kbuild@vger.kernel.org, tytso@mit.edu, akpm@linux-foundation.org, linux-mm@kvack.org, axboe@kernel.dk, viro@zeniv.linux.org.uk, paulmck@linux.vnet.ibm.com, mingo@redhat.com, tglx@linutronix.de, bart.vanassche@sandisk.com, davem@davemloft.net

This plugin mitigates the problem of the kernel having too little entropy during
and after boot for generating crypto keys.

It creates a local variable in every marked function. The value of this variable is
modified by randomly chosen operations (add, xor and rol) and
random values (gcc generates them at compile time and the stack pointer at runtime).
It depends on the control flow (e.g., loops, conditions).

Before the function returns the plugin writes this local variable
into the latent_entropy global variable. The value of this global variable is
added to the kernel entropy pool in do_one_initcall() and _do_fork().

Signed-off-by: Emese Revfy <re.emese@gmail.com>
---
 arch/Kconfig                                |  18 ++
 arch/powerpc/kernel/Makefile                |   8 +-
 include/linux/random.h                      |  10 +
 init/main.c                                 |   1 +
 kernel/fork.c                               |   1 +
 mm/page_alloc.c                             |   5 +
 scripts/Makefile.gcc-plugins                |  10 +-
 scripts/gcc-plugins/Makefile                |   1 +
 scripts/gcc-plugins/latent_entropy_plugin.c | 454 ++++++++++++++++++++++++++++
 9 files changed, 502 insertions(+), 6 deletions(-)
 create mode 100644 scripts/gcc-plugins/latent_entropy_plugin.c

diff --git a/arch/Kconfig b/arch/Kconfig
index 5feadad..7115867 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -393,6 +393,24 @@ config GCC_PLUGIN_SANCOV
 	  gcc-4.5 on). It is based on the commit "Add fuzzing coverage support"
 	  by Dmitry Vyukov <dvyukov@google.com>.
 
+config GCC_PLUGIN_LATENT_ENTROPY
+	bool "Generate some entropy during boot and runtime"
+	depends on GCC_PLUGINS
+	help
+	  By saying Y here the kernel will instrument some kernel code to
+	  extract some entropy from both original and artificially created
+	  program state.  This will help especially embedded systems where
+	  there is little 'natural' source of entropy normally.  The cost
+	  is some slowdown of the boot process (about 0.5%) and fork and
+	  irq processing.
+
+	  Note that entropy extracted this way is not known to be cryptographically
+	  secure!
+
+	  This plugin was ported from grsecurity/PaX. More information at:
+	   * https://grsecurity.net/
+	   * https://pax.grsecurity.net/
+
 config HAVE_CC_STACKPROTECTOR
 	bool
 	help
diff --git a/arch/powerpc/kernel/Makefile b/arch/powerpc/kernel/Makefile
index 2da380f..6c7e448 100644
--- a/arch/powerpc/kernel/Makefile
+++ b/arch/powerpc/kernel/Makefile
@@ -16,10 +16,10 @@ endif
 
 ifdef CONFIG_FUNCTION_TRACER
 # Do not trace early boot code
-CFLAGS_REMOVE_cputable.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
-CFLAGS_REMOVE_prom_init.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
-CFLAGS_REMOVE_btext.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
-CFLAGS_REMOVE_prom.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
+CFLAGS_REMOVE_cputable.o = -mno-sched-epilog $(CC_FLAGS_FTRACE) $(DISABLE_LATENT_ENTROPY_PLUGIN)
+CFLAGS_REMOVE_prom_init.o = -mno-sched-epilog $(CC_FLAGS_FTRACE) $(DISABLE_LATENT_ENTROPY_PLUGIN)
+CFLAGS_REMOVE_btext.o = -mno-sched-epilog $(CC_FLAGS_FTRACE) $(DISABLE_LATENT_ENTROPY_PLUGIN)
+CFLAGS_REMOVE_prom.o = -mno-sched-epilog $(CC_FLAGS_FTRACE) $(DISABLE_LATENT_ENTROPY_PLUGIN)
 # do not trace tracer code
 CFLAGS_REMOVE_ftrace.o = -mno-sched-epilog $(CC_FLAGS_FTRACE)
 # timers used by tracing
diff --git a/include/linux/random.h b/include/linux/random.h
index e47e533..4ea73ee 100644
--- a/include/linux/random.h
+++ b/include/linux/random.h
@@ -18,6 +18,16 @@ struct random_ready_callback {
 };
 
 extern void add_device_randomness(const void *, unsigned int);
+
+#ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
+static inline void add_latent_entropy(void)
+{
+	add_device_randomness((const void *)&latent_entropy, sizeof(latent_entropy));
+}
+#else
+static inline void add_latent_entropy(void) {}
+#endif
+
 extern void add_input_randomness(unsigned int type, unsigned int code,
 				 unsigned int value);
 extern void add_interrupt_randomness(int irq, int irq_flags);
diff --git a/init/main.c b/init/main.c
index 4c17fda..07e4174 100644
--- a/init/main.c
+++ b/init/main.c
@@ -781,6 +781,7 @@ int __init_or_module do_one_initcall(initcall_t fn)
 	}
 	WARN(msgbuf[0], "initcall %pF returned with %s\n", fn, msgbuf);
 
+	add_latent_entropy();
 	return ret;
 }
 
diff --git a/kernel/fork.c b/kernel/fork.c
index cdf520f..d07d5a6 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -1766,6 +1766,7 @@ long _do_fork(unsigned long clone_flags,
 
 	p = copy_process(clone_flags, stack_start, stack_size,
 			 child_tidptr, NULL, trace, tls, NUMA_NO_NODE);
+	add_latent_entropy();
 	/*
 	 * Do this prior waking up the new thread - the thread pointer
 	 * might get invalid after that point, if the thread exits quickly.
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index f8f3bfc..d10324e 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1234,6 +1234,11 @@ static void __free_pages_ok(struct page *page, unsigned int order)
 	local_irq_restore(flags);
 }
 
+#ifdef CONFIG_GCC_PLUGIN_LATENT_ENTROPY
+volatile u64 latent_entropy;
+EXPORT_SYMBOL(latent_entropy);
+#endif
+
 static void __init __free_pages_boot_core(struct page *page, unsigned int order)
 {
 	unsigned int nr_pages = 1 << order;
diff --git a/scripts/Makefile.gcc-plugins b/scripts/Makefile.gcc-plugins
index 5e22b60..cd7902c 100644
--- a/scripts/Makefile.gcc-plugins
+++ b/scripts/Makefile.gcc-plugins
@@ -6,6 +6,12 @@ ifdef CONFIG_GCC_PLUGINS
 
   gcc-plugin-$(CONFIG_GCC_PLUGIN_CYC_COMPLEXITY)	+= cyc_complexity_plugin.so
 
+  gcc-plugin-$(CONFIG_GCC_PLUGIN_LATENT_ENTROPY)	+= latent_entropy_plugin.so
+  gcc-plugin-cflags-$(CONFIG_GCC_PLUGIN_LATENT_ENTROPY)	+= -DLATENT_ENTROPY_PLUGIN
+  ifdef CONFIG_PAX_LATENT_ENTROPY
+    DISABLE_LATENT_ENTROPY_PLUGIN			+= -fplugin-arg-latent_entropy_plugin-disable
+  endif
+
   ifdef CONFIG_GCC_PLUGIN_SANCOV
     ifeq ($(CFLAGS_KCOV),)
       # It is needed because of the gcc-plugin.sh and gcc version checks.
@@ -19,9 +25,9 @@ ifdef CONFIG_GCC_PLUGINS
     endif
   endif
 
-  GCC_PLUGINS_CFLAGS := $(addprefix -fplugin=$(objtree)/scripts/gcc-plugins/, $(gcc-plugin-y))
+  GCC_PLUGINS_CFLAGS := $(strip $(addprefix -fplugin=$(objtree)/scripts/gcc-plugins/, $(gcc-plugin-y)) $(gcc-plugin-cflags-y))
 
-  export PLUGINCC GCC_PLUGINS_CFLAGS GCC_PLUGIN SANCOV_PLUGIN
+  export PLUGINCC GCC_PLUGINS_CFLAGS GCC_PLUGIN SANCOV_PLUGIN DISABLE_LATENT_ENTROPY_PLUGIN
 
   ifeq ($(PLUGINCC),)
     ifneq ($(GCC_PLUGINS_CFLAGS),)
diff --git a/scripts/gcc-plugins/Makefile b/scripts/gcc-plugins/Makefile
index 88c8ec4..a3f8ca4a 100644
--- a/scripts/gcc-plugins/Makefile
+++ b/scripts/gcc-plugins/Makefile
@@ -23,5 +23,6 @@ always := $($(HOSTLIBS)-y)
 
 cyc_complexity_plugin-objs := cyc_complexity_plugin.o
 sancov_plugin-objs := sancov_plugin.o
+latent_entropy_plugin-objs := latent_entropy_plugin.o
 
 clean-files += *.so
diff --git a/scripts/gcc-plugins/latent_entropy_plugin.c b/scripts/gcc-plugins/latent_entropy_plugin.c
new file mode 100644
index 0000000..f606caa
--- /dev/null
+++ b/scripts/gcc-plugins/latent_entropy_plugin.c
@@ -0,0 +1,454 @@
+/*
+ * Copyright 2012-2016 by the PaX Team <pageexec@freemail.hu>
+ * Copyright 2016 by Emese Revfy <re.emese@gmail.com>
+ * Licensed under the GPL v2
+ *
+ * Note: the choice of the license means that the compilation process is
+ *       NOT 'eligible' as defined by gcc's library exception to the GPL v3,
+ *       but for the kernel it doesn't matter since it doesn't link against
+ *       any of the gcc libraries
+ *
+ * gcc plugin to help generate a little bit of entropy from program state,
+ * used throughout the uptime of the kernel
+ *
+ * TODO:
+ * - add ipa pass to identify not explicitly marked candidate functions
+ * - mix in more program state (function arguments/return values, loop variables, etc)
+ * - more instrumentation control via attribute parameters
+ *
+ * BUGS:
+ * - none known
+ *
+ * Options:
+ * -fplugin-arg-latent_entropy_plugin-disable
+ *
+ * Attribute: __attribute__((latent_entropy))
+ *  The latent_entropy gcc attribute can be only on functions and variables.
+ *  If it is on a function then the plugin will instrument it. If the attribute
+ *  is on a variable then the plugin will initialize it with a random value.
+ *  The variable must be an integer, an integer array type or a structure with integer fields.
+ */
+
+#include "gcc-common.h"
+
+int plugin_is_GPL_compatible;
+
+static GTY(()) tree latent_entropy_decl;
+
+static struct plugin_info latent_entropy_plugin_info = {
+	.version	= "201605292100",
+	.help		= "disable\tturn off latent entropy instrumentation\n",
+};
+
+static unsigned HOST_WIDE_INT seed;
+static unsigned HOST_WIDE_INT get_random_const(void)
+{
+	unsigned int i;
+	unsigned HOST_WIDE_INT ret = 0;
+
+	for (i = 0; i < 8 * sizeof ret; i++) {
+		ret = (ret << 1) | (seed & 1);
+		seed >>= 1;
+		if (ret & 1)
+			seed ^= 0xD800000000000000ULL;
+	}
+
+	return ret;
+}
+
+static tree handle_latent_entropy_attribute(tree *node, tree name, tree args __unused, int flags __unused, bool *no_add_attrs)
+{
+	tree type;
+	unsigned long long mask;
+#if BUILDING_GCC_VERSION <= 4007
+	VEC(constructor_elt, gc) *vals;
+#else
+	vec<constructor_elt, va_gc> *vals;
+#endif
+
+	switch (TREE_CODE(*node)) {
+	default:
+		*no_add_attrs = true;
+		error("%qE attribute only applies to functions and variables", name);
+		break;
+
+	case VAR_DECL:
+		if (DECL_INITIAL(*node)) {
+			*no_add_attrs = true;
+			error("variable %qD with %qE attribute must not be initialized", *node, name);
+			break;
+		}
+
+		if (!TREE_STATIC(*node)) {
+			*no_add_attrs = true;
+			error("variable %qD with %qE attribute must not be local", *node, name);
+			break;
+		}
+
+		type = TREE_TYPE(*node);
+		switch (TREE_CODE(type)) {
+		default:
+			*no_add_attrs = true;
+			error("variable %qD with %qE attribute must be an integer or a fixed length integer array type"
+				"or a fixed sized structure with integer fields", *node, name);
+			break;
+
+		case RECORD_TYPE: {
+			tree field;
+			unsigned int nelt = 0;
+
+			for (field = TYPE_FIELDS(type); field; nelt++, field = TREE_CHAIN(field)) {
+				tree fieldtype;
+
+				fieldtype = TREE_TYPE(field);
+				if (TREE_CODE(fieldtype) == INTEGER_TYPE)
+					continue;
+
+				*no_add_attrs = true;
+				error("structure variable %qD with %qE attribute has a non-integer field %qE", *node, name, field);
+				break;
+			}
+
+			if (field)
+				break;
+
+#if BUILDING_GCC_VERSION <= 4007
+			vals = VEC_alloc(constructor_elt, gc, nelt);
+#else
+			vec_alloc(vals, nelt);
+#endif
+
+			for (field = TYPE_FIELDS(type); field; field = TREE_CHAIN(field)) {
+				tree fieldtype;
+
+				fieldtype = TREE_TYPE(field);
+				mask = 1ULL << (TREE_INT_CST_LOW(TYPE_SIZE(fieldtype)) - 1);
+				mask = 2 * (mask - 1) + 1;
+
+				if (TYPE_UNSIGNED(fieldtype))
+					CONSTRUCTOR_APPEND_ELT(vals, field, build_int_cstu(fieldtype, mask & get_random_const()));
+				else
+					CONSTRUCTOR_APPEND_ELT(vals, field, build_int_cst(fieldtype, mask & get_random_const()));
+			}
+
+			DECL_INITIAL(*node) = build_constructor(type, vals);
+			break;
+		}
+
+		case INTEGER_TYPE:
+			mask = 1ULL << (TREE_INT_CST_LOW(TYPE_SIZE(type)) - 1);
+			mask = 2 * (mask - 1) + 1;
+
+			if (TYPE_UNSIGNED(type))
+				DECL_INITIAL(*node) = build_int_cstu(type, mask & get_random_const());
+			else
+				DECL_INITIAL(*node) = build_int_cst(type, mask & get_random_const());
+			break;
+
+		case ARRAY_TYPE: {
+			tree elt_type, array_size, elt_size;
+			unsigned int i, nelt;
+
+			elt_type = TREE_TYPE(type);
+			elt_size = TYPE_SIZE_UNIT(TREE_TYPE(type));
+			array_size = TYPE_SIZE_UNIT(type);
+
+			if (TREE_CODE(elt_type) != INTEGER_TYPE || !array_size || TREE_CODE(array_size) != INTEGER_CST) {
+				*no_add_attrs = true;
+				error("array variable %qD with %qE attribute must be a fixed length integer array type", *node, name);
+				break;
+			}
+
+			nelt = TREE_INT_CST_LOW(array_size) / TREE_INT_CST_LOW(elt_size);
+#if BUILDING_GCC_VERSION <= 4007
+			vals = VEC_alloc(constructor_elt, gc, nelt);
+#else
+			vec_alloc(vals, nelt);
+#endif
+
+			mask = 1ULL << (TREE_INT_CST_LOW(TYPE_SIZE(elt_type)) - 1);
+			mask = 2 * (mask - 1) + 1;
+
+			for (i = 0; i < nelt; i++)
+				if (TYPE_UNSIGNED(elt_type))
+					CONSTRUCTOR_APPEND_ELT(vals, size_int(i), build_int_cstu(elt_type, mask & get_random_const()));
+				else
+					CONSTRUCTOR_APPEND_ELT(vals, size_int(i), build_int_cst(elt_type, mask & get_random_const()));
+
+			DECL_INITIAL(*node) = build_constructor(type, vals);
+			break;
+		}
+		}
+		break;
+
+	case FUNCTION_DECL:
+		break;
+	}
+
+	return NULL_TREE;
+}
+
+static struct attribute_spec latent_entropy_attr = {
+	.name				= "latent_entropy",
+	.min_length			= 0,
+	.max_length			= 0,
+	.decl_required			= true,
+	.type_required			= false,
+	.function_type_required		= false,
+	.handler			= handle_latent_entropy_attribute,
+#if BUILDING_GCC_VERSION >= 4007
+	.affects_type_identity		= false
+#endif
+};
+
+static void register_attributes(void *event_data __unused, void *data __unused)
+{
+	register_attribute(&latent_entropy_attr);
+}
+
+static bool latent_entropy_gate(void)
+{
+	/* don't bother with noreturn functions for now */
+	if (TREE_THIS_VOLATILE(current_function_decl))
+		return false;
+
+	/* gcc-4.5 doesn't discover some trivial noreturn functions */
+	if (EDGE_COUNT(EXIT_BLOCK_PTR_FOR_FN(cfun)->preds) == 0)
+		return false;
+
+	return lookup_attribute("latent_entropy", DECL_ATTRIBUTES(current_function_decl)) != NULL_TREE;
+}
+
+static tree create_a_tmp_var(tree type, const char *name)
+{
+	tree var;
+
+	var = create_tmp_var(type, name);
+	add_referenced_var(var);
+	mark_sym_for_renaming(var);
+	return var;
+}
+
+static enum tree_code get_op(tree *rhs)
+{
+	static enum tree_code op;
+	unsigned HOST_WIDE_INT random_const;
+
+	random_const = get_random_const();
+
+	switch (op) {
+	case BIT_XOR_EXPR:
+		op = PLUS_EXPR;
+		break;
+
+	case PLUS_EXPR:
+		if (rhs) {
+			op = LROTATE_EXPR;
+			random_const &= HOST_BITS_PER_WIDE_INT - 1;
+			break;
+		}
+
+	case LROTATE_EXPR:
+	default:
+		op = BIT_XOR_EXPR;
+		break;
+	}
+	if (rhs)
+		*rhs = build_int_cstu(unsigned_intDI_type_node, random_const);
+	return op;
+}
+
+static void perturb_local_entropy(basic_block bb, tree local_entropy)
+{
+	gimple_stmt_iterator gsi;
+	gimple assign;
+	tree rhs;
+	enum tree_code subcode;
+
+	subcode = get_op(&rhs);
+	assign = gimple_build_assign_with_ops(subcode, local_entropy, local_entropy, rhs);
+	gsi = gsi_after_labels(bb);
+	gsi_insert_before(&gsi, assign, GSI_NEW_STMT);
+	update_stmt(assign);
+}
+
+static void perturb_latent_entropy(basic_block bb, tree rhs)
+{
+	gimple_stmt_iterator gsi;
+	gimple assign;
+	tree temp;
+	enum tree_code subcode;
+
+	/* create temporary copy of latent_entropy */
+	temp = create_a_tmp_var(unsigned_intDI_type_node, "temp_latent_entropy");
+
+	gsi = gsi_last_bb(bb);
+
+	/* 1. read... */
+	add_referenced_var(latent_entropy_decl);
+	mark_sym_for_renaming(latent_entropy_decl);
+	assign = gimple_build_assign(temp, latent_entropy_decl);
+	gsi_insert_before(&gsi, assign, GSI_NEW_STMT);
+	update_stmt(assign);
+
+	/* 2. ...modify... */
+	subcode = get_op(NULL);
+	assign = gimple_build_assign_with_ops(subcode, temp, temp, rhs);
+	gsi_insert_after(&gsi, assign, GSI_NEW_STMT);
+	update_stmt(assign);
+
+	/* 3. ...write latent_entropy */
+	assign = gimple_build_assign(latent_entropy_decl, temp);
+	gsi_insert_after(&gsi, assign, GSI_NEW_STMT);
+	update_stmt(assign);
+}
+
+static void mix_in_sp(basic_block bb, tree local_entropy)
+{
+	gimple assign, call;
+	tree frame_addr, rand_const;
+	gimple_stmt_iterator gsi = gsi_after_labels(bb);
+
+	frame_addr = create_a_tmp_var(ptr_type_node, "local_entropy_frame_addr");
+
+	call = gimple_build_call(builtin_decl_implicit(BUILT_IN_FRAME_ADDRESS), 1, integer_zero_node);
+	gimple_call_set_lhs(call, frame_addr);
+	gsi_insert_before(&gsi, call, GSI_NEW_STMT);
+	update_stmt(call);
+
+	assign = gimple_build_assign(local_entropy, fold_convert(unsigned_intDI_type_node, frame_addr));
+	gsi_insert_after(&gsi, assign, GSI_NEW_STMT);
+	update_stmt(assign);
+
+	rand_const = build_int_cstu(unsigned_intDI_type_node, get_random_const());
+	assign = gimple_build_assign_with_ops(BIT_XOR_EXPR, local_entropy, local_entropy, rand_const);
+	gsi_insert_after(&gsi, assign, GSI_NEW_STMT);
+	update_stmt(assign);
+}
+
+static unsigned int latent_entropy_execute(void)
+{
+	basic_block bb;
+	tree local_entropy;
+
+	if (!latent_entropy_decl) {
+		varpool_node_ptr node;
+
+		FOR_EACH_VARIABLE(node) {
+			tree var = NODE_DECL(node);
+
+			if (DECL_NAME_LENGTH(var) < sizeof("latent_entropy") - 1)
+				continue;
+			if (strcmp(IDENTIFIER_POINTER(DECL_NAME(var)), "latent_entropy"))
+				continue;
+			latent_entropy_decl = var;
+			break;
+		}
+		if (!latent_entropy_decl)
+			return 0;
+	}
+
+	gcc_assert(single_succ_p(ENTRY_BLOCK_PTR_FOR_FN(cfun)));
+	bb = single_succ(ENTRY_BLOCK_PTR_FOR_FN(cfun));
+	if (!single_pred_p(bb)) {
+		split_edge(single_succ_edge(ENTRY_BLOCK_PTR_FOR_FN(cfun)));
+		gcc_assert(single_succ_p(ENTRY_BLOCK_PTR_FOR_FN(cfun)));
+		bb = single_succ(ENTRY_BLOCK_PTR_FOR_FN(cfun));
+	}
+
+	/* create local entropy variable */
+	local_entropy = create_a_tmp_var(unsigned_intDI_type_node, "local_entropy");
+
+	/* 1. stack pointer */
+	mix_in_sp(bb, local_entropy);
+
+	bb = bb->next_bb;
+	/* 2. instrument each BB with an operation on the local entropy variable */
+	while (bb != EXIT_BLOCK_PTR_FOR_FN(cfun)) {
+		perturb_local_entropy(bb, local_entropy);
+		bb = bb->next_bb;
+	};
+
+	/* 3. mix local entropy into the global entropy variable */
+	gcc_assert(single_pred_p(EXIT_BLOCK_PTR_FOR_FN(cfun)));
+	perturb_latent_entropy(single_pred(EXIT_BLOCK_PTR_FOR_FN(cfun)), local_entropy);
+	return 0;
+}
+
+static void latent_entropy_start_unit(void *gcc_data __unused, void *user_data __unused)
+{
+	tree latent_entropy_type;
+
+	seed = get_random_seed(false);
+
+	if (in_lto_p)
+		return;
+
+	/* extern volatile u64 latent_entropy */
+	gcc_assert(TYPE_PRECISION(long_long_unsigned_type_node) == 64);
+	latent_entropy_type = build_qualified_type(long_long_unsigned_type_node, TYPE_QUALS(long_long_unsigned_type_node) | TYPE_QUAL_VOLATILE);
+	latent_entropy_decl = build_decl(UNKNOWN_LOCATION, VAR_DECL, get_identifier("latent_entropy"), latent_entropy_type);
+
+	TREE_STATIC(latent_entropy_decl) = 1;
+	TREE_PUBLIC(latent_entropy_decl) = 1;
+	TREE_USED(latent_entropy_decl) = 1;
+	DECL_PRESERVE_P(latent_entropy_decl) = 1;
+	TREE_THIS_VOLATILE(latent_entropy_decl) = 1;
+	DECL_EXTERNAL(latent_entropy_decl) = 1;
+	DECL_ARTIFICIAL(latent_entropy_decl) = 1;
+	lang_hooks.decls.pushdecl(latent_entropy_decl);
+}
+
+#define PASS_NAME latent_entropy
+#define PROPERTIES_REQUIRED PROP_gimple_leh | PROP_cfg
+#define TODO_FLAGS_FINISH TODO_verify_ssa | TODO_verify_stmts | TODO_dump_func | TODO_update_ssa
+#include "gcc-generate-gimple-pass.h"
+
+int plugin_init(struct plugin_name_args *plugin_info, struct plugin_gcc_version *version)
+{
+	bool enabled = true;
+	const char * const plugin_name = plugin_info->base_name;
+	const int argc = plugin_info->argc;
+	const struct plugin_argument * const argv = plugin_info->argv;
+	int i;
+
+	struct register_pass_info latent_entropy_pass_info;
+
+	latent_entropy_pass_info.pass				= make_latent_entropy_pass();
+	latent_entropy_pass_info.reference_pass_name		= "optimized";
+	latent_entropy_pass_info.ref_pass_instance_number	= 1;
+	latent_entropy_pass_info.pos_op				= PASS_POS_INSERT_BEFORE;
+	static const struct ggc_root_tab gt_ggc_r_gt_latent_entropy[] = {
+		{
+			.base = &latent_entropy_decl,
+			.nelt = 1,
+			.stride = sizeof(latent_entropy_decl),
+			.cb = &gt_ggc_mx_tree_node,
+			.pchw = &gt_pch_nx_tree_node
+		},
+		LAST_GGC_ROOT_TAB
+	};
+
+	if (!plugin_default_version_check(version, &gcc_version)) {
+		error(G_("incompatible gcc/plugin versions"));
+		return 1;
+	}
+
+	for (i = 0; i < argc; ++i) {
+		if (!(strcmp(argv[i].key, "disable"))) {
+			enabled = false;
+			continue;
+		}
+		error(G_("unkown option '-fplugin-arg-%s-%s'"), plugin_name, argv[i].key);
+	}
+
+	register_callback(plugin_name, PLUGIN_INFO, NULL, &latent_entropy_plugin_info);
+	if (enabled) {
+		register_callback(plugin_name, PLUGIN_START_UNIT, &latent_entropy_start_unit, NULL);
+		register_callback(plugin_name, PLUGIN_REGISTER_GGC_ROOTS, NULL, (void *)&gt_ggc_r_gt_latent_entropy);
+		register_callback(plugin_name, PLUGIN_PASS_MANAGER_SETUP, NULL, &latent_entropy_pass_info);
+	}
+	register_callback(plugin_name, PLUGIN_ATTRIBUTES, register_attributes, NULL);
+
+	return 0;
+}
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
