Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id CF8206B0541
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 09:07:25 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id z53so37253529wrz.10
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 06:07:25 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id l63si9679693wml.98.2017.07.28.06.07.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 06:07:24 -0700 (PDT)
Date: Fri, 28 Jul 2017 15:07:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Possible race condition in oom-killer
Message-ID: <20170728130723.GP2274@dhcp22.suse.cz>
References: <e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com>
 <20170728123235.GN2274@dhcp22.suse.cz>
 <46e1e3ee-af9a-4e67-8b4b-5cf21478ad21@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <46e1e3ee-af9a-4e67-8b4b-5cf21478ad21@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Manish Jaggi <mjaggi@caviumnetworks.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 28-07-17 21:59:50, Tetsuo Handa wrote:
> (Oops. Forgot to add CC.)
> 
> On 2017/07/28 21:32, Michal Hocko wrote:
> > [CC linux-mm]
> >
> > On Fri 28-07-17 17:22:25, Manish Jaggi wrote:
> >> was: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
> >>
> >> Hi Michal,
> >> On 7/27/2017 2:54 PM, Michal Hocko wrote:
> >>> On Thu 27-07-17 13:59:09, Manish Jaggi wrote:
> >>> [...]
> >>>> With 4.11.6 I was getting random kernel panics (Out of memory - No process left to kill),
> >>>>  when running LTP oom01 /oom02 ltp tests on our arm64 hardware with ~256G memory and high core count.
> >>>> The issue experienced was as follows
> >>>> 	that either test (oom01/oom02) selected a pid as victim and waited for the pid to be killed.
> >>>> 	that pid was marked as killed but somewhere there is a race and the process didnt get killed.
> >>>> 	and the oom01/oom02 test started killing further processes, till it panics.
> >>>> IIUC this issue is quite similar to your patch description. But applying your patch I still see the issue.
> >>>> If it is not related to this patch, can you please suggest by looking at the log, what could be preventing
> >>>> the killing of victim.
> >>>>
> >>>> Log (https://pastebin.com/hg5iXRj2)
> >>>>
> >>>> As a subtest of oom02 starts, it prints out the victim - In this case 4578
> >>>>
> >>>> oom02       0  TINFO  :  start OOM testing for mlocked pages.
> >>>> oom02       0  TINFO  :  expected victim is 4578.
> >>>>
> >>>> When oom02 thread invokes oom-killer, it did select 4578  for killing...
> >>> I will definitely have a look. Can you report it in a separate email
> >>> thread please? Are you able to reproduce with the current Linus or
> >>> linux-next trees?
> >> Yes this issue is visible with linux-next.
> >
> > Could you provide the full kernel log from this run please? I do not
> > expect there to be much difference but just to be sure that the code I
> > am looking at matches logs.
> 
> 4578 is consuming memory as mlocked pages. But the OOM reaper cannot reclaim
> mlocked pages (i.e. can_madv_dontneed_vma() returns false due to VM_LOCKED), can it?

You are absolutely right. I am pretty sure I've checked mlocked counter
as the first thing but that must be from one of the earlier oom reports.
My fault I haven't checked it in the critical one

[  365.267347] oom_reaper: reaped process 4578 (oom02), now anon-rss:131559616kB, file-rss:0kB, shmem-rss:0kB
[  365.282658] oom_reaper: reaped process 4583 (oom02), now anon-rss:131561664kB, file-rss:0kB, shmem-rss:0kB

and the above screemed about the fact I was just completely blind.

mlock pages handling is on my todo list for quite some time already but
I didn't get around it to implement that. mlock code is very tricky.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
