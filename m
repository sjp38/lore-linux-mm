Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id C2B786B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 09:39:35 -0500 (EST)
Received: by mail-ot0-f199.google.com with SMTP id a32so9818984otj.5
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 06:39:35 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 7si2723112otm.390.2018.03.05.06.39.34
        for <linux-mm@kvack.org>;
        Mon, 05 Mar 2018 06:39:34 -0800 (PST)
Date: Mon, 5 Mar 2018 14:39:23 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 08/14] khwasan: perform untagged pointers comparison
 in krealloc
Message-ID: <20180305143923.oefjqjiulaedax3y@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <ec749c799f1e9d2d212db146ae764fb7f2c26f7e.1520017438.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ec749c799f1e9d2d212db146ae764fb7f2c26f7e.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 02, 2018 at 08:44:27PM +0100, Andrey Konovalov wrote:
> The krealloc function checks where the same buffer was reused or a new one
> allocated by comparing kernel pointers. KHWASAN changes memory tag on the
> krealloc'ed chunk of memory and therefore also changes the pointer tag of
> the returned pointer. Therefore we need to perform comparison on untagged
> (with tags reset) pointers to check whether it's the same memory region or
> not.
> ---
>  mm/slab_common.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/slab_common.c b/mm/slab_common.c
> index a33e61315ca6..7c829cbda1a5 100644
> --- a/mm/slab_common.c
> +++ b/mm/slab_common.c
> @@ -1494,7 +1494,7 @@ void *krealloc(const void *p, size_t new_size, gfp_t flags)
>  	}
>  
>  	ret = __do_krealloc(p, new_size, flags);
> -	if (ret && p != ret)
> +	if (ret && khwasan_reset_tag((void *)p) != khwasan_reset_tag(ret))

Why doesn't khwasan_reset_tag() take a const void *, like
khwasan_set_tag() does? That way, this cast wouldn't be necessary.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
