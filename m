Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E74BF6B5452
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 21:23:19 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id 2-v6so4925286plc.11
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 18:23:19 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w5-v6sor2445985pfn.0.2018.08.30.18.23.18
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 18:23:18 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and pmdp_set_wrprotect for _PAGE_DIRTY_SW
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <CAG48ez3ixWROuQc6WZze6qPL6q0e_gCnMU4XF11JUWziePsBJg@mail.gmail.com>
Date: Thu, 30 Aug 2018 18:23:15 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <337F9DA7-ED07-4CD0-B41C-22D570527362@amacapital.net>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com> <20180830143904.3168-13-yu-cheng.yu@intel.com> <CAG48ez0Rca0XsdXJZ07c+iGPyep0Gpxw+sxQuACP5gyPaBgDKA@mail.gmail.com> <079a55f2-4654-4adf-a6ef-6e480b594a2f@linux.intel.com> <CAG48ez2gHOD9hH4+0wek5vUOv9upj79XWoug2SXjdwfXWoQqxw@mail.gmail.com> <ce051b5b-feef-376f-e085-11f65a5f2215@linux.intel.com> <1535649960.26689.15.camel@intel.com> <33d45a12-513c-eba2-a2de-3d6b630e928e@linux.intel.com> <1535651666.27823.6.camel@intel.com> <CAG48ez3ixWROuQc6WZze6qPL6q0e_gCnMU4XF11JUWziePsBJg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>
Cc: yu-cheng.yu@intel.com, Dave Hansen <dave.hansen@linux.intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com



> On Aug 30, 2018, at 10:59 AM, Jann Horn <jannh@google.com> wrote:
>=20
>> On Thu, Aug 30, 2018 at 7:58 PM Yu-cheng Yu <yu-cheng.yu@intel.com> wrote=
:
>>=20
>>> On Thu, 2018-08-30 at 10:33 -0700, Dave Hansen wrote:
>>>> On 08/30/2018 10:26 AM, Yu-cheng Yu wrote:
>>>>=20
>>>> We don't have the guard page now, but there is a shadow stack
>>>> token
>>>> there, which cannot be used as a return address.
>>> The overall concern is that we could overflow into a page that we
>>> did
>>> not intend.  Either another actual shadow stack or something that a
>>> page
>>> that the attacker constructed, like the transient scenario Jann
>>> described.
>>>=20
>>=20
>> A task could go beyond the bottom of its shadow stack by doing either
>> 'ret' or 'incssp'.  If it is the 'ret' case, the token prevents it.
>> If it is the 'incssp' case, a guard page cannot prevent it entirely,
>> right?
>=20
> I mean the other direction, on "call".

I still think that shadow stacks should work just like mmap and that mmap sh=
ould learn to add guard pages for all non-MAP_FIXED allocations.=
