Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 56F416B0005
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 13:02:39 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id l1so2170696pga.1
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:02:39 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l1-v6si275678pld.81.2018.02.14.10.02.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 14 Feb 2018 10:02:38 -0800 (PST)
Received: from mail-io0-f169.google.com (mail-io0-f169.google.com [209.85.223.169])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 04376217A0
	for <linux-mm@kvack.org>; Wed, 14 Feb 2018 18:02:38 +0000 (UTC)
Received: by mail-io0-f169.google.com with SMTP id b198so26061098iof.6
        for <linux-mm@kvack.org>; Wed, 14 Feb 2018 10:02:37 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180214175548.6uxpm3bspmgqi7hs@node.shutemov.name>
References: <20180214111656.88514-1-kirill.shutemov@linux.intel.com>
 <20180214111656.88514-9-kirill.shutemov@linux.intel.com> <CALCETrVafx9kZwsJrihUxKszio9rJCPZJHnWSh3QC992o=zxnA@mail.gmail.com>
 <20180214175548.6uxpm3bspmgqi7hs@node.shutemov.name>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 14 Feb 2018 18:02:16 +0000
Message-ID: <CALCETrX6URu5+aNnRC6YeAT3hFyuiVdnrpQ2-eT9_Wdc5hQm8w@mail.gmail.com>
Subject: Re: [PATCH 8/9] x86/mm: Make __VIRTUAL_MASK_SHIFT dynamic
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Ingo Molnar <mingo@redhat.com>, X86 ML <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>, Linus Torvalds <torvalds@linux-foundation.org>, Borislav Petkov <bp@suse.de>, Andi Kleen <ak@linux.intel.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Feb 14, 2018 at 5:55 PM, Kirill A. Shutemov
<kirill@shutemov.name> wrote:
> On Wed, Feb 14, 2018 at 05:22:58PM +0000, Andy Lutomirski wrote:
>> On Wed, Feb 14, 2018 at 11:16 AM, Kirill A. Shutemov
>> <kirill.shutemov@linux.intel.com> wrote:
>> > For boot-time switching between paging modes, we need to be able to
>> > adjust virtual mask shifts.
>> >
>> > The change doesn't affect the kernel image size much:
>> >
>> >    text    data     bss     dec     hex filename
>> > 8628892 4734340 1368064 14731296         e0c820 vmlinux.before
>> > 8628966 4734340 1368064 14731370         e0c86a vmlinux.after
>> >
>> > Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
>> > ---
>> >  arch/x86/entry/entry_64.S            | 12 ++++++++++++
>> >  arch/x86/include/asm/page_64_types.h |  2 +-
>> >  arch/x86/mm/dump_pagetables.c        | 12 ++++++++++--
>> >  arch/x86/mm/kaslr.c                  |  4 +++-
>> >  4 files changed, 26 insertions(+), 4 deletions(-)
>> >
>> > diff --git a/arch/x86/entry/entry_64.S b/arch/x86/entry/entry_64.S
>> > index cd216c9431e1..1608b13a0b36 100644
>> > --- a/arch/x86/entry/entry_64.S
>> > +++ b/arch/x86/entry/entry_64.S
>> > @@ -260,8 +260,20 @@ GLOBAL(entry_SYSCALL_64_after_hwframe)
>> >          * Change top bits to match most significant bit (47th or 56th bit
>> >          * depending on paging mode) in the address.
>> >          */
>> > +#ifdef CONFIG_X86_5LEVEL
>> > +       testl   $1, pgtable_l5_enabled(%rip)
>> > +       jz      1f
>> > +       shl     $(64 - 57), %rcx
>> > +       sar     $(64 - 57), %rcx
>> > +       jmp     2f
>> > +1:
>> > +       shl     $(64 - 48), %rcx
>> > +       sar     $(64 - 48), %rcx
>> > +2:
>> > +#else
>> >         shl     $(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
>> >         sar     $(64 - (__VIRTUAL_MASK_SHIFT+1)), %rcx
>> > +#endif
>>
>> Eww.
>>
>> Can't this be ALTERNATIVE "shl ... sar ...", "shl ... sar ...",
>> X86_FEATURE_5LEVEL or similar?
>
> Optimization comes in a separate patch:
>
> https://git.kernel.org/pub/scm/linux/kernel/git/kas/linux.git/commit/?h=la57/boot-switching/wip&id=015fa3576a7f2b8bd271096bb3a12b06cdc845af
>

Nice!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
