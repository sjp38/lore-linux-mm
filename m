Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 058C26B52D8
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 14:55:45 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id x2-v6so5493475pgp.4
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 11:55:44 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id e31-v6si7250938pgm.166.2018.08.30.11.55.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 11:55:43 -0700 (PDT)
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
 <20180830143904.3168-13-yu-cheng.yu@intel.com>
 <CAG48ez0Rca0XsdXJZ07c+iGPyep0Gpxw+sxQuACP5gyPaBgDKA@mail.gmail.com>
 <079a55f2-4654-4adf-a6ef-6e480b594a2f@linux.intel.com>
 <CAG48ez2gHOD9hH4+0wek5vUOv9upj79XWoug2SXjdwfXWoQqxw@mail.gmail.com>
 <ce051b5b-feef-376f-e085-11f65a5f2215@linux.intel.com>
 <B2222C69-337B-44F2-9DA6-69E685AA469B@amacapital.net>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <e164a320-25a4-a9fc-3256-901b778468f3@linux.intel.com>
Date: Thu, 30 Aug 2018 11:55:14 -0700
MIME-Version: 1.0
In-Reply-To: <B2222C69-337B-44F2-9DA6-69E685AA469B@amacapital.net>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@amacapital.net>
Cc: Jann Horn <jannh@google.com>, yu-cheng.yu@intel.com, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On 08/30/2018 10:34 AM, Andy Lutomirski wrote:
>> But, to keep B's TLB from picking up the entry, I think we can just make
>> it !Present for a moment.  No TLB can cache it, and I believe the same
>> "don't set Dirty on a !Writable entry" logic also holds for !Present
>> (modulo a weird erratum or two).
> Can we get documentation?  Pretty please?

The accessed bit description in the SDM looks pretty good to me today:

> Whenever the processor uses a paging-structure entry as part of
> linear-address translation, it sets the accessed flag in that entry
> (if it is not already set).
If it's !Present, it can't used as part of a translation so can't be
set.  I think that covers the thing I was unsure about.

But, Dirty is a bit, er, muddier, but mostly because it only gets set on
leaf entries:

> Whenever there is a write to a linear address, the processor sets the
> dirty flag (if it is not already set) in the paging- structure entry
> that identifies the final physical address for the linear address
> (either a PTE or a paging-structure entry in which the PS flag is
> 1).

That little hunk will definitely need to get updated with something like:

	On processors enumerating support for CET, the processor will on
	set the dirty flag on paging structure entries in which the W
	flag is 1.
