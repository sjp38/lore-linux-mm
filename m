Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 051646B0269
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 18:40:50 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id z21-v6so8263749plo.13
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 15:40:49 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id p4-v6si1586660pgp.299.2018.07.11.15.40.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 15:40:48 -0700 (PDT)
Subject: Re: [RFC PATCH v2 22/27] x86/cet/ibt: User-mode indirect branch
 tracking support
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
 <20180710222639.8241-23-yu-cheng.yu@intel.com>
 <3a7e9ce4-03c6-cc28-017b-d00108459e94@linux.intel.com>
 <1531347019.15351.89.camel@intel.com>
From: Dave Hansen <dave.hansen@linux.intel.com>
Message-ID: <f97ce234-52fa-e666-2250-098925cf3c39@linux.intel.com>
Date: Wed, 11 Jul 2018 15:40:46 -0700
MIME-Version: 1.0
In-Reply-To: <1531347019.15351.89.camel@intel.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yu-cheng Yu <yu-cheng.yu@intel.com>, x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>

On 07/11/2018 03:10 PM, Yu-cheng Yu wrote:
> On Tue, 2018-07-10 at 17:11 -0700, Dave Hansen wrote:
>> Is this feature *integral* to shadow stacks?A A Or, should it just be
>> in a
>> different series?
> 
> The whole CET series is mostly about SHSTK and only a minority for IBT.
> IBT changes cannot be applied by itself without first applying SHSTK
> changes. A Would the titles help, e.g. x86/cet/ibt, x86/cet/shstk, etc.?

That doesn't really answer what I asked, though.

Do shadow stacks *require* IBT?  Or, should we concentrate on merging
shadow stacks themselves first and then do IBT at a later time, in a
different patch series?

But, yes, better patch titles would help, although I'm not sure that's
quite the format that Ingo and Thomas prefer.

>>> +int cet_setup_ibt_bitmap(void)
>>> +{
>>> +	u64 r;
>>> +	unsigned long bitmap;
>>> +	unsigned long size;
>>> +
>>> +	if (!cpu_feature_enabled(X86_FEATURE_IBT))
>>> +		return -EOPNOTSUPP;
>>> +
>>> +	size = TASK_SIZE_MAX / PAGE_SIZE / BITS_PER_BYTE;
>> Just a note: this table is going to be gigantic on 5-level paging
>> systems, and userspace won't, by default use any of that extra
>> address
>> space.A A I think it ends up being a 512GB allocation in a 128TB
>> address
>> space.
>>
>> Is that a problem?
>> 
>> On 5-level paging systems, maybe we should just stick it up in the 
>> high part of the address space.
> 
> We do not know in advance if dlopen() needs to create the bitmap. A Do
> we always reserve high address or force legacy libs to low address?

Does it matter?  Does code ever get pointers to this area?  Might they
be depending on high address bits for the IBT being clear?


>>> +	bitmap = ibt_mmap(0, size);
>>> +
>>> +	if (bitmap >= TASK_SIZE_MAX)
>>> +		return -ENOMEM;
>>> +
>>> +	bitmap &= PAGE_MASK;
>> We're page-aligning the result of an mmap()?A A Why?
> 
> This may not be necessary. A The lower bits of MSR_IA32_U_CET are
> settings and not part of the bitmap address. A Is this is safer?

No.  If we have mmap() returning non-page-aligned addresses, we have
bigger problems.  Worst-case, do

	WARN_ON_ONCE(bitmap & ~PAGE_MASK);

>>> +	current->thread.cet.ibt_bitmap_addr = bitmap;
>>> +	current->thread.cet.ibt_bitmap_size = size;
>>> +	return 0;
>>> +}
>>> +
>>> +void cet_disable_ibt(void)
>>> +{
>>> +	u64 r;
>>> +
>>> +	if (!cpu_feature_enabled(X86_FEATURE_IBT))
>>> +		return;
>> Does this need a check for being already disabled?
> 
> We need that. A We cannot write to those MSRs if the CPU does not
> support it.

No, I mean for code doing cet_disable_ibt() twice in a row.

>>> +	rdmsrl(MSR_IA32_U_CET, r);
>>> +	r &= ~(MSR_IA32_CET_ENDBR_EN | MSR_IA32_CET_LEG_IW_EN |
>>> +	A A A A A A A MSR_IA32_CET_NO_TRACK_EN);
>>> +	wrmsrl(MSR_IA32_U_CET, r);
>>> +	current->thread.cet.ibt_enabled = 0;
>>> +}
>> What's the locking for current->thread.cet?
> 
> Now CET is not locked until the application callsA ARCH_CET_LOCK.

No, I mean what is the in-kernel locking for the current->thread.cet
data structure?  Is there none because it's only every modified via
current->thread and it's entirely thread-local?
