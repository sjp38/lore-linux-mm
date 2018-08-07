Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 69EAB6B000A
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 16:28:47 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id u4-v6so7712233pgr.2
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 13:28:47 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id h21-v6si2251858pgi.430.2018.08.07.13.28.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 13:28:46 -0700 (PDT)
Received: from mail-wr1-f51.google.com (mail-wr1-f51.google.com [209.85.221.51])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id BCF1F21736
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 20:28:45 +0000 (UTC)
Received: by mail-wr1-f51.google.com with SMTP id u12-v6so16960668wrr.4
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 13:28:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.21.1808072218310.1672@nanos.tec.linutronix.de>
References: <1533637471-30953-1-git-send-email-joro@8bytes.org>
 <1533637471-30953-3-git-send-email-joro@8bytes.org> <feea2aff-91ff-89a6-9d7c-5402a1d6a27f@intel.com>
 <CALCETrXj1-CC-rcnM5s2SvbSFKjZPMYj0O-9d1PY0MRdGEKs-g@mail.gmail.com> <alpine.DEB.2.21.1808072218310.1672@nanos.tec.linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 7 Aug 2018 13:28:23 -0700
Message-ID: <CALCETrX4e=U21c+_9u_PrvJecDpjKiuQ-KGeW=Z3ME=a2=Kj9Q@mail.gmail.com>
Subject: Re: [PATCH 2/3] x86/mm/pti: Don't clear permissions in pti_clone_pmd()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Joerg Roedel <joro@8bytes.org>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Tue, Aug 7, 2018 at 1:21 PM, Thomas Gleixner <tglx@linutronix.de> wrote:
> On Tue, 7 Aug 2018, Andy Lutomirski wrote:
>
>> On Tue, Aug 7, 2018 at 11:34 AM, Dave Hansen <dave.hansen@intel.com> wrote:
>> > On 08/07/2018 03:24 AM, Joerg Roedel wrote:
>> >> The function sets the global-bit on cloned PMD entries,
>> >> which only makes sense when the permissions are identical
>> >> between the user and the kernel page-table.
>> >>
>> >> Further, only write-permissions are cleared for entry-text
>> >> and kernel-text sections, which are not writeable anyway.
>> >
>> > I think this patch is correct, but I'd be curious if Andy remembers why
>> > we chose to clear _PAGE_RW on these things.  It might have been that we
>> > were trying to say that the *entry* code shouldn't write to this stuff,
>> > regardless of whether the normal kernel can.
>> >
>> > But, either way, I agree with the logic here that Global pages must
>> > share permissions between both mappings, so feel free to add my Ack.  I
>> > just want to make sure Andy doesn't remember some detail I'm forgetting.
>>
>> I suspect it's because we used to (and maybe still do) initialize the
>> user tables before mark_read_only().
>
> We still do that because we need the entry stuff working for interrupts
> early on. We now repeat the clone after mark_ro so the mask RW is not
> longer required.

Agreed.
