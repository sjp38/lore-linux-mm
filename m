Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 496356B000A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 06:05:28 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id p7-v6so1781607eds.19
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 03:05:28 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [81.169.241.247])
        by mx.google.com with ESMTPS id v12-v6si697918edr.266.2018.07.13.03.05.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 13 Jul 2018 03:05:27 -0700 (PDT)
Date: Fri, 13 Jul 2018 12:05:19 +0200
From: Joerg Roedel <joro@8bytes.org>
Subject: Re: [PATCH 05/39] x86/entry/32: Unshare NMI return path
Message-ID: <20180713100519.pn7ium7a4ga24dys@8bytes.org>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-6-git-send-email-joro@8bytes.org>
 <BEEA447A-26A1-49C9-925A-63F96E9115B0@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BEEA447A-26A1-49C9-925A-63F96E9115B0@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, aliguori@amazon.com, daniel.gruss@iaik.tugraz.at, hughd@google.com, keescook@google.com, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>, jroedel@suse.de

On Thu, Jul 12, 2018 at 01:53:19PM -0700, Andy Lutomirski wrote:
> > On Jul 11, 2018, at 4:29 AM, Joerg Roedel <joro@8bytes.org> wrote:
> > NMI will no longer use most of the shared return path,
> > because NMI needs special handling when the CR3 switches for
> > PTI are added.
> 
> Why?  What would go wrong?
> 
> How many return-to-usermode paths will we have?  64-bit has only one.

In the non-NMI return path we make a decission on whether we return to
user-space or kernel-space and do different things based on that. For
example, when returning to user-space we call
prepare_exit_to_usermode(). With the CR3 switches added later we also
unconditionally switch to user-cr3 when we are in the return-to-user
path.

The NMI return path does not need any of that, as it doesn't call
prepare_exit_to_usermode() even when it returns to user-space. It
doesn't even care where it returns to. It just remembers stack and cr3
on entry in callee-safed registers and restores that on exit. This works
in the NMI path because it is pretty simple and doesn't do any fancy
work on exit.

While working on a previous version I also tried to store stack and cr3
in a callee-safed register and restore that on exit again, but it didn't
work, most likley because something in-between overwrote one of the
registers. I also found it a bit fragile to make make two registers
untouchable in the whole entry-code. It doesn't make future changes
simpler or more robust.

So long story short, the NMI path can be simpler wrt. stack and cr3
handling as the other entry/exit points, and therefore it is handled
differently.

Regards,

	Joerg
