Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE5D6B0254
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 12:07:05 -0400 (EDT)
Received: by pacex6 with SMTP id ex6so58926239pac.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 09:07:04 -0700 (PDT)
Received: from mailout3.samsung.com (mailout3.samsung.com. [203.254.224.33])
        by mx.google.com with ESMTPS id cs1si67463340pbb.133.2015.10.08.09.07.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 Oct 2015 09:07:04 -0700 (PDT)
Received: from epcpsbgr5.samsung.com
 (u145.gpu120.samsung.co.kr [203.254.230.145])
 by mailout3.samsung.com (Oracle Communications Messaging Server 7.0.5.31.0
 64bit (built May  5 2014))
 with ESMTP id <0NVW019BGSRPI3B0@mailout3.samsung.com> for linux-mm@kvack.org;
 Fri, 09 Oct 2015 01:07:01 +0900 (KST)
From: PINTU KUMAR <pintu.k@samsung.com>
References: <1443696523-27262-1-git-send-email-pintu.k@samsung.com>
 <20151001133843.GG24077@dhcp22.suse.cz>
 <010401d0ff34$f48e8eb0$ddabac10$@samsung.com>
 <20151005122258.GA7023@dhcp22.suse.cz>
 <014e01d10004$c45bba30$4d132e90$@samsung.com>
 <20151006154152.GC20600@dhcp22.suse.cz>
 <023601d1010f$787696b0$6963c410$@samsung.com>
 <20151008141851.GD426@dhcp22.suse.cz>
In-reply-to: <20151008141851.GD426@dhcp22.suse.cz>
Subject: RE: [PATCH 1/1] mm: vmstat: Add OOM kill count in vmstat counter
Date: Thu, 08 Oct 2015 21:36:24 +0530
Message-id: <032501d101e3$82588ba0$8709a2e0$@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-transfer-encoding: 7bit
Content-language: en-us
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Michal Hocko' <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, minchan@kernel.org, dave@stgolabs.net, koct9i@gmail.com, rientjes@google.com, hannes@cmpxchg.org, penguin-kernel@i-love.sakura.ne.jp, bywxiaobai@163.com, mgorman@suse.de, vbabka@suse.cz, js1304@gmail.com, kirill.shutemov@linux.intel.com, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, cl@linux.com, fengguang.wu@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpgs@samsung.com, pintu_agarwal@yahoo.com, pintu.ping@gmail.com, vishnu.ps@samsung.com, rohit.kr@samsung.com, c.rajkumar@samsung.com, sreenathd@samsung.com

Hi,

Thank you very much for your reply and comments.

> -----Original Message-----
> From: Michal Hocko [mailto:mhocko@kernel.org]
> Sent: Thursday, October 08, 2015 7:49 PM
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
> On Wed 07-10-15 20:18:16, PINTU KUMAR wrote:
> [...]
> > Ok, let me explain the real case that we have experienced.
> > In our case, we have low memory killer in user space itself that
> > invoked based on some memory threshold.
> > Something like, below 100MB threshold starting killing until it comes
> > back to 150MB.
> > During our long duration ageing test (more than 72 hours) we observed
> > that many applications are killed.
> > Now, we were not sure if killing happens in user space or kernel space.
> > When we saw the kernel logs, it generated many logs such as;
> > /var/log/{messages, messages.0, messages.1, messages.2, messages.3,
> > etc.} But, none of the logs contains kernel OOM messages. Although
> > there were some LMK kill in user space.
> > Then in another round of test we keep dumping _dmesg_ output to a file
> > after each iteration.
> > After 3 days of tests this time we observed that dmesg output dump
> > contains many kernel oom messages.
> 
> I am confused. So you suspect that the OOM report didn't get to
> /var/log/messages while it was in dmesg?

No, I mean to say that all the /var/log/messages were over-written (after 3
days).
Or, it was cleared due to storage space constraints. So, oom kill logs were not
visible.
So, in our ageing test scripts, we keep dumping the dmesg output, during our
tests.
For_each_application:
Do
	Launch an application from cmdline
	Sleep 10 seconds
	dmesg -c >> /var/log/dmesg.log
Done
Continue this loop for more than 300 times.
After 3 days, when we analyzed the dump, we found that dmesg.log contains some
OOM messages.
Whereas, these OOM logs were not found in /var/log/messages.
May be we do heavy logging because in ageing test we enable maximum
functionality (Wifi, BT, GPS, fully loaded system).

Hope, it is clear now. If not, please ask me for more information.

> 
> > Now, every time this dumping is not feasible. And instead of counting
> > manually in log file, we wanted to know number of oom kills happened during
> this tests.
> > So we decided to add a counter in /proc/vmstat to track the kernel
> > oom_kill, and monitor it during our ageing test.
> >
> > Basically, we wanted to tune our user space LMK killer for different
> > threshold values, so that we can completely avoid the kernel oom kill.
> > So, just by looking into this counter, we could able to tune the LMK
> > threshold values without depending on the kernel log messages.
> 
> Wouldn't a trace point suit you better for this particular use case
considering this
> is a testing environment?
> 
Tracing for oom_kill count?
Actually, tracing related configs will be normally disabled in release binary.
And it is not always feasible to perform tracing for such long duration tests.
Then it should be valid for other counters as well.

> > Also, in most of the system /var/log/messages are not present and we
> > just depends on kernel dmesg output, which is petty small for longer run.
> > Even if we reduce the loglevel to 4, it may not be suitable to capture all
logs.
> 
> Hmm, I would consider a logless system considerably crippled but I see your
> point and I can imagine that especially small devices might try to save every
> single B of the storage. Such a system is basically undebugable IMO but it
still
> might be interesting to see OOM killer traces.
> 
Exactly, some of the small embedded systems might be having 512MB, 256MB, 128MB,
or even lesser.
Also, the storage space will be 8GB or below.
In such a system we cannot afford heavy log files and exact tuning and stability
is most important.
Even all tracing / profiling configs will be disabled to lowest level for
reducing kernel code size as well.

> > > What is even more confusing is the mixing of memcg and global oom
> > > conditions.  They are really different things. Memcg API will even
> > > give you notification about the OOM event.
> > >
> > Ok, you are suggesting to divide the oom_kill counter into 2 parts
> > (global &
> > memcg) ?
> > May be something like:
> > nr_oom_victims
> > nr_memcg_oom_victims
> 
> You do not need the later. Memcg interface already provides you with a
> notification API and if a counter is _really_ needed then it should be
per-memcg
> not a global cumulative number.

Ok, for memory cgroups, you mean to say this one?
sh-3.2# cat /sys/fs/cgroup/memory/memory.oom_control
oom_kill_disable 0
under_oom 0

I am actually confused here what to do next?
Shall I push a new patch set with just:
nr_oom_victims counter ?

Or, please let me know, if more information is missing.
If you have any more suggestions, please let me know.
I will really feel glad about it.
Thank you very much for all your suggestions and review so far.


> --
> Michal Hocko
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
