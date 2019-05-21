Return-Path: <SRS0=IGNm=TV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EAB10C04AAF
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:46:42 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 98FEF20856
	for <linux-mm@archiver.kernel.org>; Tue, 21 May 2019 10:46:42 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 98FEF20856
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3266B6B0003; Tue, 21 May 2019 06:46:42 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D63A6B0005; Tue, 21 May 2019 06:46:42 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C6816B0006; Tue, 21 May 2019 06:46:42 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id C04A66B0003
	for <linux-mm@kvack.org>; Tue, 21 May 2019 06:46:41 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n52so30176838edd.2
        for <linux-mm@kvack.org>; Tue, 21 May 2019 03:46:41 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:date:from:to
         :cc:subject:message-id:references:mime-version:content-disposition
         :content-transfer-encoding:in-reply-to:user-agent;
        bh=E5CMEcj5vfS13AkMYT1wlLpY3YNow37t7mt2E+e89j0=;
        b=OsaSiqStFBIOTp6GdZnYlU9pbSBG19Uy5by5vddGNahIBdXrCeMfZp2kUfLz3oe/nA
         RuC/P50u7obzMkrrZQHXpCywICzP2W9Pcec5sHnFQyZPEtf+yP3bl2c8aFIOmNYXoQ6/
         Uqb2ALRaituERK3kKWglVsoA+hYlEGhfc4HRtUnE5b/TUyjghZrn7ARoS5qzh0QdS+ha
         TgUS/UxJkDnGc0tDywdx6gv1VcSzStjGNGuXgUx5OHhjuiRagrZTER81PDN+z/dd1QTQ
         2CiU5DdZ1siH2/VRgzwF++LU5YXHCcyfan102HzlgDsVcV/dZ8CO4j5/kQUAsMhkvdpq
         iPPQ==
X-Original-Authentication-Results: mx.google.com;       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Gm-Message-State: APjAAAVMbM0o8nokkpV329eMX9FYal88f1MRJlk/r2Wi/liCq4blBzJD
	sR7FOncR0AFmq1q0ijW+wkcfOg/6a+QTp/iCveUzFvato31hQ7yXNXZxw/FMvR5rMfpx5lO31h/
	ucP+e/nhdUF0yfd/RIP2m7eGs2HCq2E3/Zsc65azSfSuDs9vfHoKbdF6OLcuz7CU=
X-Received: by 2002:a50:9738:: with SMTP id c53mr80380724edb.156.1558435601306;
        Tue, 21 May 2019 03:46:41 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxJ4zQqqXhGLzYF2wcvp4BjYP2ORJErcyK4TGEhSM9A/J6bUjZu5iqRSUrw8wuVDpyvMnOa
X-Received: by 2002:a50:9738:: with SMTP id c53mr80380642edb.156.1558435600246;
        Tue, 21 May 2019 03:46:40 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558435600; cv=none;
        d=google.com; s=arc-20160816;
        b=xKuMVWzi23eradk3AGMY5N0urzRFCu9vbATcDcvVH6Cfjlcy9nw8jmPiY0Sf5+TDW8
         dM+sqlUfDsdW20XYls8yRfIylbtprNqWj6aYcxoG8sFwd/Sl+knkeCM4KnNgvSTKO6uF
         XDBJOOWSuQbQXYOvfhhA1/js2AHcikw9OoTLeSLoBZXDAquPKqNCjOc9ERRFv2A6fYUs
         ijmADI7w/WFx14zZ9RRhTB4WGPORab5678X9uyljb33eOEMsn4tH+4RVFdl7/oZrbpd6
         nj7fnbfewNs3gVxKh50CZZW8PuJYbEgRldRJ4Va45ojFRop5p6TWaxuj/Efxuf3U2RZ2
         U5Tw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=user-agent:in-reply-to:content-transfer-encoding
         :content-disposition:mime-version:references:message-id:subject:cc
         :to:from:date;
        bh=E5CMEcj5vfS13AkMYT1wlLpY3YNow37t7mt2E+e89j0=;
        b=JtKv+fddBdrJaz0d00nst4Jh7oy9LXpZyCDavivmsGfn9Fmy/ebgksxds2uUOdWUIL
         6eXHL6Eodmt1dOdGktBKGL9GWvqfTLiP8ET7M5mkz18rWCLWv2R0Hmd7ltowbtU4uXG/
         Pro8hXtBSnDiuur3TAGXplpa6JGsO5PsBInoR9GIbwR/ByZNZoYjgtJeHxo2sCIIiqtI
         QhMlqaMvT3FW/PtbJjhlazTt8Ae8wEGnUBQpGkoVnNRgkx16VeSmroB2j1M8o1z9IfyG
         m01SIb08vZUusP29AUwnzdGzhB4U26dh09J35SPXTpxnOdgAcDKOh7jxXt5BAofAkq0w
         bfNA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d21si4025849edb.358.2019.05.21.03.46.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 May 2019 03:46:40 -0700 (PDT)
Received-SPF: softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) client-ip=195.135.220.15;
Authentication-Results: mx.google.com;
       spf=softfail (google.com: domain of transitioning mhocko@kernel.org does not designate 195.135.220.15 as permitted sender) smtp.mailfrom=mhocko@kernel.org;
       dmarc=fail (p=NONE sp=NONE dis=NONE) header.from=kernel.org
X-Virus-Scanned: by amavisd-new at test-mx.suse.de
Received: from relay2.suse.de (unknown [195.135.220.254])
	by mx1.suse.de (Postfix) with ESMTP id 4AB4BAF1C;
	Tue, 21 May 2019 10:46:39 +0000 (UTC)
Date: Tue, 21 May 2019 12:46:38 +0200
From: Michal Hocko <mhocko@kernel.org>
To: Daniel Vetter <daniel.vetter@ffwll.ch>
Cc: DRI Development <dri-devel@lists.freedesktop.org>,
	Intel Graphics Development <intel-gfx@lists.freedesktop.org>,
	LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Rientjes <rientjes@google.com>,
	Christian =?iso-8859-1?Q?K=F6nig?= <christian.koenig@amd.com>,
	=?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Wei Wang <wvw@google.com>,
	Andy Shevchenko <andriy.shevchenko@linux.intel.com>,
	Thomas Gleixner <tglx@linutronix.de>, Jann Horn <jannh@google.com>,
	Feng Tang <feng.tang@intel.com>, Kees Cook <keescook@chromium.org>,
	Randy Dunlap <rdunlap@infradead.org>,
	Daniel Vetter <daniel.vetter@intel.com>
Subject: Re: [PATCH] kernel.h: Add non_block_start/end()
Message-ID: <20190521104638.GO32329@dhcp22.suse.cz>
References: <20190521100611.10089-1-daniel.vetter@ffwll.ch>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190521100611.10089-1-daniel.vetter@ffwll.ch>
User-Agent: Mutt/1.10.1 (2018-07-13)
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue 21-05-19 12:06:11, Daniel Vetter wrote:
> In some special cases we must not block, but there's not a
> spinlock, preempt-off, irqs-off or similar critical section already
> that arms the might_sleep() debug checks. Add a non_block_start/end()
> pair to annotate these.
> 
> This will be used in the oom paths of mmu-notifiers, where blocking is
> not allowed to make sure there's forward progress. Quoting Michal:
> 
> "The notifier is called from quite a restricted context - oom_reaper -
> which shouldn't depend on any locks or sleepable conditionals. The code
> should be swift as well but we mostly do care about it to make a forward
> progress. Checking for sleepable context is the best thing we could come
> up with that would describe these demands at least partially."
> 
> Peter also asked whether we want to catch spinlocks on top, but Michal
> said those are less of a problem because spinlocks can't have an
> indirect dependency upon the page allocator and hence close the loop
> with the oom reaper.
> 
> Suggested by Michal Hocko.
> 
> v2:
> - Improve commit message (Michal)
> - Also check in schedule, not just might_sleep (Peter)
> 
> v3: It works better when I actually squash in the fixup I had lying
> around :-/
> 
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Ingo Molnar <mingo@redhat.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: David Rientjes <rientjes@google.com>
> Cc: "Christian König" <christian.koenig@amd.com>
> Cc: Daniel Vetter <daniel.vetter@ffwll.ch>
> Cc: "Jérôme Glisse" <jglisse@redhat.com>
> Cc: linux-mm@kvack.org
> Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
> Cc: Wei Wang <wvw@google.com>
> Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> Cc: Thomas Gleixner <tglx@linutronix.de>
> Cc: Jann Horn <jannh@google.com>
> Cc: Feng Tang <feng.tang@intel.com>
> Cc: Kees Cook <keescook@chromium.org>
> Cc: Randy Dunlap <rdunlap@infradead.org>
> Cc: linux-kernel@vger.kernel.org
> Acked-by: Christian König <christian.koenig@amd.com> (v1)
> Signed-off-by: Daniel Vetter <daniel.vetter@intel.com>

I like this in general. The implementation looks reasonable to me but I
didn't check deeply enough to give my R-by or A-by.

> ---
>  include/linux/kernel.h | 10 +++++++++-
>  include/linux/sched.h  |  4 ++++
>  kernel/sched/core.c    | 19 ++++++++++++++-----
>  3 files changed, 27 insertions(+), 6 deletions(-)
> 
> diff --git a/include/linux/kernel.h b/include/linux/kernel.h
> index 74b1ee9027f5..b5f2c2ff0eab 100644
> --- a/include/linux/kernel.h
> +++ b/include/linux/kernel.h
> @@ -214,7 +214,9 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
>   * might_sleep - annotation for functions that can sleep
>   *
>   * this macro will print a stack trace if it is executed in an atomic
> - * context (spinlock, irq-handler, ...).
> + * context (spinlock, irq-handler, ...). Additional sections where blocking is
> + * not allowed can be annotated with non_block_start() and non_block_end()
> + * pairs.
>   *
>   * This is a useful debugging help to be able to catch problems early and not
>   * be bitten later when the calling function happens to sleep when it is not
> @@ -230,6 +232,10 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
>  # define cant_sleep() \
>  	do { __cant_sleep(__FILE__, __LINE__, 0); } while (0)
>  # define sched_annotate_sleep()	(current->task_state_change = 0)
> +# define non_block_start() \
> +	do { current->non_block_count++; } while (0)
> +# define non_block_end() \
> +	do { WARN_ON(current->non_block_count-- == 0); } while (0)
>  #else
>    static inline void ___might_sleep(const char *file, int line,
>  				   int preempt_offset) { }
> @@ -238,6 +244,8 @@ extern void __cant_sleep(const char *file, int line, int preempt_offset);
>  # define might_sleep() do { might_resched(); } while (0)
>  # define cant_sleep() do { } while (0)
>  # define sched_annotate_sleep() do { } while (0)
> +# define non_block_start() do { } while (0)
> +# define non_block_end() do { } while (0)
>  #endif
>  
>  #define might_sleep_if(cond) do { if (cond) might_sleep(); } while (0)
> diff --git a/include/linux/sched.h b/include/linux/sched.h
> index 11837410690f..7f5b293e72df 100644
> --- a/include/linux/sched.h
> +++ b/include/linux/sched.h
> @@ -908,6 +908,10 @@ struct task_struct {
>  	struct mutex_waiter		*blocked_on;
>  #endif
>  
> +#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
> +	int				non_block_count;
> +#endif
> +
>  #ifdef CONFIG_TRACE_IRQFLAGS
>  	unsigned int			irq_events;
>  	unsigned long			hardirq_enable_ip;
> diff --git a/kernel/sched/core.c b/kernel/sched/core.c
> index 102dfcf0a29a..ed7755a28465 100644
> --- a/kernel/sched/core.c
> +++ b/kernel/sched/core.c
> @@ -3264,13 +3264,22 @@ static noinline void __schedule_bug(struct task_struct *prev)
>  /*
>   * Various schedule()-time debugging checks and statistics:
>   */
> -static inline void schedule_debug(struct task_struct *prev)
> +static inline void schedule_debug(struct task_struct *prev, bool preempt)
>  {
>  #ifdef CONFIG_SCHED_STACK_END_CHECK
>  	if (task_stack_end_corrupted(prev))
>  		panic("corrupted stack end detected inside scheduler\n");
>  #endif
>  
> +#ifdef CONFIG_DEBUG_ATOMIC_SLEEP
> +	if (!preempt && prev->state && prev->non_block_count) {
> +		printk(KERN_ERR "BUG: scheduling in a non-blocking section: %s/%d/%i\n",
> +			prev->comm, prev->pid, prev->non_block_count);
> +		dump_stack();
> +		add_taint(TAINT_WARN, LOCKDEP_STILL_OK);
> +	}
> +#endif
> +
>  	if (unlikely(in_atomic_preempt_off())) {
>  		__schedule_bug(prev);
>  		preempt_count_set(PREEMPT_DISABLED);
> @@ -3377,7 +3386,7 @@ static void __sched notrace __schedule(bool preempt)
>  	rq = cpu_rq(cpu);
>  	prev = rq->curr;
>  
> -	schedule_debug(prev);
> +	schedule_debug(prev, preempt);
>  
>  	if (sched_feat(HRTICK))
>  		hrtick_clear(rq);
> @@ -6102,7 +6111,7 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
>  	rcu_sleep_check();
>  
>  	if ((preempt_count_equals(preempt_offset) && !irqs_disabled() &&
> -	     !is_idle_task(current)) ||
> +	     !is_idle_task(current) && !current->non_block_count) ||
>  	    system_state == SYSTEM_BOOTING || system_state > SYSTEM_RUNNING ||
>  	    oops_in_progress)
>  		return;
> @@ -6118,8 +6127,8 @@ void ___might_sleep(const char *file, int line, int preempt_offset)
>  		"BUG: sleeping function called from invalid context at %s:%d\n",
>  			file, line);
>  	printk(KERN_ERR
> -		"in_atomic(): %d, irqs_disabled(): %d, pid: %d, name: %s\n",
> -			in_atomic(), irqs_disabled(),
> +		"in_atomic(): %d, irqs_disabled(): %d, non_block: %d, pid: %d, name: %s\n",
> +			in_atomic(), irqs_disabled(), current->non_block_count,
>  			current->pid, current->comm);
>  
>  	if (task_stack_end_corrupted(current))
> -- 
> 2.20.1
> 

-- 
Michal Hocko
SUSE Labs

