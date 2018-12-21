Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 6A2AC8E0001
	for <linux-mm@kvack.org>; Fri, 21 Dec 2018 14:07:59 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id v74-v6so1946148lje.6
        for <linux-mm@kvack.org>; Fri, 21 Dec 2018 11:07:59 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n5sor7382638lfl.69.2018.12.21.11.07.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 21 Dec 2018 11:07:57 -0800 (PST)
Subject: Re: [PATCH 03/12] __wr_after_init: generic functionality
References: <20181221181423.20455-1-igor.stoppa@huawei.com>
 <20181221181423.20455-4-igor.stoppa@huawei.com>
 <20181221184120.GG10600@bombadil.infradead.org>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <14487401-dec3-6a7d-a0b1-e369e93aa9c4@gmail.com>
Date: Fri, 21 Dec 2018 21:07:54 +0200
MIME-Version: 1.0
In-Reply-To: <20181221184120.GG10600@bombadil.infradead.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Andy Lutomirski <luto@amacapital.net>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, Mimi Zohar <zohar@linux.vnet.ibm.com>, Thiago Jung Bauermann <bauerman@linux.ibm.com>, igor.stoppa@huawei.com, Nadav Amit <nadav.amit@gmail.com>, Kees Cook <keescook@chromium.org>, Ahmed Soliman <ahmedsoliman@mena.vt.edu>, linux-integrity@vger.kernel.org, kernel-hardening@lists.openwall.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org



On 21/12/2018 20:41, Matthew Wilcox wrote:
> On Fri, Dec 21, 2018 at 08:14:14PM +0200, Igor Stoppa wrote:
>> +static inline int memtst(void *p, int c, __kernel_size_t len)
> 
> I don't understand why you're verifying that writes actually happen
> in production code.  Sure, write lib/test_wrmem.c or something, but
> verifying every single rare write seems like a mistake to me.

This is actually something I wrote more as a stop-gap.
I have the feeling there should be already something similar available.
And probably I could not find it. Unless it's so trivial that it doesn't 
deserve to become a function?

But if there is really no existing alternative, I can put it in a 
separate file.

> 
>> +#ifndef CONFIG_PRMEM
> 
> So is this PRMEM or wr_mem?  It's not obvious that CONFIG_PRMEM controls
> wrmem.

In my mind (maybe still clinging to the old implementation), PRMEM is 
the master toggle, for protected memory.

Then there are various types and the first one being now implemented is 
write rare after init (because ro after init already exists).

However, the same levels of protection should then follow for 
dynamically allocated memory (ye old pmalloc).

PRMEM would then become the moniker for the whole shebang.

>> +#define wr_assign(var, val)	((var) = (val))
> 
> The hamming distance between 'var' and 'val' is too small.  The convention
> in the line immediately below (p and v) is much more readable.

ok, I'll fix it

>> +#define wr_rcu_assign_pointer(p, v)	rcu_assign_pointer(p, v)
>> +#define wr_assign(var, val) ({			\
>> +	typeof(var) tmp = (typeof(var))val;	\
>> +						\
>> +	wr_memcpy(&var, &tmp, sizeof(var));	\
>> +	var;					\
>> +})
> 
> Doesn't wr_memcpy return 'var' anyway?

It should return the destination, which is &var.

But I wanted to return the actual value of the assignment, val

Like if I do  (a = 7)  it evaluates to 7,

similarly wr_assign(a, 7) would also evaluate to 7

The reason why i returned var instead of val is that it would allow to 
detect any error.

>> +/**
>> + * wr_memcpy() - copyes size bytes from q to p
> 
> typo

:-( thanks

>> + * @p: beginning of the memory to write to
>> + * @q: beginning of the memory to read from
>> + * @size: amount of bytes to copy
>> + *
>> + * Returns pointer to the destination
> 
>> + * The architecture code must provide:
>> + *   void __wr_enable(wr_state_t *state)
>> + *   void *__wr_addr(void *addr)
>> + *   void *__wr_memcpy(void *p, const void *q, __kernel_size_t size)
>> + *   void __wr_disable(wr_state_t *state)
> 
> This section shouldn't be in the user documentation of wr_memcpy().

ok

>> + */
>> +void *wr_memcpy(void *p, const void *q, __kernel_size_t size)
>> +{
>> +	wr_state_t wr_state;
>> +	void *wr_poking_addr = __wr_addr(p);
>> +
>> +	if (WARN_ONCE(!wr_ready, "No writable mapping available") ||
> 
> Surely not.  If somebody's called wr_memcpy() before wr_ready is set,
> that means we can just call memcpy().


What I was trying to catch is the case where, after a failed init, the 
writable mapping doesn't exist. In that case wr_ready is also not set.

The problem is that I just don't know what to do in a case where there 
has been such a major error which prevents he creation of hte alternate 
mapping.

I understand that we still want to continue, to provide as much debug 
info as possible, but I am at a loss about finding the saner course of 
actions.

--
igor
