Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f70.google.com (mail-wm1-f70.google.com [209.85.128.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9A1646B0271
	for <linux-mm@kvack.org>; Thu,  4 Oct 2018 12:12:17 -0400 (EDT)
Received: by mail-wm1-f70.google.com with SMTP id p4-v6so1532652wmc.1
        for <linux-mm@kvack.org>; Thu, 04 Oct 2018 09:12:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t184-v6sor3702601wmb.7.2018.10.04.09.12.16
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 04 Oct 2018 09:12:16 -0700 (PDT)
MIME-Version: 1.0
References: <20180921150553.21016-1-yu-cheng.yu@intel.com> <20180921150553.21016-7-yu-cheng.yu@intel.com>
 <20181004132811.GJ32759@asgard.redhat.com> <3350f7b42b32f3f7a1963a9c9c526210c24f7b05.camel@intel.com>
 <87murtn19o.fsf@mid.deneb.enyo.de>
In-Reply-To: <87murtn19o.fsf@mid.deneb.enyo.de>
From: Andy Lutomirski <luto@amacapital.net>
Date: Thu, 4 Oct 2018 09:12:04 -0700
Message-ID: <CALCETrXTqxQLWEHhSQ6WsDosnD61rnN2TgAFFomVAf5URP4DzA@mail.gmail.com>
Subject: Re: [RFC PATCH v4 6/9] x86/cet/ibt: Add arch_prctl functions for IBT
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Florian Weimer <fw@deneb.enyo.de>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, Eugene Syromiatnikov <esyr@redhat.com>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromium.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, Randy Dunlap <rdunlap@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, libc-alpha <libc-alpha@sourceware.org>, Carlos O'Donell <carlos@redhat.com>

On Thu, Oct 4, 2018 at 9:08 AM Florian Weimer <fw@deneb.enyo.de> wrote:
>
> * Yu-cheng Yu:
>
> > On Thu, 2018-10-04 at 15:28 +0200, Eugene Syromiatnikov wrote:
> >> On Fri, Sep 21, 2018 at 08:05:50AM -0700, Yu-cheng Yu wrote:
> >> > Update ARCH_CET_STATUS and ARCH_CET_DISABLE to include Indirect
> >> > Branch Tracking features.
> >> >
> >> > Introduce:
> >> >
> >> > arch_prctl(ARCH_CET_LEGACY_BITMAP, unsigned long *addr)
> >> >     Enable the Indirect Branch Tracking legacy code bitmap.
> >> >
> >> >     The parameter 'addr' is a pointer to a user buffer.
> >> >     On returning to the caller, the kernel fills the following:
> >> >
> >> >     *addr = IBT bitmap base address
> >> >     *(addr + 1) = IBT bitmap size
> >>
> >> Again, some structure with a size field would be better from
> >> UAPI/extensibility standpoint.
> >>
> >> One additional point: "size" in the structure from kernel should have
> >> structure size expected by kernel, and at least providing there "0" from
> >> user space shouldn't lead to failure (in fact, it is possible to provide
> >> structure size back to userspace even if buffer is too small, along
> >> with error).
> >
> > This has been in GLIBC v2.28.  We cannot change it anymore.
>
> In theory, you could, if you change the ARCH_CET_LEGACY_BITMAP
> constant, so that glibc will not use the different arch_prctl
> operation.  We could backport the change into the glibc 2.28 dynamic
> linker, so that existing binaries will start using CET again.  Then
> only statically linked binaries will be impacted.
>
> It's definitely not ideal, but it's doable if the interface is
> terminally broken or otherwise unacceptable.  But to me it looks like
> this threshold isn't reached here.

I tend to agree.

But I do think there's a real problem that should be fixed and won't
affect ABI: the *name* of the prctl is pretty bad.  I read the test
several times trying to decide if you meant
ARCH_GET_CET_LEGACY_BITMAP?  But you don't.

Maybe name it ARCH_CET_CREATE_LEGACY_BITMAP?  And explicitly document
what it does if legacy bitmap already exists?

--Andy
