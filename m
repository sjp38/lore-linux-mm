Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 157D7440313
	for <linux-mm@kvack.org>; Mon,  5 Oct 2015 02:12:30 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so26432847pad.1
        for <linux-mm@kvack.org>; Sun, 04 Oct 2015 23:12:29 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id he4si37752187pbc.109.2015.10.04.23.12.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 04 Oct 2015 23:12:29 -0700 (PDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout1.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NVQ01NASH8Q1F60@mailout1.samsung.com> for linux-mm@kvack.org;
 Mon, 05 Oct 2015 15:12:26 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
 <20151001133843.GG24077@dhcp22.suse.cz>
In-reply-to: <20151001133843.GG24077@dhcp22.suse.cz>
Subject: RE: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
Date: Mon, 05 Oct 2015 11:42:49 +0530
Message-id: <010401d0ff34$f48e8eb0$ddabac10$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

Hi,

> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@kernel.org]
> Sent: Thursday, October 01, 2015 7:09 PM
> To: Pintu Kumar
> Cc: akpm@linux-foundation.org; minchan@kernel.org; dave@stgolabs.net;
> koct9i@gmail.com; rientjes@google.com; hannes@cmpxchg.org; penguin-
> kernel@i-love.sakura.ne.jp; bywxiaobai@163.com; mgorman@suse.de;
> vbabka@suse.cz; js1304@gmail.com; kirill.shutemov@linux.intel.com;
> alexander.h.duyck@redhat.com; sasha.levin@oracle.com; cl@linux.com;
> fengguang.wu@intel.com; linux-kernel@vger.kernel.org; linux-mm@kvack.org;
> cpgs@samsung.com; pintu_agarwal@yahoo.com; pintu.ping@gmail.com;
> vishnu.ps@samsung.com; rohit.kr@samsung.com; c.rajkumar@samsung.com;
> sreenathd@samsung.com
> Subject: Re: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
> 
> On Thu 01-10-15 16:18:43, Pintu Kumar wrote:
> > This patch maintains number of oom calls and number of oom kill count
> > in /proc/vmstat.
> > It is helpful during sluggish, aging or long duration tests.
> > Currently if the OOM happens, it can be only seen in kernel ring buffer.
> > But during long duration tests, all the dmesg and /var/log/messages*
> > could be overwritten.
> > So, just like other counters, the oom can also be maintained in
> > /proc/vmstat.
> > It can be also seen if all logs are disabled in kernel.
> >
> > A snapshot of the result of over night test is shown below:
> > $ cat /proc/vmstat
> > oom_stall 610
> > oom_kill_count 1763
> >
> > Here, oom_stall indicates that there are 610 times, kernel entered
> > into OOM cases. However, there were around 1763 oom killing happens.
> 
> This alone looks quite suspicious. Unless you have tasks which share the
address
> space without being in the same thread group this shouldn't happen in such a
> large scale.

Yes, this accounts for out_of_memory even from memory cgroups.
Please check few snapshots of dmesg outputs captured during over-night tests.
........
[49479.078033]  [2:      xxxxxxxx:20874] Memory cgroup out of memory: Kill
process 20880 (xxxxxxx) score 112 or sacrifice child
[49480.910430]  [2:      xxxxxxxx:20882] Memory cgroup out of memory: Kill
process 20888 (xxxxxxxx) score 112 or sacrifice child
[49567.046203]  [0:        yyyyyyy:  548] Out of memory: Kill process 20458
(zzzzzzzzzz) score 102 or sacrifice child
[49567.346588]  [0:        yyyyyyy:  548] Out of memory: Kill process 21102
(zzzzzzzzzz) score 104 or sacrifice child
.........
The _out of memory_ count in dmesg dump output exactly matches the number in
/proc/vmstat -> oom_kill_count

> </me looks into the patch>
> And indeed the patch is incorrect. You are only counting OOMs from the page
> allocator slow path. You are missing all the OOM invocations from the page
fault
> path.

Sorry, I am not sure what exactly you mean. Please point me out if I am missing
some places.
Actually, I tried to add it at generic place that is; oom_kill_process, which is
called by out_of_memory(...).
Are you talking about: pagefault_out_of_memory(...) ?
But, this is already calling: out_of_memory. No?

> The placement inside __alloc_pages_may_oom looks quite arbitrary as well. You
> are not counting events where we are OOM but somebody is holding the
> oom_mutex but you do count last attempt before going really OOM. Then we
> have cases which do not invoke OOM killer which are counted into oom_stall as
> well. I am not sure whether they should because I am not quite sure about the
> semantic of the counter in the first place.

Ok. Yes, it can be added right after it enters into __alloc_pages_may_oom.
I will make the changes.
Actually, I knowingly skipped the oom_lock case, because in our 3.10 kernel, we
had note_oom_kill(..) 
Added right after this check.
So, I also added it exactly at the same place.
Ok, I can make the necessary changes, if the oom_lock case also matters. 

> What is it supposed to tell us? How many times the system had to go into
> emergency OOM steps? How many times the direct reclaim didn't make any
> progress so we can consider the system OOM?
> 
Yes, exactly, oom_stall can tell, how many times OOM is invoked in the system.
Yes, it can also tell how many times direct_reclaim fails completely.
Currently, we don't have any counter for direct_reclaim success/fail.
Also, oom_kill_process will not be invoked for higher orders
(PAGE_ALLOC_COSTLY_ORDER).
But, it will enter OOM and results into straight page allocation failure.

> oom_kill_count has a slightly misleading names because it suggests how many
> times oom_kill was called but in fact it counts the oom victims.
> Not sure whether this information is so much useful but the semantic is clear
at
> least.
> 
Ok, agree about the semantic of the name: oom_kill_count.
If possible please suggest a better name.
How about the following names?
oom_victim_count ?
oom_nr_killed ?
oom_nr_victim ?

> > The OOM is bad for the any system. So, this counter can help the
> > developer in tuning the memory requirement at least during initial bringup.
> >
> > Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
> > ---
> >  include/linux/vm_event_item.h |    2 ++
> >  mm/oom_kill.c                 |    2 ++
> >  mm/page_alloc.c               |    2 +-
> >  mm/vmstat.c                   |    2 ++
> >  4 files changed, 7 insertions(+), 1 deletion(-)
> >
> > diff --git a/include/linux/vm_event_item.h
> > b/include/linux/vm_event_item.h index 2b1cef8..ade0851 100644
> > --- a/include/linux/vm_event_item.h
> > +++ b/include/linux/vm_event_item.h
> > @@ -57,6 +57,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN,
> > PSWPOUT,  #ifdef CONFIG_HUGETLB_PAGE
> >  		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,  #endif
> > +		OOM_STALL,
> > +		OOM_KILL_COUNT,
> >  		UNEVICTABLE_PGCULLED,	/* culled to noreclaim list */
> >  		UNEVICTABLE_PGSCANNED,	/* scanned for reclaimability */
> >  		UNEVICTABLE_PGRESCUED,	/* rescued from noreclaim list */
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c index 03b612b..e79caed
> > 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -570,6 +570,7 @@ void oom_kill_process(struct oom_control *oc, struct
> task_struct *p,
> >  	 * space under its control.
> >  	 */
> >  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> > +	count_vm_event(OOM_KILL_COUNT);
> >  	mark_oom_victim(victim);
> >  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-
> rss:%lukB\n",
> >  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
> @@
> > -600,6 +601,7 @@ void oom_kill_process(struct oom_control *oc, struct
> task_struct *p,
> >  				task_pid_nr(p), p->comm);
> >  			task_unlock(p);
> >  			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
> > +			count_vm_event(OOM_KILL_COUNT);
> >  		}
> >  	rcu_read_unlock();
> >
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c index 9bcfd70..1d82210
> > 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2761,7 +2761,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned
> int order,
> >  		schedule_timeout_uninterruptible(1);
> >  		return NULL;
> >  	}
> > -
> > +	count_vm_event(OOM_STALL);
> >  	/*
> >  	 * Go through the zonelist yet one more time, keep very high watermark
> >  	 * here, this is only to catch a parallel oom killing, we must fail
> > if diff --git a/mm/vmstat.c b/mm/vmstat.c index 1fd0886..f054265
> > 100644
> > --- a/mm/vmstat.c
> > +++ b/mm/vmstat.c
> > @@ -808,6 +808,8 @@ const char * const vmstat_text[] = {
> >  	"htlb_buddy_alloc_success",
> >  	"htlb_buddy_alloc_fail",
> >  #endif
> > +	"oom_stall",
> > +	"oom_kill_count",
> >  	"unevictable_pgs_culled",
> >  	"unevictable_pgs_scanned",
> >  	"unevictable_pgs_rescued",
> > --
> > 1.7.9.5
> 
> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
