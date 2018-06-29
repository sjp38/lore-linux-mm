Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id DC2DB6B000D
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 09:18:33 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id h195-v6so1814390itb.3
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 06:18:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t10-v6sor265754jai.1.2018.06.29.06.18.32
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 29 Jun 2018 06:18:32 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180629112613.7i4xesjyxolc63gu@ltop.local>
References: <cover.1530018818.git.andreyknvl@google.com> <20180628105057.GA26019@e103592.cambridge.arm.com>
 <CAAeHK+w0T43+h3xqU4a-qutxd-qiEhsvk0eaZpmAn-T0hpaLZQ@mail.gmail.com>
 <20180629110419.GC26019@e103592.cambridge.arm.com> <20180629112613.7i4xesjyxolc63gu@ltop.local>
From: Andrey Konovalov <andreyknvl@google.com>
Date: Fri, 29 Jun 2018 15:18:31 +0200
Message-ID: <CAAeHK+zXzTEo_DJ5a7KaVDQa06Gx98Oj2O3jMFJo_tNgkq822g@mail.gmail.com>
Subject: Re: [PATCH v4 00/17] khwasan: kernel hardware assisted address sanitizer
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Cc: Dave Martin <Dave.Martin@arm.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Paul Lawrence <paullawrence@google.com>, Linux Memory Management List <linux-mm@kvack.org>, Alexander Potapenko <glider@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Christoph Lameter <cl@linux.com>, Ingo Molnar <mingo@kernel.org>, Jacob Bramley <Jacob.Bramley@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, kasan-dev <kasan-dev@googlegroups.com>, linux-sparse@vger.kernel.org, Geert Uytterhoeven <geert@linux-m68k.org>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Evgeniy Stepanov <eugenis@google.com>, Arnd Bergmann <arnd@arndb.de>, Linux Kbuild mailing list <linux-kbuild@vger.kernel.org>, Marc Zyngier <marc.zyngier@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Dmitry Vyukov <dvyukov@google.com>, Kostya Serebryany <kcc@google.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Nick Desaulniers <ndesaulniers@google.com>, LKML <linux-kernel@vger.kernel.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, smatch@vger.kernel.org, Dan Carpenter <dan.carpenter@oracle.com>

On Fri, Jun 29, 2018 at 1:26 PM, Luc Van Oostenryck
<luc.vanoostenryck@gmail.com> wrote:
> On Fri, Jun 29, 2018 at 12:04:22PM +0100, Dave Martin wrote:
>>
>> Can sparse be hacked to identify pointer subtractions where the pointers
>> are cannot be statically proved to point into the same allocation?

Re all the comments about finding all the places where we do pointer
subtraction/comparison:

I might be wrong, but I doubt you can easily do that with static analysis.

What we could do is to try to detect all such subtractions/comparisons
dynamically. The idea is to instrument all pointer/ulong
subtraction/comparison instructions and try to detect tags mismatch.
And then run some workload (e.g. syzkaller) to trigger more kernel
code. The question is how much false positives we would get, since I
imagine there would be a number of cases when we compare some random
ulongs.
