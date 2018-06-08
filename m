Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC37E6B0003
	for <linux-mm@kvack.org>; Fri,  8 Jun 2018 00:22:15 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s84-v6so7045053oig.17
        for <linux-mm@kvack.org>; Thu, 07 Jun 2018 21:22:15 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m67-v6sor2672154oib.298.2018.06.07.21.22.14
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Jun 2018 21:22:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com>
References: <20180607143807.3611-1-yu-cheng.yu@intel.com> <20180607143807.3611-7-yu-cheng.yu@intel.com>
 <CALCETrU6axo158CiSCRRkC4GC5hib9hypC98t7LLjA3gDaacsw@mail.gmail.com>
 <1528403417.5265.35.camel@2b52.sc.intel.com> <CALCETrXz3WWgZwUXJsDTWvmqKUArQFuMH1xJdSLVKFpTysNWxg@mail.gmail.com>
 <CAMe9rOr49V8rqRa_KVsw61PWd+crkQvPDgPKtvowazjmsfgWWQ@mail.gmail.com>
From: "H.J. Lu" <hjl.tools@gmail.com>
Date: Thu, 7 Jun 2018 21:22:13 -0700
Message-ID: <CAMe9rOphjpPd3HnKAdU-RmG0RGj6c2oAbnq+C2Jd1srsqTA7=w@mail.gmail.com>
Subject: Re: [PATCH 06/10] x86/cet: Add arch_prctl functions for shadow stack
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>, LKML <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, X86 ML <x86@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Arnd Bergmann <arnd@arndb.de>, mike.kravetz@oracle.com

On Thu, Jun 7, 2018 at 3:02 PM, H.J. Lu <hjl.tools@gmail.com> wrote:
> On Thu, Jun 7, 2018 at 2:01 PM, Andy Lutomirski <luto@kernel.org> wrote:
>> On Thu, Jun 7, 2018 at 1:33 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>>>
>>> On Thu, 2018-06-07 at 11:48 -0700, Andy Lutomirski wrote:
>>> > On Thu, Jun 7, 2018 at 7:41 AM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote:
>>> > >
>>> > > The following operations are provided.
>>> > >
>>> > > ARCH_CET_STATUS:
>>> > >         return the current CET status
>>> > >
>>> > > ARCH_CET_DISABLE:
>>> > >         disable CET features
>>> > >
>>> > > ARCH_CET_LOCK:
>>> > >         lock out CET features
>>> > >
>>> > > ARCH_CET_EXEC:
>>> > >         set CET features for exec()
>>> > >
>>> > > ARCH_CET_ALLOC_SHSTK:
>>> > >         allocate a new shadow stack
>>> > >
>>> > > ARCH_CET_PUSH_SHSTK:
>>> > >         put a return address on shadow stack
>>> > >

>> And why do we need ARCH_CET_EXEC?
>>
>> For background, I really really dislike adding new state that persists
>> across exec().  It's nice to get as close to a clean slate as possible
>> after exec() so that programs can run in a predictable environment.
>> exec() is also a security boundary, and anything a task can do to
>> affect itself after exec() needs to have its security implications
>> considered very carefully.  (As a trivial example, you should not be
>> able to use cetcmd ... sudo [malicious options here] to cause sudo to
>> run with CET off and then try to exploit it via the malicious options.
>>
>> If a shutoff is needed for testing, how about teaching ld.so to parse
>> LD_CET=no or similar and protect it the same way as LD_PRELOAD is
>> protected.  Or just do LD_PRELOAD=/lib/libdoesntsupportcet.so.
>>
>
> I will take a look.

We can use LD_CET to turn off CET.   Since most of legacy binaries
are compatible with shadow stack,  ARCH_CET_EXEC can be used
to turn on shadow stack on legacy binaries:

[hjl@gnu-cet-1 glibc]$ readelf -n /bin/ls| head -10

Displaying notes found in: .note.ABI-tag
  Owner                 Data size Description
  GNU                  0x00000010 NT_GNU_ABI_TAG (ABI version tag)
    OS: Linux, ABI: 3.2.0

Displaying notes found in: .note.gnu.property
  Owner                 Data size Description
  GNU                  0x00000020 NT_GNU_PROPERTY_TYPE_0
      Properties: x86 ISA used:
[hjl@gnu-cet-1 glibc]$ cetcmd --on -- /bin/ls /
Segmentation fault
[hjl@gnu-cet-1 glibc]$ cetcmd --on -f shstk -- /bin/ls /
bin   dev  export  lib   libx32      media  mnt  opt root  sbin  sys  usr
boot  etc  home    lib64  lost+found  misc   net  proc run   srv   tmp  var
[hjl@gnu-cet-1 glibc]$ cetcmd --on -f ibt -- /bin/ls /
Segmentation fault
[hjl@gnu-cet-1 glibc]$

-- 
H.J.
