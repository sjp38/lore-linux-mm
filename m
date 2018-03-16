Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f197.google.com (mail-yw0-f197.google.com [209.85.161.197])
	by kanga.kvack.org (Postfix) with ESMTP id 9B8C76B0009
	for <linux-mm@kvack.org>; Fri, 16 Mar 2018 14:16:59 -0400 (EDT)
Received: by mail-yw0-f197.google.com with SMTP id r202so10720543ywg.20
        for <linux-mm@kvack.org>; Fri, 16 Mar 2018 11:16:59 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id t195sor2998860ywg.322.2018.03.16.11.16.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 16 Mar 2018 11:16:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAAeHK+xNjYOAhLBogYYfXi+KiFf9SDYGoaV6og=aRmuB7rhvHg@mail.gmail.com>
References: <cover.1520017438.git.andreyknvl@google.com> <06a4d0c483fba8babd01fe23727fe4a79482d309.1520017438.git.andreyknvl@google.com>
 <CAG_fn=XjN2zQQrL1r-pv5rMhLgmvOyh8LS9QF0PQ8Y7gk4AVug@mail.gmail.com>
 <CAAeHK+wGHsFeDP_QMQRzWGTFg10bxfJPxx-_7Ja-_uTP8GJtCA@mail.gmail.com>
 <7f8e8f46-791e-7e8f-551b-f93aa64bcf6e@virtuozzo.com> <CAAeHK+xNjYOAhLBogYYfXi+KiFf9SDYGoaV6og=aRmuB7rhvHg@mail.gmail.com>
From: Evgenii Stepanov <eugenis@google.com>
Date: Fri, 16 Mar 2018 11:16:57 -0700
Message-ID: <CAFKCwriP6KY6PaHheZi9gLVebKp-rLa-gATSSE3R-fhrRYex3A@mail.gmail.com>
Subject: Re: [RFC PATCH 09/14] khwasan: add hooks implementation
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Jonathan Corbet <corbet@lwn.net>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Theodore Ts'o <tytso@mit.edu>, Jan Kara <jack@suse.com>, Christopher Li <sparse@chrisli.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Masahiro Yamada <yamada.masahiro@socionext.com>, Michal Marek <michal.lkml@markovi.net>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Yury Norov <ynorov@caviumnetworks.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Bob Picco <bob.picco@oracle.com>, Suzuki K Poulose <suzuki.poulose@arm.com>, Kristina Martsenko <kristina.martsenko@arm.com>, Punit Agrawal <punit.agrawal@arm.com>, Dave Martin <Dave.Martin@arm.com>, James Morse <james.morse@arm.com>, Julien Thierry <julien.thierry@arm.com>, Michael Weiser <michael.weiser@gmx.de>, Steve Capper <steve.capper@arm.com>, Ingo Molnar <mingo@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Paul Lawrence <paullawrence@google.com>, David Woodhouse <dwmw@amazon.co.uk>, Kees Cook <keescook@chromium.org>, Geert Uytterhoeven <geert@linux-m68k.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Arnd Bergmann <arnd@arndb.de>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-ext4@vger.kernel.org, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Kees Cook <keescook@google.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>

On Fri, Mar 16, 2018 at 11:09 AM, Andrey Konovalov
<andreyknvl@google.com> wrote:
> On Thu, Mar 15, 2018 at 5:52 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>> On 03/13/2018 08:00 PM, Andrey Konovalov wrote:
>>> On Tue, Mar 13, 2018 at 4:05 PM, 'Alexander Potapenko' via kasan-dev
>>> <kasan-dev@googlegroups.com> wrote:
>>>> Does it make sense to generate the redzone tag from the object tag
>>>> (e.g. by addding 1 to it)?
>>>
>>> Yes, I think so, will do!
>>>
>>
>> Wouldn't be better to have some reserved tag value for invalid memory (redzones/free), so that
>> we catch access to such memory with 100% probability?
>
> We could do that. That would reduce the chance to detect a
> use-after-free though, since we're using fewer different tag values
> for the objects themselves. I don't have a strong opinion about which
> one is better though.

hwasan does not need redzones. As for use-after-free, to catch it with
100% probability one would need infinite memory for the quarantine. It
is possible to guarantee 100% detection of linear buffer overflow by
giving live adjacent chunks distinct tags.
