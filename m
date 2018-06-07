Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7D76B0006
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 16:53:57 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e3-v6so5047370pfe.15
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:53:57 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id d125-v6si6302749pgc.94.2018.06.07.13.53.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jun 2018 13:53:56 -0700 (PDT)
Received: from mail-wr0-f171.google.com (mail-wr0-f171.google.com [209.85.128.171])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 6EA182089E
	for <linux-mm@kvack.org>; Thu,  7 Jun 2018 20:53:55 +0000 (UTC)
Received: by mail-wr0-f171.google.com with SMTP id x4-v6so3044854wro.11
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 13:53:55 -0700 (PDT)
MIME-Version: 1.0
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-5-yu-cheng.yu@intel.com>
 <CALCETrUqXvh2FDXe6bveP10TFpzptEyQe2=mdfZFGKU0T+NXsA@mail.gmail.com> <3c1bdf85-0c52-39ed-a799-e26ac0e52391@redhat.com>
In-Reply-To: <3c1bdf85-0c52-39ed-a799-e26ac0e52391@redhat.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Thu, 7 Jun 2018 13:53:41 -0700
Message-ID: <CALCETrWPDXpbVcuFK_1M5DtaCOW_LSf-XHFAD0vpc735oFWLPg@mail.gmail.com>
Subject: Re: [PATCH 04/10] x86/cet: Handle thread shadow stack
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fweimer@redhat.com>
Cc: Andrew Lutomirski <luto@kernel.org>, Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 12:47 PM Florian Weimer <fweimer@redhat.com> wrote:
>
> On 06/07/2018 08:21 PM, Andy Lutomirski wrote:
> > On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrot=
e:
> >>
> >> When fork() specifies CLONE_VM but not CLONE_VFORK, the child
> >> needs a separate program stack and a separate shadow stack.
> >> This patch handles allocation and freeing of the thread shadow
> >> stack.
> >
> > Aha -- you're trying to make this automatic.  I'm not convinced this
> > is a good idea.  The Linux kernel has a long and storied history of
> > enabling new hardware features in ways that are almost entirely
> > useless for userspace.
> >
> > Florian, do you have any thoughts on how the user/kernel interaction
> > for the shadow stack should work?
>
> I have not looked at this in detail, have not played with the emulator,
> and have not been privy to any discussions before these patches have
> been posted, however =E2=80=A6
>
> I believe that we want as little code in userspace for shadow stack
> management as possible.  One concern I have is that even with the code
> we arguably need for various kinds of stack unwinding, we might have
> unwittingly built a generic trampoline that leads to full CET bypass.

I was imagining an API like "allocate a shadow stack for the current
thread, fail if the current thread already has one, and turn on the
shadow stack".  glibc would call clone and then call this ABI pretty
much immediately (i.e. before making any calls from which it expects
to return).

We definitely want strong enough user control that tools like CRIU can
continue to work.  I haven't looked at the SDM recently enough to
remember for sure, but I'm reasonably confident that user code can
learn the address of its own shadow stack.  If nothing else, CRIU
needs to be able to restore from a context where there's a signal on
the stack and the signal frame contains a shadow stack pointer.


>
> I also expect that we'd only have donor mappings in userspace anyway,
> and that the memory is not actually accessible from userspace if it is
> used for a shadow stack.
>
> > My intuition would be that all
> > shadow stack management should be entirely controlled by userspace --
> > newly cloned threads (with CLONE_VM) should have no shadow stack
> > initially, and newly started processes should have no shadow stack
> > until they ask for one.
>
> If the new thread doesn't have a shadow stack, we need to disable
> signals around clone, and we are very likely forced to rewrite the early
> thread setup in assembler, to avoid spurious calls (including calls to
> thunks to get EIP on i386).  I wouldn't want to do this If we can avoid
> it.  Just using C and hoping to get away with it doesn't sound greater,
> either.  And obviously there is the matter that the initial thread setup
> code ends up being that universal trampoline.
>

Only if the trampoline works if the shadow stack is already enabled.

I could very easily be convinced that automatic shadow stack setup is
a good idea, but I still think we need manual control for CRIU and
such.
