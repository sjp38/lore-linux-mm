Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f197.google.com (mail-lj1-f197.google.com [209.85.208.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6B7398E0001
	for <linux-mm@kvack.org>; Sun,  9 Dec 2018 17:32:25 -0500 (EST)
Received: by mail-lj1-f197.google.com with SMTP id e12-v6so2288664ljb.18
        for <linux-mm@kvack.org>; Sun, 09 Dec 2018 14:32:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f18sor2298833lfa.66.2018.12.09.14.32.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Dec 2018 14:32:23 -0800 (PST)
Subject: Re: [PATCH 2/6] __wr_after_init: write rare for static allocation
References: <20181204121805.4621-1-igor.stoppa@huawei.com>
 <20181204121805.4621-3-igor.stoppa@huawei.com>
 <CALCETrVvoui0vksdt0Y9rdGL5ipEn_FtSXVVUFdH03ZC93cy_A@mail.gmail.com>
 <20181206094451.GC13538@hirez.programming.kicks-ass.net>
From: Igor Stoppa <igor.stoppa@gmail.com>
Message-ID: <d9382720-3c39-5f10-afcd-dc17727fe4dc@gmail.com>
Date: Mon, 10 Dec 2018 00:32:21 +0200
MIME-Version: 1.0
In-Reply-To: <20181206094451.GC13538@hirez.programming.kicks-ass.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>, Andy Lutomirski <luto@kernel.org>
Cc: linux-arch <linux-arch@vger.kernel.org>, linux-s390 <linux-s390@vger.kernel.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Kees Cook <keescook@chromium.org>, Matthew Wilcox <willy@infradead.org>, Igor Stoppa <igor.stoppa@huawei.com>, Nadav Amit <nadav.amit@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, linux-integrity <linux-integrity@vger.kernel.org>, Kernel Hardening <kernel-hardening@lists.openwall.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 06/12/2018 11:44, Peter Zijlstra wrote:
> On Wed, Dec 05, 2018 at 03:13:56PM -0800, Andy Lutomirski wrote:
> 
>>> +       if (op == WR_MEMCPY)
>>> +               memcpy((void *)wr_poking_addr, (void *)src, len);
>>> +       else if (op == WR_MEMSET)
>>> +               memset((u8 *)wr_poking_addr, (u8)src, len);
>>> +       else if (op == WR_RCU_ASSIGN_PTR)
>>> +               /* generic version of rcu_assign_pointer */
>>> +               smp_store_release((void **)wr_poking_addr,
>>> +                                 RCU_INITIALIZER((void **)src));
>>> +       kasan_enable_current();
>>
>> Hmm.  I suspect this will explode quite badly on sane architectures
>> like s390.  (In my book, despite how weird s390 is, it has a vastly
>> nicer model of "user" memory than any other architecture I know
>> of...).  I think you should use copy_to_user(), etc, instead.  I'm not
>> entirely sure what the best smp_store_release() replacement is.
>> Making this change may also mean you can get rid of the
>> kasan_disable_current().
> 
> If you make the MEMCPY one guarantee single-copy atomicity for native
> words then you're basically done.
> 
> smp_store_release() can be implemented with:
> 
> 	smp_mb();
> 	WRITE_ONCE();
> 
> So if we make MEMCPY provide the WRITE_ONCE(), all we need is that
> barrier, which we can easily place at the call site and not overly
> complicate our interface with this.

Ok, so the 3rd case (WR_RCU_ASSIGN_PTR) could be handled outside of this 
function.
But, since now memcpy() will be replaced by copy_to_user(), can I assume 
that also copy_to_user() will be atomic, if the destination is properly 
aligned? On x86_64 it seems yes, however it's not clear to me if this is 
the outcome of an optimization or if I can expect it to be always true.


--
igor
