Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 12CE46B0005
	for <linux-mm@kvack.org>; Fri,  9 Mar 2018 14:00:04 -0500 (EST)
Received: by mail-oi0-f72.google.com with SMTP id u74so5093483oif.19
        for <linux-mm@kvack.org>; Fri, 09 Mar 2018 11:00:04 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id c137si461221oig.205.2018.03.09.11.00.02
        for <linux-mm@kvack.org>;
        Fri, 09 Mar 2018 11:00:02 -0800 (PST)
Date: Fri, 9 Mar 2018 18:59:48 +0000
From: Mark Rutland <mark.rutland@arm.com>
Subject: Re: [RFC PATCH 06/14] khwasan: enable top byte ignore for the kernel
Message-ID: <20180309185947.tk6vg3nplvg7ll52@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com>
 <739eecf573b6342fc41c4f89d7f64eb8c183e312.1520017438.git.andreyknvl@google.com>
 <20180305143625.vtrfvsbw7loxngaj@lakrids.cambridge.arm.com>
 <CAAeHK+xd1g0Jqvz+KT9=Cb4PmXWMHS0t+FWqSBhFEHmC1DBkPQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAeHK+xd1g0Jqvz+KT9=Cb4PmXWMHS0t+FWqSBhFEHmC1DBkPQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 09, 2018 at 07:17:14PM +0100, Andrey Konovalov wrote:
> On Mon, Mar 5, 2018 at 3:36 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> > On Fri, Mar 02, 2018 at 08:44:25PM +0100, Andrey Konovalov wrote:
> >> KHWASAN uses the Top Byte Ignore feature of arm64 CPUs to store a pointer
> >> tag in the top byte of each pointer. This commit enables the TCR_TBI1 bit,
> >> which enables Top Byte Ignore for the kernel, when KHWASAN is used.
> >> ---
> >>  arch/arm64/include/asm/pgtable-hwdef.h | 1 +
> >>  arch/arm64/mm/proc.S                   | 8 +++++++-
> >>  2 files changed, 8 insertions(+), 1 deletion(-)
> >
> > Before it's safe to do this, I also think you'll need to fix up at
> > least:

> > * access_ok()
> 
> This is used for accessing user addresses, and they are not tagged. Am
> I missing something?

No, I just confused myself. ;)

I was converned that a kernel address with the top byte clear might
spuriously pass access_ok(), but I was mistaken. Bit 55 of the address
would be set, and this would fall outside of USER_DS (which is
TASK_SIZE_64 - 1).

So access_ok() should be fine as-is.

Sorry for the noise!

Mark.
