Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F35C56B0069
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:07:14 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id r88so18347866pfi.23
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:07:14 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id m6si13071576pfh.41.2017.12.12.10.07.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 10:07:13 -0800 (PST)
Received: from mail-it0-f41.google.com (mail-it0-f41.google.com [209.85.214.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 8B8A420837
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 18:07:13 +0000 (UTC)
Received: by mail-it0-f41.google.com with SMTP id 68so403105ite.4
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:07:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171212180509.iewpmzdhvsusk2nk@hirez.programming.kicks-ass.net>
References: <20171212173221.496222173@linutronix.de> <20171212173333.669577588@linutronix.de>
 <CALCETrXLeGGw+g7GiGDmReXgOxjB-cjmehdryOsFK4JB5BJAFQ@mail.gmail.com> <20171212180509.iewpmzdhvsusk2nk@hirez.programming.kicks-ass.net>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 12 Dec 2017 10:06:51 -0800
Message-ID: <CALCETrXTYY2oDSNXapFPX5z=dgZ5ievemoxupO6uD_88h5b90A@mail.gmail.com>
Subject: Re: [patch 05/16] mm: Allow special mappings with user access cleared
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 10:05 AM, Peter Zijlstra <peterz@infradead.org> wrote:
> On Tue, Dec 12, 2017 at 10:00:08AM -0800, Andy Lutomirski wrote:
>> On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
>> > From: Peter Zijstra <peterz@infradead.org>
>> >
>> > In order to create VMAs that are not accessible to userspace create a new
>> > VM_NOUSER flag. This can be used in conjunction with
>> > install_special_mapping() to inject 'kernel' data into the userspace map.
>> >
>> > Similar to how arch_vm_get_page_prot() allows adding _PAGE_flags to
>> > pgprot_t, introduce arch_vm_get_page_prot_excl() which masks
>> > _PAGE_flags from pgprot_t and use this to implement VM_NOUSER for x86.
>>
>> How does this interact with get_user_pages(), etc?
>
> gup would find the page. These patches do in fact rely on that through
> the populate things.
>

Blech.  So you can write(2) from the LDT to a file and you can even
sendfile it, perhaps.  What happens if it's get_user_page()'d when
modify_ldt() wants to free it?

This patch series scares the crap out of me.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
