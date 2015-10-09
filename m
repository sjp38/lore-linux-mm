Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id D23F86B0255
	for <linux-mm@kvack.org>; Fri,  9 Oct 2015 09:00:43 -0400 (EDT)
Received: by padhy16 with SMTP id hy16so86552677pad.1
        for <linux-mm@kvack.org>; Fri, 09 Oct 2015 06:00:43 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id ko6si2429914pab.144.2015.10.09.06.00.42
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 09 Oct 2015 06:00:42 -0700 (PDT)
Received: from epcpsbgr3.samsung.com
 (u143.gpu120.samsung.co.kr [203.254.230.143])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NVY00U23ET5DA60@mailout3.samsung.com> for linux-mm@kvack.org;
 Fri, 09 Oct 2015 22:00:41 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
 <20151001133843.GG24077@dhcp22.suse.cz>
 <010401d0ff34$f48e8eb0$ddabac10$@samsung.com>
 <20151005122258.GA7023@dhcp22.suse.cz>
 <014e01d10004$c45bba30$4d132e90$@samsung.com>
 <20151006154152.GC20600@dhcp22.suse.cz>
 <023601d1010f$787696b0$6963c410$@samsung.com>
 <20151008141851.GD426@dhcp22.suse.cz>
 <032501d101e3$82588ba0$8709a2e0$@samsung.com>
 <20151008163049.GJ426@dhcp22.suse.cz>
In-reply-to: <20151008163049.GJ426@dhcp22.suse.cz>
Subject: RE: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
Date: Fri, 09 Oct 2015 18:29:49 +0530
Message-id: <03ad01d10292$a45c53d0$ed14fb70$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com


> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@kernel.org]
> Sent: Thursday, October 08, 2015 10:01 PM
> To: PINTU KUMAR
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
> On Thu 08-10-15 21:36:24, PINTU KUMAR wrote:
> [...]
> > Whereas, these OOM logs were not found in /var/log/messages.
> > May be we do heavy logging because in ageing test we enable maximum
> > functionality (Wifi, BT, GPS, fully loaded system).
> 
> If you swamp your logs so heavily that even critical messages won't make it
into
> the log files then your logging is basically useless for anything serious. But
that is
> not really that important.
> 
> > Hope, it is clear now. If not, please ask me for more information.
> >
> > >
> > > > Now, every time this dumping is not feasible. And instead of
> > > > counting manually in log file, we wanted to know number of oom
> > > > kills happened during
> > > this tests.
> > > > So we decided to add a counter in /proc/vmstat to track the kernel
> > > > oom_kill, and monitor it during our ageing test.
> > > >
> > > > Basically, we wanted to tune our user space LMK killer for
> > > > different threshold values, so that we can completely avoid the kernel
oom
> kill.
> > > > So, just by looking into this counter, we could able to tune the
> > > > LMK threshold values without depending on the kernel log messages.
> > >
> > > Wouldn't a trace point suit you better for this particular use case
> > > considering this is a testing environment?
> > >
> > Tracing for oom_kill count?
> > Actually, tracing related configs will be normally disabled in release
binary.
> 
> Yes but your use case described a testing environment.
> 
> > And it is not always feasible to perform tracing for such long duration
tests.
> 
> I do not see why long duration would be a problem. Each tracepoint can be
> enabled separatelly.
> 
> > Then it should be valid for other counters as well.
> >
> > > > Also, in most of the system /var/log/messages are not present and
> > > > we just depends on kernel dmesg output, which is petty small for longer
> run.
> > > > Even if we reduce the loglevel to 4, it may not be suitable to
> > > > capture all
> > logs.
> > >
> > > Hmm, I would consider a logless system considerably crippled but I
> > > see your point and I can imagine that especially small devices might
> > > try to save every single B of the storage. Such a system is
> > > basically undebugable IMO but it
> > still
> > > might be interesting to see OOM killer traces.
> > >
> > Exactly, some of the small embedded systems might be having 512MB,
> > 256MB, 128MB, or even lesser.
> > Also, the storage space will be 8GB or below.
> > In such a system we cannot afford heavy log files and exact tuning and
> > stability is most important.
> 
> And that is what log level is for. If your logs are heavy with error levels
then you
> are far from being production ready... ;)
> 
> > Even all tracing / profiling configs will be disabled to lowest level
> > for reducing kernel code size as well.
> 
> What level is that? crit? Is err really that noisy?
> 
No. I was talking about kernel configs. Normally we keep some profiling/tracing
related configs disabled for low memory system, to save some kernel code size.
The point is that it's always not easy for all systems to heavily depends on
logging and tracing.
Else, the other counters would also not be required.
We thought that the /proc/vmstat output (which is ideally available in all
systems, small or big, embedded or none embedded), it can quickly tell us what
has happened really.

> [...]
> > > > Ok, you are suggesting to divide the oom_kill counter into 2 parts
> > > > (global &
> > > > memcg) ?
> > > > May be something like:
> > > > nr_oom_victims
> > > > nr_memcg_oom_victims
> > >
> > > You do not need the later. Memcg interface already provides you with
> > > a notification API and if a counter is _really_ needed then it
> > > should be per-memcg not a global cumulative number.
> >
> > Ok, for memory cgroups, you mean to say this one?
> > sh-3.2# cat /sys/fs/cgroup/memory/memory.oom_control
> > oom_kill_disable 0
> > under_oom 0
> 
> Yes this is the notification API.
> 
> > I am actually confused here what to do next?
> > Shall I push a new patch set with just:
> > nr_oom_victims counter ?
> 
> Yes you can repost with a better description about a typical usage scenarios.
I
> cannot say I would be completely sold to this because the only relevant
usecase
> I've heard so far is the logless system which is pretty much a corner case.
This is
> not a reason to nack it though. It is definitely better than the original
oom_stall
> suggestion because it has a clear semantic at least.

Ok, thank you very much for your suggestions.
I agree, oom_stall is not so important.
I will try to submit a new patch set with only _nr_oom_victims_ with the
descriptions about the usefulness that I came across.
If anybody else can point out other use cases, please let me know. 
I will be happy to try that and share the results.

> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
