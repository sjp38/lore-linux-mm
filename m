Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD8C96B0268
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 11:33:21 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id a6so5100313pff.17
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:33:21 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p29si3128974pgn.443.2017.12.14.08.33.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 14 Dec 2017 08:33:20 -0800 (PST)
Received: from mail-it0-f53.google.com (mail-it0-f53.google.com [209.85.214.53])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id E4FEF2192A
	for <linux-mm@kvack.org>; Thu, 14 Dec 2017 16:33:19 +0000 (UTC)
Received: by mail-it0-f53.google.com with SMTP id f143so12462349itb.0
        for <linux-mm@kvack.org>; Thu, 14 Dec 2017 08:33:19 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171214113851.348915849@infradead.org>
References: <20171214112726.742649793@infradead.org> <20171214113851.348915849@infradead.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 14 Dec 2017 08:32:57 -0800
Message-ID: <CALCETrV2WOYxXFFwDGJjtuZwBUpUyWhrr-Q1Q-CvYhVCycrtww@mail.gmail.com>
Subject: Re: [PATCH v2 05/17] x86/ldt: Prevent ldt inheritance on exec
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, "Liguori, Anthony" <aliguori@amazon.com>, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Dan Williams <dan.j.williams@intel.com>

On Thu, Dec 14, 2017 at 3:27 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> From: Thomas Gleixner <tglx@linutronix.de>
>
> The LDT is inheritet independent of fork or exec, but that makes no sense
> at all because exec is supposed to start the process clean.
>
> The reason why this happens is that init_new_context_ldt() is called from
> init_new_context() which obviously needs to be called for both fork() and
> exec().
>
> It would be surprising if anything relies on that behaviour, so it seems to
> be safe to remove that misfeature.
>
> Split the context initialization into two parts. Clear the ldt pointer and
> initialize the mutex from the general context init and move the LDT
> duplication to arch_dup_mmap() which is only called on fork().

I like this one.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
