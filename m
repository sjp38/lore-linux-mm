Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C37CC280852
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 04:55:56 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id k80so2962346wrc.15
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 01:55:56 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 34si2882629wrf.313.2017.08.24.01.55.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 01:55:55 -0700 (PDT)
Date: Thu, 24 Aug 2017 10:55:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH RFC v2] Add /proc/pid/smaps_rollup
Message-ID: <20170824085553.GB5943@dhcp22.suse.cz>
References: <20170808132554.141143-1-dancol@google.com>
 <20170810001557.147285-1-dancol@google.com>
 <20170810043831.GB2249@bbox>
 <20170810084617.GI23863@dhcp22.suse.cz>
 <r0251soju3fo.fsf@dancol.org>
 <20170810105852.GM23863@dhcp22.suse.cz>
 <CAPz6YkUNu1uH057ENuH+Umq5J=J24my0p91mvYMtEb4Vy6Dhqg@mail.gmail.com>
 <CAEe=SxkgPUEkHdQm+M49EBc_Y_bEnNbe5fed3yALUx2eUbMrGQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAEe=SxkgPUEkHdQm+M49EBc_Y_bEnNbe5fed3yALUx2eUbMrGQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Murray <timmurray@google.com>
Cc: Sonny Rao <sonnyrao@chromium.org>, Daniel Colascione <dancol@google.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Joel Fernandes <joelaf@google.com>, Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, Robert Foss <robert.foss@collabora.com>, linux-api@vger.kernel.org, Luigi Semenzato <semenzato@google.com>

Sorry for a late reply

On Thu 10-08-17 12:17:07, Tim Murray wrote:
> I've looked into this a fair bit on the Android side, so I can provide
> some context. There are two main reasons why Android gathers PSS
> information:
> 
> 1. Android devices can show the user the amount of memory used per
> application via the settings app. This is a less important use case.

yes

> 2. We log PSS to help identify leaks in applications. We have found an
> enormous number of bugs (in the Android platform, in Google's own
> apps, and in third-party applications) using this data.
> 
> To do this, system_server (the main process in Android userspace) will
> sample the PSS of a process three seconds after it changes state (for
> example, app is launched and becomes the foreground application) and
> about every ten minutes after that. The net result is that PSS
> collection is regularly running on at least one process in the system
> (usually a few times a minute while the screen is on, less when screen
> is off due to suspend). PSS of a process is an incredibly useful stat
> to track, and we aren't going to get rid of it. We've looked at some
> very hacky approaches using RSS ("take the RSS of the target process,
> subtract the RSS of the zygote process that is the parent of all
> Android apps") to reduce the accounting time, but it regularly
> overestimated the memory used by 20+ percent. Accordingly, I don't
> think that there's a good alternative to using PSS.

Even if the RSS overestimates this shouldn't hide a memory leak, no?

> We started looking into PSS collection performance after we noticed
> random frequency spikes while a phone's screen was off; occasionally,
> one of the CPU clusters would ramp to a high frequency because there
> was 200-300ms of constant CPU work from a single thread in the main
> Android userspace process. The work causing the spike (which is
> reasonable governor behavior given the amount of CPU time needed) was
> always PSS collection. As a result, Android is burning more power than
> we should be on PSS collection.

Yes, this really sucks but we are revolving around the same point. It
really sucks that we burn so much time just copying the output to the
userspace when the real stuff (vma walk and pte walk) has to be done
anyway. AFAIR I could reduce the overhead by using more appropriate
seq_* functions but maybe we can do even better.

> The other issue (and why I'm less sure about improving smaps as a
> long-term solution) is that the number of VMAs per process has
> increased significantly from release to release. After trying to
> figure out why we were seeing these 200-300ms PSS collection times on
> Android O but had not noticed it in previous versions, we found that
> the number of VMAs in the main system process increased by 50% from
> Android N to Android O (from ~1800 to ~2700) and varying increases in
> every userspace process. Android M to N also had an increase in the
> number of VMAs, although not as much. I'm not sure why this is
> increasing so much over time, but thinking about ASLR and ways to make
> ASLR better, I expect that this will continue to increase going
> forward. I would not be surprised if we hit 5000 VMAs on the main
> Android process (system_server) by 2020.

The thing is, however, that the larger amount of VMAs will also mean
more work on the kernel side. The data collection has to be done anyway.
 
> If we assume that the number of VMAs is going to increase over time,
> then doing anything we can do to reduce the overhead of each VMA
> during PSS collection seems like the right way to go, and that means
> outputting an aggregate statistic (to avoid whatever overhead there is
> per line in writing smaps and in reading each line from userspace).
> 
> Also, Dan sent me some numbers from his benchmark measuring PSS on
> system_server (the big Android process) using smaps vs smaps_rollup:
> 
> using smaps:
> iterations:1000 pid:1163 pss:220023808
>  0m29.46s real 0m08.28s user 0m20.98s system
> 
> using smaps_rollup:
> iterations:1000 pid:1163 pss:220702720
>  0m04.39s real 0m00.03s user 0m04.31s system

I would assume we would do all we can to reduce this kernel->user
overhead first before considering a new user visible file. I haven't
seen any attempts except from the low hanging fruid I have tried.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
