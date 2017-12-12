Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8A5056B026C
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 13:03:42 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id p17so18337250pfh.18
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:03:42 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id s4si11690737pgp.418.2017.12.12.10.03.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 12 Dec 2017 10:03:41 -0800 (PST)
Received: from mail-it0-f47.google.com (mail-it0-f47.google.com [209.85.214.47])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 0E30A20C0F
	for <linux-mm@kvack.org>; Tue, 12 Dec 2017 18:03:41 +0000 (UTC)
Received: by mail-it0-f47.google.com with SMTP id d16so421591itj.1
        for <linux-mm@kvack.org>; Tue, 12 Dec 2017 10:03:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171212173221.496222173@linutronix.de>
References: <20171212173221.496222173@linutronix.de>
From: Andy Lutomirski <luto@kernel.org>
Date: Tue, 12 Dec 2017 10:03:19 -0800
Message-ID: <CALCETrVDiL6Q7mXmewpjWcC_LMofYTNYh7w4cR=4UDvCq=9B_w@mail.gmail.com>
Subject: Re: [patch 00/16] x86/ldt: Use a VMA based read only mapping
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, X86 ML <x86@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirsky <luto@kernel.org>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bpetkov@suse.de>, Greg KH <gregkh@linuxfoundation.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, Brian Gerst <brgerst@gmail.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Denys Vlasenko <dvlasenk@redhat.com>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, David Laight <David.Laight@aculab.com>, Eduardo Valentin <eduval@amazon.com>, aliguori@amazon.com, Will Deacon <will.deacon@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Dec 12, 2017 at 9:32 AM, Thomas Gleixner <tglx@linutronix.de> wrote:
> Peter and myself spent quite some time to figure out how to make CPUs cope
> with a RO mapped LDT.
>
> While the initial trick of writing the ACCESS bit in a special fault
> handler covers most cases, the tricky problem of CS/SS in return to user
> space (IRET ...) was giving us quite some headache.
>
> Peter finally found a way to do so. Touching the CS/SS selectors with LAR
> on the way out to user space makes it work w/o trouble.
>
> Contrary to the approach Andy was taking with storing the LDT in a special
> map area, the following series uses a special mapping which is mapped
> without the user bit and read only. This just ties the LDT to the process
> which is the most natural way to do it, removes the requirement for special
> pagetable code and works independent of pagetable isolation.
>
> This was tested on quite a range of Intel and AMD machines, but the test
> coverage on 32bit is quite meager. I'll resurrect a few dust bricks
> tomorrow.

I think it's neat that you got this working.  But it's like three
times the size of my patch, is *way* more intrusive, and isn't
obviously correct WRT IRET and load_gs_index().  So... how is it
better than my patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
