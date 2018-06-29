Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id B80636B0007
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 08:45:10 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id h195-v6so1712338itb.3
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 05:45:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o79-v6sor374226itc.52.2018.06.29.05.45.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Jun 2018 05:45:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180628124039.8a42ab5e2994fb2876ff4f75@linux-foundation.org>
References: <cover.1530018818.git.andreyknvl@google.com> <20180627160800.3dc7f9ee41c0badbf7342520@linux-foundation.org>
 <CAAeHK+xz552VNpZxgWwU-hbTqF5_F6YVDw3fSv=4OT8mNrqPzg@mail.gmail.com> <20180628124039.8a42ab5e2994fb2876ff4f75@linux-foundation.org>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 29 Jun 2018 14:45:08 +0200
Message-ID: <CAAeHK+xsBOKghUp9XhpfXGqU=gjSYuy3G2GH14zWNEmaLPy8_w@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-doc@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, linux-sparse@vger.kernel.org, Linux Memory Management List <linux-mm@kvack.org>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>

On Thu, Jun 28, 2018 at 9:40 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 28 Jun 2018 20:29:07 +0200 Andrey Konovalov <andreyknvl@google.com> wrote:
>
>> >> Slab memory usage after boot [2]:
>> >> * ~40 kb for clean kernel
>> >> * ~105 kb + 1/8th shadow ~= 118 kb for KASAN
>> >> * ~47 kb + 1/16th shadow ~= 50 kb for KHWASAN
>> >>
>> >> Network performance [3]:
>> >> * 8.33 Gbits/sec for clean kernel
>> >> * 3.17 Gbits/sec for KASAN
>> >> * 2.85 Gbits/sec for KHWASAN
>> >>
>> >> Note, that KHWASAN (compared to KASAN) doesn't require quarantine.
>> >>
>> >> [1] Time before the ext4 driver is initialized.
>> >> [2] Measured as `cat /proc/meminfo | grep Slab`.
>> >> [3] Measured as `iperf -s & iperf -c 127.0.0.1 -t 30`.
>> >
>> > The above doesn't actually demonstrate the whole point of the
>> > patchset: to reduce KASAN's very high memory consumption?
>>
>> You mean that memory usage numbers collected after boot don't give a
>> representative picture of actual memory consumption on real workloads?
>>
>> What kind of memory consumption testing would you like to see?
>
> Well, 100kb or so is a teeny amount on virtually any machine.  I'm
> assuming the savings are (much) more significant once the machine gets
> loaded up and doing work?

So with clean kernel after boot we get 40 kb memory usage. With KASAN
it is ~120 kb, which is 200% overhead. With KHWASAN it's 50 kb, which
is 25% overhead. This should approximately scale to any amounts of
used slab memory. For example with 100 mb memory usage we would get
+200 mb for KASAN and +25 mb with KHWASAN. (And KASAN also requires
quarantine for better use-after-free detection). I can explicitly
mention the overhead in %s in the changelog.

If you think it makes sense, I can also make separate measurements
with some workload. What kind of workload should I use?
