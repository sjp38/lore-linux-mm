Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5FBE16B0005
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 13:07:31 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id r202-v6so201729ywg.11
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 10:07:31 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h124-v6sor52560ybb.68.2018.06.19.10.07.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 10:07:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1529427588.23068.7.camel@intel.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-7-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
 <1528403417.5265.35.camel@2b52.sc.intel.com> <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com>
 <alpine.DEB.2.21.1806121155450.2157@nanos.tec.linutronix.de>
 <CAMe9rOoCiXQ4iVD3j_AHGrvEXtoaVVZVs7H7fCuqNEuuR5j+2Q@mail.gmail.com>
 <CALCETrXO8R+RQPhJFk4oiA4PF77OgSS2Yro_POXQj1zvdLo61A@mail.gmail.com>
 <CAMe9rOpLxPussn7gKvn0GgbOB4f5W+DKOGipe_8NMam+Afd+RA@mail.gmail.com>
 <CALCETrWmGRkQvsUgRaj+j0CP4beKys+TT5aDR5+18nuphwr+Cw@mail.gmail.com>
 <CAMe9rOpzcCdje=bUVs+C1WrY6GuwA-8AUFVLOG325LGz7KHJxw@mail.gmail.com>
 <alpine.DEB.2.21.1806122046520.1592@nanos.tec.linutronix.de>
 <CAMe9rOrGjJf0aMnUjAP38MqvOiW3=iXGQjcUT3O=f9pE85hXaw@mail.gmail.com>
 <CALCETrVsh5t-V1Sm88LsZE_+DS0GE_bMWbcoX3SjD6GnrB08Pw@mail.gmail.com>
 <CAGXu5jK0gospOXRpN6zYiQPXOZeE=YpVAz2qu4Zc3-32v85+EQ@mail.gmail.com>
 <569B4719-6283-4575-A16E-D0A78D280F4E@amacapital.net> <CAGXu5jJNgu4bW_Zthqjfpe9gLxK0zxG8QFEqqK+pJNebz6tUaw@mail.gmail.com>
 <1529427588.23068.7.camel@intel.com>
From: Kees Cook <keescook@chromium.org>
Date: Tue, 19 Jun 2018 10:07:28 -0700
Message-ID: <CAGXu5jJ4ivrvi-kG0iY=4C0mQQXBDXwPdfY36Dk+JqOpX19n0w@mail.gmail.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>
Cc: Andy Lutomirski <luto@amacapital.net>, Andy Lutomirski <luto@kernel.org>, "H. J. Lu" <hjl.tools@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com, Florian Weimer <fweimer@redhat.com>

On Tue, Jun 19, 2018 at 9:59 AM, Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
> On Tue, 2018-06-19 at 09:44 -0700, Kees Cook wrote:
>> On Tue, Jun 19, 2018 at 7:50 AM, Andy Lutomirski <luto@amacapital.net
>> > wrote:
>> >
>> > >
>> > > On Jun 18, 2018, at 5:52 PM, Kees Cook <keescook@chromium.org>
>> > > wrote:
>> > > Following Linus's request for "slow introduction" of new security
>> > > features, likely the best approach is to default to "relaxed"
>> > > (with a
>> > > warning about down-grades), and allow distros/end-users to pick
>> > > "forced" if they know their libraries are all CET-enabled.
>> > I still don=E2=80=99t get what =E2=80=9Crelaxed=E2=80=9D is for.  I th=
ink the right design
>> > is:
>> >
>> > Processes start with CET on or off depending on the ELF note, but
>> > they start with CET unlocked no matter what. They can freely switch
>> > CET on and off (subject to being clever enough not to crash if they
>> > turn it on and then return right off the end of the shadow stack)
>> > until they call ARCH_CET_LOCK.
>> I'm fine with this. I'd expect modern loaders to just turn on CET and
>> ARCH_CET_LOCK immediately and be done with it. :P
>
> This is the current implementation.  If the loader has CET in its ELF
> header, it is executed with CET on.  The loader will turn off CET if
> the application being loaded does not support it (in the ELF header).
>  The loader calls ARCH_CET_LOCK before passing to the application.  But
> how do we handle dlopen?

I thought CET_LOCK would not get set in "relaxed" mode, due to dlopen
usage, and that would be the WARN case. People without dlopen concerns
can boot with "enforced" mode? If a system builder knows there are no
legacy dlopens they build with enforced enabled, etc.

>> > Ptrace gets new APIs to turn CET on and off and to lock and unlock
>> > it.  If an attacker finds a =E2=80=9Cptrace me and turn off CET=E2=80=
=9D gadget,
>> > then they might as well just do =E2=80=9Cptrace me and write shell cod=
e=E2=80=9D
>> > instead. It=E2=80=99s basically the same gadget. Keep in mind that the
>> > actual sequence of syscalls to do this is incredibly complicated.
>> Right -- if an attacker can control ptrace of the target, we're way
>> past CET. The only concern I have, though, is taking advantage of
>> expected ptracing. For example: browsers tend to have crash handlers
>> that launch a ptracer. If ptracing disabled CET for all threads, this
>> won't by safe: an attacker just gains control in two threads, crashes
>> one to get the ptracer to attach, which disables CET in the other
>> thread and the attacker continues ROP as normal. As long as the
>> ptrace
>> disabling is thread-specific, I think this will be okay.
>
> If ptrace can turn CET on/off and it is thread-specific, do we still
> need ptrace lock/unlock?

Does it provide anything beyond what PR_DUMPABLE does?

-Kees

--=20
Kees Cook
Pixel Security
