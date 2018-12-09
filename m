Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id EAD288E0001
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 17:09:47 -0500 (EST)
Received: by mail-lj1-f199.google.com with SMTP id g92-v6so2282200ljg.23
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 14:09:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a4sor2300538lfj.30.2018.12.09.14.09.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Dec 2018 14:09:46 -0800 (PST)
Subject: Re: [PATCH 2/6] __wr_after_init: write rare for static allocation
References: <20181204121805.4621-1-igor.stoppa@huawei.com>
 <20181204121805.4621-3-igor.stoppa@huawei.com>
 <CALCETrVvoui0vksdt0Y9rdGL5ipEn_FtSXVVUFdH03ZC93cy_A@mail.gmail.com>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <8c4c45a5-a4c9-7094-002e-9b6006eb2f9e@gmail.com>
Date: Mon, 10 Dec 2018 00:09:40 +0200
MIME-Version: 1.0
In-Reply-To: <CALCETrVvoui0vksdt0Y9rdGL5ipEn_FtSXVVUFdH03ZC93cy_A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andy Lutomirski <luto@kernel.org>, linux-arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Igor Stoppa <igor.stoppa@huawei.com>, Nadav Amit <nadav.amit@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-integrity <linux-integrity@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 06/12/2018 01:13, Andy Lutomirski wrote:

>> +       kasan_disable_current();
>> +       if (op == WR_MEMCPY)
>> +               memcpy((void *)wr_poking_addr, (void *)src, len);
>> +       else if (op == WR_MEMSET)
>> +               memset((u8 *)wr_poking_addr, (u8)src, len);
>> +       else if (op == WR_RCU_ASSIGN_PTR)
>> +               /* generic version of rcu_assign_pointer */
>> +               smp_store_release((void **)wr_poking_addr,
>> +                                 RCU_INITIALIZER((void **)src));
>> +       kasan_enable_current();
> 
> Hmm.  I suspect this will explode quite badly on sane architectures
> like s390.  (In my book, despite how weird s390 is, it has a vastly
> nicer model of "user" memory than any other architecture I know
> of...).

I see. I can try to setup also a qemu target for s390, for my tests.
There seems to be a Debian image, to have a fully bootable system.

> I think you should use copy_to_user(), etc, instead.

I'm having troubles with the "etc" part: as far as I can see, there are 
both generic and specific support for both copying and clearing 
user-space memory from kernel, however I couldn't find something that 
looks like a memset_user().

I can of course roll my own, for example iterating copy_to_user() with 
the support of a pre-allocated static buffer (1 page should be enough).

But, before I go down this path, I wanted to confirm that there's really 
nothing better that I could use.

If that's really the case, the static buffer instance should be 
replicated for each core, I think, since each core could be performing 
its own memset_user() at the same time.

Alternatively, I could do a loop of WRITE_ONCE(), however I'm not sure 
how that would work with (lack-of) alignment and might require also a 
preamble/epilogue to deal with unaligned data?

>  I'm not
> entirely sure what the best smp_store_release() replacement is.
> Making this change may also mean you can get rid of the
> kasan_disable_current().
> 
>> +
>> +       barrier(); /* XXX redundant? */
> 
> I think it's redundant.  If unuse_temporary_mm() allows earlier stores
> to hit the wrong address space, then something is very very wrong, and
> something is also very very wrong if the optimizer starts moving
> stores across a function call that is most definitely a barrier.

ok, thanks

>> +
>> +       unuse_temporary_mm(prev);
>> +       /* XXX make the verification optional? */
>> +       if (op == WR_MEMCPY)
>> +               BUG_ON(memcmp((void *)dst, (void *)src, len));
>> +       else if (op == WR_MEMSET)
>> +               BUG_ON(memtst((void *)dst, (u8)src, len));
>> +       else if (op == WR_RCU_ASSIGN_PTR)
>> +               BUG_ON(*(unsigned long *)dst != src);
> 
> Hmm.  If you allowed cmpxchg or even plain xchg, then these bug_ons
> would be thoroughly buggy, but maybe they're okay.  But they should,
> at most, be WARN_ON_ONCE(), 

I have to confess that I do not understand why Nadav's patchset was 
required to use BUG_ON(), while here it's not correct, not even for 
memcopy or memset .

Is it because it is single-threaded?
Or is it because text_poke() is patching code, instead of data?
I can turn to WARN_ON_ONCE(), but I'd like to understand the reason.

> given that you can trigger them by writing
> the same addresses from two threads at once, and this isn't even
> entirely obviously bogus given the presence of smp_store_release().

True, however would it be reasonable to require the use of an explicit 
writer lock, from the user?

This operation is not exactly fast and should happen seldom; I'm not 
sure if it's worth supporting cmpxchg. The speedup would be minimal.

I'd rather not implement the locking implicitly, even if it would be 
possible to detect simultaneous writes, because it might lead to overall 
inconsistent data.

--
igor
