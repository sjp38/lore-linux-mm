Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5C4C76B5028
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 13:34:41 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id 132-v6so5322548pga.18
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 10:34:41 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x61-v6sor2492770plb.12.2018.08.30.10.34.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 30 Aug 2018 10:34:40 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (1.0)
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and pmdp_set_wrprotect for _PAGE_DIRTY_SW
From: Andy Lutomirski <luto@amacapital.net>
In-Reply-To: <ce051b5b-feef-376f-e085-11f65a5f2215@linux.intel.com>
Date: Thu, 30 Aug 2018 10:34:37 -0700
Content-Transfer-Encoding: quoted-printable
Message-Id: <B2222C69-337B-44F2-9DA6-69E685AA469B@amacapital.net>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com> <20180830143904.3168-13-yu-cheng.yu@intel.com> <CAG48ez0Rca0XsdXJZ07c+iGPyep0Gpxw+sxQuACP5gyPaBgDKA@mail.gmail.com> <079a55f2-4654-4adf-a6ef-6e480b594a2f@linux.intel.com> <CAG48ez2gHOD9hH4+0wek5vUOv9upj79XWoug2SXjdwfXWoQqxw@mail.gmail.com> <ce051b5b-feef-376f-e085-11f65a5f2215@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Jann Horn <jannh@google.com>, yu-cheng.yu@intel.com, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com



> On Aug 30, 2018, at 10:19 AM, Dave Hansen <dave.hansen@linux.intel.com> wr=
ote:
>=20
>> On 08/30/2018 09:23 AM, Jann Horn wrote:
>> Three threads (A, B, C) run with the same CR3.
>>=20
>> 1. a dirty+writable PTE is placed directly in front of B's shadow stack.
>>   (this can happen, right? or is there a guard page?)
>> 2. C's TLB caches the dirty+writable PTE.
>> 3. A performs some syscall that triggers ptep_set_wrprotect().
>> 4. A's syscall calls clear_bit().
>> 5. B's TLB caches the transient shadow stack.
>> [now C has write access to B's transiently-extended shadow stack]
>> 6. B recurses into the transiently-extended shadow stack
>> 7. C overwrites the transiently-extended shadow stack area.
>> 8. B returns through the transiently-extended shadow stack, giving
>>    the attacker instruction pointer control in B.
>> 9. A's syscall broadcasts a TLB flush.
>=20
> Heh, that's a good point.  The shadow stack permissions are *not*
> strictly reduced because a page getting marked as shadow-stack has
> *increased* permissions when being used as a shadow stack.  Fun.
>=20
> For general hardening, it seems like we want to ensure that there's a
> guard page at the bottom of the shadow stack.  Yu-cheng, do we have a
> guard page?
>=20
> But, to keep B's TLB from picking up the entry, I think we can just make
> it !Present for a moment.  No TLB can cache it, and I believe the same
> "don't set Dirty on a !Writable entry" logic also holds for !Present
> (modulo a weird erratum or two).

Can we get documentation?  Pretty please?
