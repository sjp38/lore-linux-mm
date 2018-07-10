Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id C9C6C6B027B
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 19:52:39 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a12-v6so14844612pfn.12
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 16:52:39 -0700 (PDT)
Received: from mga06.intel.com (mga06.intel.com. [134.134.136.31])
        by mx.google.com with ESMTPS id e18-v6si16875106pgd.88.2018.07.10.16.52.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 16:52:38 -0700 (PDT)
Subject: Re: [RFC PATCH v2 11/27] x86/mm: Modify ptep_set_wrprotect and
 pmdp_set_wrprotect for _PAGE_DIRTY_SW
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-12-yu-cheng.yu@intel.com>
 <fbf45667-5388-44a6-1f22-07bcc03e1804@linux.intel.com>
 <DDFF4AF4-51D2-44F5-8B63-E8454F712EC6@gmail.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <2dac9ec0-b144-ac9a-ae35-14f9ff5fc834@linux.intel.com>
Date: Tue, 10 Jul 2018 16:52:37 -0700
MIME-Version: 1.0
In-Reply-To: <DDFF4AF4-51D2-44F5-8B63-E8454F712EC6@gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nadav Amit <nadav.amit@gmail.com>, Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/10/2018 04:23 PM, Nadav Amit wrote:
> at 6:44 PM, Dave Hansen <dave.hansen@linux.intel.com> wrote:
> 
>> On 07/10/2018 03:26 PM, Yu-cheng Yu wrote:
>>> +	/*
>>> +	 * On platforms before CET, other threads could race to
>>> +	 * create a RO and _PAGE_DIRTY_HW PMD again.  However,
>>> +	 * on CET platforms, this is safe without a TLB flush.
>>> +	 */
>>
>> If I didn't work for Intel, I'd wonder what the heck CET is and what the
>> heck it has to do with _PAGE_DIRTY_HW.  I think we need a better comment
>> than this.  How about:
>>
>> 	Some processors can _start_ a write, but end up seeing
>> 	a read-only PTE by the time they get to getting the
>> 	Dirty bit.  In this case, they will set the Dirty bit,
>> 	leaving a read-only, Dirty PTE which looks like a Shadow
>> 	Stack PTE.
>>
>> 	However, this behavior has been improved and will *not* occur on
>> 	processors supporting Shadow Stacks.  Without this guarantee, a
>> 	transition to a non-present PTE and flush the TLB would be
>> 	needed.
> 
> Interesting. Does that regard the knights landing bug or something more
> general?

It's more general.

> Will the write succeed or trigger a page-fault in this case?

It will trigger a page fault.
