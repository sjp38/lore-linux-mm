Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9155A6B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 12:03:22 -0500 (EST)
Received: by mail-yb0-f198.google.com with SMTP id o65so141182585yba.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 09:03:22 -0800 (PST)
Received: from mail-yw0-x241.google.com (mail-yw0-x241.google.com. [2607:f8b0:4002:c05::241])
        by mx.google.com with ESMTPS id t202si1323506ywg.292.2017.02.07.09.03.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 09:03:21 -0800 (PST)
Received: by mail-yw0-x241.google.com with SMTP id q71so9877606ywg.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 09:03:21 -0800 (PST)
Date: Tue, 7 Feb 2017 12:03:19 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207170319.GA6164@htj.duckdns.org>
References: <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
 <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
 <20170207102809.awh22urqmfrav5r6@techsingularity.net>
 <20170207103552.GH5065@dhcp22.suse.cz>
 <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
 <20170207114327.GI5065@dhcp22.suse.cz>
 <20170207123708.GO5065@dhcp22.suse.cz>
 <20170207135846.usfrn7e4znjhmogn@techsingularity.net>
 <20170207141911.GR5065@dhcp22.suse.cz>
 <20170207153459.GV5065@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207153459.GV5065@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

Hello,

Sorry about the delay.

On Tue, Feb 07, 2017 at 04:34:59PM +0100, Michal Hocko wrote:
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index c3358d4f7932..b6411816787a 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2343,7 +2343,16 @@ void drain_local_pages(struct zone *zone)
>  
>  static void drain_local_pages_wq(struct work_struct *work)
>  {
> +	/*
> +	 * drain_all_pages doesn't use proper cpu hotplug protection so
> +	 * we can race with cpu offline when the WQ can move this from
> +	 * a cpu pinned worker to an unbound one. We can operate on a different
> +	 * cpu which is allright but we also have to make sure to not move to
> +	 * a different one.
> +	 */
> +	preempt_disable();
>  	drain_local_pages(NULL);
> +	preempt_enable();
>  }
>  
>  /*
> @@ -2379,12 +2388,6 @@ void drain_all_pages(struct zone *zone)
>  	}
>  
>  	/*
> -	 * As this can be called from reclaim context, do not reenter reclaim.
> -	 * An allocation failure can be handled, it's simply slower
> -	 */
> -	get_online_cpus();
> -
> -	/*
>  	 * We don't care about racing with CPU hotplug event
>  	 * as offline notification will cause the notified
>  	 * cpu to drain that CPU pcps and on_each_cpu_mask
> @@ -2423,7 +2426,6 @@ void drain_all_pages(struct zone *zone)
>  	for_each_cpu(cpu, &cpus_with_pcps)
>  		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
>  
> -	put_online_cpus();
>  	mutex_unlock(&pcpu_drain_mutex);

I think this would work; however, a more canonical way would be
something along the line of...

  drain_all_pages()
  {
	  ...
	  spin_lock();
	  for_each_possible_cpu() {
		  if (this cpu should get drained) {
			  queue_work_on(this cpu's work);
		  }
	  }
	  spin_unlock();
	  ...
  }

  offline_hook()
  {
	  spin_lock();
	  this cpu should get drained = false;
	  spin_unlock();
	  queue_work_on(this cpu's work);
	  flush_work(this cpu's work);
  }

I think what workqueue should do is automatically flush in-flight CPU
work items on CPU offline and erroring out on queue_work_on() on
offline CPUs.  And we now actually can do that because we have lifted
the guarantee that queue_work() is local CPU affine some releases ago.
I'll look into it soonish.

For the time being, either approach should be fine.  The more
canonical one might be a bit less surprising but the
preempt_disable/enable() change is short and sweet and completely fine
for the case at hand.

Please feel free to add

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
