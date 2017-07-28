Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6839A6B0533
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 08:32:37 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id p17so12889787wmd.5
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 05:32:37 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x70si3430029wma.164.2017.07.28.05.32.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 05:32:36 -0700 (PDT)
Date: Fri, 28 Jul 2017 14:32:35 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Possible race condition in oom-killer
Message-ID: <20170728123235.GN2274@dhcp22.suse.cz>
References: <e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manish Jaggi <mjaggi@caviumnetworks.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

[CC linux-mm]

On Fri 28-07-17 17:22:25, Manish Jaggi wrote:
> was: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
> 
> Hi Michal,
> On 7/27/2017 2:54 PM, Michal Hocko wrote:
> >On Thu 27-07-17 13:59:09, Manish Jaggi wrote:
> >[...]
> >>With 4.11.6 I was getting random kernel panics (Out of memory - No process left to kill),
> >>  when running LTP oom01 /oom02 ltp tests on our arm64 hardware with ~256G memory and high core count.
> >>The issue experienced was as follows
> >>	that either test (oom01/oom02) selected a pid as victim and waited for the pid to be killed.
> >>	that pid was marked as killed but somewhere there is a race and the process didnt get killed.
> >>	and the oom01/oom02 test started killing further processes, till it panics.
> >>IIUC this issue is quite similar to your patch description. But applying your patch I still see the issue.
> >>If it is not related to this patch, can you please suggest by looking at the log, what could be preventing
> >>the killing of victim.
> >>
> >>Log (https://pastebin.com/hg5iXRj2)
> >>
> >>As a subtest of oom02 starts, it prints out the victim - In this case 4578
> >>
> >>oom02       0  TINFO  :  start OOM testing for mlocked pages.
> >>oom02       0  TINFO  :  expected victim is 4578.
> >>
> >>When oom02 thread invokes oom-killer, it did select 4578  for killing...
> >I will definitely have a look. Can you report it in a separate email
> >thread please? Are you able to reproduce with the current Linus or
> >linux-next trees?
> Yes this issue is visible with linux-next.

Could you provide the full kernel log from this run please? I do not
expect there to be much difference but just to be sure that the code I
am looking at matches logs.

[...]
> >>[  365.283361] oom02:4586 invoked oom-killer: gfp_mask=0x16040c0(GFP_KERNEL|__GFP_COMP|__GFP_NOTRACK), nodemask=1,  order=0, oom_score_adj=0
> >Yes because
> >[  365.283499] Node 1 Normal free:19500kB min:33804kB low:165916kB high:298028kB active_anon:13312kB inactive_anon:172kB active_file:0kB inactive_file:1044kB unevictable:131560064kB writepending:0kB present:134213632kB managed:132113248kB mlocked:131560064kB slab_reclaimable:5748kB slab_unreclaimable:17808kB kernel_stack:2720kB pagetables:254636kB bounce:0kB free_pcp:10476kB local_pcp:144kB free_cma:0kB
> >
> >Although we have killed and reaped oom02 process Node1 is still below
> >min watermark and that is why we have hit the oom killer again. It
> >is not immediatelly clear to me why, that would require a deeper
> >inspection.
> I have a doubt here
> my understanding of oom test: oom() function basically forks itself and
> starts n threads each thread has a loop which allocates and touches memory
> thus will trigger oom-killer and will kill the process. the parent process
> is on a wait() and will print pass/fail.
> 
> So IIUC when 4578 is reaped all the child threads should be terminated,
> which happens in pass case (line 152)
> But even after being killed and reaped,  the oom killer is invoked again
> which doesn't seem right.

As I've said the OOM killer hits because the memory from Node 1 didn't
get freed for some reasov or got immediatally populated.

> Could it be that the process is just marked hidden from oom including its
> threads, thus oom-killer continues.

The whole process should be killed and the OOM reaper should only mark
the victim oom invisible _after_ the address space has been reaped (and
memory freed). You said the patch from
http://lkml.kernel.org/r/20170724072332.31903-1-mhocko@kernel.org didn't
help so it shouldn't be a race with the last __mmput.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
