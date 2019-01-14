Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f200.google.com (mail-qk1-f200.google.com [209.85.222.200])
	by kanga.kvack.org (Postfix) with ESMTP id 34D4A8E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 21:33:55 -0500 (EST)
Received: by mail-qk1-f200.google.com with SMTP id w185so15591390qka.9
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 18:33:55 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 12sor77473747qvi.67.2019.01.13.18.33.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 13 Jan 2019 18:33:54 -0800 (PST)
Subject: Re: [PATCH v2] rbtree: fix the red root
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <20190111205843.25761-1-cai@lca.pw>
 <a783f23d-77ab-a7d3-39d1-4008d90094c3@lechnology.com>
 <CANN689G0zbk7sMbQ+p9NQGQ=NWq-Q0mQOOjeFkLp19YrTfgcLg@mail.gmail.com>
 <864d6b85-3336-4040-7c95-7d9615873777@lechnology.com>
From: Qian Cai <cai@lca.pw>
Message-ID: <b1033d96-ebdd-e791-650a-c6564f030ce1@lca.pw>
Date: Sun, 13 Jan 2019 21:33:51 -0500
MIME-Version: 1.0
In-Reply-To: <864d6b85-3336-4040-7c95-7d9615873777@lechnology.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Lechner <david@lechnology.com>, Michel Lespinasse <walken@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, esploit@protonmail.ch, jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, joeypabalinas@gmail.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>



On 1/13/19 9:20 PM, David Lechner wrote:
> On 1/11/19 8:58 PM, Michel Lespinasse wrote:
>> On Fri, Jan 11, 2019 at 3:47 PM David Lechner <david@lechnology.com> wrote:
>>>
>>> On 1/11/19 2:58 PM, Qian Cai wrote:
>>>> A GPF was reported,
>>>>
>>>> kasan: CONFIG_KASAN_INLINE enabled
>>>> kasan: GPF could be caused by NULL-ptr deref or user memory access
>>>> general protection fault: 0000 [#1] SMP KASAN
>>>>           kasan_die_handler.cold.22+0x11/0x31
>>>>           notifier_call_chain+0x17b/0x390
>>>>           atomic_notifier_call_chain+0xa7/0x1b0
>>>>           notify_die+0x1be/0x2e0
>>>>           do_general_protection+0x13e/0x330
>>>>           general_protection+0x1e/0x30
>>>>           rb_insert_color+0x189/0x1480
>>>>           create_object+0x785/0xca0
>>>>           kmemleak_alloc+0x2f/0x50
>>>>           kmem_cache_alloc+0x1b9/0x3c0
>>>>           getname_flags+0xdb/0x5d0
>>>>           getname+0x1e/0x20
>>>>           do_sys_open+0x3a1/0x7d0
>>>>           __x64_sys_open+0x7e/0xc0
>>>>           do_syscall_64+0x1b3/0x820
>>>>           entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>>>
>>>> It turned out,
>>>>
>>>> gparent = rb_red_parent(parent);
>>>> tmp = gparent->rb_right; <-- GPF was triggered here.
>>>>
>>>> Apparently, "gparent" is NULL which indicates "parent" is rbtree's root
>>>> which is red. Otherwise, it will be treated properly a few lines above.
>>>>
>>>> /*
>>>>    * If there is a black parent, we are done.
>>>>    * Otherwise, take some corrective action as,
>>>>    * per 4), we don't want a red root or two
>>>>    * consecutive red nodes.
>>>>    */
>>>> if(rb_is_black(parent))
>>>>        break;
>>>>
>>>> Hence, it violates the rule #1 (the root can't be red) and need a fix
>>>> up, and also add a regression test for it. This looks like was
>>>> introduced by 6d58452dc06 where it no longer always paint the root as
>>>> black.
>>>>
>>>> Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only
>>>> when necessary)
>>>> Reported-by: Esme <esploit@protonmail.ch>
>>>> Tested-by: Joey Pabalinas <joeypabalinas@gmail.com>
>>>> Signed-off-by: Qian Cai <cai@lca.pw>
>>>> ---
>>>
>>> Tested-by: David Lechner <david@lechnology.com>
>>> FWIW, this fixed the following crash for me:
>>>
>>> Unable to handle kernel NULL pointer dereference at virtual address 00000004
>>
>> Just to clarify, do you have a way to reproduce this crash without the fix ?
> 
> I am starting to suspect that my crash was caused by some new code
> in the drm-misc-next tree that might be causing a memory corruption.
> It threw me off that the stack trace didn't contain anything related
> to drm.
> 
> See: https://patchwork.freedesktop.org/patch/276719/
>

It may be useful for those who could reproduce this issue to turn on those
memory corruption debug options to narrow down a bit.

CONFIG_DEBUG_PAGEALLOC=y
CONFIG_DEBUG_PAGEALLOC_ENABLE_DEFAULT=y
CONFIG_KASAN=y
CONFIG_KASAN_GENERIC=y
CONFIG_SLUB_DEBUG_ON=y
