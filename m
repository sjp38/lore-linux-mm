Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 48F226B0005
	for <linux-mm@kvack.org>; Sat, 14 Jul 2018 04:02:06 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id b25-v6so9962389eds.17
        for <linux-mm@kvack.org>; Sat, 14 Jul 2018 01:02:06 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u10-v6si1174407edj.219.2018.07.14.01.02.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 14 Jul 2018 01:02:04 -0700 (PDT)
Date: Sat, 14 Jul 2018 10:01:59 +0200
From: Joerg Roedel <jroedel@suse.de>
Subject: Re: [PATCH 10/39] x86/entry/32: Handle Entry from Kernel-Mode on
 Entry-Stack
Message-ID: <20180714080159.hqp36q7fxzb2ktlq@suse.de>
References: <1531308586-29340-1-git-send-email-joro@8bytes.org>
 <1531308586-29340-11-git-send-email-joro@8bytes.org>
 <CALCETrUg_4q8a2Tt_Z+GtVuBwj3Ct3=j7M-YhiK06=XjxOG82A@mail.gmail.com>
 <20180714052110.cobtew6rms23ih37@suse.de>
 <7AB4F269-E0E8-4290-A764-69D8605467E8@amacapital.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <7AB4F269-E0E8-4290-A764-69D8605467E8@amacapital.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Andy Lutomirski <luto@kernel.org>, Joerg Roedel <joro@8bytes.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, X86 ML <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linus Torvalds <torvalds@linux-foundation.org>, Dave Hansen <dave.hansen@intel.com>, Josh Poimboeuf <jpoimboe@redhat.com>, Juergen Gross <jgross@suse.com>, Peter Zijlstra <peterz@infradead.org>, Borislav Petkov <bp@alien8.de>, Jiri Kosina <jkosina@suse.cz>, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Brian Gerst <brgerst@gmail.com>, David Laight <David.Laight@aculab.com>, Denys Vlasenko <dvlasenk@redhat.com>, Eduardo Valentin <eduval@amazon.com>, Greg KH <gregkh@linuxfoundation.org>, Will Deacon <will.deacon@arm.com>, "Liguori, Anthony" <aliguori@amazon.com>, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, Hugh Dickins <hughd@google.com>, Kees Cook <keescook@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Waiman Long <llong@redhat.com>, Pavel Machek <pavel@ucw.cz>, "David H . Gutteridge" <dhgutteridge@sympatico.ca>

On Fri, Jul 13, 2018 at 11:26:54PM -0700, Andy Lutomirski wrote:
> > So based on that, I did the above because the entry-stack is a per-cpu
> > data structure and I am not sure that we always return from the exception
> > on the same CPU where we got it. Therefore the path is called
> > PARANOID_... :)
> 
> But we should just be able to IRET and end up right back on the entry
> stack where we were when we got interrupted.

Yeah, but using another CPUs entry-stack is a bad idea, no? Especially
since the owning CPU might have overwritten our content there already.

> On x86_64, we *definitely* cana??t schedule in NMI, MCE, or #DB because
> wea??re on a percpu stack. Are you *sure* we need this patch?

I am sure we need this patch, but not 100% sure that we really can
change CPUs in this path. We are not only talking about NMI, #MC and
#DB, but also about #GP and every other exception that can happen while
writing segments registers or on iret. With this implementation we are
on the safe side for this unlikely slow-path.

Regards,

	Joerg
