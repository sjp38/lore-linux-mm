Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id 207634403E0
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 05:30:28 -0500 (EST)
Received: by mail-lf0-f72.google.com with SMTP id a132so616452lfa.17
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 02:30:28 -0800 (PST)
Received: from SELDSEGREL01.sonyericsson.com (seldsegrel01.sonyericsson.com. [37.139.156.29])
        by mx.google.com with ESMTPS id i72si1605225lfk.589.2017.11.08.02.30.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Nov 2017 02:30:26 -0800 (PST)
Subject: Re: [PATCH] mm: don't warn about allocations which stall for too long
References: <1509017339-4802-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20171026114100.tfb3xemvumg2a7su@dhcp22.suse.cz>
From: peter enderborg <peter.enderborg@sonymobile.com>
Message-ID: <91bdbdea-3f33-b7c0-8345-d0fa8c7f1cf1@sonymobile.com>
Date: Wed, 8 Nov 2017 11:30:23 +0100
MIME-Version: 1.0
In-Reply-To: <20171026114100.tfb3xemvumg2a7su@dhcp22.suse.cz>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Language: en-GB
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cong Wang <xiyou.wangcong@gmail.com>, Dave Hansen <dave.hansen@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Vlastimil Babka <vbabka@suse.cz>, "yuwang.yuwang" <yuwang.yuwang@alibaba-inc.com>

On 10/26/2017 01:41 PM, Michal Hocko wrote:
> On Thu 26-10-17 20:28:59, Tetsuo Handa wrote:
>> Commit 63f53dea0c9866e9 ("mm: warn about allocations which stall for too
>> long") was a great step for reducing possibility of silent hang up probl=
em
>> caused by memory allocation stalls. But this commit reverts it, for it i=
s
>> possible to trigger OOM lockup and/or soft lockups when many threads
>> concurrently called warn_alloc() (in order to warn about memory allocati=
on
>> stalls) due to current implementation of printk(), and it is difficult t=
o
>> obtain useful information due to limitation of synchronous warning
>> approach.
>>
>> Current printk() implementation flushes all pending logs using the conte=
xt
>> of a thread which called console_unlock(). printk() should be able to fl=
ush
>> all pending logs eventually unless somebody continues appending to print=
k()
>> buffer.
>>
>> Since warn_alloc() started appending to printk() buffer while waiting fo=
r
>> oom_kill_process() to make forward progress when oom_kill_process() is
>> processing pending logs, it became possible for warn_alloc() to force
>> oom_kill_process() loop inside printk(). As a result, warn_alloc()
>> significantly increased possibility of preventing oom_kill_process() fro=
m
>> making forward progress.
>>
>> ---------- Pseudo code start ----------
>> Before warn_alloc() was introduced:
>>
>>   retry:
>>     if (mutex_trylock(&oom_lock)) {
>>       while (atomic_read(&printk_pending_logs) > 0) {
>>         atomic_dec(&printk_pending_logs);
>>         print_one_log();
>>       }
>>       // Send SIGKILL here.
>>       mutex_unlock(&oom_lock)
>>     }
>>     goto retry;
>>
>> After warn_alloc() was introduced:
>>
>>   retry:
>>     if (mutex_trylock(&oom_lock)) {
>>       while (atomic_read(&printk_pending_logs) > 0) {
>>         atomic_dec(&printk_pending_logs);
>>         print_one_log();
>>       }
>>       // Send SIGKILL here.
>>       mutex_unlock(&oom_lock)
>>     } else if (waited_for_10seconds()) {
>>       atomic_inc(&printk_pending_logs);
>>     }
>>     goto retry;
>> ---------- Pseudo code end ----------
>>
>> Although waited_for_10seconds() becomes true once per 10 seconds, unboun=
ded
>> number of threads can call waited_for_10seconds() at the same time. Also=
,
>> since threads doing waited_for_10seconds() keep doing almost busy loop, =
the
>> thread doing print_one_log() can use little CPU resource. Therefore, thi=
s
>> situation can be simplified like
>>
>> ---------- Pseudo code start ----------
>>   retry:
>>     if (mutex_trylock(&oom_lock)) {
>>       while (atomic_read(&printk_pending_logs) > 0) {
>>         atomic_dec(&printk_pending_logs);
>>         print_one_log();
>>       }
>>       // Send SIGKILL here.
>>       mutex_unlock(&oom_lock)
>>     } else {
>>       atomic_inc(&printk_pending_logs);
>>     }
>>     goto retry;
>> ---------- Pseudo code end ----------
>>
>> when printk() is called faster than print_one_log() can process a log.
>>
>> One of possible mitigation would be to introduce a new lock in order to
>> make sure that no other series of printk() (either oom_kill_process() or
>> warn_alloc()) can append to printk() buffer when one series of printk()
>> (either oom_kill_process() or warn_alloc()) is already in progress. Such
>> serialization will also help obtaining kernel messages in readable form.
>>
>> ---------- Pseudo code start ----------
>>   retry:
>>     if (mutex_trylock(&oom_lock)) {
>>       mutex_lock(&oom_printk_lock);
>>       while (atomic_read(&printk_pending_logs) > 0) {
>>         atomic_dec(&printk_pending_logs);
>>         print_one_log();
>>       }
>>       // Send SIGKILL here.
>>       mutex_unlock(&oom_printk_lock);
>>       mutex_unlock(&oom_lock)
>>     } else {
>>       if (mutex_trylock(&oom_printk_lock)) {
>>         atomic_inc(&printk_pending_logs);
>>         mutex_unlock(&oom_printk_lock);
>>       }
>>     }
>>     goto retry;
>> ---------- Pseudo code end ----------
>>
>> But this commit does not go that direction, for we don't want to introdu=
ce
>> a new lock dependency, and we unlikely be able to obtain useful informat=
ion
>> even if we serialized oom_kill_process() and warn_alloc().
>>
>> Synchronous approach is prone to unexpected results (e.g. too late [1], =
too
>> frequent [2], overlooked [3]). As far as I know, warn_alloc() never help=
ed
>> with providing information other than "something is going wrong".
>> I want to consider asynchronous approach which can obtain information
>> during stalls with possibly relevant threads (e.g. the owner of oom_lock
>> and kswapd-like threads) and serve as a trigger for actions (e.g. turn
>> on/off tracepoints, ask libvirt daemon to take a memory dump of stalling
>> KVM guest for diagnostic purpose).
>>
>> This commit temporarily looses ability to report e.g. OOM lockup due to
>> unable to invoke the OOM killer due to !__GFP_FS allocation request.
>> But asynchronous approach will be able to detect such situation and emit
>> warning. Thus, let's remove warn_alloc().
>>
>> [1] https://bugzilla.kernel.org/show_bug.cgi?id=3D192981
>> [2] http://lkml.kernel.org/r/CAM_iQpWuPVGc2ky8M-9yukECtS+zKjiDasNymX7rMc=
BjBFyM_A@mail.gmail.com
>> [3] commit db73ee0d46379922 ("mm, vmscan: do not loop on too_many_isolat=
ed for ever"))
>>
>> Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
>> Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
>> Reported-by: yuwang.yuwang <yuwang.yuwang@alibaba-inc.com>
>> Reported-by: Johannes Weiner <hannes@cmpxchg.org>
>> Cc: Michal Hocko <mhocko@kernel.org>
>> Cc: Vlastimil Babka <vbabka@suse.cz>
>> Cc: Mel Gorman <mgorman@suse.de>
>> Cc: Dave Hansen <dave.hansen@intel.com>
>> Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
>> Cc: Petr Mladek <pmladek@suse.com>
> The changelog is a bit excessive but it points out the real problem is
> that printk is simply not ready for the sync warning which is good to
> document and I hope that this will get addressed in a foreseeable future.
> For the mean time it is simply better to remove the warning rather than
> risk more issues.
>
> Acked-by: Michal Hocko <mhocko@suse.com>
>
>> ---
>>  mm/page_alloc.c | 10 ----------
>>  1 file changed, 10 deletions(-)
>>
>> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>> index 97687b3..a4edfba 100644
>> --- a/mm/page_alloc.c
>> +++ b/mm/page_alloc.c
>> @@ -3856,8 +3856,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>>  	enum compact_result compact_result;
>>  	int compaction_retries;
>>  	int no_progress_loops;
>> -	unsigned long alloc_start =3D jiffies;
>> -	unsigned int stall_timeout =3D 10 * HZ;
>>  	unsigned int cpuset_mems_cookie;
>>  	int reserve_flags;
>> =20
>> @@ -3989,14 +3987,6 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
>>  	if (!can_direct_reclaim)
>>  		goto nopage;
>> =20
>> -	/* Make sure we know about allocations which stall for too long */
>> -	if (time_after(jiffies, alloc_start + stall_timeout)) {
>> -		warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
>> -			"page allocation stalls for %ums, order:%u",
>> -			jiffies_to_msecs(jiffies-alloc_start), order);
>> -		stall_timeout +=3D 10 * HZ;
>> -	}
>> -
>>  	/* Avoid recursion of direct reclaim */
>>  	if (current->flags & PF_MEMALLOC)
>>  		goto nopage;
>> --=20
>> 1.8.3.1

What about the idea to keep the function, but instead of printing only do a=
 trace event.

Subject: [PATCH] Remove printk from time delay warning

Adding a trace event, so we can keep the function
but it need to be runtime enabed.
---
=C2=A0include/trace/events/kmem.h | 30 ++++++++++++++++++++++++++++++
=C2=A0mm/page_alloc.c=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 |=C2=A0 8 +++++---
=C2=A02 files changed, 35 insertions(+), 3 deletions(-)

diff --git a/include/trace/events/kmem.h b/include/trace/events/kmem.h
index 285feea..eb2fdaf 100644
--- a/include/trace/events/kmem.h
+++ b/include/trace/events/kmem.h
@@ -277,6 +277,36 @@ TRACE_EVENT(mm_page_pcpu_drain,
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 __entry->order, __entry->migratetype)
=C2=A0);
=C2=A0
+TRACE_EVENT(mm_page_alloc_warn,
+
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 TP_PROTO(int alloc_order,
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 nodemask_t *nodemask,
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 u64 msdelay,
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 gfp_t gfp_flags),
+
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 TP_ARGS(alloc_order, nodemask, msdela=
y, gfp_flags),
+
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 TP_STRUCT__entry(
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 __field(int, alloc_order)
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 __field(nodemask_t *, nodemask)
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 __field(u64, msdelay)
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 __field(gfp_t, gfp_flags)
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ),
+
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 TP_fast_assign(
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 __entry->alloc_order=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0 =3D alloc_order;
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 __entry->nodemask=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D nodemask;
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 __entry->msdelay=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D=
 msdelay;
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 __entry->gfp_flags=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 =3D gfp_flags;
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 ),
+
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 TP_printk("alloc_order=3D%d nodemask=
=3D%*pbl delay=3D%llu gfp_flags=3D%s",
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 __entry->alloc_order,
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 nodemask_pr_args(__entry->nodemask),
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 __entry->msdelay,
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0 show_gfp_flags(__entry->gfp_flags))
+);
+
=C2=A0TRACE_EVENT(mm_page_alloc_extfrag,
=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 TP_PROTO(struct page *page,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 77e4d3c..cc806a2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4003,9 +4003,11 @@ __alloc_pages_slowpath(gfp_t gfp_mask, unsigned int =
order,
=C2=A0
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 /* Make sure we know about alloc=
ations which stall for too long */
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 if (time_after(jiffies, alloc_st=
art + stall_timeout)) {
-=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 warn_alloc(gfp_mask & ~__GFP_NOWARN, ac->nodemask,
-=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 "page allocati=
on stalls for %ums, order:%u",
-=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 jiffies_to_mse=
cs(jiffies-alloc_start), order);
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 trace_mm_page_alloc_warn(order,
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 ac->nodemask,
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 jiffies_to_msecs(jiffies-alloc_start),
+=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0 gfp_mask);
+
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0 stall_timeout +=3D 10 * HZ;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 }
=C2=A0
--=20
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
