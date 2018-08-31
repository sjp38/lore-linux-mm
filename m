Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 620DF6B5831
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 13:52:04 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id q21-v6so7181216pff.21
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 10:52:04 -0700 (PDT)
Received: from mga12.intel.com (mga12.intel.com. [192.55.52.136])
        by mx.google.com with ESMTPS id 91-v6si10856491plc.500.2018.08.31.10.52.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 31 Aug 2018 10:52:03 -0700 (PDT)
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
 <20180830143904.3168-13-yu-cheng.yu@intel.com>
 <CAG48ez0Rca0XsdXJZ07c+iGPyep0Gpxw+sxQuACP5gyPaBgDKA@mail.gmail.com>
 <079a55f2-4654-4adf-a6ef-6e480b594a2f@linux.intel.com>
 <CAG48ez2gHOD9hH4+0wek5vUOv9upj79XWoug2SXjdwfXWoQqxw@mail.gmail.com>
 <ce051b5b-feef-376f-e085-11f65a5f2215@linux.intel.com>
 <B2222C69-337B-44F2-9DA6-69E685AA469B@amacapital.net>
 <e164a320-25a4-a9fc-3256-901b778468f3@linux.intel.com>
 <CALCETrUE6mY-+YCaJjGJuEqE_OBQc=QUR1XMnPW9VwTb8=HK4w@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <72456264-2214-3c01-593a-7de862f1799d@linux.intel.com>
Date: Fri, 31 Aug 2018 10:52:02 -0700
MIME-Version: 1.0
In-Reply-To: <CALCETrUE6mY-+YCaJjGJuEqE_OBQc=QUR1XMnPW9VwTb8=HK4w@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>
Cc: Jann Horn <jannh@google.com>, Yu-cheng Yu <yu-cheng.yu@intel.com>, the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H. J. Lu" <hjl.tools@gmail.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, "Shanbhogue, Vedvyas" <vedvyas.shanbhogue@intel.com>

On 08/31/2018 10:46 AM, Andy Lutomirski wrote:
> On Thu, Aug 30, 2018 at 11:55 AM, Dave Hansen
>> That little hunk will definitely need to get updated with something like:
>>
>>         On processors enumerating support for CET, the processor will on
>>         set the dirty flag on paging structure entries in which the W
>>         flag is 1.
> 
> Can we get something much stronger, perhaps?  Like this:
> 
> On processors enumerating support for CET, the processor will write to
> the accessed and/or dirty flags atomically, as if using the LOCK
> CMPXCHG instruction.  The memory access, any cached entries in any
> paging-structure caches, and the values in the paging-structure entry
> before and after writing the A and/or D bits will all be consistent.

There's some talk of this already in: 8.1.2.1 Automatic Locking:

> When updating page-directory and page-table entries a?? When updating 
> page-directory and page-table entries, the processor uses locked 
> cycles to set the accessed and dirty flag in the page-directory and
> page-table entries.
As for the A/D consistency, I'll see if I can share that before it hits
the SDM for real and see if it's sufficient for everybody.
