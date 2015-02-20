Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4DF986B006C
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 18:15:16 -0500 (EST)
Received: by paceu11 with SMTP id eu11so11454005pac.10
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 15:15:16 -0800 (PST)
Received: from ipmail06.adl2.internode.on.net (ipmail06.adl2.internode.on.net. [150.101.137.129])
        by mx.google.com with ESMTP id rr7si7085499pab.233.2015.02.20.15.15.14
        for <linux-mm@kvack.org>;
        Fri, 20 Feb 2015 15:15:15 -0800 (PST)
Date: Sat, 21 Feb 2015 10:15:11 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: How to handle TIF_MEMDIE stalls?
Message-ID: <20150220231511.GH12722@dastard>
References: <201502172123.JIE35470.QOLMVOFJSHOFFt@I-love.SAKURA.ne.jp>
 <20150217125315.GA14287@phnom.home.cmpxchg.org>
 <20150217225430.GJ4251@dastard>
 <20150219102431.GA15569@phnom.home.cmpxchg.org>
 <20150219225217.GY12722@dastard>
 <201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201502201936.HBH34799.SOLFFFQtHOMOJV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, mhocko@suse.cz, dchinner@redhat.com, linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, xfs@oss.sgi.com

On Fri, Feb 20, 2015 at 07:36:33PM +0900, Tetsuo Handa wrote:
> Dave Chinner wrote:
> > I really don't care about the OOM Killer corner cases - it's
> > completely the wrong way line of development to be spending time on
> > and you aren't going to convince me otherwise. The OOM killer a
> > crutch used to justify having a memory allocation subsystem that
> > can't provide forward progress guarantee mechanisms to callers that
> > need it.
> 
> I really care about the OOM Killer corner cases, for I'm
> 
>   (1) seeing trouble cases which occurred in enterprise systems
>       under OOM conditions

You reach OOM, then your SLAs are dead and buried. Reboot the
box - its a much more reliable way of returning to a working system
than playing Russian Roulette with the OOM killer.

>   (2) trying to downgrade OOM "Deadlock or Genocide" attacks (which
>       an unprivileged user with a login shell can trivially trigger
>       since Linux 2.0) to OOM "Genocide" attacks in order to allow
>       OOM-unkillable daemons to restart OOM-killed processes
> 
>   (3) waiting for a bandaid for (2) in order to propose changes for
>       mitigating OOM "Genocide" attacks (as bad guys will find how to
>       trigger OOM "Deadlock or Genocide" attacks from changes for
>       mitigating OOM "Genocide" attacks)

Which is yet another indication that the OOM killer is the wrong
solution to the "lack of forward progress" problem. Any one can
generate enough memory pressure to trigger the OOM killer; we can't
prevent that from occurring when the OOM killer can be invoked by
user processes.

> I started posting to linux-mm ML in order to make forward progress
> about (1) and (2). I don't want the memory allocation subsystem to
> lock up an entire system by indefinitely disabling memory releasing
> mechanism provided by the OOM killer.
> 
> > I've proposed a method of providing this forward progress guarantee
> > for subsystems of arbitrary complexity, and this removes the
> > dependency on the OOM killer for fowards allocation progress in such
> > contexts (e.g. filesystems). We should be discussing how to
> > implement that, not what bandaids we need to apply to the OOM
> > killer. I want to fix the underlying problems, not push them under
> > the OOM-killer bus...
> 
> I'm fine with that direction for new kernels provided that a simple
> bandaid which can be backported to distributor kernels for making
> OOM "Deadlock" attacks impossible is implemented. Therefore, I'm
> discussing what bandaids we need to apply to the OOM killer.

The band-aids being proposed are worse than the problem they are
intended to cover up. In which case, the band-aids should not be
applied.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
