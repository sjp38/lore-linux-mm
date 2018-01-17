Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 56DA228029C
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 09:00:09 -0500 (EST)
Received: by mail-io0-f200.google.com with SMTP id t134so18087248iof.6
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 06:00:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u62sor796712ioe.322.2018.01.17.06.00.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 17 Jan 2018 06:00:08 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <CAMzpN2j5EUh5TJDVWPPvL9Wn9LCcouCTjZ-CUuKRRo+rvsiH+g@mail.gmail.com>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-4-git-send-email-joro@8bytes.org> <CALCETrW9F4QDFPG=ATs0QiyQO526SK0s==oYKhvVhxaYCw+65g@mail.gmail.com>
 <20180117092442.GJ28161@8bytes.org> <CAMzpN2j5EUh5TJDVWPPvL9Wn9LCcouCTjZ-CUuKRRo+rvsiH+g@mail.gmail.com>
From: Brian Gerst <brgerst@gmail.com>
Date: Wed, 17 Jan 2018 06:00:07 -0800
Message-ID: <CAMzpN2hXjHhx_9GDih8r808dYemYcy02f+LeXfG_8iuJkN82gA@mail.gmail.com>
Subject: Re: [PATCH 03/16] x86/entry/32: Leave the kernel via the trampoline stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joerg Roedel <joro@8bytes.org>
Cc: Andy Lutomirski <luto@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Wed, Jan 17, 2018 at 5:57 AM, Brian Gerst <brgerst@gmail.com> wrote:
> On Wed, Jan 17, 2018 at 1:24 AM, Joerg Roedel <joro@8bytes.org> wrote:
>> On Tue, Jan 16, 2018 at 02:48:43PM -0800, Andy Lutomirski wrote:
>>> On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
>>> > +       /* Restore user %edi and user %fs */
>>> > +       movl (%edi), %edi
>>> > +       popl %fs
>>>
>>> Yikes!  We're not *supposed* to be able to observe an asynchronous
>>> descriptor table change, but if the LDT changes out from under you,
>>> this is going to blow up badly.  It would be really nice if you could
>>> pull this off without percpu access or without needing to do this
>>> dance where you load user FS, then kernel FS, then user FS.  If that's
>>> not doable, then you should at least add exception handling -- look at
>>> the other 'pop %fs' instructions in entry_32.S.
>>
>> You are right! This also means I need to do the 'popl %fs' before the
>> cr3-switch. I'll fix it in the next version.
>>
>> I have no real idea on how to switch back to the entry stack without
>> access to per_cpu variables. I also can't access the cpu_entry_area for
>> the cpu yet, because for that we need to be on the entry stack already.
>
> Switch to the trampoline stack before loading user segments.

But then again, you could take a fault on the trampoline stack if you
get a bad segment.  Perhaps just pushing the new stack pointer onto
the process stack before user segment loads will be the right move.

--
Brian Gerst

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
