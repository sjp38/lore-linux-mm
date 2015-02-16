Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1629F6B0038
	for <linux-mm@kvack.org>; Sun, 15 Feb 2015 23:10:53 -0500 (EST)
Received: by pdno5 with SMTP id o5so32455393pdn.8
        for <linux-mm@kvack.org>; Sun, 15 Feb 2015 20:10:52 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id bi10si2463437pdb.172.2015.02.15.20.10.50
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 15 Feb 2015 20:10:51 -0800 (PST)
From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH v11 18/19] module: fix types of device tables aliases
In-Reply-To: <1422985392-28652-19-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com> <1422985392-28652-1-git-send-email-a.ryabinin@samsung.com> <1422985392-28652-19-git-send-email-a.ryabinin@samsung.com>
Date: Mon, 16 Feb 2015 13:14:02 +1030
Message-ID: <87d25aa83x.fsf@rustcorp.com.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>, linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Dmitry Chernenkov <dmitryc@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, x86@kernel.org, linux-mm@kvack.org

Andrey Ryabinin <a.ryabinin@samsung.com> writes:
> MODULE_DEVICE_TABLE() macro used to create aliases to device tables.
> Normally alias should have the same type as aliased symbol.
>
> Device tables are arrays, so they have 'struct type##_device_id[x]'
> types. Alias created by MODULE_DEVICE_TABLE() will have non-array type -
> 	'struct type##_device_id'.
>
> This inconsistency confuses compiler, it could make a wrong
> assumption about variable's size which leads KASan to
> produce a false positive report about out of bounds access.

Hmm, as Andrew Morton points out, this breaks some usage; if we just
fix the type (struct type##_device_id[]) will that work instead?

I'm guessing not, since typeof(x) will presumably preserve sizing
information?

Cheers,
Rusty.

>
> For every global variable compiler calls __asan_register_globals()
> passing information about global variable (address, size, size with
> redzone, name ...) __asan_register_globals() poison symbols
> redzone to detect possible out of bounds accesses.
>
> When symbol has an alias __asan_register_globals() will be called
> as for symbol so for alias. Compiler determines size of variable by
> size of variable's type. Alias and symbol have the same address,
> so if alias have the wrong size part of memory that actually belongs
> to the symbol could be poisoned as redzone of alias symbol.
>
> By fixing type of alias symbol we will fix size of it, so
> __asan_register_globals() will not poison valid memory.
>
> Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
> ---
>  include/linux/module.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/include/linux/module.h b/include/linux/module.h
> index b653d7c..42999fe 100644
> --- a/include/linux/module.h
> +++ b/include/linux/module.h
> @@ -135,7 +135,7 @@ void trim_init_extable(struct module *m);
>  #ifdef MODULE
>  /* Creates an alias so file2alias.c can find device table. */
>  #define MODULE_DEVICE_TABLE(type, name)					\
> -  extern const struct type##_device_id __mod_##type##__##name##_device_table \
> +extern const typeof(name) __mod_##type##__##name##_device_table		\
>    __attribute__ ((unused, alias(__stringify(name))))
>  #else  /* !MODULE */
>  #define MODULE_DEVICE_TABLE(type, name)
> -- 
> 2.2.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
