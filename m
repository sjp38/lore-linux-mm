Received: by fg-out-1718.google.com with SMTP id 19so2161733fgg.4
        for <linux-mm@kvack.org>; Wed, 11 Jun 2008 16:04:37 -0700 (PDT)
Message-ID: <48505A0C.7060506@gmail.com>
Date: Thu, 12 Jun 2008 01:04:44 +0200
From: Andrea Righi <righi.andrea@gmail.com>
Reply-To: righi.andrea@gmail.com
MIME-Version: 1.0
Subject: Re: [-mm][PATCH 2/4] Setup the memrlimit controller (v5)
References: <20080521152921.15001.65968.sendpatchset@localhost.localdomain>	<20080521152948.15001.39361.sendpatchset@localhost.localdomain>	<4850070F.6060305@gmail.com>	<20080611121510.d91841a3.akpm@linux-foundation.org>	<485032C8.4010001@gmail.com>	<20080611134323.936063d3.akpm@linux-foundation.org>	<485055FF.9020500@gmail.com> <20080611155530.099a54d6.akpm@linux-foundation.org>
In-Reply-To: <20080611155530.099a54d6.akpm@linux-foundation.org>
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: balbir@linux.vnet.ibm.com, linux-mm@kvack.org, skumar@linux.vnet.ibm.com, yamamoto@valinux.co.jp, menage@google.com, lizf@cn.fujitsu.com, linux-kernel@vger.kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Thu, 12 Jun 2008 00:47:27 +0200
> Andrea Righi <righi.andrea@gmail.com> wrote:
> 
>> Andrew Morton wrote:
>>>> At least we could add something like:
>>>>
>>>> #ifdef CONFIG_32BIT
>>>> #define PAGE_ALIGN64(addr) (((((addr)+PAGE_SIZE-1))>>PAGE_SHIFT)<<PAGE_SHIFT)
>>>> #else
>>>> #define PAGE_ALIGN64(addr) PAGE_ALIGN(addr)
>>>> #endif
>>>>
>>>> But IMHO the single PAGE_ALIGN64() implementation is more clear.
>>> No, we should just fix PAGE_ALIGN.  It should work correctly when
>>> passed a long-long.  Otherwse it's just a timebomb.
>>>
>>> This:
>>>
>>> #define PAGE_ALIGN(addr) ({				\
>>> 	typeof(addr) __size = PAGE_SIZE;		\
>>> 	typeof(addr) __mask = PAGE_MASK;		\
>>> 	(addr + __size - 1) & __mask;			\
>>> })
>>>
>>> (with a suitable comment) does what we want.  I didn't check to see
>>> whether this causes the compiler to generate larger code, but it
>>> shouldn't.
>>>
>> No, it doesn't work. The problem seems to be in the PAGE_MASK definition
>> (from include/asm-x86/page.h for example):
>>
>> /* PAGE_SHIFT determines the page size */
>> #define PAGE_SHIFT      12
>> #define PAGE_SIZE       (_AC(1,UL) << PAGE_SHIFT)
>> #define PAGE_MASK       (~(PAGE_SIZE-1))
>>
>> The "~" is performed on a 32-bit value, so everything in "and" with
>> PAGE_MASK greater than 4GB will be truncated to the 32-bit boundary.
> 
> OK, I oversimplified my testcase.
> 
>> What do you think about the following?
>>
>> #define PAGE_SIZE64 (1ULL << PAGE_SHIFT)
>> #define PAGE_MASK64 (~(PAGE_SIZE64 - 1))
>>
>> #define PAGE_ALIGN(addr) ({					\
>> 	typeof(addr) __size = PAGE_SIZE;			\
>> 	typeof(addr) __ret = (addr) + __size - 1;		\
>> 	__ret > -1UL ? __ret & PAGE_MASK64 : __ret & PAGE_MASK;	\
>> })
> 
> Complex.  And I'd worry about added code overhead.
> 
> What about
> 
> #define PAGE_ALIGN(addr) ALIGN(addr, PAGE_SIZE)
> 
> ?
> 
> afaict ALIGN() tries to do the right thing, and if it doesn't, we
> should fix ALIGN().

Good! Much simpler.

-Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
