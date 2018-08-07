Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 01D416B0003
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 15:38:48 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id g26-v6so11053777pfo.7
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 12:38:47 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id t24-v6si1935363pgm.106.2018.08.07.12.38.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Aug 2018 12:38:46 -0700 (PDT)
Received: from mail-wr1-f47.google.com (mail-wr1-f47.google.com [209.85.221.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 3AC3C2174D
	for <linux-mm@kvack.org>; Tue,  7 Aug 2018 19:38:46 +0000 (UTC)
Received: by mail-wr1-f47.google.com with SMTP id u12-v6so16847542wrr.4
        for <linux-mm@kvack.org>; Tue, 07 Aug 2018 12:38:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <feea2aff-91ff-89a6-9d7c-5402a1d6a27f@intel.com>
References: <1533637471-30953-1-git-send-email-joro@8bytes.org>
 <1533637471-30953-3-git-send-email-joro@8bytes.org> <feea2aff-91ff-89a6-9d7c-5402a1d6a27f@intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 7 Aug 2018 12:38:24 -0700
Message-ID: <CALCETrXj1-CC-rcnM5s2SvbSFKjZPMYj0O-9d1PY0MRdGEKs-g@mail.gmail.com>
Subject: Re: [PATCH 2/3] x86/mm/pti: Don't clear permissions in pti_clone_pmd()
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, Joerg Roedel <jroedel@suse.de>

On Tue, Aug 7, 2018 at 11:34 AM, Dave Hansen <dave.hansen@intel.com> wrote:
> On 08/07/2018 03:24 AM, Joerg Roedel wrote:
>> The function sets the global-bit on cloned PMD entries,
>> which only makes sense when the permissions are identical
>> between the user and the kernel page-table.
>>
>> Further, only write-permissions are cleared for entry-text
>> and kernel-text sections, which are not writeable anyway.
>
> I think this patch is correct, but I'd be curious if Andy remembers why
> we chose to clear _PAGE_RW on these things.  It might have been that we
> were trying to say that the *entry* code shouldn't write to this stuff,
> regardless of whether the normal kernel can.
>
> But, either way, I agree with the logic here that Global pages must
> share permissions between both mappings, so feel free to add my Ack.  I
> just want to make sure Andy doesn't remember some detail I'm forgetting.

I suspect it's because we used to (and maybe still do) initialize the
user tables before mark_read_only().
