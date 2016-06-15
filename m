Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id B5A766B0005
	for <linux-mm@kvack.org>; Wed, 15 Jun 2016 14:55:47 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id a2so15289380lfe.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 11:55:47 -0700 (PDT)
Received: from mail-wm0-x22f.google.com (mail-wm0-x22f.google.com. [2a00:1450:400c:c09::22f])
        by mx.google.com with ESMTPS id w142si12207776wmw.108.2016.06.15.11.55.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Jun 2016 11:55:46 -0700 (PDT)
Received: by mail-wm0-x22f.google.com with SMTP id a66so25808796wme.0
        for <linux-mm@kvack.org>; Wed, 15 Jun 2016 11:55:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
References: <20160615001754.f9e986cf961d1466f5e086dc@gmail.com>
From: Kees Cook <keescook@chromium.org>
Date: Wed, 15 Jun 2016 11:55:44 -0700
Message-ID: <CAGXu5jK-QVhbuOnNENq9PesPTdPCnbgODzb0qn=q4ZMS0-ndBA@mail.gmail.com>
Subject: Re: [PATCH v3 0/4] Introduce the latent_entropy gcc plugin
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Emese Revfy <re.emese@gmail.com>
Cc: "kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, PaX Team <pageexec@freemail.hu>, Brad Spengler <spender@grsecurity.net>, Michal Marek <mmarek@suse.com>, LKML <linux-kernel@vger.kernel.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, linux-kbuild <linux-kbuild@vger.kernel.org>, Theodore Ts'o <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Jens Axboe <axboe@kernel.dk>, Al Viro <viro@zeniv.linux.org.uk>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, bart.vanassche@sandisk.com, "David S. Miller" <davem@davemloft.net>

On Tue, Jun 14, 2016 at 3:17 PM, Emese Revfy <re.emese@gmail.com> wrote:
> I would like to introduce the latent_entropy gcc plugin. This plugin mitigates
> the problem of the kernel having too little entropy during and after boot
> for generating crypto keys.
>
> This plugin mixes random values into the latent_entropy global variable
> in functions marked by the __latent_entropy attribute.
> The value of this global variable is added to the kernel entropy pool
> to increase the entropy.
>
> It is a CII project supported by the Linux Foundation.
>
> The latent_entropy plugin was ported from grsecurity/PaX originally written by
> the PaX Team. You can find more about the plugin here:
> https://grsecurity.net/pipermail/grsecurity/2012-July/001093.html
>
> The plugin supports all gcc version from 4.5 to 6.0.
>
> I do some changes above the PaX version. The important one is mixing
> the stack pointer into the global variable too.
> You can find more about the changes here:
> https://github.com/ephox-gcc-plugins/latent_entropy
>
> This patch set is based on the "Introduce GCC plugin infrastructure" patch set (v9 next-20160520).
>
> Emese Revfy (4):
>  Add support for passing gcc plugin arguments
>  Add the latent_entropy gcc plugin
>  Mark functions with the latent_entropy attribute
>  Add the extra_latent_entropy kernel parameter
>
>
> Changes from v2:
>   * Moved the passing of gcc plugin arguments into a separate patch
>     (Suggested-by: Kees Cook <keescook@chromium.org>)
>   * Mix the global entropy variable with the stack pointer (latent_entropy_plugin.c)
>   * Handle tail calls (latent_entropy_plugin.c)
>   * Fix some indentation related warnings suggested by checkpatch.pl (latent_entropy_plugin.c)
>   * Commented some latent_entropy plugin code
>     (Suggested-by: Kees Cook <keescook@chromium.org>)

This continues to look great to me, thanks for all the added comments
and improvements.

One thing I'd still really like to see is that each patch passes
script/checkpatch.pl with as few issues as possible. The >80 character
lines are a problem, and I think they impede readability. Quoting from
Documentation/CodingStyle:


 The limit on the length of lines is 80 columns and this is a strongly
 preferred limit.

 Statements longer than 80 columns will be broken into sensible chunks, unless
 exceeding 80 columns significantly increases readability and does not hide
 information. Descendants are always substantially shorter than the parent and
 are placed substantially to the right. The same applies to function headers
 with a long argument list. However, never break user-visible strings such as
 printk messages, because that breaks the ability to grep for them.


Personally, I'm okay with exceptions where they make sense, but they
should be exceptions, as opposed to being common. Right now in this
series, there are a lot of cases of long lines even in places where it
isn't code, like in commit messages and Kconfig text.

Here's the current output from checkpatch.pl:

0002-Add-the-latent_entropy-gcc-plugin.patch
total: 5 errors, 54 warnings, 702 lines checked

0003-Mark-functions-with-the-latent_entropy-attribute.patch
total: 2 errors, 8 warnings, 0 checks, 197 lines checked

0004-Add-the-extra_latent_entropy-kernel-parameter.patch
total: 0 errors, 3 warnings, 65 lines checked

The 54 warnings in the plugin should get vastly reduced. You can
ignore things that aren't correct, like:

ERROR: Macros with complex values should be enclosed in parentheses
#148: FILE: include/linux/init.h:42:
+#define __init         __section(.init.text) __cold notrace __latent_entropy

Obviously __init isn't a "regular" macro, etc. And other misparsings
can be ignored, like:

ERROR: spaces required around that '>' (ctx:VxW)
#310: FILE: scripts/gcc-plugins/latent_entropy_plugin.c:127:
+       vec<constructor_elt, va_gc> *vals;
                                  ^
since checkpatch doesn't know about such things.

But things like this should be fixed:

WARNING: line over 80 characters
#157: FILE: include/linux/init.h:95:
+#define __meminit        __section(.meminit.text) __cold notrace
__latent_entropy

I'd expect it to look like:

#define __meminit        __section(.meminit.text) __cold notrace \
                                                  __latent_entropy

And for function declarations:

WARNING: line over 80 characters
#185: FILE: kernel/fork.c:409:
+static __latent_entropy int dup_mmap(struct mm_struct *mm, struct
mm_struct *oldmm)

static __latent_entropy int dup_mmap(struct mm_struct *mm,
                                     struct mm_struct *oldmm)

and for long code lines:

WARNING: line over 80 characters
#774: FILE: scripts/gcc-plugins/latent_entropy_plugin.c:591:
+               register_callback(plugin_name,
PLUGIN_REGISTER_GGC_ROOTS, NULL, (void *)&gt_ggc_r_gt_latent_entropy);

                register_callback(plugin_name, PLUGIN_REGISTER_GGC_ROOTS,
                                  NULL, (void *)&gt_ggc_r_gt_latent_entropy);

Cases of long text lines are an exception, though:

WARNING: line over 80 characters
#322: FILE: scripts/gcc-plugins/latent_entropy_plugin.c:139:
+                       error("variable %qD with %qE attribute must
not be initialized", *node, name);

This should leave the text unbroken, but wrap the next part:

                        error("variable %qD with %qE attribute must
not be initialized",
                              *node, name);

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
