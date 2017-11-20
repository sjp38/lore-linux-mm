Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 574766B0033
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 14:56:13 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id j58so9397076qtj.18
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 11:56:13 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id d55si2137230qte.83.2017.11.20.11.56.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 20 Nov 2017 11:56:11 -0800 (PST)
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
 <20171120015000.GA13507@js1304-P5Q-DELUXE>
From: Wengang <wen.gang.wang@oracle.com>
Message-ID: <8bdd114f-4bf1-e60d-eb78-af67f6c74abc@oracle.com>
Date: Mon, 20 Nov 2017 11:56:05 -0800
MIME-Version: 1.0
In-Reply-To: <20171120015000.GA13507@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Content-Language: en-US
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Dmitry Vyukov <dvyukov@google.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>



On 11/19/2017 05:50 PM, Joonsoo Kim wrote:
> On Fri, Nov 17, 2017 at 11:56:21PM +0100, Dmitry Vyukov wrote:
>> On Fri, Nov 17, 2017 at 11:30 PM, Wengang Wang <wen.gang.wang@oracle.com> wrote:
>>> Kasan advanced check, I'm going to add this feature.
>>> Currently Kasan provide the detection of use-after-free and out-of-bounds
>>> problems. It is not able to find the overwrite-on-allocated-memory issue.
>>> We sometimes hit this kind of issue: We have a messed up structure
>>> (usually dynamially allocated), some of the fields in the structure were
>>> overwritten with unreasaonable values. And kernel may panic due to those
>>> overeritten values. We know those fields were overwritten somehow, but we
>>> have no easy way to find out which path did the overwritten. The advanced
>>> check wants to help in this scenario.
>>>
>>> The idea is to define the memory owner. When write accesses come from
>>> non-owner, error should be reported. Normally the write accesses on a given
>>> structure happen in only several or a dozen of functions if the structure
>>> is not that complicated. We call those functions "allowed functions".
>>> The work of defining the owner and binding memory to owner is expected to
>>> be done by the memory consumer. In the above case, memory consume register
>>> the owner as the functions which have write accesses to the structure then
>>> bind all the structures to the owner. Then kasan will do the "owner check"
>>> after the basic checks.
>>>
>>> As implementation, kasan provides a API to it's user to register their
>>> allowed functions. The API returns a token to users.  At run time, users
>>> bind the memory ranges they are interested in to the check they registered.
>>> Kasan then checks the bound memory ranges with the allowed functions.
>>>
>>>
>>> Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> Hello, Wengang.
>
> Nice idea. I also think that we need this kind of debugging tool. It's very
> hard to detect overwritten bugs.
>
> In fact, I made a quite similar tool, valid access checker (A.K.A.
> vchecker). See the following link.
>
> https://github.com/JoonsooKim/linux/tree/vchecker-master-v0.3-next-20170106
>
> Vchecker has some advanced features compared to yours.
>
> 1. Target object can be choosen at runtime by debugfs. It doesn't
> require re-compile to register the target object.
Hi Joonsoo, good to know you are also interested in this!

Yes, if can be choosen via debugfs, it doesn't need re-compile.
Well, I wonder what do you expect to be chosen from use space?

>
> 2. It has another feature that checks the value stored in the object.
> Usually, invalid writer stores odd value into the object and vchecker
> can detect this case.
It's good to do the check. Well, as I understand, it tells something bad 
(overwitten) happened.
But it can't tell who did the overwritten, right?  (I didn't look at 
your patch yet,) do you recall the last write somewhere?

>
> 3. It has a callstack checker (memory owner checker in yours). It
> checks all the callstack rather than just the caller. It's important
> since invalid writer could call the parent function of owner function
> and it would not be catched by checking just the caller.
>
> 4. The callstack checker is more automated. vchecker collects the valid
> callstack by running the system.
I think we can merge the above two into one.
So you are doing full stack check.  Well, finding out the all the paths 
which have the write access may be not a very easy thing.
Missing some paths may cause dmesg flooding, and those log won't help at 
all. Finding out all the (owning) caller only is relatively much easier.
There do is the case you pointed out here. In this case, the debugger 
can make slight change to the calling path. And as I understand,
most of the overwritten are happening in quite different call paths, 
they are not calling the (owning) caller.

>
> FYI, I attach some commit descriptions of the vchecker.
>
>      vchecker: store/report callstack of value writer
>      
>      The purpose of the value checker is finding invalid user writing
>      invalid value at the moment that the value is written. However, there is
>      a missing infrastructure that passes writing value to the checker
>      since we temporarilly piggyback on the KASAN. So, we cannot easily
>      detect this case in time.
>      
>      However, by following way, we can emulate similar effect.
>      
>      1. Store callstack when memory is written.

Oh, seems you are storing the callstack for each write. -- I am not sure 
if that would too heavy.
Actually I was thinking to have a check on the new value. But seems 
compiler doesn't provide that.
>      2. If check is failed in next access, report previous write-access
>      callstack
>      
>      It will caught offending user properly.
>      
>      
>      Following output "Call trace: Invalid writer" part is the result
>      of this patch. We find the invalid value at workfn+0x71 but report
>      writer at workfn+0x61.
>      
>      [  133.024076] ==================================================================
>      [  133.025576] BUG: VCHECKER: invalid access in workfn+0x71/0xc0 at addr ffff8800683dd6c8
>      [  133.027196] Read of size 8 by task kworker/1:1/48
>      [  133.028020] 0x8 0x10 value
>      [  133.028020] 0xffff 4
>      [  133.028020] Call trace: Invalid writer
>      [  133.028020]
>      [  133.028020] [<ffffffff81043b1b>] save_stack_trace+0x1b/0x20
>      [  133.028020]
>      [  133.028020] [<ffffffff812c0db9>] save_stack+0x39/0x70
>      [  133.028020]
>      [  133.028020] [<ffffffff812c0fe3>] check_value+0x43/0x80
>      [  133.028020]
>      [  133.028020] [<ffffffff812c1762>] vchecker_check+0x1c2/0x380
>      [  133.028020]
>      [  133.028020] [<ffffffff812be49d>] __asan_store8+0x8d/0xc0
>      [  133.028020]
>      [  133.028020] [<ffffffff815eadd1>] workfn+0x61/0xc0
>      [  133.028020]
>      [  133.028020] [<ffffffff810be3df>] process_one_work+0x28f/0x680
>      [  133.028020]
>      [  133.028020] [<ffffffff810bf272>] worker_thread+0xa2/0x870
>      [  133.028020]
>      [  133.028020] [<ffffffff810c86a5>] kthread+0x195/0x1e0
>      [  133.028020]
>      [  133.028020] [<ffffffff81b9d3d2>] ret_from_fork+0x22/0x30
>      [  133.028020] CPU: 1 PID: 48 Comm: kworker/1:1 Not tainted 4.10.0-rc2-next-20170106+ #1179
>      [  133.028020] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
>      [  133.028020] Workqueue: events workfn
>      [  133.028020] Call Trace:
>      [  133.028020]  dump_stack+0x4d/0x63
>      [  133.028020]  kasan_object_err+0x21/0x80
>      [  133.028020]  vchecker_check+0x2af/0x380
>      [  133.028020]  ? workfn+0x71/0xc0
>      [  133.028020]  ? workfn+0x71/0xc0
>      [  133.028020]  __asan_load8+0x87/0xb0
>      [  133.028020]  workfn+0x71/0xc0
>      [  133.028020]  process_one_work+0x28f/0x680
>      [  133.028020]  worker_thread+0xa2/0x870
>      [  133.028020]  kthread+0x195/0x1e0
>      [  133.028020]  ? put_pwq_unlocked+0xc0/0xc0
>      [  133.028020]  ? kthread_park+0xd0/0xd0
>      [  133.028020]  ret_from_fork+0x22/0x30
>      [  133.028020] Object at ffff8800683dd6c0, in cache vchecker_test size: 24
>      [  133.028020] Allocated:
>      [  133.028020] PID = 48
>
>
>      vchecker: Add 'callstack' checker
>      
>      The callstack checker is to find invalid code paths accessing to a
>      certain field in an object.  Currently it only saves all stack traces at
>      the given offset.  Reporting will be added in the next patch.
>      
>      The below example checks callstack of anon_vma:
>      
>        # cd /sys/kernel/debug/vchecker
>        # echo 0 8 > anon_vma/callstack  # offset 0, size 8
>        # echo 1 > anon_vma/enable
an echo "anon_vma" > <something> first?
How do you define and path the valid (owning) full stack to kasan?

>      
>        # cat anon_vma/callstack        # show saved callstacks
>        0x0 0x8 callstack
>        total: 42
>        callstack #0
>          anon_vma_fork+0x101/0x280
>          copy_process.part.10+0x15ff/0x2a40
>          _do_fork+0x155/0x7d0
>          SyS_clone+0x19/0x20
>          do_syscall_64+0xdf/0x460
>          return_from_SYSCALL_64+0x0/0x7a
>        ...
>
>
>      vchecker: Support toggle on/off of callstack check
>      
>      By default, callstack checker only collects callchains.  When a user
>      writes 'on' to the callstack file in debugfs, it checks and reports new
>      callstacks.  Writing 'off' to disable it again.
>      
>        # cd /sys/kernel/debug/vchecker
>        # echo 0 8 > anon_vma/callstack
>        # echo 1 > anon_vma/enable
>      
>        ... (do some work to collect enough callstacks) ...
How to define "enough" here?
>      
>        # echo on > anon_vma/callstack
>      
>
> The reason I didn't submit the vchecker to mainline is that I didn't find
> the case that this tool is useful in real life. Most of the system broken case
> can be debugged by other ways. Do you see the real case that this tool is
> helpful? If so, I think that vchecker is more appropriate to be upstreamed.
> Could you share your opinion?
Yes, people find other ways to solve overwritten issue (so did I) in the 
past. If kasan doesn't provide this functionality, developers have no 
way to choose it.
Though people have other ways to find the root cause, the other ways 
maybe take (maybe much) longer. I didn't solve problems with the owner 
check yet since I just make available recently.  But considering the 
overwritten issues I have ever hit, the owner check definitely helps and 
I definitely will try the owner check when I have a new overwritten issue!

Why not send your patch for review?

thanks,
wengang

>
> Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
