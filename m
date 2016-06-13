Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 24BA36B0278
	for <linux-mm@kvack.org>; Mon, 13 Jun 2016 17:42:16 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l184so10039644lfl.3
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 14:42:16 -0700 (PDT)
Received: from mail-wm0-x236.google.com (mail-wm0-x236.google.com. [2a00:1450:400c:c09::236])
        by mx.google.com with ESMTPS id t205si666653wmb.32.2016.06.13.14.42.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 13 Jun 2016 14:42:14 -0700 (PDT)
Received: by mail-wm0-x236.google.com with SMTP id m124so97242992wme.1
        for <linux-mm@kvack.org>; Mon, 13 Jun 2016 14:42:14 -0700 (PDT)
Date: Mon, 13 Jun 2016 23:49:02 +0200
From: Emese Revfy <re.emese@gmail.com>
Subject: Re: [PATCH v2 1/3] Add the latent_entropy gcc plugin
Message-Id: <20160613234902.cbc2c0ccf90527ede8258843@gmail.com>
In-Reply-To: <CAGXu5jKuNiAq_Q_x2bTDvuQw2c=Zk9we8N9Fuh59kfFbyUcOBg@mail.gmail.com>
References: <20160531013029.4c5db8b570d86527b0b53fe4@gmail.com>
	<20160531013145.612696c12f2ef744af739803@gmail.com>
	<CAGXu5jKuNiAq_Q_x2bTDvuQw2c=Zk9we8N9Fuh59kfFbyUcOBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Thu, 9 Jun 2016 14:51:45 -0700
Kees Cook <keescook@chromium.org> wrote:

> On Mon, May 30, 2016 at 4:31 PM, Emese Revfy <re.emese@gmail.com> wrote:
> > -  GCC_PLUGINS_CFLAGS := $(addprefix -fplugin=$(objtree)/scripts/gcc-plugins/, $(gcc-plugin-y))
> > +  GCC_PLUGINS_CFLAGS := $(strip $(addprefix -fplugin=$(objtree)/scripts/gcc-plugins/, $(gcc-plugin-y)) $(gcc-plugin-cflags-y))
> 
> Is this change part of latent_entropy, or a general fix to the gcc
> plugin infrastructure?

This is a new feature in the gcc plugin infrastructure. The latent_entropy plugin has an argument and
we must add it (with a space) to the cflags.

> > + * gcc plugin to help generate a little bit of entropy from program state,
> > + * used throughout the uptime of the kernel
> 
> I think this comment needs a lot of expanding. What are all the ways
> that this plugin makes changes to code? Things I think I see are:
> pre-filling data variables with randomness, creating a local_entropy
> variable (local to what?), mixing stack pointer (into what?), updating
> latent_entropy global.

I demonstrated the details here:
https://github.com/ephox-gcc-plugins/latent_entropy/commit/049acd9f478d47ee6526d8e93ab8cfcc3ff91b13

> > +static unsigned HOST_WIDE_INT seed;
> > +static unsigned HOST_WIDE_INT get_random_const(void)
> > +{
> > +       unsigned int i;
> > +       unsigned HOST_WIDE_INT ret = 0;
> > +
> > +       for (i = 0; i < 8 * sizeof ret; i++) {
> > +               ret = (ret << 1) | (seed & 1);
> > +               seed >>= 1;
> > +               if (ret & 1)
> > +                       seed ^= 0xD800000000000000ULL;
> > +       }
> > +
> > +       return ret;
> > +}
> 
> Please add some comments above this function about why the seed is
> chosen this way, how it is expected to change over the lifetime of the
> plugin, etc.

You can see the comments here:
https://github.com/ephox-gcc-plugins/latent_entropy/commit/4999276e866271c69186a8e3112c265b6a0f3205

> > +static tree handle_latent_entropy_attribute(tree *node, tree name, tree args __unused, int flags __unused, bool *no_add_attrs)
> 
> Can you add comments to each section below describing what's being
> checked for? Or describe above the function what specific situations
> are valid for using the attribute? (The latter patch says "functions",
> but also marks other kinds of things.)

I think the error messages already describe all the wrong situations.
What would you like to see in addition to the existing error messages?

You can find a description about the attribute here:
https://github.com/ephox-gcc-plugins/latent_entropy/commit/f0ec66810682579109469b862ac5169aa2a743ca

> > +                       mask = 1ULL << (TREE_INT_CST_LOW(TYPE_SIZE(type)) - 1);
> > +                       mask = 2 * (mask - 1) + 1;
> > +
> > +                       if (TYPE_UNSIGNED(type))
> > +                               DECL_INITIAL(*node) = build_int_cstu(type, mask & get_random_const());
> > +                       else
> > +                               DECL_INITIAL(*node) = build_int_cst(type, mask & get_random_const());
> > +                       break;
> 
> What is happening here? Is this populating integers with the random
> const? (I assume the ARRAY_TYPE version of this is the same thing,
> only multiple times. Could that be made into a function instead of
> cut/paste with a loop in the ARRAY_TYPE case below?

https://github.com/ephox-gcc-plugins/latent_entropy/commit/d65864b6ca2e61cc73cd28309ba0779fde75b4f2
 
> > +static enum tree_code get_op(tree *rhs)
> 
> Please describe this state machine, and why it does what it does. :)

https://github.com/ephox-gcc-plugins/latent_entropy/commit/c4cc18cfb5d37121fe62907bed6b5aaafb84fff8
 
> > +{
> > +       static enum tree_code op;
> > +       unsigned HOST_WIDE_INT random_const;
> > +
> > +       random_const = get_random_const();
> > +
> > +       switch (op) {
> > +       case BIT_XOR_EXPR:
> > +               op = PLUS_EXPR;
> > +               break;
> > +
> > +       case PLUS_EXPR:
> > +               if (rhs) {
> > +                       op = LROTATE_EXPR;
> > +                       random_const &= HOST_BITS_PER_WIDE_INT - 1;
> > +                       break;
> > +               }
> 
> What's happening here with the random_const?

I wrote a comment, you can find it here:
https://github.com/ephox-gcc-plugins/latent_entropy/commit/da452fdbc0247095fdf2b1f52eb4ddd368fad640

> > +
> > +       case LROTATE_EXPR:
> > +       default:
> > +               op = BIT_XOR_EXPR;
> > +               break;
> > +       }
> > +       if (rhs)
> > +               *rhs = build_int_cstu(unsigned_intDI_type_node, random_const);
> > +       return op;
> > +}
> > +
> > +static void perturb_local_entropy(basic_block bb, tree local_entropy)
> 
> What effect does this function have on the resulting code output?

Would you like to see more on top of this comment:
https://github.com/ephox-gcc-plugins/latent_entropy/commit/049acd9f478d47ee6526d8e93ab8cfcc3ff91b13

> > +static void perturb_latent_entropy(basic_block bb, tree rhs)
> 
> Same for this. I assume this is effectively:
> 
>    u64 temp_latent_entropy;
> 
>    temp_latent_entropy = latent_entropy;
>    temp_latent_entropy = temp_latent_entropy OP rhs
>    latent_entropy = temp_latent_entropy;
> 
> Where does rhs come from? (Is this the "local_entropy" below?)

Sure, I'll rename the rhs parameter to local_entropy.

> > +static void mix_in_sp(basic_block bb, tree local_entropy)
> 
> What is the stack pointer mixed into?

I already wrote some comments:
https://github.com/ephox-gcc-plugins/latent_entropy/commit/d2781819d774b4370c248cdb8d0dd2b47308b6f4

> This below needs a bit more detail in comments. IIUC, it's creating a
> local (to the .o file? the basic block?) variable, initializing it
> with the stack, perturbing it with random operations, then updating
> the latent_entropy with it?
> > +       /* create local entropy variable */
> > +       local_entropy = create_a_tmp_var(unsigned_intDI_type_node, "local_entropy");
> 
> What value does local_entropy have initially?

You can see it here:
https://github.com/ephox-gcc-plugins/latent_entropy/commit/049acd9f478d47ee6526d8e93ab8cfcc3ff91b13

-- 
Emese

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
