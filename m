Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id DDEBE6B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 19:46:24 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id w1-v6so3113849plq.8
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 16:46:24 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b184-v6si7036940pfa.167.2018.07.05.16.46.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jul 2018 16:46:23 -0700 (PDT)
Date: Thu, 5 Jul 2018 16:46:21 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch v3] mm, oom: fix unnecessary killing of additional
 processes
Message-Id: <20180705164621.0a4fe6ab3af27a1d387eecc9@linux-foundation.org>
In-Reply-To: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
References: <alpine.DEB.2.21.1806211434420.51095@chino.kir.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: kbuild test robot <fengguang.wu@intel.com>, Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 21 Jun 2018 14:35:20 -0700 (PDT) David Rientjes <rientjes@google.com> wrote:

> The oom reaper ensures forward progress by setting MMF_OOM_SKIP itself if
> it cannot reap an mm.  This can happen for a variety of reasons,
> including:
> 
>  - the inability to grab mm->mmap_sem in a sufficient amount of time,
> 
>  - when the mm has blockable mmu notifiers that could cause the oom reaper
>    to stall indefinitely,
> 
> but we can also add a third when the oom reaper can "reap" an mm but doing
> so is unlikely to free any amount of memory:
> 
>  - when the mm's memory is mostly mlocked.

Michal has been talking about making the oom-reaper handle mlocked
memory.  Where are we at with that?

> When all memory is mlocked, the oom reaper will not be able to free any
> substantial amount of memory.  It sets MMF_OOM_SKIP before the victim can
> unmap and free its memory in exit_mmap() and subsequent oom victims are
> chosen unnecessarily.  This is trivial to reproduce if all eligible
> processes on the system have mlocked their memory: the oom killer calls
> panic() even though forward progress can be made.
> 
> This is the same issue where the exit path sets MMF_OOM_SKIP before
> unmapping memory and additional processes can be chosen unnecessarily
> because the oom killer is racing with exit_mmap() and is separate from
> the oom reaper setting MMF_OOM_SKIP prematurely.
> 
> We can't simply defer setting MMF_OOM_SKIP, however, because if there is
> a true oom livelock in progress, it never gets set and no additional
> killing is possible.
> 
> To fix this, this patch introduces a per-mm reaping period, which is
> configurable through the new oom_free_timeout_ms file in debugfs and
> defaults to one second to match the current heuristics.  This support
> requires that the oom reaper's list becomes a proper linked list so that
> other mm's may be reaped while waiting for an mm's timeout to expire.
> 
> This replaces the current timeouts in the oom reaper: (1) when trying to
> grab mm->mmap_sem 10 times in a row with HZ/10 sleeps in between and (2)
> a HZ sleep if there are blockable mmu notifiers.  It extends it with
> timeout to allow an oom victim to reach exit_mmap() before choosing
> additional processes unnecessarily.
> 
> The exit path will now set MMF_OOM_SKIP only after all memory has been
> freed, so additional oom killing is justified, and rely on MMF_UNSTABLE to
> determine when it can race with the oom reaper.
> 
> The oom reaper will now set MMF_OOM_SKIP only after the reap timeout has
> lapsed because it can no longer guarantee forward progress.  Since the
> default oom_free_timeout_ms is one second, the same as current heuristics,
> there should be no functional change with this patch for users who do not
> tune it to be longer other than MMF_OOM_SKIP is set by exit_mmap() after
> free_pgtables(), which is the preferred behavior.
> 
> The reaping timeout can intentionally be set for a substantial amount of
> time, such as 10s, since oom livelock is a very rare occurrence and it's
> better to optimize for preventing additional (unnecessary) oom killing
> than a scenario that is much more unlikely.
> 
> ..
>
> +#ifdef CONFIG_DEBUG_FS
> +static int oom_free_timeout_ms_read(void *data, u64 *val)
> +{
> +	*val = oom_free_timeout_ms;
> +	return 0;
> +}
> +
> +static int oom_free_timeout_ms_write(void *data, u64 val)
> +{
> +	if (val > 60 * 1000)
> +		return -EINVAL;
> +
> +	oom_free_timeout_ms = val;
> +	return 0;
> +}
> +DEFINE_SIMPLE_ATTRIBUTE(oom_free_timeout_ms_fops, oom_free_timeout_ms_read,
> +			oom_free_timeout_ms_write, "%llu\n");
> +#endif /* CONFIG_DEBUG_FS */

One of the several things I dislike about debugfs is that nobody
bothers documenting it anywhere.  But this should really be documented.
I'm not sure where, but the documentation will find itself alongside a
bunch of procfs things which prompts the question "why it *this* one in
debugfs"?

>  static int __init oom_init(void)
>  {
>  	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> +#ifdef CONFIG_DEBUG_FS
> +	if (!IS_ERR(oom_reaper_th))
> +		debugfs_create_file("oom_free_timeout_ms", 0200, NULL, NULL,
> +				    &oom_free_timeout_ms_fops);
> +#endif
>  	return 0;
>  }
>  subsys_initcall(oom_init)
