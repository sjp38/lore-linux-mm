Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 729D16B0003
	for <linux-mm@kvack.org>; Wed,  7 Mar 2018 13:16:07 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id g195so3141838itg.7
        for <linux-mm@kvack.org>; Wed, 07 Mar 2018 10:16:07 -0800 (PST)
Received: from resqmta-ch2-02v.sys.comcast.net (resqmta-ch2-02v.sys.comcast.net. [2001:558:fe21:29:69:252:207:34])
        by mx.google.com with ESMTPS id z190si12684844ioz.133.2018.03.07.10.16.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Mar 2018 10:16:06 -0800 (PST)
Date: Wed, 7 Mar 2018 12:16:02 -0600 (CST)
From: Christopher Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 07/14] khwasan: add tag related helper functions
In-Reply-To: <CAAeHK+w3Sm=NF+gWasJ8XdcmsWP_Kx6_B5ECbqLHFPvUxMzDCA@mail.gmail.com>
Message-ID: <alpine.DEB.2.20.1803071215050.6373@nuc-kabylake>
References: <cover.1520017438.git.andreyknvl@google.com> <226055ec7c1a01dd8211ca9a8b34c07162be37fa.1520017438.git.andreyknvl@google.com> <20180305143246.o7bass2rhbksneqb@lakrids.cambridge.arm.com>
 <CAAeHK+w3Sm=NF+gWasJ8XdcmsWP_Kx6_B5ECbqLHFPvUxMzDCA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>


On Tue, 6 Mar 2018, Andrey Konovalov wrote:

> >> +     u32 state = this_cpu_read(prng_state);
> >> +
> >> +     state = 1664525 * state + 1013904223;
> >> +     this_cpu_write(prng_state, state);
> >
> > Have you considered preemption here? Is the assumption that it happens
> > sufficiently rarely that cross-contaminating the prng state isn't a
> > problem?
>
> Hi Mark!
>
> Yes, I have. If a preemption happens between this_cpu_read and
> this_cpu_write, the only side effect is that we'll give a few
> allocated in different contexts objects the same tag. Sine KHWASAN is
> meant to be used a probabilistic bug-detection debug feature, this
> doesn't seem to have serious negative impact.
>
> I'll add a comment about this though.

You could use this_cpu_cmpxchg here to make it a bit better but it
probably does not matter.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
