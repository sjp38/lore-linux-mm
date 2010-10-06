Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 791DE6B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 20:15:40 -0400 (EDT)
Received: by iwn41 with SMTP id 41so1523828iwn.14
        for <linux-mm@kvack.org>; Tue, 05 Oct 2010 17:15:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
References: <1286175485-30643-1-git-send-email-gthelen@google.com>
	<1286175485-30643-5-git-send-email-gthelen@google.com>
	<20101005160332.GB9515@barrios-desktop>
	<xr93wrpwkypv.fsf@ninji.mtv.corp.google.com>
Date: Wed, 6 Oct 2010 09:15:34 +0900
Message-ID: <AANLkTikKXNx-Cj2UY+tJj8ifC+Je5WDbS=eR6xsKM1uU@mail.gmail.com>
Subject: Re: [PATCH 04/10] memcg: disable local interrupts in lock_page_cgroup()
From: Minchan Kim <minchan.kim@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, containers@lists.osdl.org, Andrea Righi <arighi@develer.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Wed, Oct 6, 2010 at 8:26 AM, Greg Thelen <gthelen@google.com> wrote:
> Minchan Kim <minchan.kim@gmail.com> writes:
>
>> On Sun, Oct 03, 2010 at 11:57:59PM -0700, Greg Thelen wrote:
>>> If pages are being migrated from a memcg, then updates to that
>>> memcg's page statistics are protected by grabbing a bit spin lock
>>> using lock_page_cgroup(). =A0In an upcoming commit memcg dirty page
>>> accounting will be updating memcg page accounting (specifically:
>>> num writeback pages) from softirq. =A0Avoid a deadlocking nested
>>> spin lock attempt by disabling interrupts on the local processor
>>> when grabbing the page_cgroup bit_spin_lock in lock_page_cgroup().
>>> This avoids the following deadlock:
>>> statistic
>>> =A0 =A0 =A0 CPU 0 =A0 =A0 =A0 =A0 =A0 =A0 CPU 1
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 inc_file_mapped
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock
>>> =A0 start move
>>> =A0 synchronize_rcu
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_page_cgroup
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 softirq
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 test_clear_page_writeback
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mem_cgroup_dec_page_stat(NR=
_WRITEBACK)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_lock
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lock_page_cgroup =A0 /* dea=
dlock */
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page_cgroup
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 unlock_page_cgroup
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rcu_read_unlock
>>>
>>> By disabling interrupts in lock_page_cgroup, nested calls
>>> are avoided. =A0The softirq would be delayed until after inc_file_mappe=
d
>>> enables interrupts when calling unlock_page_cgroup().
>>>
>>> The normal, fast path, of memcg page stat updates typically
>>> does not need to call lock_page_cgroup(), so this change does
>>> not affect the performance of the common case page accounting.
>>>
>>> Signed-off-by: Andrea Righi <arighi@develer.com>
>>> Signed-off-by: Greg Thelen <gthelen@google.com>
>>> ---
>>> =A0include/linux/page_cgroup.h | =A0 =A08 +++++-
>>> =A0mm/memcontrol.c =A0 =A0 =A0 =A0 =A0 =A0 | =A0 51 +++++++++++++++++++=
++++++-----------------
>>> =A02 files changed, 36 insertions(+), 23 deletions(-)
>>>
>>> diff --git a/include/linux/page_cgroup.h b/include/linux/page_cgroup.h
>>> index b59c298..872f6b1 100644
>>> --- a/include/linux/page_cgroup.h
>>> +++ b/include/linux/page_cgroup.h
>>> @@ -117,14 +117,18 @@ static inline enum zone_type page_cgroup_zid(stru=
ct page_cgroup *pc)
>>> =A0 =A0 =A0return page_zonenum(pc->page);
>>> =A0}
>>>
>>> -static inline void lock_page_cgroup(struct page_cgroup *pc)
>>> +static inline void lock_page_cgroup(struct page_cgroup *pc,
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0unsign=
ed long *flags)
>>> =A0{
>>> + =A0 =A0local_irq_save(*flags);
>>> =A0 =A0 =A0bit_spin_lock(PCG_LOCK, &pc->flags);
>>> =A0}
>>
>> Hmm. Let me ask questions.
>>
>> 1. Why do you add new irq disable region in general function?
>> I think __do_fault is a one of fast path.
>
> This is true. =A0I used pft to measure the cost of this extra locking
> code. =A0This pft workload exercises this memcg call stack:
> =A0 =A0 =A0 =A0lock_page_cgroup+0x39/0x5b
> =A0 =A0 =A0 =A0__mem_cgroup_commit_charge+0x2c/0x98
> =A0 =A0 =A0 =A0mem_cgroup_charge_common+0x66/0x76
> =A0 =A0 =A0 =A0mem_cgroup_newpage_charge+0x40/0x4f
> =A0 =A0 =A0 =A0handle_mm_fault+0x2e3/0x869
> =A0 =A0 =A0 =A0do_page_fault+0x286/0x29b
> =A0 =A0 =A0 =A0page_fault+0x1f/0x30
>
> I ran 100 iterations of "pft -m 8g -t 16 -a" and focused on the
> flt/cpu/s.
>
> First I established a performance baseline using upstream mmotm locking
> (not disabling interrupts).
> =A0 =A0 =A0 =A0100 samples: mean 51930.16383 =A0stddev 2.032% (1055.40818=
272)
>
> Then I introduced this patch, which disabled interrupts in
> lock_page_cgroup():
> =A0 =A0 =A0 =A0100 samples: mean 52174.17434 =A0stddev 1.306% (681.144426=
46)
>
> Then I replaced this patch's usage of local_irq_save/restore() with
> local_bh_disable/enable().
> =A0 =A0 =A0 =A0100 samples: mean 51810.58591 =A0stddev 1.892% (980.340335=
322)
>
> The proposed patch (#2) actually improves allocation performance by
> 0.47% when compared to the baseline (#1). =A0However, I believe that this
> is in the statistical noise. =A0This particular workload does not seem to
> be affected this patch.

Yes. But irq disable has a interrupt latency problem as well as just
overhead of instruction.
I have a concern about interrupt latency.
I have a experience that too many disable irq makes irq handler
latency too slow in embedded system.
For example, irq handler latency is a important factor in ARM perf to
capture program counter.
That's because ARM perf doesn't use NMI handler.

>
>> Could you disable softirq using _local_bh_disable_ not in general functi=
on
>> but in your context?
>
> lock_page_cgroup() is only used by mem_cgroup in memcontrol.c.
>
> local_bh_disable() should also work instead of my proposed patch, which
> used local_irq_save/restore(). =A0local_bh_disable() will not disable all
> interrupts so it should have less impact. =A0But I think that usage of
> local_bh_disable() it still something that has to happen in the general
> lock_page_cgroup() function. =A0The softirq can occur at an arbitrary tim=
e
> and processor with the possibility of interrupting anyone who does not
> have interrupts or softirq disabled. =A0Therefore the softirq could
> interrupt code that has used lock_page_cgroup(), unless
> lock_page_cgroup() explicitly (as proposed) disables interrupts (or
> softirq). =A0If (as you suggest) some calls to lock_page_cgroup() did not
> disable softirq, then a deadlock is possible because the softirq may
> interrupt the holder of the page cgroup spinlock and the softirq routine
> that also wants the spinlock would spin forever.
>
> Is there a preference between local_bh_disable() and local_irq_save()?
> Currently the page uses local_irq_save(). =A0However I think it could wor=
k
> by local_bh_disable(), which might have less system impact.

If many users need to update page stat in interrupt handler in future,
local_irq_save would be good candidate. otherwise, local_bh_disable doesn't
affect the system as you said. We could add the comment following as.

/*
 * NOTE :
 * If some user want to update page stat in interrupt handler,
 * We should consider local_irq_save instead of local_bh_disable.
 */

>
>> how do you expect that how many users need irq lock to update page state=
?
>> If they don't need to disalbe irq?
>
> Are you asking how many cases need to disable irq to update page state?
> Because there exists some code (writeback memcg counter update) that
> lock the spinlock in softirq, then it must not be allowed to interrupt
> any holders of the spinlock. =A0Therefore any code that locked the
> page_cgroup spinlock must disable interrupts (or softirq) to prevent
> being preempted by a softirq that will attempt to lock the same
> spinlock.
>
>> We can pass some argument which present to need irq lock or not.
>> But it seems to make code very ugly.
>
> This would be ugly and I do not think it would avoid the deadlock
> because the softirq for the writeback may occur for a particular page at
> any time. =A0Anyone who might be interrupted by this softirq must either:
> a) not hold the page_cgroup spinlock
> or
> b) disable interrupts (or softirq) to avoid being preempted by code that
> =A0 may want the spinlock.
>
>> 2. So could you solve the problem in your design?
>> I mean you could update page state out of softirq?
>> (I didn't look at the your patches all. Sorry if I am missing something)
>
> The writeback statistics are normally updated for non-memcg in
> test_clear_page_writeback(). =A0Here is an example call stack (innermost
> last):
> =A0 =A0 =A0 =A0system_call_fastpath+0x16/0x1b
> =A0 =A0 =A0 =A0sys_exit_group+0x17/0x1b
> =A0 =A0 =A0 =A0do_group_exit+0x7d/0xa8
> =A0 =A0 =A0 =A0do_exit+0x1fb/0x705
> =A0 =A0 =A0 =A0exit_mm+0x129/0x136
> =A0 =A0 =A0 =A0mmput+0x48/0xb9
> =A0 =A0 =A0 =A0exit_mmap+0x96/0xe9
> =A0 =A0 =A0 =A0unmap_vmas+0x52e/0x788
> =A0 =A0 =A0 =A0page_remove_rmap+0x69/0x6d
> =A0 =A0 =A0 =A0mem_cgroup_update_page_stat+0x191/0x1af
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0<INTERRUPT>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0call_function_single_interrupt+0x13/0x20
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0smp_call_function_single_interrupt+0x25/0x=
27
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0irq_exit+0x4a/0x8c
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0do_softirq+0x3d/0x85
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0call_softirq+0x1c/0x3e
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__do_softirq+0xed/0x1e3
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_done_softirq+0x72/0x82
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0scsi_softirq_done+0x10a/0x113
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0scsi_finish_command+0xe8/0xf1
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0scsi_io_completion+0x1b0/0x42c
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_end_request+0x10/0x12
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_end_bidi_request+0x1f/0x5d
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_update_bidi_request+0x20/0x6f
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blk_update_request+0x1a1/0x360
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0req_bio_endio+0x96/0xb6
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0bio_endio+0x31/0x33
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mpage_end_io_write+0x66/0x7d
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0end_page_writeback+0x29/0x43
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0test_clear_page_writeback+0xb6/0xef
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mem_cgroup_update_page_stat+0xb2/0x1af
>
> Given that test_clear_page_writeback() is where non-memcg stats are
> updated for non-memcg, it seems like the most natural place to update
> memcg writeback stats. =A0Theoretically we could introduce some sort of
> work queue of pages that need writeback stat updates.
> test_clear_page_writeback() would enqueue to-do work items to this list.
> A worker thread (not running in softirq) would process this list and
> apply the changes to the mem_cgroup. =A0This seems very complex and will
> likely introduce a longer code path that will introduce even more
> overhead.

Agreed.

>
>> 3. Normally, we have updated page state without disable irq.
>> Why does memcg need it?
>
> Non-memcg writeback stats updates do disable interrupts by using
> spin_lock_irqsave(). =A0See upstream test_clear_page_writeback() for
> an example.
>
> Memcg must determine the cgroup associated with the page to adjust that
> cgroup's page counter. =A0Example: when a page writeback completes, the
> associated mem_cgroup writeback page counter is decremented. =A0In memcg
> this is complicated by the ability to migrate pages between cgroups.
> When a page migration is in progress then locking is needed to ensure
> that page's associated cgroup does not change until after the statistic
> update is complete. =A0This migration race is already efficiently solved
> in mmotm efficiently with mem_cgroup_stealed(), which safely avoids many
> unneeded locking calls. =A0This proposed patch integrates with the
> mem_cgroup_stealed() solution.
>
>> I hope we don't add irq disable region as far as possbile.
>
> I also do not like this, but do not see a better way. =A0We could use
> local_bh_disable(), but I think it needs to be uniformly applied by
> adding it to lock_page_cgroup().


First of all, we could add your patch as it is and I don't expect any
regression report about interrupt latency.
That's because many embedded guys doesn't use mmotm and have a
tendency to not report regression of VM.
Even they don't use memcg. Hmm...

I pass the decision to MAINTAINER Kame and Balbir.
Thanks for the detail explanation.

>
> --
> Greg
>



--=20
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
