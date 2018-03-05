Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id F0C596B0006
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 09:44:17 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id x126so8750815oia.18
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 06:44:17 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id d15si3718073otk.62.2018.03.05.06.44.16
        for <linux-mm@kvack.org>;
        Mon, 05 Mar 2018 06:44:17 -0800 (PST)
Date: Mon, 5 Mar 2018 14:44:05 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 09/14] khwasan: add hooks implementation
Message-ID: <20180305144405.jhrftj56hnlfl4ko@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 02, 2018 at 08:44:28PM +0100, Andrey Konovalov wrote:
>  void check_memory_region(unsigned long addr, size_t size, bool write,
>  				unsigned long ret_ip)
>  {
> +	u8 tag;
> +	u8 *shadow_first, *shadow_last, *shadow;
> +	void *untagged_addr;
> +
> +	tag = get_tag((void *)addr);

Please make get_tag() take a const void *, then this cast can go.

> +	untagged_addr = reset_tag((void *)addr);

Likewise for reset_tag().

> +	shadow_first = (u8 *)kasan_mem_to_shadow(untagged_addr);
> +	shadow_last = (u8 *)kasan_mem_to_shadow(untagged_addr + size - 1);

I don't think these u8 * casts are necessary, since
kasan_mem_to_shadow() returns a void *.

> +
> +	for (shadow = shadow_first; shadow <= shadow_last; shadow++) {
> +		if (*shadow != tag) {
> +			/* Report invalid-access bug here */
> +			return;

Huh? Should that be a TODO?

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
