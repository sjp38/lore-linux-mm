Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 94AB16B0003
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 17:05:30 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id 1-v6so8694596plv.6
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 14:05:30 -0800 (PST)
Received: from mail.zytor.com (terminus.zytor.com. [198.137.202.136])
        by mx.google.com with ESMTPS id o1-v6si9981323pld.259.2018.03.05.14.05.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 05 Mar 2018 14:05:29 -0800 (PST)
Subject: Re: [PATCH 07/34] x86/entry/32: Restore segments before int registers
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-8-git-send-email-joro@8bytes.org>
 <CA+55aFym-18UbD5K3n1Ki=mvpuLqa7E6E=qG0aE-dctzTap_WQ@mail.gmail.com>
 <20180305131231.GR16484@8bytes.org>
 <CA+55aFwn5EkHTfrUFww54CDWovoUornv6rSrao43agbLBQD6-Q@mail.gmail.com>
 <CAMzpN2hscOXJFzm07Hk=2Ttr3wQFSisxP=EZhRMtAU6xSm8zSw@mail.gmail.com>
 <CA+55aFwxiZ9bD2Zu5xV0idz_dDctPvrrWA2r54+NL4aj9oeN8Q@mail.gmail.com>
 <20180305213550.GV16484@8bytes.org>
 <CA+55aFx2dxZmL487CnhV6rWRiqmJwZNAspyPqCD4Hwqxwncs6Q@mail.gmail.com>
From: "H. Peter Anvin" <hpa@zytor.com>
Message-ID: <12c11262-5e0f-2987-0a74-3bde4b66c352@zytor.com>
Date: Mon, 5 Mar 2018 14:03:49 -0800
MIME-Version: 1.0
In-Reply-To: <CA+55aFx2dxZmL487CnhV6rWRiqmJwZNAspyPqCD4Hwqxwncs6Q@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Joerg Roedel <joro@8bytes.org>
Cc: Brian Gerst <brgerst@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?UTF-8?B?SsO8cmdlbiBHcm/Dnw==?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On 03/05/18 13:58, Linus Torvalds wrote:
> On Mon, Mar 5, 2018 at 1:35 PM, Joerg Roedel <joro@8bytes.org> wrote:
>> On Mon, Mar 05, 2018 at 12:50:33PM -0800, Linus Torvalds wrote:
>>>
>>> Ahh, good. So presumably Joerg actually did check it, just didn't even notice ;)
>>
>> Yeah, sort of. I ran the test, but it didn't catch the failure case in
>> previous versions which was return to user with kernel-cr3 :)
> 
> Ahh. Yes, that's bad. The NX protection to guarantee that you don't
> return to user mode was really good on x86-64.
> 
> So some other case could slip through, because user code can happily
> run with the kernel page tables.
> 
>> I could probably add some debug instrumentation to check for that in my
>> future testing, as there is no NX protection in the user address-range
>> for the kernel-cr3.
> 
> Does not NX work with PAE?
> 
> Oh, it looks like the NX bit is marked as "RSVD (must be 0)" in the
> PDPDT. Oh well.
> 

On NX-enabled hardware NX works with PDE, but the PDPDT in general
doesn't have permission bits (it's really more of a set of four CR3s
than a page table level.)

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
