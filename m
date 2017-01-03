Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id A57766B0253
	for <linux-mm@kvack.org>; Tue,  3 Jan 2017 13:29:54 -0500 (EST)
Received: by mail-vk0-f72.google.com with SMTP id q13so235619398vkd.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 10:29:54 -0800 (PST)
Received: from mail-ua0-x235.google.com (mail-ua0-x235.google.com. [2607:f8b0:400c:c08::235])
        by mx.google.com with ESMTPS id d3si17415461vkh.92.2017.01.03.10.29.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 03 Jan 2017 10:29:53 -0800 (PST)
Received: by mail-ua0-x235.google.com with SMTP id 88so324528551uaq.3
        for <linux-mm@kvack.org>; Tue, 03 Jan 2017 10:29:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <3492795.xaneWtGxgW@wuerfel>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
 <2736959.3MfCab47fD@wuerfel> <CALCETrV_qejd-Ozqo4vTqz=LuukMUPeQ7EVUQbfTxs_xNbO3oQ@mail.gmail.com>
 <3492795.xaneWtGxgW@wuerfel>
From: Andy Lutomirski <luto@amacapital.net>
Date: Tue, 3 Jan 2017 10:29:33 -0800
Message-ID: <CALCETrUCdu3kTBU09gXaSppO7VCm+872zkGnovaZKTXBbY2wTg@mail.gmail.com>
Subject: Re: [RFC, PATCHv2 29/29] mm, x86: introduce RLIMIT_VADDR
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnd Bergmann <arnd@arndb.de>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>

On Tue, Jan 3, 2017 at 5:18 AM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Monday, January 2, 2017 10:08:28 PM CET Andy Lutomirski wrote:
>>
>> > This seems to nicely address the same problem on arm64, which has
>> > run into the same issue due to the various page table formats
>> > that can currently be chosen at compile time.
>>
>> On further reflection, I think this has very little to do with paging
>> formats except insofar as paging formats make us notice the problem.
>> The issue is that user code wants to be able to assume an upper limit
>> on an address, and it gets an upper limit right now that depends on
>> architecture due to paging formats.  But someone really might want to
>> write a *portable* 64-bit program that allocates memory with the high
>> 16 bits clear.  So let's add such a mechanism directly.
>>
>> As a thought experiment, what if x86_64 simply never allocated "high"
>> (above 2^47-1) addresses unless a new mmap-with-explicit-limit syscall
>> were used?  Old glibc would continue working.  Old VMs would work.
>> New programs that want to use ginormous mappings would have to use the
>> new syscall.  This would be totally stateless and would have no issues
>> with CRIU.
>
> I can see this working well for the 47-bit addressing default, but
> what about applications that actually rely on 39-bit addressing
> (I'd have to double-check, but I think this was the limit that
> people were most interested in for arm64)?
>
> 39 bits seems a little small to make that the default for everyone
> who doesn't pass the extra flag. Having to pass another flag to
> limit the addresses introduces other problems (e.g. mmap from
> library call that doesn't pass that flag).

That's a fair point.  Maybe my straw man isn't so good.

>
>> If necessary, we could also have a prctl that changes a
>> "personality-like" limit that is in effect when the old mmap was used.
>> I say "personality-like" because it would reset under exactly the same
>> conditions that personality resets itself.
>
> For "personality-like", it would still have to interact
> with the existing PER_LINUX32 and PER_LINUX32_3GB flags that
> do the exact same thing, so actually using personality might
> be better.
>
> We still have a few bits in the personality arguments, and
> we could combine them with the existing ADDR_LIMIT_3GB
> and ADDR_LIMIT_32BIT flags that are mutually exclusive by
> definition, such as
>
>         ADDR_LIMIT_32BIT =      0x0800000, /* existing */
>         ADDR_LIMIT_3GB   =      0x8000000, /* existing */
>         ADDR_LIMIT_39BIT =      0x0010000, /* next free bit */
>         ADDR_LIMIT_42BIT =      0x8010000,
>         ADDR_LIMIT_47BIT =      0x0810000,
>         ADDR_LIMIT_48BIT =      0x8810000,
>
> This would probably take only one or two personality bits for the
> limits that are interesting in practice.

Hmm.  What if we approached this a bit differently?  We could add a
single new personality bit ADDR_LIMIT_EXPLICIT.  Setting this bit
cause PER_LINUX32_3GB etc to be automatically cleared.  When
ADDR_LIMIT_EXPLICIT is in effect, prctl can set a 64-bit numeric
limit.  If ADDR_LIMIT_EXPLICIT is cleared, the prctl value stops being
settable and reading it via prctl returns whatever is implied by the
other personality bits.

--Andy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
