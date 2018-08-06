Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id 16A236B0007
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 15:12:57 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id r15-v6so2256280lff.19
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 12:12:57 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i67-v6sor1264076lfa.169.2018.08.06.12.12.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 12:12:55 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180803150945.GC9297@kroah.com>
References: <cover.1529507994.git.andreyknvl@google.com> <CAAeHK+zqtyGzd_CZ7qKZKU-uZjZ1Pkmod5h8zzbN0xCV26nSfg@mail.gmail.com>
 <20180626172900.ufclp2pfrhwkxjco@armageddon.cambridge.arm.com>
 <CAAeHK+yqWKTdTG+ymZ2-5XKiDANV+fmUjnQkRy-5tpgphuLJRA@mail.gmail.com>
 <CAAeHK+wJbbCZd+-X=9oeJgsqQJiq8h+Aagz3SQMPaAzCD+pvFw@mail.gmail.com>
 <CAAeHK+yWF05XoU+0iuJoXAL3cWgdtxbeLoBz169yP12W4LkcQw@mail.gmail.com>
 <20180801174256.5mbyf33eszml4nmu@armageddon.cambridge.arm.com>
 <CAAeHK+zb7vcehuX9=oxLUJVJr1ZcgmRTODQz7wsPy+rJb=3kbQ@mail.gmail.com>
 <CAAeHK+xTxPhfbVTNxcbsx7VdwQ21Bt-vo2ZU1tEM1_JX7uKnng@mail.gmail.com> <20180803150945.GC9297@kroah.com>
From: Luc Van Oostenryck <luc.vanoostenryck@gmail.com>
Date: Mon, 6 Aug 2018 21:12:53 +0200
Message-ID: <CAExDi1T=s1ASPz6wMbV-G+Wiq8u9zu9cFztaCQ1kDy_TDQkXvg@mail.gmail.com>
Subject: Re: [PATCH v4 0/7] arm64: untag user pointers passed to the kernel
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Cc: Andrey Konovalov <andreyknvl@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Mark Rutland <mark.rutland@arm.com>, Kate Stewart <kstewart@linuxfoundation.org>, linux-doc@vger.kernel.org, Will Deacon <will.deacon@arm.com>, Kostya Serebryany <kcc@google.com>, linux-kselftest@vger.kernel.org, Chintan Pandya <cpandya@codeaurora.org>, Shuah Khan <shuah@kernel.org>, Ingo Molnar <mingo@kernel.org>, linux-arch@vger.kernel.org, Jacob Bramley <Jacob.Bramley@arm.com>, Dmitry Vyukov <dvyukov@google.com>, Evgeniy Stepanov <eugenis@google.com>, Kees Cook <keescook@chromium.org>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Al Viro <viro@zeniv.linux.org.uk>, Linux ARM <linux-arm-kernel@lists.infradead.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Lee Smith <Lee.Smith@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Robin Murphy <robin.murphy@arm.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Matthew Wilcox <willy@infradead.org>

On Fri, Aug 3, 2018 at 5:09 PM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> On Fri, Aug 03, 2018 at 04:59:18PM +0200, Andrey Konovalov wrote:
>> On Thu, Aug 2, 2018 at 5:00 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> > On Wed, Aug 1, 2018 at 7:42 PM, Catalin Marinas <catalin.marinas@arm.com> wrote:
>> >> On Mon, Jul 16, 2018 at 01:25:59PM +0200, Andrey Konovalov wrote:
>> >>> On Thu, Jun 28, 2018 at 9:30 PM, Andrey Konovalov <andreyknvl@google.com> wrote:
>> >>> So the checker reports ~100 different places where a __user pointer
>> >>> being casted. I've looked through them and found 3 places where we
>> >>> need to add untagging. Source code lines below come from 4.18-rc2+
>> >>> (6f0d349d).
>> >> [...]
>> >>> I'll add the 3 patches with fixes to v5 of this patchset.
>> >>
>> >> Thanks for investigating. You can fix those three places in your code
>> >
>> > OK, will do.
>> >
>> >> but I was rather looking for a way to check such casting in the future
>> >> for newly added code. While for the khwasan we can assume it's a debug
>> >> option, the tagged user pointers are ABI and we need to keep it stable.
>> >>
>> >> We could we actually add some macros for explicit conversion between
>> >> __user ptr and long and silence the warning there (I guess this would
>> >> work better for sparse). We can then detect new ptr to long casts as
>> >> they appear. I just hope that's not too intrusive.
>> >>
>> >> (I haven't tried the sparse patch yet, hopefully sometime this week)
>> >
>> > Haven't look at that sparse patch yet myself, but sounds doable.
>> > Should these macros go into this patchset or should they go
>> > separately?
>>
>> Started looking at this. When I run sparse with default checks enabled
>> (make C=1) I get countless warnings. Does anybody actually use it?
>
> Try using a more up-to-date version of sparse.  Odds are you are using
> an old one, there is a newer version in a different branch on kernel.org
> somewhere...
>
> greg k-h
>

Quoting Linus in [1]:

Honestly, I'd like to just encourage people to get the sparse update
from Luc Van Oostenryck instead.

For a while there it looked like Chris Li would just pull from Luc,
and we'd have timely releases, but that really doesn't seem to have
ended up happening after all. So right now it's probably just best to
get Luc's tree instead from

    https://github.com/lucvoo/sparse-dev

which also ends up fixing a lot of other issues.

[1] https://lore.kernel.org/lkml/CA+55aFzYEnZR2GZLR-DwpONjMNYGYoDy+6AWLCVNayWiaZuqoA@mail.gmail.com/T/#u
