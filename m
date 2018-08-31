Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2EFBB6B582A
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 13:47:16 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id b29-v6so7233623pfm.1
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 10:47:16 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id 64-v6si9696275plk.257.2018.08.31.10.47.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 10:47:14 -0700 (PDT)
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 34DB12084E
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 17:47:14 +0000 (UTC)
Received: by mail-wm0-f41.google.com with SMTP id b19-v6so5981929wme.3
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 10:47:14 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <e164a320-25a4-a9fc-3256-901b778468f3@linux.intel.com>
References: <20180830143904.3168-1-yu-cheng.yu@intel.com> <20180830143904.3168-13-yu-cheng.yu@intel.com>
 <CAG48ez0Rca0XsdXJZ07c+iGPyep0Gpxw+sxQuACP5gyPaBgDKA@mail.gmail.com>
 <079a55f2-4654-4adf-a6ef-6e480b594a2f@linux.intel.com> <CAG48ez2gHOD9hH4+0wek5vUOv9upj79XWoug2SXjdwfXWoQqxw@mail.gmail.com>
 <ce051b5b-feef-376f-e085-11f65a5f2215@linux.intel.com> <B2222C69-337B-44F2-9DA6-69E685AA469B@amacapital.net>
 <e164a320-25a4-a9fc-3256-901b778468f3@linux.intel.com>
From: Andy Lutomirski <luto@kernel.org>
Date: Fri, 31 Aug 2018 10:46:51 -0700
Message-ID: <CALCETrUE6mY-+YCaJjGJuEqE_OBQc=QUR1XMnPW9VwTb8=HK4w@mail.gmail.com>
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Jann Horn <jannh@google.com>, Yu-cheng Yu <yu-cheng.yu@intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On Thu, Aug 30, 2018 at 11:55 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
> On 08/30/2018 10:34 AM, Andy Lutomirski wrote:
>>> But, to keep B's TLB from picking up the entry, I think we can just make
>>> it !Present for a moment.  No TLB can cache it, and I believe the same
>>> "don't set Dirty on a !Writable entry" logic also holds for !Present
>>> (modulo a weird erratum or two).
>> Can we get documentation?  Pretty please?
>
> The accessed bit description in the SDM looks pretty good to me today:
>
>> Whenever the processor uses a paging-structure entry as part of
>> linear-address translation, it sets the accessed flag in that entry
>> (if it is not already set).
> If it's !Present, it can't used as part of a translation so can't be
> set.  I think that covers the thing I was unsure about.
>
> But, Dirty is a bit, er, muddier, but mostly because it only gets set on
> leaf entries:
>
>> Whenever there is a write to a linear address, the processor sets the
>> dirty flag (if it is not already set) in the paging- structure entry
>> that identifies the final physical address for the linear address
>> (either a PTE or a paging-structure entry in which the PS flag is
>> 1).
>
> That little hunk will definitely need to get updated with something like:
>
>         On processors enumerating support for CET, the processor will on
>         set the dirty flag on paging structure entries in which the W
>         flag is 1.

Can we get something much stronger, perhaps?  Like this:

On processors enumerating support for CET, the processor will write to
the accessed and/or dirty flags atomically, as if using the LOCK
CMPXCHG instruction.  The memory access, any cached entries in any
paging-structure caches, and the values in the paging-structure entry
before and after writing the A and/or D bits will all be consistent.

I'm sure this could be worded better.  The point is that the CPU
should, atomically, load the PTE, check if it allows the access, set A
and/or D appropriately, write the new value to the TLB, and use that
value for the access.  This is clearly a little bit slower than what
old CPUs could do when writing to an already-in-TLB writable non-dirty
entry, but new CPUs are going to have to atomically check the W bit.
(I assume that even old CPUs will *atomically* set the D bit as if by
LOCK BTS, but this is all very vague in the SDM IIRC.)
