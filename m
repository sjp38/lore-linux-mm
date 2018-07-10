Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id E51D76B0283
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:23:12 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id w137-v6so429453wme.2
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:23:12 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t24-v6sor120681wmh.29.2018.07.10.16.23.11
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 10 Jul 2018 16:23:11 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [RFC PATCH v2 11/27] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
From: Nadav Amit <nadav.amit@gmail.com>
In-Reply-To: <fbf45667-5388-44a6-1f22-07bcc03e1804@linux.intel.com>
Date: Tue, 10 Jul 2018 19:23:04 -0400
Content-Transfer-Encoding: 7bit
Message-Id: <DDFF4AF4-51D2-44F5-8B63-E8454F712EC6@gmail.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-12-yu-cheng.yu@intel.com>
 <fbf45667-5388-44a6-1f22-07bcc03e1804@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>, Yu-cheng Yu <yu-cheng.yu@intel.com>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: X86 ML <x86@kernel.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

at 6:44 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:

> On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
>> +	/*
>> +	 * On platforms before CET, other threads could race to
>> +	 * create a RO and _PAGE_DIRTY_HW PMD again.  However,
>> +	 * on CET platforms, this is safe without a TLB flush.
>> +	 */
> 
> If I didn't work for Intel, I'd wonder what the heck CET is and what the
> heck it has to do with _PAGE_DIRTY_HW.  I think we need a better comment
> than this.  How about:
> 
> 	Some processors can _start_ a write, but end up seeing
> 	a read-only PTE by the time they get to getting the
> 	Dirty bit.  In this case, they will set the Dirty bit,
> 	leaving a read-only, Dirty PTE which looks like a Shadow
> 	Stack PTE.
> 
> 	However, this behavior has been improved and will *not* occur on
> 	processors supporting Shadow Stacks.  Without this guarantee, a
> 	transition to a non-present PTE and flush the TLB would be
> 	needed.

Interesting. Does that regard the knights landing bug or something more
general?

Will the write succeed or trigger a page-fault in this case?

[ I know it is not related to the patch, but I would appreciate if you share
your knowledge ]

Regards,
Nadav
