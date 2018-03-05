Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9638D6B0012
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 11:44:52 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id f16so11708103wre.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 08:44:52 -0800 (PST)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id 35si2305971edm.241.2018.03.05.08.44.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 05 Mar 2018 08:44:49 -0800 (PST)
Date: Mon, 5 Mar 2018 17:44:48 +0100
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 07/34] x86/entry/32: Restore segments before int registers
Message-ID: <20180305164448.GS16484@8bytes.org>
References: <1520245563-8444-1-git-send-email-joro@8bytes.org>
 <1520245563-8444-8-git-send-email-joro@8bytes.org>
 <CA+55aFym-18UbD5K3n1Ki=mvpuLqa7E6E=qG0aE-dctzTap_WQ@mail.gmail.com>
 <20180305131231.GR16484@8bytes.org>
 <CAMzpN2gQ0pfSZES_cnNJSzvvGxbzuHdP0iAjx5GG5kJ6FGudbw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAMzpN2gQ0pfSZES_cnNJSzvvGxbzuHdP0iAjx5GG5kJ6FGudbw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brian Gerst <brgerst@gmail.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Anvin <hpa@zytor.com>, the arch/x86 maintainers <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, =?iso-8859-1?Q?J=FCrgen_Gro=DF?= <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, Joerg Roedel <jroedel@suse.de>

On Mon, Mar 05, 2018 at 09:51:29AM -0500, Brian Gerst wrote:
> For the IRET fault case you will still need to catch it in the
> exception code.  See the 64-bit code (.Lerror_bad_iret) for example.
> For 32-bit, you could just expand that check to cover the whole exit
> prologue after the CR3 switch, including the data segment loads.

I had a look at the 64 bit code and the exception-in-kernel case seems
to be handled differently than on 32 bit. The 64 bit entry code has
checks for certain kinds of errors like iret exceptions.

On 32 bit this is implemented via the standard exception tables which
get an entry for every EIP that might fault (usually segment loading
operations, but also iret).

So, unless I am missing something, all the exception entry code has to
do is to remember the stack and the cr3 with which it was entered (if
entered from kernel mode) and restore those before iret. And this is
what I implemented in v3 of this patch-set.


Regards,

	Joerg

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
