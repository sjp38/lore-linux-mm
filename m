Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8140C6B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 12:30:56 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so33567272wic.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:30:56 -0700 (PDT)
Received: from mail-wi0-f194.google.com (mail-wi0-f194.google.com. [209.85.212.194])
        by mx.google.com with ESMTPS id r7si12648153wiz.94.2015.10.08.09.30.55
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 09:30:55 -0700 (PDT)
Received: by wiku15 with SMTP id u15so5753008wik.1
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:30:54 -0700 (PDT)
Date: Thu, 8 Oct 2015 18:30:50 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
Message-ID: <20151008163049.GJ426@dhcp22.suse.cz>
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
 <20151001133843.GG24077@dhcp22.suse.cz>
 <010401d0ff34$f48e8eb0$ddabac10$@samsung.com>
 <20151005122258.GA7023@dhcp22.suse.cz>
 <014e01d10004$c45bba30$4d132e90$@samsung.com>
 <20151006154152.GC20600@dhcp22.suse.cz>
 <023601d1010f$787696b0$6963c410$@samsung.com>
 <20151008141851.GD426@dhcp22.suse.cz>
 <032501d101e3$82588ba0$8709a2e0$@samsung.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <032501d101e3$82588ba0$8709a2e0$@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: PINTU KUMAR <pintu.k@samsung.com>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

On Thu 08-10-15 21:36:24, PINTU KUMAR wrote:
[...]
> Whereas, these OOM logs were not found in /var/log/messages.
> May be we do heavy logging because in ageing test we enable maximum
> functionality (Wifi, BT, GPS, fully loaded system).

If you swamp your logs so heavily that even critical messages won't make
it into the log files then your logging is basically useless for
anything serious. But that is not really that important.

> Hope, it is clear now. If not, please ask me for more information.
> 
> > 
> > > Now, every time this dumping is not feasible. And instead of counting
> > > manually in log file, we wanted to know number of oom kills happened during
> > this tests.
> > > So we decided to add a counter in /proc/vmstat to track the kernel
> > > oom_kill, and monitor it during our ageing test.
> > >
> > > Basically, we wanted to tune our user space LMK killer for different
> > > threshold values, so that we can completely avoid the kernel oom kill.
> > > So, just by looking into this counter, we could able to tune the LMK
> > > threshold values without depending on the kernel log messages.
> > 
> > Wouldn't a trace point suit you better for this particular use case
> > considering this
> > is a testing environment?
> > 
> Tracing for oom_kill count?
> Actually, tracing related configs will be normally disabled in release binary.

Yes but your use case described a testing environment.

> And it is not always feasible to perform tracing for such long duration tests.

I do not see why long duration would be a problem. Each tracepoint can
be enabled separatelly.

> Then it should be valid for other counters as well.
> 
> > > Also, in most of the system /var/log/messages are not present and we
> > > just depends on kernel dmesg output, which is petty small for longer run.
> > > Even if we reduce the loglevel to 4, it may not be suitable to capture all
> logs.
> > 
> > Hmm, I would consider a logless system considerably crippled but I see your
> > point and I can imagine that especially small devices might try to save every
> > single B of the storage. Such a system is basically undebugable IMO but it
> still
> > might be interesting to see OOM killer traces.
> > 
> Exactly, some of the small embedded systems might be having 512MB, 256MB, 128MB,
> or even lesser.
> Also, the storage space will be 8GB or below.
> In such a system we cannot afford heavy log files and exact tuning and stability
> is most important.

And that is what log level is for. If your logs are heavy with error
levels then you are far from being production ready... ;)

> Even all tracing / profiling configs will be disabled to lowest level for
> reducing kernel code size as well.

What level is that? crit? Is err really that noisy?
 
[...]
> > > Ok, you are suggesting to divide the oom_kill counter into 2 parts
> > > (global &
> > > memcg) ?
> > > May be something like:
> > > nr_oom_victims
> > > nr_memcg_oom_victims
> > 
> > You do not need the later. Memcg interface already provides you with a
> > notification API and if a counter is _really_ needed then it should be
> > per-memcg
> > not a global cumulative number.
> 
> Ok, for memory cgroups, you mean to say this one?
> sh-3.2# cat /sys/fs/cgroup/memory/memory.oom_control
> oom_kill_disable 0
> under_oom 0

Yes this is the notification API.

> I am actually confused here what to do next?
> Shall I push a new patch set with just:
> nr_oom_victims counter ?

Yes you can repost with a better description about a typical usage
scenarios. I cannot say I would be completely sold to this because
the only relevant usecase I've heard so far is the logless system
which is pretty much a corner case. This is not a reason to nack it
though. It is definitely better than the original oom_stall suggestion
because it has a clear semantic at least.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
