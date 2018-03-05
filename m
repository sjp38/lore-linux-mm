Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9EA306B0010
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 09:36:38 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id u68so8831532oia.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 06:36:38 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b13si3707072oih.300.2018.03.05.06.36.37
        for <linux-mm@kvack.org>;
        Mon, 05 Mar 2018 06:36:37 -0800 (PST)
Date: Mon, 5 Mar 2018 14:36:26 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 06/14] khwasan: enable top byte ignore for the kernel
Message-ID: <20180305143625.vtrfvsbw7loxngaj@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <739eecf573b6342fc41c4f89d7f64eb8c183e312.1520017438.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <739eecf573b6342fc41c4f89d7f64eb8c183e312.1520017438.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 02, 2018 at 08:44:25PM +0100, Andrey Konovalov wrote:
> KHWASAN uses the Top Byte Ignore feature of arm64 CPUs to store a pointer
> tag in the top byte of each pointer. This commit enables the TCR_TBI1 bit,
> which enables Top Byte Ignore for the kernel, when KHWASAN is used.
> ---
>  arch/arm64/include/asm/pgtable-hwdef.h | 1 +
>  arch/arm64/mm/proc.S                   | 8 +++++++-
>  2 files changed, 8 insertions(+), 1 deletion(-)

Before it's safe to do this, I also think you'll need to fix up at
least:

* virt_to_phys()

* access_ok()

... and potentially others which assume that bits [63:56] of kernel
addresses are 0xff. For example, bits of the fault handling logic might
need fixups.

Thanks,
Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
