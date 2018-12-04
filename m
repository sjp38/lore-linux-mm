Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1435B6B6DCC
	for <linux-mm@kvack.org>; Tue,  4 Dec 2018 03:42:59 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id s14so13422307pfk.16
        for <linux-mm@kvack.org>; Tue, 04 Dec 2018 00:42:59 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [203.11.71.1])
        by mx.google.com with ESMTPS id u7si17481851pfu.270.2018.12.04.00.42.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Dec 2018 00:42:57 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH 1/2] mm: add probe_user_read() and probe_user_address()
In-Reply-To: <dd9ef91add7fcf5a9e369dde322b1822e90eb218.1543811917.git.christophe.leroy@c-s.fr>
References: <dd9ef91add7fcf5a9e369dde322b1822e90eb218.1543811917.git.christophe.leroy@c-s.fr>
Date: Tue, 04 Dec 2018 19:42:52 +1100
Message-ID: <874lbtisxf.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>, Kees Cook <keescook@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>
Cc: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-mm@kvack.org

Christophe Leroy <christophe.leroy@c-s.fr> writes:

> In the powerpc, there are several places implementing safe
                ^
                code ?

> access to user data. This is sometimes implemented using
> probe_kernel_address() with additional access_ok() verification,
> sometimes with get_user() enclosed in a pagefault_disable()/enable()
> pair, etc... :
>     show_user_instructions()
>     bad_stack_expansion()
>     p9_hmi_special_emu()
>     fsl_pci_mcheck_exception()
>     read_user_stack_64()
>     read_user_stack_32() on PPC64
>     read_user_stack_32() on PPC32
>     power_pmu_bhrb_to()
>
> In the same spirit as probe_kernel_read() and probe_kernel_address(),
> this patch adds probe_user_read() and probe_user_address().
>
> probe_user_read() does the same as probe_kernel_read() but
> first checks that it is really a user address.
>
> probe_user_address() is a shortcut to probe_user_read()

...

> +#define probe_user_address(addr, retval)		\
> +	probe_user_read(&(retval), addr, sizeof(retval))

I realise you added probe_user_address() to mirror probe_kernel_address(),
but I'd rather we just used probe_user_read() directly.

The only advantage of probe_kernel_address() is that you don't have to
mention retval twice.

But the downsides are that it's not obvious that you're writing to
retval (because the macro takes the address for you), and retval is
evaluated twice (the latter is usually not a problem but it can be).

eg, call sites like this are confusing:

static int read_user_stack_64(unsigned long __user *ptr, unsigned long *ret)
{
        ...

	if (!probe_user_address(ptr, *ret))
		return 0;

It's confusing because ret is a pointer, but then we dereference it
before passing it to probe_user_address(), so it looks like we're just
passing a value, but we're not.

Compare to:

	if (!probe_user_read(ret, ptr, sizeof(*ret)))
        	return 0;

Which is entirely analogous to a call to memcpy() and involves no magic.

I know there's lots of precedent here with get_user() etc. but that
doesn't mean we have to follow that precedent blindly :)

I guess perhaps we can add probe_user_address() but just not use it in
the powerpc code, if other folks want it to exist.

cheers
