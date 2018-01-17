Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 7FC10280281
	for <linux-mm@kvack.org>; Wed, 17 Jan 2018 04:24:44 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id c11so7071627wrb.23
        for <linux-mm@kvack.org>; Wed, 17 Jan 2018 01:24:44 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id e6si4926705edk.214.2018.01.17.01.24.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jan 2018 01:24:43 -0800 (PST)
Date: Wed, 17 Jan 2018 10:24:42 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 03/16] x86/entry/32: Leave the kernel via the trampoline
 stack
Message-ID: <20180117092442.GJ28161@8bytes.org>
References: <1516120619-1159-1-git-send-email-joro@8bytes.org>
 <1516120619-1159-4-git-send-email-joro@8bytes.org>
 <CALCETrW9F4QDFPG=ATs0QiyQO526SK0s==oYKhvVhxaYCw+65g@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALCETrW9F4QDFPG=ATs0QiyQO526SK0s==oYKhvVhxaYCw+65g@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Joerg Roedel <jroedel@suse.de>

On Tue, Jan 16, 2018 at 02:48:43PM -0800, Andy Lutomirski wrote:
> On Tue, Jan 16, 2018 at 8:36 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > +       /* Restore user %edi and user %fs */
> > +       movl (%edi), %edi
> > +       popl %fs
> 
> Yikes!  We're not *supposed* to be able to observe an asynchronous
> descriptor table change, but if the LDT changes out from under you,
> this is going to blow up badly.  It would be really nice if you could
> pull this off without percpu access or without needing to do this
> dance where you load user FS, then kernel FS, then user FS.  If that's
> not doable, then you should at least add exception handling -- look at
> the other 'pop %fs' instructions in entry_32.S.

You are right! This also means I need to do the 'popl %fs' before the
cr3-switch. I'll fix it in the next version.

I have no real idea on how to switch back to the entry stack without
access to per_cpu variables. I also can't access the cpu_entry_area for
the cpu yet, because for that we need to be on the entry stack already.


	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
