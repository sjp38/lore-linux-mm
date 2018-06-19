Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 905E66B0007
	for <linux-mm@kvack.org>; Tue, 19 Jun 2018 10:50:49 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id p91-v6so12109408plb.12
        for <linux-mm@kvack.org>; Tue, 19 Jun 2018 07:50:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 70-v6sor6049417pla.67.2018.06.19.07.50.47
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 19 Jun 2018 07:50:47 -0700 (PDT)
Content-Type: text/plain;
	charset=utf-8
Mime-Version: 1.0 (1.0)
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <CAGXu5jK0gospOXRpN6zYiQPXOZeE=YpVAz2qu4Zc3-32v85+EQ@mail.gmail.com>
Date: Tue, 19 Jun 2018 07:50:43 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <569B4719-6283-4575-A16E-D0A78D280F4E@amacapital.net>
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
 <CALCETrVsh5t-V1Sm88LsZE_+DS0GE_bMWbcoX3SjD6GnrB08Pw@mail.gmail.com> <CAGXu5jK0gospOXRpN6zYiQPXOZeE=YpVAz2qu4Zc3-32v85+EQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@kernel.org>, "H. J. Lu" <hjl.tools@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com, Florian Weimer <fweimer@redhat.com>



> On Jun 18, 2018, at 5:52 PM, Kees Cook <keescook@chromium.org> wrote:
>=20
>> On Mon, Jun 18, 2018 at 3:03 PM, Andy Lutomirski <luto@kernel.org> wrote:=

>>> On Tue, Jun 12, 2018 at 12:34 PM H.J. Lu <hjl.tools@gmail.com> wrote:
>>>=20
>>>> On Tue, Jun 12, 2018 at 11:59 AM, Thomas Gleixner <tglx@linutronix.de> w=
rote:
>>>>> On Tue, 12 Jun 2018, H.J. Lu wrote:
>>>>>> On Tue, Jun 12, 2018 at 9:34 AM, Andy Lutomirski <luto@kernel.org> wr=
ote:
>>>>>>> On Tue, Jun 12, 2018 at 9:05 AM H.J. Lu <hjl.tools@gmail.com> wrote:=

>>>>>>>> On Tue, Jun 12, 2018 at 9:01 AM, Andy Lutomirski <luto@kernel.org> w=
rote:
>>>>>>>>> On Tue, Jun 12, 2018 at 4:43 AM H.J. Lu <hjl.tools@gmail.com> wrot=
e:
>>>>>>>>>> On Tue, Jun 12, 2018 at 3:03 AM, Thomas Gleixner <tglx@linutronix=
.de> wrote:
>>>>>>>>>> That works for stuff which loads all libraries at start time, but=
 what
>>>>>>>>>> happens if the program uses dlopen() later on? If CET is force lo=
cked and
>>>>>>>>>> the library is not CET enabled, it will fail.
>>>>>>>>>=20
>>>>>>>>> That is to prevent disabling CET by dlopening a legacy shared libr=
ary.
>>>>>>>>>=20
>>>>>>>>>> I don't see the point of trying to support CET by magic. It adds c=
omplexity
>>>>>>>>>> and you'll never be able to handle all corner cases correctly. dl=
open() is
>>>>>>>>>> not even a corner case.
>>>>>>>>>=20
>>>>>>>>> That is a price we pay for security.  To enable CET, especially sh=
adow
>>>>>>>>> shack, the program and all of shared libraries it uses should be C=
ET
>>>>>>>>> enabled.  Most of programs can be enabled with CET by compiling th=
em
>>>>>>>>> with -fcf-protection.
>>>>>>>>=20
>>>>>>>> If you charge too high a price for security, people may turn it off=
.
>>>>>>>> I think we're going to need a mode where a program says "I want to u=
se
>>>>>>>> the CET, but turn it off if I dlopen an unsupported library".  Ther=
e
>>>>>>>> are programs that load binary-only plugins.
>>>>>>>=20
>>>>>>> You can do
>>>>>>>=20
>>>>>>> # export GLIBC_TUNABLES=3Dglibc.tune.hwcaps=3D-SHSTK
>>>>>>>=20
>>>>>>> which turns off shadow stack.
>>>>>>>=20
>>>>>>=20
>>>>>> Which exactly illustrates my point.  By making your security story to=
o
>>>>>> absolute, you'll force people to turn it off when they don't need to.=

>>>>>> If I'm using a fully CET-ified distro and I'm using a CET-aware
>>>>>> program that loads binary plugins, and I may or may not have an old
>>>>>> (binary-only, perhaps) plugin that doesn't support CET, then the
>>>>>> behavior I want is for CET to be on until I dlopen() a program that
>>>>>> doesn't support it.  Unless there's some ABI reason why that can't be=

>>>>>> done, but I don't think there is.
>>>>>=20
>>>>> We can make it opt-in via GLIBC_TUNABLES.  But by default, the legacy
>>>>> shared object is disallowed when CET is enabled.
>>>>=20
>>>> That's a bad idea. Stuff has launchers which people might not be able t=
o
>>>> change. So they will simply turn of CET completely or it makes them hac=
k
>>>> horrible crap into init, e.g. the above export.
>>>>=20
>>>> Give them sane kernel options:
>>>>=20
>>>>     cet =3D off, relaxed, forced
>>>>=20
>>>> where relaxed allows to run binary plugins. Then let dlopen() call into=
 the
>>>> kernel with the filepath of the library to check for CET and that will t=
ell
>>>> you whether its ok or or not and do the necessary magic in the kernel w=
hen
>>>> CET has to be disabled due to a !CET library/application.
>>>>=20
>>>> That's also making the whole thing independent of magic glibc environme=
nt
>>>> options and allows it to be used all over the place in the same way.
>>>=20
>>> This is very similar to our ARCH_CET_EXEC proposal which controls how
>>> CET should be enforced.   But Andy thinks it is a bad idea.
>>=20
>> I do think it's a bad idea to have a new piece of state that survives
>> across exec().  It's going to have nasty usability problems and nasty
>> security problems.
>>=20
>> We may need a mode by which glibc can turn CET *back off* even after a
>> program had it on if it dlopens() an old binary.  Or maybe there won't
>> be demand.  I can certainly understand why the CET_LOCK feature is
>> there, although I think we need a way to override it using something
>> like ptrace().  I'm not convinced that CET_LOCK is really needed, but
>> someone who understand the thread model should chime in.
>>=20
>> Kees, do you know anyone who has a good enough understanding of
>> usermode exploits and how they'll interact with CET?
>=20
> Adding Florian to CC, but if something gets CET enabled, it really
> shouldn't have a way to turn it off. If there's a way to turn it off,
> all the ROP research will suddenly turn to exactly one gadget before
> doing the rest of the ROP: turning off CET. Right now ROP is: use
> stack-pivot gadget, do everything else. Allowed CET to turn off will
> just add one step: use CET-off gadget, use stack-pivot gadget, do
> everything else. :P

Fair enough=20

>=20
> Following Linus's request for "slow introduction" of new security
> features, likely the best approach is to default to "relaxed" (with a
> warning about down-grades), and allow distros/end-users to pick
> "forced" if they know their libraries are all CET-enabled.

I still don=E2=80=99t get what =E2=80=9Crelaxed=E2=80=9D is for.  I think th=
e right design is:

Processes start with CET on or off depending on the ELF note, but they start=
 with CET unlocked no matter what. They can freely switch CET on and off (su=
bject to being clever enough not to crash if they turn it on and then return=
 right off the end of the shadow stack) until they call ARCH_CET_LOCK.

Ptrace gets new APIs to turn CET on and off and to lock and unlock it.  If a=
n attacker finds a =E2=80=9Cptrace me and turn off CET=E2=80=9D gadget, then=
 they might as well just do =E2=80=9Cptrace me and write shell code=E2=80=9D=
 instead. It=E2=80=99s basically the same gadget. Keep in mind that the actu=
al sequence of syscalls to do this is incredibly complicated.

It=E2=80=99s unclear to me that forcing CET on belongs in the kernel at all.=
  By the time an attacker can find a non-CET ELF binary and can exec it in a=
 context where it does their bidding, the attacker is far beyond what CET ca=
n even try to help. At this point we=E2=80=99re talking about an attacker wh=
o can effectively invoke system(3) with arbitrary parameters, and attackers w=
ith *that* power don=E2=80=99t need ROP and the like.

There is a new feature I=E2=80=99d like to see, though: add an ELF note to b=
less a binary as being an ELF interpreter. And add an LSM callback to valida=
te an ELF interpreter.  Let=E2=80=99s minimize the shenanigans that people w=
ho control containers can get up to. (Obviously the ELF note part would need=
 to be opt-in.)=
