Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id A41896B0559
	for <linux-mm@kvack.org>; Fri, 28 Jul 2017 10:12:55 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p43so34155553wrb.6
        for <linux-mm@kvack.org>; Fri, 28 Jul 2017 07:12:55 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id m77si12763445wmc.23.2017.07.28.07.12.54
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 28 Jul 2017 07:12:54 -0700 (PDT)
Date: Fri, 28 Jul 2017 16:12:53 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Possible race condition in oom-killer
Message-ID: <20170728141252.GU2274@dhcp22.suse.cz>
References: <e6c83a26-1d59-4afd-55cf-04e58bdde188@caviumnetworks.com>
 <20170728123235.GN2274@dhcp22.suse.cz>
 <88cbd07e-6e5e-924f-cdd3-82e65722ed30@caviumnetworks.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <88cbd07e-6e5e-924f-cdd3-82e65722ed30@caviumnetworks.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Manish Jaggi <mjaggi@caviumnetworks.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri 28-07-17 19:20:42, Manish Jaggi wrote:
> 
> Hi Michal,
> On 7/28/2017 6:02 PM, Michal Hocko wrote:
> >[CC linux-mm]
> >
> >On Fri 28-07-17 17:22:25, Manish Jaggi wrote:
> >>was: Re: [PATCH] mm, oom: allow oom reaper to race with exit_mmap
> >>
> >>Hi Michal,
> >>On 7/27/2017 2:54 PM, Michal Hocko wrote:
> >>>On Thu 27-07-17 13:59:09, Manish Jaggi wrote:
> >>>[...]
> >>>>With 4.11.6 I was getting random kernel panics (Out of memory - No process left to kill),
> >>>>  when running LTP oom01 /oom02 ltp tests on our arm64 hardware with ~256G memory and high core count.
> >>>>The issue experienced was as follows
> >>>>	that either test (oom01/oom02) selected a pid as victim and waited for the pid to be killed.
> >>>>	that pid was marked as killed but somewhere there is a race and the process didnt get killed.
> >>>>	and the oom01/oom02 test started killing further processes, till it panics.
> >>>>IIUC this issue is quite similar to your patch description. But applying your patch I still see the issue.
> >>>>If it is not related to this patch, can you please suggest by looking at the log, what could be preventing
> >>>>the killing of victim.
> >>>>
> >>>>Log (https://pastebin.com/hg5iXRj2)
> >>>>
> >>>>As a subtest of oom02 starts, it prints out the victim - In this case 4578
> >>>>
> >>>>oom02       0  TINFO  :  start OOM testing for mlocked pages.
> >>>>oom02       0  TINFO  :  expected victim is 4578.
> >>>>
> >>>>When oom02 thread invokes oom-killer, it did select 4578  for killing...
> >>>I will definitely have a look. Can you report it in a separate email
> >>>thread please? Are you able to reproduce with the current Linus or
> >>>linux-next trees?
> >>Yes this issue is visible with linux-next.
> >Could you provide the full kernel log from this run please? I do not
> >expect there to be much difference but just to be sure that the code I
> >am looking at matches logs.
> The log is here: https://pastebin.com/Pmn5ZwEM
> mlocked memory keeps on increasing till panic.

Thank you for retesting. I confirm the issue is that the oom reaper
hides the oom victim too early because the whole address space is
mlocked basically and there is not much to free. As the exit of the test
takes some time a new instance of the test pid 4625 in this case will go
and consume more than the exiting frees and that would go on an on until
we kill other eligible tasks until we panic due to no more eligible
tasks.

This is a bad situation and as I've said elsewhere in the thread the
proper fix is to teach the oom reaper to handle mlocked pages. This is
not a trivial task. We could play some other dirty tricks but I am not
sure it is worth it considering this is rather artificial test. 

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
