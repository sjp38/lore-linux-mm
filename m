Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vs1-f72.google.com (mail-vs1-f72.google.com [209.85.217.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E8448E0002
	for <linux-mm@kvack.org>; Sun, 13 Jan 2019 21:20:17 -0500 (EST)
Received: by mail-vs1-f72.google.com with SMTP id x1so10330669vsc.0
        for <linux-mm@kvack.org>; Sun, 13 Jan 2019 18:20:17 -0800 (PST)
Received: from vern.gendns.com (vern.gendns.com. [98.142.107.122])
        by mx.google.com with ESMTPS id w20si19451407vse.127.2019.01.13.18.20.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Jan 2019 18:20:16 -0800 (PST)
Subject: Re: [PATCH v2] rbtree: fix the red root
References: <20190111181600.GJ6310@bombadil.infradead.org>
 <20190111205843.25761-1-cai@lca.pw>
 <a783f23d-77ab-a7d3-39d1-4008d90094c3@lechnology.com>
 <CANN689G0zbk7sMbQ+p9NQGQ=NWq-Q0mQOOjeFkLp19YrTfgcLg@mail.gmail.com>
From: David Lechner <david@lechnology.com>
Message-ID: <864d6b85-3336-4040-7c95-7d9615873777@lechnology.com>
Date: Sun, 13 Jan 2019 20:20:12 -0600
MIME-Version: 1.0
In-Reply-To: <CANN689G0zbk7sMbQ+p9NQGQ=NWq-Q0mQOOjeFkLp19YrTfgcLg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michel Lespinasse <walken@google.com>
Cc: Qian Cai <cai@lca.pw>, Andrew Morton <akpm@linux-foundation.org>, esploit@protonmail.ch, jejb@linux.ibm.com, dgilbert@interlog.com, martin.petersen@oracle.com, joeypabalinas@gmail.com, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 1/11/19 8:58 PM, Michel Lespinasse wrote:
> On Fri, Jan 11, 2019 at 3:47 PM David Lechner <david@lechnology.com> wrote:
>>
>> On 1/11/19 2:58 PM, Qian Cai wrote:
>>> A GPF was reported,
>>>
>>> kasan: CONFIG_KASAN_INLINE enabled
>>> kasan: GPF could be caused by NULL-ptr deref or user memory access
>>> general protection fault: 0000 [#1] SMP KASAN
>>>           kasan_die_handler.cold.22+0x11/0x31
>>>           notifier_call_chain+0x17b/0x390
>>>           atomic_notifier_call_chain+0xa7/0x1b0
>>>           notify_die+0x1be/0x2e0
>>>           do_general_protection+0x13e/0x330
>>>           general_protection+0x1e/0x30
>>>           rb_insert_color+0x189/0x1480
>>>           create_object+0x785/0xca0
>>>           kmemleak_alloc+0x2f/0x50
>>>           kmem_cache_alloc+0x1b9/0x3c0
>>>           getname_flags+0xdb/0x5d0
>>>           getname+0x1e/0x20
>>>           do_sys_open+0x3a1/0x7d0
>>>           __x64_sys_open+0x7e/0xc0
>>>           do_syscall_64+0x1b3/0x820
>>>           entry_SYSCALL_64_after_hwframe+0x49/0xbe
>>>
>>> It turned out,
>>>
>>> gparent = rb_red_parent(parent);
>>> tmp = gparent->rb_right; <-- GPF was triggered here.
>>>
>>> Apparently, "gparent" is NULL which indicates "parent" is rbtree's root
>>> which is red. Otherwise, it will be treated properly a few lines above.
>>>
>>> /*
>>>    * If there is a black parent, we are done.
>>>    * Otherwise, take some corrective action as,
>>>    * per 4), we don't want a red root or two
>>>    * consecutive red nodes.
>>>    */
>>> if(rb_is_black(parent))
>>>        break;
>>>
>>> Hence, it violates the rule #1 (the root can't be red) and need a fix
>>> up, and also add a regression test for it. This looks like was
>>> introduced by 6d58452dc06 where it no longer always paint the root as
>>> black.
>>>
>>> Fixes: 6d58452dc06 (rbtree: adjust root color in rb_insert_color() only
>>> when necessary)
>>> Reported-by: Esme <esploit@protonmail.ch>
>>> Tested-by: Joey Pabalinas <joeypabalinas@gmail.com>
>>> Signed-off-by: Qian Cai <cai@lca.pw>
>>> ---
>>
>> Tested-by: David Lechner <david@lechnology.com>
>> FWIW, this fixed the following crash for me:
>>
>> Unable to handle kernel NULL pointer dereference at virtual address 00000004
> 
> Just to clarify, do you have a way to reproduce this crash without the fix ?

I am starting to suspect that my crash was caused by some new code
in the drm-misc-next tree that might be causing a memory corruption.
It threw me off that the stack trace didn't contain anything related
to drm.

See: https://patchwork.freedesktop.org/patch/276719/

> 
> I don't think the fix is correct, because it just silently ignores a
> corrupted rbtree (red root node). But the code that creates this
> situation certainly needs to be fixed - having a reproduceable test
> case would certainly help here.
> 
> Regarding 6d58452dc06, the reasoning was that this code expects to be
> called after inserting a new (red) leaf into an rbtree that had all of
> its data structure invariants satisfied. So in this context, it should
> not be necessary to always reset the root to black, as this should
> already be the case...
> 
