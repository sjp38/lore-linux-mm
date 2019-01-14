Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f69.google.com (mail-lf1-f69.google.com [209.85.167.69])
	by kanga.kvack.org (Postfix) with ESMTP id EFDE18E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 22:53:07 -0500 (EST)
Received: by mail-lf1-f69.google.com with SMTP id n26so1510700lfh.13
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 19:53:07 -0800 (PST)
Received: from smtp.infotech.no (smtp.infotech.no. [82.134.31.41])
        by mx.google.com with ESMTP id y18-v6si27054612lji.22.2019.01.13.19.53.05
        for <linux-mm@kvack.org>;
        Sun, 13 Jan 2019 19:53:05 -0800 (PST)
Reply-To: dgilbert@interlog.com
Subject: Re: [PATCH v2] rbtree: fix the red root
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <20190111205843.25761-1-cai@lca.pw>
 <a783f23d-77ab-a7d3-39d1-4008d90094c3@lechnology.com>
 <CANN689G0zbk7sMbQ+p9NQGQ=NWq-Q0mQOOjeFkLp19YrTfgcLg@mail.gmail.com>
 <864d6b85-3336-4040-7c95-7d9615873777@lechnology.com>
 <b1033d96-ebdd-e791-650a-c6564f030ce1@lca.pw>
 <8v11ZOLyufY7NLAHDFApGwXOO_wGjVHtsbw1eiZ__YvI9EZCDe_4FNmlp0E-39lnzGQHhHAczQ6Q6lQPzVU2V6krtkblM8IFwIXPHZCuqGE=@protonmail.ch>
From: Douglas Gilbert <dgilbert@interlog.com>
Message-ID: <c6265fc0-4089-9d1a-ba7c-b267b847747e@interlog.com>
Date: Sun, 13 Jan 2019 22:52:16 -0500
MIME-Version: 1.0
In-Reply-To: <8v11ZOLyufY7NLAHDFApGwXOO_wGjVHtsbw1eiZ__YvI9EZCDe_4FNmlp0E-39lnzGQHhHAczQ6Q6lQPzVU2V6krtkblM8IFwIXPHZCuqGE=@protonmail.ch>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-CA
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Esme <esploit@protonmail.ch>, Qian Cai <cai@lca.pw>
Cc: David Lechner <david@lechnology.com>, Michel Lespinasse <walken@google.com>, Andrew Morton <akpm@linux-foundation.org>, "jejb@linux.ibm.com" <jejb@linux.ibm.com>, "martin.petersen@oracle.com" <martin.petersen@oracle.com>, "joeypabalinas@gmail.com" <joeypabalinas@gmail.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 2019-01-13 10:07 p.m., Esme wrote:
> ‐‐‐‐‐‐‐ Original Message ‐‐‐‐‐‐‐
> On Sunday, January 13, 2019 9:33 PM, Qian Cai <cai@lca.pw> wrote:
> 
>> On 1/13/19 9:20 PM, David Lechner wrote:
>>
>>> On 1/11/19 8:58 PM, Michel Lespinasse wrote:
>>>
>>>> On Fri, Jan 11, 2019 at 3:47 PM David Lechner david@lechnology.com wrote:
>>>>
>>>>> On 1/11/19 2:58 PM, Qian Cai wrote:
>>>>>
>>>>>> A GPF was reported,
>>>>>> kasan: CONFIG_KASAN_INLINE enabled
>>>>>> kasan: GPF could be caused by NULL-ptr deref or user memory access
>>>>>> general protection fault: 0000 [#1] SMP KASAN
>>>>>>            kasan_die_handler.cold.22+0x11/0x31
>>>>>>            notifier_call_chain+0x17b/0x390
>>>>>>            atomic_notifier_call_chain+0xa7/0x1b0
>>>>>>            notify_die+0x1be/0x2e0
>>>>>>            do_general_protection+0x13e/0x330
>>>>>>            general_protection+0x1e/0x30
>>>>>>            rb_insert_color+0x189/0x1480
>>>>>>            create_object+0x785/0xca0
>>>>>>            kmemleak_alloc+0x2f/0x50
>>>>>>            kmem_cache_alloc+0x1b9/0x3c0
>>>>>>            getname_flags+0xdb/0x5d0
>>>>>>            getname+0x1e/0x20
>>>>>>            do_sys_open+0x3a1/0x7d0
>>>>>>            __x64_sys_open+0x7e/0xc0
>>>>>>            do_syscall_64+0x1b3/0x820
>>>>>>            entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>>>>> It turned out,
>>>>>> gparent = rb_red_parent(parent);
>>>>>> tmp = gparent->rb_right; <-- GPF was triggered here.
>>>>>> Apparently, "gparent" is NULL which indicates "parent" is rbtree's root
>>>>>> which is red. Otherwise, it will be treated properly a few lines above.
>>>>>> /*
>>>>>>     * If there is a black parent, we are done.
>>>>>>     * Otherwise, take some corrective action as,
>>>>>>     * per 4), we don't want a red root or two
>>>>>>     * consecutive red nodes.
>>>>>>     */
>>>>>> if(rb_is_black(parent))
>>>>>>         break;
>>>>>> Hence, it violates the rule #1 (the root can't be red) and need a fix
>>>>>> up, and also add a regression test for it. This looks like was
>>>>>> introduced by 6d58452dc06 where it no longer always paint the root as
>>>>>> black.
>>>>>>
>>>>>> Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only
>>>>>> when necessary)
>>>>>> Reported-by: Esme esploit@protonmail.ch
>>>>>> Tested-by: Joey Pabalinas joeypabalinas@gmail.com
>>>>>> Signed-off-by: Qian Cai cai@lca.pw
>>>>>>
>>>>>> ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
>>>>>
>>>>> Tested-by: David Lechner david@lechnology.com
>>>>> FWIW, this fixed the following crash for me:
>>>>> Unable to handle kernel NULL pointer dereference at virtual address 00000004
>>>>
>>>> Just to clarify, do you have a way to reproduce this crash without the fix ?
>>>
>>> I am starting to suspect that my crash was caused by some new code
>>> in the drm-misc-next tree that might be causing a memory corruption.
>>> It threw me off that the stack trace didn't contain anything related
>>> to drm.
>>> See: https://patchwork.freedesktop.org/patch/276719/
>>
>> It may be useful for those who could reproduce this issue to turn on those
>> memory corruption debug options to narrow down a bit.
>>
>> CONFIG_DEBUG_PAGEALLOC=y
>> CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=y
>> CONFIG_KASAN=y
>> CONFIG_KASAN_GENERIC=y
>> CONFIG_SLUB_DEBUG_ON=y
> 
> I have been on SLAB, I configured SLAB DEBUG with a fresh pull from github. Linux syzkaller 5.0.0-rc2 #9 SMP Sun Jan 13 21:57:40 EST 2019 x86_64
> ...
> 
> In an effort to get a different stack into the kernel, I felt that nothing works better than fork bomb? :)
> 
> Let me know if that helps.
> 
> root@syzkaller:~# gcc -o test3 test3.c
> root@syzkaller:~# while : ; do ./test3 & done

And is test3 the same multi-threaded program that enters the kernel via
/dev/sg0 and then calls SCSI_IOCTL_SEND_COMMAND which goes to the SCSI
mid-level and thence to the block layer?

And please remind me, does it also fail on lk 4.20.2 ?

Doug Gilbert
