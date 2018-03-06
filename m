Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id B23AB6B000A
	for <linux-mm@kvack.org>; Tue,  6 Mar 2018 13:38:11 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id e14so31337itd.5
        for <linux-mm@kvack.org>; Tue, 06 Mar 2018 10:38:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 66sor7989166ioi.29.2018.03.06.10.38.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 06 Mar 2018 10:38:10 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180305144405.jhrftj56hnlfl4ko@lakrids.cambridge.arm.com>
References: <cover.1520017438.git.andreyknvl@google.com> <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
 <20180305144405.jhrftj56hnlfl4ko@lakrids.cambridge.arm.com>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Tue, 6 Mar 2018 19:38:08 +0100
Message-ID: <CAAeHK+x0gjQT95Suq-xqpbSUVo4Z3r8j48vOOG+NCgGS+cnAGA@mail.gmail.com>
Subject: Re: [RFC PATCH 09/14] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Mon, Mar 5, 2018 at 3:44 PM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Mar 02, 2018 at 08:44:28PM +0100, Andrey Konovalov wrote:
>>  void check_memory_region(unsigned long addr, size_t size, bool write,
>>                               unsigned long ret_ip)
>>  {
>> +     u8 tag;
>> +     u8 *shadow_first, *shadow_last, *shadow;
>> +     void *untagged_addr;
>> +
>> +     tag = get_tag((void *)addr);
>
> Please make get_tag() take a const void *, then this cast can go.

Will do in v2.

>
>> +     untagged_addr = reset_tag((void *)addr);
>
> Likewise for reset_tag().

Ack.

>
>> +     shadow_first = (u8 *)kasan_mem_to_shadow(untagged_addr);
>> +     shadow_last = (u8 *)kasan_mem_to_shadow(untagged_addr + size - 1);
>
> I don't think these u8 * casts are necessary, since
> kasan_mem_to_shadow() returns a void *.

Ack.

>
>> +
>> +     for (shadow = shadow_first; shadow <= shadow_last; shadow++) {
>> +             if (*shadow != tag) {
>> +                     /* Report invalid-access bug here */
>> +                     return;
>
> Huh? Should that be a TODO?

This is fixed in one of the next commits. I decided to split the main
runtime logic and the reporting parts, so this comment is a
placeholder, which is replaced with the proper error reporting
function call later in the patch series. I can make it a /* TODO:
comment */, if you think that looks better.

>
> Thanks,
> Mark.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
