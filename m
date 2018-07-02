Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8D1376B026D
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 16:22:27 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id b67-v6so1565650vka.11
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 13:22:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 20-v6sor3965061uak.71.2018.07.02.13.22.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 13:22:26 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180702122112.267261b1e1609cf522753cf3@linux-foundation.org>
References: <cover.1530018818.git.andreyknvl@google.com> <20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
 <CAAeHK+xz552VNpZxgWwU-hbTqF5_F6YVDw3fSv=4OT8mNrqPzg@mail.gmail.com>
 <20180628124039.8a42ab5e2994fb2876ff4f75@linux-foundation.org>
 <CAAeHK+xsBOKghUp9XhpfXGqU=gjSYuy3G2GH14zWNEmaLPy8_w@mail.gmail.com>
 <20180629194117.01b2d31e805808eee5c97b4d@linux-foundation.org>
 <CAFKCwrjxGEa6CLJnjmNy+92d2GSUkoymQ6Sm91CDpMZcJCcWCA@mail.gmail.com> <20180702122112.267261b1e1609cf522753cf3@linux-foundation.org>
From: Evgenii Stepanov <eugenis@google.com>
Date: Mon, 2 Jul 2018 13:22:23 -0700
Message-ID: <CAFKCwri_W8qEw-qMs+gXGqMGdZO82WpCiVpzcG4kinEyL7+zGg@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

On Mon, Jul 2, 2018 at 12:21 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Mon, 2 Jul 2018 12:16:42 -0700 Evgenii Stepanov <eugenis@google.com> wrote:
>
>> On Fri, Jun 29, 2018 at 7:41 PM, Andrew Morton
>> <akpm@linux-foundation.org> wrote:
>> > On Fri, 29 Jun 2018 14:45:08 +0200 Andrey Konovalov <andreyknvl@google.com> wrote:
>> >
>> >> >> What kind of memory consumption testing would you like to see?
>> >> >
>> >> > Well, 100kb or so is a teeny amount on virtually any machine.  I'm
>> >> > assuming the savings are (much) more significant once the machine gets
>> >> > loaded up and doing work?
>> >>
>> >> So with clean kernel after boot we get 40 kb memory usage. With KASAN
>> >> it is ~120 kb, which is 200% overhead. With KHWASAN it's 50 kb, which
>> >> is 25% overhead. This should approximately scale to any amounts of
>> >> used slab memory. For example with 100 mb memory usage we would get
>> >> +200 mb for KASAN and +25 mb with KHWASAN. (And KASAN also requires
>> >> quarantine for better use-after-free detection). I can explicitly
>> >> mention the overhead in %s in the changelog.
>> >>
>> >> If you think it makes sense, I can also make separate measurements
>> >> with some workload. What kind of workload should I use?
>> >
>> > Whatever workload people were running when they encountered problems
>> > with KASAN memory consumption ;)
>> >
>> > I dunno, something simple.  `find / > /dev/null'?
>> >
>>
>> Looking at a live Android device under load, slab (according to
>> /proc/meminfo) + kernel stack take 8-10% available RAM (~350MB).
>> Kasan's overhead of 2x - 3x on top of it is not insignificant.
>>
>
> (top-posting repaired.  Please don't)
>
> For a debugging, not-for-production-use feature, that overhead sounds
> quite acceptable to me.  What problems is it known to cause?

Not having this overhead enables near-production use - ex. running
kasan/khasan kernel on a personal, daily-use device to catch bugs that
do not reproduce in test configuration. These are the ones that often
cost the most engineering time to track down.

CPU overhead is bad, but generally tolerable. RAM is critical, in our
experience. Once it gets low enough, OOM-killer makes your life
miserable.
