Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id BCDAA6B02A7
	for <linux-mm@kvack.org>; Thu,  1 Oct 2015 09:38:45 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so29033233wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 06:38:45 -0700 (PDT)
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com. [209.85.212.176])
        by mx.google.com with ESMTPS id ev6si118288wjd.163.2015.10.01.06.38.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Oct 2015 06:38:44 -0700 (PDT)
Received: by wicge5 with SMTP id ge5so30508413wic.0
        for <linux-mm@kvack.org>; Thu, 01 Oct 2015 06:38:44 -0700 (PDT)
Date: Thu, 1 Oct 2015 15:38:43 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
Message-ID: <20151001133843.GG24077@dhcp22.suse.cz>
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pintu Kumar <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

On Thu 01-10-15 16:18:43, Pintu Kumar wrote:
> This patch maintains number of oom calls and number of oom kill
> count in /proc/vmstat.
> It is helpful during sluggish, aging or long duration tests.
> Currently if the OOM happens, it can be only seen in kernel ring buffer.
> But during long duration tests, all the dmesg and /var/log/messages* could
> be overwritten.
> So, just like other counters, the oom can also be maintained in
> /proc/vmstat.
> It can be also seen if all logs are disabled in kernel.
> 
> A snapshot of the result of over night test is shown below:
> $ cat /proc/vmstat
> oom_stall 610
> oom_kill_count 1763
> 
> Here, oom_stall indicates that there are 610 times, kernel entered into OOM
> cases. However, there were around 1763 oom killing happens.

This alone looks quite suspicious. Unless you have tasks which share the
address space without being in the same thread group this shouldn't
happen in such a large scale.
</me looks into the patch>
And indeed the patch is incorrect. You are only counting OOMs from the
page allocator slow path. You are missing all the OOM invocations from
the page fault path.
The placement inside __alloc_pages_may_oom looks quite arbitrary as
well. You are not counting events where we are OOM but somebody is
holding the oom_mutex but you do count last attempt before going really
OOM. Then we have cases which do not invoke OOM killer which are counted
into oom_stall as well. I am not sure whether they should because I am
not quite sure about the semantic of the counter in the first place.
What is it supposed to tell us? How many times the system had to go into
emergency OOM steps? How many times the direct reclaim didn't make any
progress so we can consider the system OOM?

oom_kill_count has a slightly misleading names because it suggests how
many times oom_kill was called but in fact it counts the oom victims.
Not sure whether this information is so much useful but the semantic is
clear at least.

> The OOM is bad for the any system. So, this counter can help the developer
> in tuning the memory requirement at least during initial bringup.
> 
> Signed-off-by: Pintu Kumar <pintu.k@samsung.com>
> ---
>  include/linux/vm_event_item.h |    2 ++
>  mm/oom_kill.c                 |    2 ++
>  mm/page_alloc.c               |    2 +-
>  mm/vmstat.c                   |    2 ++
>  4 files changed, 7 insertions(+), 1 deletion(-)
> 
> diff --git a/include/linux/vm_event_item.h b/include/linux/vm_event_item.h
> index 2b1cef8..ade0851 100644
> --- a/include/linux/vm_event_item.h
> +++ b/include/linux/vm_event_item.h
> @@ -57,6 +57,8 @@ enum vm_event_item { PGPGIN, PGPGOUT, PSWPIN, PSWPOUT,
>  #ifdef CONFIG_HUGETLB_PAGE
>  		HTLB_BUDDY_PGALLOC, HTLB_BUDDY_PGALLOC_FAIL,
>  #endif
> +		OOM_STALL,
> +		OOM_KILL_COUNT,
>  		UNEVICTABLE_PGCULLED,	/* culled to noreclaim list */
>  		UNEVICTABLE_PGSCANNED,	/* scanned for reclaimability */
>  		UNEVICTABLE_PGRESCUED,	/* rescued from noreclaim list */
> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 03b612b..e79caed 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -570,6 +570,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  	 * space under its control.
>  	 */
>  	do_send_sig_info(SIGKILL, SEND_SIG_FORCED, victim, true);
> +	count_vm_event(OOM_KILL_COUNT);
>  	mark_oom_victim(victim);
>  	pr_err("Killed process %d (%s) total-vm:%lukB, anon-rss:%lukB, file-rss:%lukB\n",
>  		task_pid_nr(victim), victim->comm, K(victim->mm->total_vm),
> @@ -600,6 +601,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
>  				task_pid_nr(p), p->comm);
>  			task_unlock(p);
>  			do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
> +			count_vm_event(OOM_KILL_COUNT);
>  		}
>  	rcu_read_unlock();
>  
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 9bcfd70..1d82210 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2761,7 +2761,7 @@ __alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
>  		schedule_timeout_uninterruptible(1);
>  		return NULL;
>  	}
> -
> +	count_vm_event(OOM_STALL);
>  	/*
>  	 * Go through the zonelist yet one more time, keep very high watermark
>  	 * here, this is only to catch a parallel oom killing, we must fail if
> diff --git a/mm/vmstat.c b/mm/vmstat.c
> index 1fd0886..f054265 100644
> --- a/mm/vmstat.c
> +++ b/mm/vmstat.c
> @@ -808,6 +808,8 @@ const char * const vmstat_text[] = {
>  	"htlb_buddy_alloc_success",
>  	"htlb_buddy_alloc_fail",
>  #endif
> +	"oom_stall",
> +	"oom_kill_count",
>  	"unevictable_pgs_culled",
>  	"unevictable_pgs_scanned",
>  	"unevictable_pgs_rescued",
> -- 
> 1.7.9.5

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
