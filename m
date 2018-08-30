Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id B706C6B51BB
	for <linux-mm@kvack.org>; Thu, 30 Aug 2018 12:09:36 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id j15-v6so5001103pfi.10
        for <linux-mm@kvack.org>; Thu, 30 Aug 2018 09:09:36 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id t80-v6si7446865pfk.228.2018.08.30.09.09.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Aug 2018 09:09:35 -0700 (PDT)
Subject: Re: [RFC PATCH v3 12/24] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
References: <20180830143904.3168-1-yu-cheng.yu@intel.com>
 <20180830143904.3168-13-yu-cheng.yu@intel.com>
 <CAG48ez0Rca0XsdXJZ07c+iGPyep0Gpxw+sxQuACP5gyPaBgDKA@mail.gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <079a55f2-4654-4adf-a6ef-6e480b594a2f@linux.intel.com>
Date: Thu, 30 Aug 2018 09:08:13 -0700
MIME-Version: 1.0
In-Reply-To: <CAG48ez0Rca0XsdXJZ07c+iGPyep0Gpxw+sxQuACP5gyPaBgDKA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jann Horn <jannh@google.com>, yu-cheng.yu@intel.com
Cc: the arch/x86 maintainers <x86@kernel.org>, "H . Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, kernel list <linux-kernel@vger.kernel.org>, linux-doc@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arch <linux-arch@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, hjl.tools@gmail.com, Jonathan Corbet <corbet@lwn.net>, keescook@chromiun.org, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, ravi.v.shankar@intel.com, vedvyas.shanbhogue@intel.com

On 08/30/2018 08:49 AM, Jann Horn wrote:
>> @@ -1203,7 +1203,28 @@ static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
>>  static inline void ptep_set_wrprotect(struct mm_struct *mm,
>>                                       unsigned long addr, pte_t *ptep)
>>  {
>> +       pte_t pte;
>> +
>>         clear_bit(_PAGE_BIT_RW, (unsigned long *)&ptep->pte);
>> +       pte = *ptep;
>> +
>> +       /*
>> +        * Some processors can start a write, but ending up seeing
>> +        * a read-only PTE by the time they get to the Dirty bit.
>> +        * In this case, they will set the Dirty bit, leaving a
>> +        * read-only, Dirty PTE which looks like a Shadow Stack PTE.
>> +        *
>> +        * However, this behavior has been improved and will not occur
>> +        * on processors supporting Shadow Stacks.  Without this
>> +        * guarantee, a transition to a non-present PTE and flush the
>> +        * TLB would be needed.
>> +        *
>> +        * When change a writable PTE to read-only and if the PTE has
>> +        * _PAGE_DIRTY_HW set, we move that bit to _PAGE_DIRTY_SW so
>> +        * that the PTE is not a valid Shadow Stack PTE.
>> +        */
>> +       pte = pte_move_flags(pte, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
>> +       set_pte_at(mm, addr, ptep, pte);
>>  }
> I don't understand why it's okay that you first atomically clear the
> RW bit, then atomically switch from DIRTY_HW to DIRTY_SW. Doesn't that
> mean that between the two atomic writes, another core can incorrectly
> see a shadow stack?

Good point.

This could result in a spurious shadow-stack fault, or allow a
shadow-stack write to the page in the transient state.

But, the shadow-stack permissions are more restrictive than what could
be in the TLB at this point, so I don't think there's a real security
implication here.

The only trouble is handling the spurious shadow-stack fault.  The
alternative is to go !Present for a bit, which we would probably just
handle fine in the existing page fault code.
