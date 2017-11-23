Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 838706B0033
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 01:17:39 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id s9so2208208pfe.20
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 22:17:39 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id x9si15506370pgo.721.2017.11.22.22.17.37
        for <linux-mm@kvack.org>;
        Wed, 22 Nov 2017 22:17:38 -0800 (PST)
Date: Thu, 23 Nov 2017 15:23:17 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/5] mm/kasan: advanced check
Message-ID: <20171123062317.GC31720@js1304-P5Q-DELUXE>
References: <20171117223043.7277-1-wen.gang.wang@oracle.com>
 <CACT4Y+ZkC8R1vL+=j4Ordr2-4BWAc8Um+hdxPPWS6_DFi58ZJA@mail.gmail.com>
 <20171120015000.GA13507@js1304-P5Q-DELUXE>
 <8bdd114f-4bf1-e60d-eb78-af67f6c74abc@oracle.com>
 <20171122043027.GA24912@js1304-P5Q-DELUXE>
 <bc1b210e-8a95-39ac-fafb-852409bdebd4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <bc1b210e-8a95-39ac-fafb-852409bdebd4@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wengang Wang <wen.gang.wang@oracle.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Linux-MM <linux-mm@kvack.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>

On Wed, Nov 22, 2017 at 11:43:00AM -0800, Wengang Wang wrote:
> 
> 
> On 2017/11/21 20:30, Joonsoo Kim wrote:
> >On Mon, Nov 20, 2017 at 11:56:05AM -0800, Wengang wrote:
> >>
> >>On 11/19/2017 05:50 PM, Joonsoo Kim wrote:
> >>>On Fri, Nov 17, 2017 at 11:56:21PM +0100, Dmitry Vyukov wrote:
> >>>>On Fri, Nov 17, 2017 at 11:30 PM, Wengang Wang <wen.gang.wang@oracle.com> wrote:
> >>>>>Kasan advanced check, I'm going to add this feature.
> >>>>>Currently Kasan provide the detection of use-after-free and out-of-bounds
> >>>>>problems. It is not able to find the overwrite-on-allocated-memory issue.
> >>>>>We sometimes hit this kind of issue: We have a messed up structure
> >>>>>(usually dynamially allocated), some of the fields in the structure were
> >>>>>overwritten with unreasaonable values. And kernel may panic due to those
> >>>>>overeritten values. We know those fields were overwritten somehow, but we
> >>>>>have no easy way to find out which path did the overwritten. The advanced
> >>>>>check wants to help in this scenario.
> >>>>>
> >>>>>The idea is to define the memory owner. When write accesses come from
> >>>>>non-owner, error should be reported. Normally the write accesses on a given
> >>>>>structure happen in only several or a dozen of functions if the structure
> >>>>>is not that complicated. We call those functions "allowed functions".
> >>>>>The work of defining the owner and binding memory to owner is expected to
> >>>>>be done by the memory consumer. In the above case, memory consume register
> >>>>>the owner as the functions which have write accesses to the structure then
> >>>>>bind all the structures to the owner. Then kasan will do the "owner check"
> >>>>>after the basic checks.
> >>>>>
> >>>>>As implementation, kasan provides a API to it's user to register their
> >>>>>allowed functions. The API returns a token to users.  At run time, users
> >>>>>bind the memory ranges they are interested in to the check they registered.
> >>>>>Kasan then checks the bound memory ranges with the allowed functions.
> >>>>>
> >>>>>
> >>>>>Signed-off-by: Wengang Wang <wen.gang.wang@oracle.com>
> >>>Hello, Wengang.
> >>>
> >>>Nice idea. I also think that we need this kind of debugging tool. It's very
> >>>hard to detect overwritten bugs.
> >>>
> >>>In fact, I made a quite similar tool, valid access checker (A.K.A.
> >>>vchecker). See the following link.
> >>>
> >>>https://github.com/JoonsooKim/linux/tree/vchecker-master-v0.3-next-20170106
> >>>
> >>>Vchecker has some advanced features compared to yours.
> >>>
> >>>1. Target object can be choosen at runtime by debugfs. It doesn't
> >>>require re-compile to register the target object.
> >>Hi Joonsoo, good to know you are also interested in this!
> >>
> >>Yes, if can be choosen via debugfs, it doesn't need re-compile.
> >>Well, I wonder what do you expect to be chosen from use space?
> >As you mentioned somewhere, this tool can be used when we find the
> >overwritten happend on some particular victims. I assumes that most of
> >the problem would happen on slab objects and userspace can choose the
> >target slab cache via debugfs interface of the vchecker.
> Yes, I agree it would be slab objects.
> If there is a way to set the slab objects to be subject of check via
> name, it is good.
> One question is how about common kmalloc slabs?  They are widely
> used and many
> problems happens with them.

Yes, kmalloc slab should be supported. I have a simple solution to
this problem and mentioned on another reply. Please reference it.

> 
> >
> >>>2. It has another feature that checks the value stored in the object.
> >>>Usually, invalid writer stores odd value into the object and vchecker
> >>>can detect this case.
> >>It's good to do the check. Well, as I understand, it tells something
> >>bad (overwitten) happened.
> >>But it can't tell who did the overwritten, right?  (I didn't look at
> >>your patch yet,) do you recall the last write somewhere?
> >Yes, it stores the callstack of the last write and report it when
> >the error is found.
> >
> >>>3. It has a callstack checker (memory owner checker in yours). It
> >>>checks all the callstack rather than just the caller. It's important
> >>>since invalid writer could call the parent function of owner function
> >>>and it would not be catched by checking just the caller.
> >>>
> >>>4. The callstack checker is more automated. vchecker collects the valid
> >>>callstack by running the system.
> >>I think we can merge the above two into one.
> >>So you are doing full stack check.  Well, finding out the all the
> >>paths which have the write access may be not a very easy thing.
> >>Missing some paths may cause dmesg flooding, and those log won't
> >>help at all. Finding out all the (owning) caller only is relatively
> >>much easier.
> >Vchecker can be easily modified to store only the caller. It just
> >requires modifying callstack depth parameter so it's so easy.
> >Moreover, it can be accomplished by adding debugfs interface.
> 
> That's good.
> >Anyway, I don't think that finding out all the (owning) caller only
> >is much easier. Think about dentry or inode object. It is accessed by
> >various code path and it's not easy to cover all the owning caller by
> >manual approach.
> Comparing to finding out full stack, it's much easier.  If we take
> dentry as example,
> I agree dentries are widely accessed and maybe finding out all the
> owning caller is not that
> easy, but comparing to finding out the full stack, it's easier.

Okay. I mean that it's not that difficult with automatic search. Just
running the workload for a while will find almost full stacks.

> >
> >
> >>There do is the case you pointed out here. In this case, the
> >>debugger can make slight change to the calling path. And as I
> >>understand,
> >>most of the overwritten are happening in quite different call paths,
> >>they are not calling the (owning) caller.
> >Agreed.
> >
> >>>FYI, I attach some commit descriptions of the vchecker.
> >>>
> >>>     vchecker: store/report callstack of value writer
> >>>     The purpose of the value checker is finding invalid user writing
> >>>     invalid value at the moment that the value is written. However, there is
> >>>     a missing infrastructure that passes writing value to the checker
> >>>     since we temporarilly piggyback on the KASAN. So, we cannot easily
> >>>     detect this case in time.
> >>>     However, by following way, we can emulate similar effect.
> >>>     1. Store callstack when memory is written.
> >>Oh, seems you are storing the callstack for each write. -- I am not
> >>sure if that would too heavy.
> >Unlike KASAN that checks all type of the objects, this debugging
> >feature is only enabled on the specific type of the objects so
> >overhead would not be too heavy in terms of system overall
> >performance.
> Yes, only specific type of objects do the extra stuff, but I am not
> sure if the overall
> performance to be affected. Actually I was thinking of tracking last
> write stack.
> At that time, I had two concerns: one is the performance affect; the
> other is if it's safe
> since memory access can happen in any context -- process context,
> soft irq and irq..

In my test, there is no performance problem. However, it's easy to
store only the caller. It would be cheaper. I will make it configurable.

> 
> BTW, how much extra memory is needed for each objects?

4 bytes per object.

> >
> >>Actually I was thinking to have a check on the new value. But seems
> >>compiler doesn't provide that.
> >Yes, look like we have a similar idea. I have some another ideas if
> >ASAN hook provides the value to be written. However, it's not
> >supported by compiler yet.
> 
> Right!
> 
> >
> >>>     2. If check is failed in next access, report previous write-access
> >>>     callstack
> >>>     It will caught offending user properly.
> >>>     Following output "Call trace: Invalid writer" part is the result
> >>>     of this patch. We find the invalid value at workfn+0x71 but report
> >>>     writer at workfn+0x61.
> >>>     [  133.024076] ==================================================================
> >>>     [  133.025576] BUG: VCHECKER: invalid access in workfn+0x71/0xc0 at addr ffff8800683dd6c8
> >>>     [  133.027196] Read of size 8 by task kworker/1:1/48
> >>>     [  133.028020] 0x8 0x10 value
> >>>     [  133.028020] 0xffff 4
> >>>     [  133.028020] Call trace: Invalid writer
> >>>     [  133.028020]
> >>>     [  133.028020] [<ffffffff81043b1b>] save_stack_trace+0x1b/0x20
> >>>     [  133.028020]
> >>>     [  133.028020] [<ffffffff812c0db9>] save_stack+0x39/0x70
> >>>     [  133.028020]
> >>>     [  133.028020] [<ffffffff812c0fe3>] check_value+0x43/0x80
> >>>     [  133.028020]
> >>>     [  133.028020] [<ffffffff812c1762>] vchecker_check+0x1c2/0x380
> >>>     [  133.028020]
> >>>     [  133.028020] [<ffffffff812be49d>] __asan_store8+0x8d/0xc0
> >>>     [  133.028020]
> >>>     [  133.028020] [<ffffffff815eadd1>] workfn+0x61/0xc0
> >>>     [  133.028020]
> >>>     [  133.028020] [<ffffffff810be3df>] process_one_work+0x28f/0x680
> >>>     [  133.028020]
> >>>     [  133.028020] [<ffffffff810bf272>] worker_thread+0xa2/0x870
> >>>     [  133.028020]
> >>>     [  133.028020] [<ffffffff810c86a5>] kthread+0x195/0x1e0
> >>>     [  133.028020]
> >>>     [  133.028020] [<ffffffff81b9d3d2>] ret_from_fork+0x22/0x30
> >>>     [  133.028020] CPU: 1 PID: 48 Comm: kworker/1:1 Not tainted 4.10.0-rc2-next-20170106+ #1179
> >>>     [  133.028020] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
> >>>     [  133.028020] Workqueue: events workfn
> >>>     [  133.028020] Call Trace:
> >>>     [  133.028020]  dump_stack+0x4d/0x63
> >>>     [  133.028020]  kasan_object_err+0x21/0x80
> >>>     [  133.028020]  vchecker_check+0x2af/0x380
> >>>     [  133.028020]  ? workfn+0x71/0xc0
> >>>     [  133.028020]  ? workfn+0x71/0xc0
> >>>     [  133.028020]  __asan_load8+0x87/0xb0
> >>>     [  133.028020]  workfn+0x71/0xc0
> >>>     [  133.028020]  process_one_work+0x28f/0x680
> >>>     [  133.028020]  worker_thread+0xa2/0x870
> >>>     [  133.028020]  kthread+0x195/0x1e0
> >>>     [  133.028020]  ? put_pwq_unlocked+0xc0/0xc0
> >>>     [  133.028020]  ? kthread_park+0xd0/0xd0
> >>>     [  133.028020]  ret_from_fork+0x22/0x30
> >>>     [  133.028020] Object at ffff8800683dd6c0, in cache vchecker_test size: 24
> >>>     [  133.028020] Allocated:
> >>>     [  133.028020] PID = 48
> >>>
> >>>
> >>>     vchecker: Add 'callstack' checker
> >>>     The callstack checker is to find invalid code paths accessing to a
> >>>     certain field in an object.  Currently it only saves all stack traces at
> >>>     the given offset.  Reporting will be added in the next patch.
> >>>     The below example checks callstack of anon_vma:
> >>>       # cd /sys/kernel/debug/vchecker
> >>>       # echo 0 8 > anon_vma/callstack  # offset 0, size 8
> >>>       # echo 1 > anon_vma/enable
> >>an echo "anon_vma" > <something> first?
> >>How do you define and path the valid (owning) full stack to kasan?
> >This interface only enables to store all the callstacks. No validation
> >check here. I think that this feature would also be helpful to debug.
> >If error happens, we can check all the previous callstacks and track
> >the buggy caller.
> Too much extra memory needed for each object? or you stores in just
> one global copy.

Just one global copy. vchecker uses stackdepot introduced for this
purpose.

> 
> >
> >>>       # cat anon_vma/callstack        # show saved callstacks
> >>>       0x0 0x8 callstack
> >>>       total: 42
> >>>       callstack #0
> >>>         anon_vma_fork+0x101/0x280
> >>>         copy_process.part.10+0x15ff/0x2a40
> >>>         _do_fork+0x155/0x7d0
> >>>         SyS_clone+0x19/0x20
> >>>         do_syscall_64+0xdf/0x460
> >>>         return_from_SYSCALL_64+0x0/0x7a
> >>>       ...
> >>>
> >>>
> >>>     vchecker: Support toggle on/off of callstack check
> >>>     By default, callstack checker only collects callchains.  When a user
> >>>     writes 'on' to the callstack file in debugfs, it checks and reports new
> >>>     callstacks.  Writing 'off' to disable it again.
> >>>       # cd /sys/kernel/debug/vchecker
> >>>       # echo 0 8 > anon_vma/callstack
> >>>       # echo 1 > anon_vma/enable
> >>>       ... (do some work to collect enough callstacks) ...
> >>How to define "enough" here?
> >The bug usually doesn't happen immediately since it usually happens on
> >the corner case. When debugging, we run the workload that causes the
> >bug and then wait for some time until the bug happens. "Enough" can
> >be defined as the middle of this waiting time. After some warm-up
> >time, all the common callstack would be collected. Then,
> >switching on this feature that reports a new callstack. If the corner
> >case that is on a new callstack happens, this new callstack will be
> >reported and we can check whether it is a true bug or not.
> What if it's not?
> I am still not convinced on if we can get "enough". We may never
> have a workload that
> make sure it covers all call stacks.

If it's not a true bug, we just need to continue the workload until a
true bug happens.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
