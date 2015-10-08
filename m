Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 1B83B6B0254
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 10:18:54 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so27481824wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 07:18:53 -0700 (PDT)
Received: from mail-wi0-f195.google.com (mail-wi0-f195.google.com. [209.85.212.195])
        by mx.google.com with ESMTPS id q7si11916286wia.93.2015.10.08.07.18.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 07:18:52 -0700 (PDT)
Received: by wicxq10 with SMTP id xq10so4870927wic.2
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 07:18:52 -0700 (PDT)
Date: Thu, 8 Oct 2015 16:18:51 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
Message-ID: <20151008141851.GD426@dhcp22.suse.cz>
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
 <20151001133843.GG24077@dhcp22.suse.cz>
 <010401d0ff34$f48e8eb0$ddabac10$@samsung.com>
 <20151005122258.GA7023@dhcp22.suse.cz>
 <014e01d10004$c45bba30$4d132e90$@samsung.com>
 <20151006154152.GC20600@dhcp22.suse.cz>
 <023601d1010f$787696b0$6963c410$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <023601d1010f$787696b0$6963c410$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

On Wed 07-10-15 20:18:16, PINTU KUMAR wrote:
[...]
> Ok, let me explain the real case that we have experienced.
> In our case, we have low memory killer in user space itself that invoked based
> on some memory threshold.
> Something like, below 100MB threshold starting killing until it comes back to
> 150MB.
> During our long duration ageing test (more than 72 hours) we observed that many
> applications are killed.
> Now, we were not sure if killing happens in user space or kernel space.
> When we saw the kernel logs, it generated many logs such as;
> /var/log/{messages, messages.0, messages.1, messages.2, messages.3, etc.}
> But, none of the logs contains kernel OOM messages. Although there were some LMK
> kill in user space.
> Then in another round of test we keep dumping _dmesg_ output to a file after
> each iteration.
> After 3 days of tests this time we observed that dmesg output dump contains many
> kernel oom messages.

I am confused. So you suspect that the OOM report didn't get to
/var/log/messages while it was in dmesg?

> Now, every time this dumping is not feasible. And instead of counting manually
> in log file, we wanted to know number of oom kills happened during this tests.
> So we decided to add a counter in /proc/vmstat to track the kernel oom_kill, and
> monitor it during our ageing test.
>
> Basically, we wanted to tune our user space LMK killer for different threshold
> values, so that we can completely avoid the kernel oom kill.
> So, just by looking into this counter, we could able to tune the LMK threshold
> values without depending on the kernel log messages.

Wouldn't a trace point suit you better for this particular use case
considering this is a testing environment?
 
> Also, in most of the system /var/log/messages are not present and we just
> depends on kernel dmesg output, which is petty small for longer run.
> Even if we reduce the loglevel to 4, it may not be suitable to capture all logs.

Hmm, I would consider a logless system considerably crippled but I see
your point and I can imagine that especially small devices might try
to save every single B of the storage. Such a system is basically
undebugable IMO but it still might be interesting to see OOM killer
traces.
 
> > What is even more confusing is the mixing of memcg and global oom
> > conditions.  They are really different things. Memcg API will even
> > give you notification about the OOM event.
> > 
> Ok, you are suggesting to divide the oom_kill counter into 2 parts (global &
> memcg) ?
> May be something like:
> nr_oom_victims
> nr_memcg_oom_victims

You do not need the later. Memcg interface already provides you with a
notification API and if a counter is _really_ needed then it should be
per-memcg not a global cumulative number.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
