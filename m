Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EF6226B0033
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 13:12:54 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id s22so3158417pfh.21
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 10:12:54 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id p2si4830537plo.798.2018.01.17.10.12.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 10:12:53 -0800 (PST)
Received: from mail-io0-f176.google.com (mail-io0-f176.google.com [209.85.223.176])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 7376D21742
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 18:12:53 +0000 (UTC)
Received: by mail-io0-f176.google.com with SMTP id f34so16592883ioi.13
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 10:12:53 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180117141006.GR28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-4-git-send-email-joro@8bytes.org> <CALCETrW9F4QDFPG=ATs0QiyQO526SK0s==oYKhvVhxaYCw+65g@mail.gmail.com>
 <20180117092442.GJ28161@8bytes.org> <CAMzpN2j5EUh5TJDVWPPvL9Wn9LCcouCTjZ-CUuKRRo+rvsiH+g@mail.gmail.com>
 <20180117141006.GR28161@8bytes.org>
From: Andy Lutomirski <luto@kernel.org>
Date: Wed, 17 Jan 2018 10:12:32 -0800
Message-ID: <CALCETrVQitDeZATQDoZQ6TKxqT=QNWs-qytUp8edrMDxXBbxYw@mail.gmail.com>
Subject: Re: [PATCH 03/16] x86/entry/32: Leave the kernel via the trampoline stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Brian Gerst <brgerst@gmail.com>, Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Wed, Jan 17, 2018 at 6:10 AM, Joerg Roedel <joro@8bytes.org> wrote:
> On Wed, Jan 17, 2018 at 05:57:53AM -0800, Brian Gerst wrote:
>> On Wed, Jan 17, 2018 at 1:24 AM, Joerg Roedel <joro@8bytes.org> wrote:
>
>> > I have no real idea on how to switch back to the entry stack without
>> > access to per_cpu variables. I also can't access the cpu_entry_area for
>> > the cpu yet, because for that we need to be on the entry stack already.
>>
>> Switch to the trampoline stack before loading user segments.
>
> That requires to copy most of pt_regs from task- to trampoline-stack,
> not sure if that is faster than temporily restoring kernel %fs.
>

I would optimize for simplicity, not speed.  You're already planning
to write to CR3, which is serializing, blows away the TLB, *and* takes
the absurdly large amount of time that the microcode needs to blow
away the TLB.

(For whatever reason, Intel doesn't seem to have hardware that can
quickly wipe the TLB.  I suspect that the actual implementation does
it in a loop and wipes little pieces at a time.  Whatever it actually
does, the CR3 write itself is very slow.)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
