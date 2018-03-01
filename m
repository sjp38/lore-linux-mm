Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A20C6B0008
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 13:24:42 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id g69so6618120ita.9
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 10:24:42 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j73sor2462032itb.80.2018.03.01.10.24.41
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 01 Mar 2018 10:24:41 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20180301165019.kuynvb6fkcwdpxjx@suse.de>
References: <1518168340-9392-1-git-send-email-joro@8bytes.org>
 <1518168340-9392-13-git-send-email-joro@8bytes.org> <afd5bae9-f53e-a225-58f1-4ba2422044e3@redhat.com>
 <20180301133430.wda4qesqhxnww7d6@8bytes.org> <2ae8b01f-844b-b8b1-3198-5db70c3e083b@redhat.com>
 <20180301165019.kuynvb6fkcwdpxjx@suse.de>
From: Brian Gerst <brgerst@gmail.com>
Date: Thu, 1 Mar 2018 13:24:39 -0500
Message-ID: <CAMzpN2gxVnb65LHXbBioM4LAMN2d-d1-xx3QyQrmsHECBXC29g@mail.gmail.com>
Subject: Re: [PATCH 12/31] x86/entry/32: Add PTI cr3 switch to non-NMI
 entry/exit points
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <jroedel@suse.de>
Cc: Waiman Long <longman@redhat.com>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>

On Thu, Mar 1, 2018 at 11:50 AM, Joerg Roedel <jroedel@suse.de> wrote:
> On Thu, Mar 01, 2018 at 09:33:11AM -0500, Waiman Long wrote:
>> On 03/01/2018 08:34 AM, Joerg Roedel wrote:
>> I think that should fix the issue of debug exception from userspace.
>>
>> One thing that I am not certain about is whether debug exception can
>> happen even if the IF flag is cleared. If it can, debug exception should
>> be handled like NMI as the state of the CR3 can be indeterminate if the
>> exception happens in the entry/exit code.
>
> I am actually not 100% sure where it can happen, from the code it can
> happen from anywhere, except when we are running on an espfix stack.
>
> So I am not sure we need the same complex handling NMIs need wrt. to
> switching the cr3s.

The IF flag only affects external maskable interrupts, not traps or
faults.  You do need to check CR3 because SYSENTER does not clear TF
and will immediately cause a debug trap on kernel entry (with user
CR3) if set.  That is why the code existed before to check for the
entry stack for debug/NMI.

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
