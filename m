Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7F0196B007E
	for <linux-mm@kvack.org>; Thu,  9 Jun 2016 17:51:49 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id k192so22590990lfb.1
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 14:51:49 -0700 (PDT)
Received: from mail-wm0-x231.google.com (mail-wm0-x231.google.com. [2a00:1450:400c:c09::231])
        by mx.google.com with ESMTPS id q6si10105158wjy.57.2016.06.09.14.51.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jun 2016 14:51:47 -0700 (PDT)
Received: by mail-wm0-x231.google.com with SMTP id k204so78048888wmk.0
        for <linux-mm@kvack.org>; Thu, 09 Jun 2016 14:51:47 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160531013145.612696c12f2ef744af739803@gmail.com>
References: <20160531013029.4c5db8b570d86527b0b53fe4@gmail.com> <20160531013145.612696c12f2ef744af739803@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Thu, 9 Jun 2016 14:51:45 -0700
Message-ID: <CAGXu5jKuNiAq_Q_x2bTDvuQw2c=Zk9we8N9Fuh59kfFbyUcOBg@mail.gmail.com>
Subject: Re: [PATCH v2 1/3] Add the latent_entropy gcc plugin
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emese Revfy <re.emese@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Mon, May 30, 2016 at 4:31 PM, Emese Revfy <re.emese@gmail.com> wrote:
> This plugin mitigates the problem of the kernel having too little entropy during
> and after boot for generating crypto keys.
>
> It creates a local variable in every marked function. The value of this variable is
> modified by randomly chosen operations (add, xor and rol) and
> random values (gcc generates them at compile time and the stack pointer at runtime).
> It depends on the control flow (e.g., loops, conditions).
>
> Before the function returns the plugin writes this local variable
> into the latent_entropy global variable. The value of this global variable is
> added to the kernel entropy pool in do_one_initcall() and _do_fork().
>
> Signed-off-by: Emese Revfy <re.emese@gmail.com>
> [...]
> diff --git a/scripts/Makefile.gcc-plugins b/scripts/Makefile.gcc-plugins
> index 5e22b60..cd7902c 100644
> --- a/scripts/Makefile.gcc-plugins
> +++ b/scripts/Makefile.gcc-plugins
> @@ -6,6 +6,12 @@ ifdef CONFIG_GCC_PLUGINS
>
>    gcc-plugin-$(CONFIG_GCC_PLUGIN_CYC_COMPLEXITY)       += cyc_complexity_plugin.so
>
> +  gcc-plugin-$(CONFIG_GCC_PLUGIN_LATENT_ENTROPY)       += latent_entropy_plugin.so
> +  gcc-plugin-cflags-$(CONFIG_GCC_PLUGIN_LATENT_ENTROPY)        += -DLATENT_ENTROPY_PLUGIN
> +  ifdef CONFIG_PAX_LATENT_ENTROPY
> +    DISABLE_LATENT_ENTROPY_PLUGIN                      += -fplugin-arg-latent_entropy_plugin-disable
> +  endif
> +
>    ifdef CONFIG_GCC_PLUGIN_SANCOV
>      ifeq ($(CFLAGS_KCOV),)
>        # It is needed because of the gcc-plugin.sh and gcc version checks.
> @@ -19,9 +25,9 @@ ifdef CONFIG_GCC_PLUGINS
;>      endif
>    endif
>
> -  GCC_PLUGINS_CFLAGS := $(addprefix -fplugin=$(objtree)/scripts/gcc-plugins/, $(gcc-plugin-y))
> +  GCC_PLUGINS_CFLAGS := $(strip $(addprefix -fplugin=$(objtree)/scripts/gcc-plugins/, $(gcc-plugin-y)) $(gcc-plugin-cflags-y))

Is this change part of latent_entropy, or a general fix to the gcc
plugin infrastructure?

>
> -  export PLUGINCC GCC_PLUGINS_CFLAGS GCC_PLUGIN SANCOV_PLUGIN
> +  export PLUGINCC GCC_PLUGINS_CFLAGS GCC_PLUGIN SANCOV_PLUGIN DISABLE_LATENT_ENTROPY_PLUGIN
>
>    ifeq ($(PLUGINCC),)
>      ifneq ($(GCC_PLUGINS_CFLAGS),)
> [...]
> diff --git a/scripts/gcc-plugins/latent_entropy_plugin.c b/scripts/gcc-plugins/latent_entropy_plugin.c
> new file mode 100644
> index 0000000..f606caa
> --- /dev/null
> +++ b/scripts/gcc-plugins/latent_entropy_plugin.c
> @@ -0,0 +1,454 @@
> +/*
> + * Copyright 2012-2016 by the PaX Team <pageexec@freemail.hu>
> + * Copyright 2016 by Emese Revfy <re.emese@gmail.com>
> + * Licensed under the GPL v2
> + *
> + * Note: the choice of the license means that the compilation process is
> + *       NOT 'eligible' as defined by gcc's library exception to the GPL v3,
> + *       but for the kernel it doesn't matter since it doesn't link against
> + *       any of the gcc libraries
> + *
> + * gcc plugin to help generate a little bit of entropy from program state,
> + * used throughout the uptime of the kernel

I think this comment needs a lot of expanding. What are all the ways
that this plugin makes changes to code? Things I think I see are:
pre-filling data variables with randomness, creating a local_entropy
variable (local to what?), mixing stack pointer (into what?), updating
latent_entropy global.

> + *
> + * TODO:
> + * - add ipa pass to identify not explicitly marked candidate functions
> + * - mix in more program state (function arguments/return values, loop variables, etc)
> + * - more instrumentation control via attribute parameters
> + *
> + * BUGS:
> + * - none known
> + *
> + * Options:
> + * -fplugin-arg-latent_entropy_plugin-disable
> + *
> + * Attribute: __attribute__((latent_entropy))
> + *  The latent_entropy gcc attribute can be only on functions and variables.
> + *  If it is on a function then the plugin will instrument it. If the attribute
> + *  is on a variable then the plugin will initialize it with a random value.
> + *  The variable must be an integer, an integer array type or a structure with integer fields.
> + */
> +
> +#include "gcc-common.h"
> +
> +int plugin_is_GPL_compatible;
> +
> +static GTY(()) tree latent_entropy_decl;
> +
> +static struct plugin_info latent_entropy_plugin_info = {
> +       .version        = "201605292100",
> +       .help           = "disable\tturn off latent entropy instrumentation\n",
> +};
> +
> +static unsigned HOST_WIDE_INT seed;
> +static unsigned HOST_WIDE_INT get_random_const(void)
> +{
> +       unsigned int i;
> +       unsigned HOST_WIDE_INT ret = 0;
> +
> +       for (i = 0; i < 8 * sizeof ret; i++) {
> +               ret = (ret << 1) | (seed & 1);
> +               seed >>= 1;
> +               if (ret & 1)
> +                       seed ^= 0xD800000000000000ULL;
> +       }
> +
> +       return ret;
> +}

Please add some comments above this function about why the seed is
chosen this way, how it is expected to change over the lifetime of the
plugin, etc.

> +static tree handle_latent_entropy_attribute(tree *node, tree name, tree args __unused, int flags __unused, bool *no_add_attrs)

Can you add comments to each section below describing what's being
checked for? Or describe above the function what specific situations
are valid for using the attribute? (The latter patch says "functions",
but also marks other kinds of things.)

> +{
> +       tree type;
> +       unsigned long long mask;
> +#if BUILDING_GCC_VERSION <= 4007
> +       VEC(constructor_elt, gc) *vals;
> +#else
> +       vec<constructor_elt, va_gc> *vals;
> +#endif
> +
> +       switch (TREE_CODE(*node)) {
> +       default:
> +               *no_add_attrs = true;
> +               error("%qE attribute only applies to functions and variables", name);
> +               break;
> +
> +       case VAR_DECL:
> +               if (DECL_INITIAL(*node)) {
> +                       *no_add_attrs = true;
> +                       error("variable %qD with %qE attribute must not be initialized", *node, name);
> +                       break;
> +               }
> +
> +               if (!TREE_STATIC(*node)) {
> +                       *no_add_attrs = true;
> +                       error("variable %qD with %qE attribute must not be local", *node, name);
> +                       break;
> +               }
> +
> +               type = TREE_TYPE(*node);
> +               switch (TREE_CODE(type)) {
> +               default:
> +                       *no_add_attrs = true;
> +                       error("variable %qD with %qE attribute must be an integer or a fixed length integer array type"
> +                               "or a fixed sized structure with integer fields", *node, name);
> +                       break;
> +
> +               case RECORD_TYPE: {
> +                       tree field;
> +                       unsigned int nelt = 0;
> +
> +                       for (field = TYPE_FIELDS(type); field; nelt++, field = TREE_CHAIN(field)) {
> +                               tree fieldtype;
> +
> +                               fieldtype = TREE_TYPE(field);
> +                               if (TREE_CODE(fieldtype) == INTEGER_TYPE)
> +                                       continue;
> +
> +                               *no_add_attrs = true;
> +                               error("structure variable %qD with %qE attribute has a non-integer field %qE", *node, name, field);
> +                               break;
> +                       }
> +
> +                       if (field)
> +                               break;
> +
> +#if BUILDING_GCC_VERSION <= 4007
> +                       vals = VEC_alloc(constructor_elt, gc, nelt);
> +#else
> +                       vec_alloc(vals, nelt);
> +#endif
> +
> +                       for (field = TYPE_FIELDS(type); field; field = TREE_CHAIN(field)) {
> +                               tree fieldtype;
> +
> +                               fieldtype = TREE_TYPE(field);
> +                               mask = 1ULL << (TREE_INT_CST_LOW(TYPE_SIZE(fieldtype)) - 1);
> +                               mask = 2 * (mask - 1) + 1;
> +
> +                               if (TYPE_UNSIGNED(fieldtype))
> +                                       CONSTRUCTOR_APPEND_ELT(vals, field, build_int_cstu(fieldtype, mask & get_random_const()));
> +                               else
> +                                       CONSTRUCTOR_APPEND_ELT(vals, field, build_int_cst(fieldtype, mask & get_random_const()));
> +                       }
> +
> +                       DECL_INITIAL(*node) = build_constructor(type, vals);
> +                       break;
> +               }
> +
> +               case INTEGER_TYPE:
> +                       mask = 1ULL << (TREE_INT_CST_LOW(TYPE_SIZE(type)) - 1);
> +                       mask = 2 * (mask - 1) + 1;
> +
> +                       if (TYPE_UNSIGNED(type))
> +                               DECL_INITIAL(*node) = build_int_cstu(type, mask & get_random_const());
> +                       else
> +                               DECL_INITIAL(*node) = build_int_cst(type, mask & get_random_const());
> +                       break;

What is happening here? Is this populating integers with the random
const? (I assume the ARRAY_TYPE version of this is the same thing,
only multiple times. Could that be made into a function instead of
cut/paste with a loop in the ARRAY_TYPE case below?

> +
> +               case ARRAY_TYPE: {
> +                       tree elt_type, array_size, elt_size;
> +                       unsigned int i, nelt;
> +
> +                       elt_type = TREE_TYPE(type);
> +                       elt_size = TYPE_SIZE_UNIT(TREE_TYPE(type));
> +                       array_size = TYPE_SIZE_UNIT(type);
> +
> +                       if (TREE_CODE(elt_type) != INTEGER_TYPE || !array_size || TREE_CODE(array_size) != INTEGER_CST) {
> +                               *no_add_attrs = true;
> +                               error("array variable %qD with %qE attribute must be a fixed length integer array type", *node, name);
> +                               break;
> +                       }
> +
> +                       nelt = TREE_INT_CST_LOW(array_size) / TREE_INT_CST_LOW(elt_size);
> +#if BUILDING_GCC_VERSION <= 4007
> +                       vals = VEC_alloc(constructor_elt, gc, nelt);
> +#else
> +                       vec_alloc(vals, nelt);
> +#endif
> +
> +                       mask = 1ULL << (TREE_INT_CST_LOW(TYPE_SIZE(elt_type)) - 1);
> +                       mask = 2 * (mask - 1) + 1;

This mask calculation appears to be cut/pasted. Should it be a macro
or function taking "type" instead?

> +
> +                       for (i = 0; i < nelt; i++)
> +                               if (TYPE_UNSIGNED(elt_type))
> +                                       CONSTRUCTOR_APPEND_ELT(vals, size_int(i), build_int_cstu(elt_type, mask & get_random_const()));
> +                               else
> +                                       CONSTRUCTOR_APPEND_ELT(vals, size_int(i), build_int_cst(elt_type, mask & get_random_const()));
> +
> +                       DECL_INITIAL(*node) = build_constructor(type, vals);
> +                       break;
> +               }
> +               }
> +               break;
> +
> +       case FUNCTION_DECL:
> +               break;
> +       }
> +
> +       return NULL_TREE;
> +}
> +
> +static struct attribute_spec latent_entropy_attr = {
> +       .name                           = "latent_entropy",
> +       .min_length                     = 0,
> +       .max_length                     = 0,
> +       .decl_required                  = true,
> +       .type_required                  = false,
> +       .function_type_required         = false,
> +       .handler                        = handle_latent_entropy_attribute,
> +#if BUILDING_GCC_VERSION >= 4007
> +       .affects_type_identity          = false
> +#endif
> +};
> +
> +static void register_attributes(void *event_data __unused, void *data __unused)
> +{
> +       register_attribute(&latent_entropy_attr);
> +}
> +
> +static bool latent_entropy_gate(void)
> +{
> +       /* don't bother with noreturn functions for now */
> +       if (TREE_THIS_VOLATILE(current_function_decl))
> +               return false;
> +
> +       /* gcc-4.5 doesn't discover some trivial noreturn functions */
> +       if (EDGE_COUNT(EXIT_BLOCK_PTR_FOR_FN(cfun)->preds) == 0)
> +               return false;
> +
> +       return lookup_attribute("latent_entropy", DECL_ATTRIBUTES(current_function_decl)) != NULL_TREE;
> +}
> +
> +static tree create_a_tmp_var(tree type, const char *name)
> +{
> +       tree var;
> +
> +       var = create_tmp_var(type, name);
> +       add_referenced_var(var);
> +       mark_sym_for_renaming(var);
> +       return var;
> +}
> +
> +static enum tree_code get_op(tree *rhs)

Please describe this state machine, and why it does what it does. :)

> +{
> +       static enum tree_code op;
> +       unsigned HOST_WIDE_INT random_const;
> +
> +       random_const = get_random_const();
> +
> +       switch (op) {
> +       case BIT_XOR_EXPR:
> +               op = PLUS_EXPR;
> +               break;
> +
> +       case PLUS_EXPR:
> +               if (rhs) {
> +                       op = LROTATE_EXPR;
> +                       random_const &= HOST_BITS_PER_WIDE_INT - 1;
> +                       break;
> +               }

What's happening here with the random_const?

> +
> +       case LROTATE_EXPR:
> +       default:
> +               op = BIT_XOR_EXPR;
> +               break;
> +       }
> +       if (rhs)
> +               *rhs = build_int_cstu(unsigned_intDI_type_node, random_const);
> +       return op;
> +}
> +
> +static void perturb_local_entropy(basic_block bb, tree local_entropy)

What effect does this function have on the resulting code output?

> +{
> +       gimple_stmt_iterator gsi;
> +       gimple assign;
> +       tree rhs;
> +       enum tree_code subcode;
> +
> +       subcode = get_op(&rhs);
> +       assign = gimple_build_assign_with_ops(subcode, local_entropy, local_entropy, rhs);
> +       gsi = gsi_after_labels(bb);
> +       gsi_insert_before(&gsi, assign, GSI_NEW_STMT);
> +       update_stmt(assign);
> +}
> +
> +static void perturb_latent_entropy(basic_block bb, tree rhs)

Same for this. I assume this is effectively:

   u64 temp_latent_entropy;

   temp_latent_entropy = latent_entropy;
   temp_latent_entropy = temp_latent_entropy OP rhs
   latent_entropy = temp_latent_entropy;

Where does rhs come from? (Is this the "local_entropy" below?)

> +{
> +       gimple_stmt_iterator gsi;
> +       gimple assign;
> +       tree temp;
> +       enum tree_code subcode;
> +
> +       /* create temporary copy of latent_entropy */
> +       temp = create_a_tmp_var(unsigned_intDI_type_node, "temp_latent_entropy");
> +
> +       gsi = gsi_last_bb(bb);
> +
> +       /* 1. read... */
> +       add_referenced_var(latent_entropy_decl);
> +       mark_sym_for_renaming(latent_entropy_decl);
> +       assign = gimple_build_assign(temp, latent_entropy_decl);
> +       gsi_insert_before(&gsi, assign, GSI_NEW_STMT);
> +       update_stmt(assign);
> +
> +       /* 2. ...modify... */
> +       subcode = get_op(NULL);
> +       assign = gimple_build_assign_with_ops(subcode, temp, temp, rhs);
> +       gsi_insert_after(&gsi, assign, GSI_NEW_STMT);
> +       update_stmt(assign);
> +
> +       /* 3. ...write latent_entropy */
> +       assign = gimple_build_assign(latent_entropy_decl, temp);
> +       gsi_insert_after(&gsi, assign, GSI_NEW_STMT);
> +       update_stmt(assign);
> +}
> +
> +static void mix_in_sp(basic_block bb, tree local_entropy)

What is the stack pointer mixed into?

> +{
> +       gimple assign, call;
> +       tree frame_addr, rand_const;
> +       gimple_stmt_iterator gsi = gsi_after_labels(bb);
> +
> +       frame_addr = create_a_tmp_var(ptr_type_node, "local_entropy_frame_addr");
> +
> +       call = gimple_build_call(builtin_decl_implicit(BUILT_IN_FRAME_ADDRESS), 1, integer_zero_node);
> +       gimple_call_set_lhs(call, frame_addr);
> +       gsi_insert_before(&gsi, call, GSI_NEW_STMT);
> +       update_stmt(call);
> +
> +       assign = gimple_build_assign(local_entropy, fold_convert(unsigned_intDI_type_node, frame_addr));
> +       gsi_insert_after(&gsi, assign, GSI_NEW_STMT);
> +       update_stmt(assign);
> +
> +       rand_const = build_int_cstu(unsigned_intDI_type_node, get_random_const());
> +       assign = gimple_build_assign_with_ops(BIT_XOR_EXPR, local_entropy, local_entropy, rand_const);
> +       gsi_insert_after(&gsi, assign, GSI_NEW_STMT);
> +       update_stmt(assign);
> +}
> +
> +static unsigned int latent_entropy_execute(void)
> +{
> +       basic_block bb;
> +       tree local_entropy;
> +
> +       if (!latent_entropy_decl) {
> +               varpool_node_ptr node;
> +
> +               FOR_EACH_VARIABLE(node) {
> +                       tree var = NODE_DECL(node);
> +
> +                       if (DECL_NAME_LENGTH(var) < sizeof("latent_entropy") - 1)
> +                               continue;
> +                       if (strcmp(IDENTIFIER_POINTER(DECL_NAME(var)), "latent_entropy"))
> +                               continue;
> +                       latent_entropy_decl = var;
> +                       break;
> +               }
> +               if (!latent_entropy_decl)
> +                       return 0;
> +       }
> +
> +       gcc_assert(single_succ_p(ENTRY_BLOCK_PTR_FOR_FN(cfun)));
> +       bb = single_succ(ENTRY_BLOCK_PTR_FOR_FN(cfun));
> +       if (!single_pred_p(bb)) {
> +               split_edge(single_succ_edge(ENTRY_BLOCK_PTR_FOR_FN(cfun)));
> +               gcc_assert(single_succ_p(ENTRY_BLOCK_PTR_FOR_FN(cfun)));
> +               bb = single_succ(ENTRY_BLOCK_PTR_FOR_FN(cfun));
> +       }
> +

This below needs a bit more detail in comments. IIUC, it's creating a
local (to the .o file? the basic block?) variable, initializing it
with the stack, perturbing it with random operations, then updating
the latent_entropy with it?

> +       /* create local entropy variable */
> +       local_entropy = create_a_tmp_var(unsigned_intDI_type_node, "local_entropy");

What value does local_entropy have initially?

> +
> +       /* 1. stack pointer */
> +       mix_in_sp(bb, local_entropy);
> +
> +       bb = bb->next_bb;
> +       /* 2. instrument each BB with an operation on the local entropy variable */
> +       while (bb != EXIT_BLOCK_PTR_FOR_FN(cfun)) {
> +               perturb_local_entropy(bb, local_entropy);
> +               bb = bb->next_bb;
> +       };
> +
> +       /* 3. mix local entropy into the global entropy variable */
> +       gcc_assert(single_pred_p(EXIT_BLOCK_PTR_FOR_FN(cfun)));
> +       perturb_latent_entropy(single_pred(EXIT_BLOCK_PTR_FOR_FN(cfun)), local_entropy);
> +       return 0;
> +}
> [...]

Thanks!

-Kees

-- 
Kees Cook
Chrome OS & Brillo Security

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
