Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id CD27E6B0069
	for <linux-mm@kvack.org>; Thu,  2 Nov 2017 14:25:00 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id b186so867865iof.21
        for <linux-mm@kvack.org>; Thu, 02 Nov 2017 11:25:00 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 70sor1765537ior.358.2017.11.02.11.24.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Nov 2017 11:24:59 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <DADF7172-F2ED-4C2A-B921-8707DEDEABD7@amacapital.net>
References: <20171031223146.6B47C861@viggo.jf.intel.com> <20171031223150.AB41C68F@viggo.jf.intel.com>
 <alpine.DEB.2.20.1711012206050.1942@nanos> <CALCETrWQ0W=Kp7fycZ2E9Dp84CCPOr1nEmsPom71ZAXeRYqr9g@mail.gmail.com>
 <alpine.DEB.2.20.1711012225400.1942@nanos> <e8149c9e-10f8-aa74-ff0e-e2de923b2128@linux.intel.com>
 <CA+55aFyijHb4WnDMKgeXekTZHYT8pajqSAu2peo3O4EKiZbYPA@mail.gmail.com>
 <alpine.DEB.2.20.1711012316130.1942@nanos> <CALCETrWS2Tqn=hthSnzxKj3tJrgK+HH2Nkdv-GiXA7bkHUBdcQ@mail.gmail.com>
 <alpine.DEB.2.20.1711021226020.2090@nanos> <c4a5395b-5869-d088-9819-8457d138dc43@linux.intel.com>
 <DADF7172-F2ED-4C2A-B921-8707DEDEABD7@amacapital.net>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 2 Nov 2017 11:24:59 -0700
Message-ID: <CA+55aFxEsMddbGhPWTQ_gDW7p-H_gxGFGz7q8LrNUxF5ChN+jg@mail.gmail.com>
Subject: Re: [PATCH 02/23] x86, kaiser: do not set _PAGE_USER for init_mm page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Dave Hansen <dave.hansen@linux.intel.com>, Thomas Gleixner <tglx@linutronix.de>, Andy Lutomirski <luto@kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, X86 ML <x86@kernel.org>

On Thu, Nov 2, 2017 at 11:19 AM, Andy Lutomirski <luto@amacapital.net> wrote:
>
> We'd have to force NONE, and Linus won't like it.

Oh, I think it's fine for the kaiser case.

I am not convinced anybody will actually use it, but if you do use it,
I suspect "the legacy vsyscall page no longer works" is the least of
your worries.

That said, I think you can keep emulation, and just make it
unreadable. That will keep legacy binaries still working, and will
break a much smaller subset. So we have four cases:

 - native
 - read-only emulation
 - unreadable emulation
 - none

and kaiser triggering that unreadable case sounds like the option
least likely to cause trouble. vsyscalls still work, anybody who tries
to trace them and look at the code will not.

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
