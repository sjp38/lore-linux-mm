Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 550776B0275
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 19:18:04 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id 39-v6so20566021ple.6
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:18:04 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id v18-v6si24041982plo.285.2018.07.13.16.18.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 16:18:03 -0700 (PDT)
Received: from mail-wr1-f42.google.com (mail-wr1-f42.google.com [209.85.221.42])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id A8A72208CC
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 23:18:02 +0000 (UTC)
Received: by mail-wr1-f42.google.com with SMTP id q10-v6so26528547wrd.4
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 16:18:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CALCETrUP1QUKPLPJg6_L5=Mzmq33cSvq+NMaYW01wTCepdjCyg@mail.gmail.com>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-4-git-send-email-joro@8bytes.org> <823BAA9B-FACA-4E91-BE56-315FF569297C@amacapital.net>
 <20180713094849.5bsfpwhxzo5r5exk@8bytes.org> <CALCETrUP1QUKPLPJg6_L5=Mzmq33cSvq+NMaYW01wTCepdjCyg@mail.gmail.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 13 Jul 2018 16:17:40 -0700
Message-ID: <CALCETrUBR-TGPY7wF4UwRb7jW39H+rJ4XFen35dgJRysk9sYTQ@mail.gmail.com>
Subject: Re: [PATCH 03/39] x86/entry/32: Load task stack from x86_tss.sp1 in
 SYSENTER handler
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Fri, Jul 13, 2018 at 10:19 AM, Andy Lutomirski <luto@kernel.org> wrote:
> On Fri, Jul 13, 2018 at 2:48 AM, Joerg Roedel <joro@8bytes.org> wrote:
>> On Thu, Jul 12, 2018 at 01:49:13PM -0700, Andy Lutomirski wrote:
>>> > On Jul 11, 2018, at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
>>> >    /* Offset from the sysenter stack to tss.sp0 */
>>> > -    DEFINE(TSS_entry_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp0) -
>>> > +    DEFINE(TSS_entry_stack, offsetof(struct cpu_entry_area, tss.x86_tss.sp1) -
>>> >           offsetofend(struct cpu_entry_area, entry_stack_page.stack));
>>> >
>>>
>>> The code reads differently. Did you perhaps mean TSS_task_stack?
>>
>> Well, the offset name came from TSS_sysenter_sp0, which was the offset
>> from the sysenter_sp0 (==sysenter-stack) to the task stack in TSS, now
>> sysenter_sp0 became entry_stack, because its used for all entry points
>> and not only sysenter. So with the old convention the naming makes still
>> sense, no?
>>
>
> Trying to parse it certainly makes my brain hurt a bit.  This is the
> offset from the entry stack to sp1, where sp1 is the location of the
> pointer to the task stack.
>
> Maybe all the arithmetic could go in entry_32.S and the asm-offset
> name could just be TSS_sp1, just like on 64-bit?
>

I re-read it again.  How about keeping TSS_entry_stack but making it
be the offset from the TSS to the entry stack.  Then do the arithmetic
in asm.
