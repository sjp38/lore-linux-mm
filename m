Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 41E2C6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 03:52:23 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id o80so1929910wme.1
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 00:52:23 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w4si18614880wjp.216.2016.07.26.00.52.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 26 Jul 2016 00:52:22 -0700 (PDT)
Date: Tue, 26 Jul 2016 09:52:20 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH v3 0/8] Change OOM killer to use list of mm_struct.
Message-ID: <20160726075219.GF32462@dhcp22.suse.cz>
References: <20160725112140.GF9401@dhcp22.suse.cz>
 <201607252047.CHG57343.JFSOHMFVOQFtLO@I-love.SAKURA.ne.jp>
 <20160725115900.GG9401@dhcp22.suse.cz>
 <201607252302.JFE86466.FOMFVFJOtSHQLO@I-love.SAKURA.ne.jp>
 <20160725141749.GI9401@dhcp22.suse.cz>
 <201607260640.CFJ12946.SMOFFQVHFJtLOO@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201607260640.CFJ12946.SMOFFQVHFJtLOO@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com, mst@redhat.com

On Tue 26-07-16 06:40:54, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Mon 25-07-16 23:02:35, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > On Mon 25-07-16 20:47:03, Tetsuo Handa wrote:
> > > > > Michal Hocko wrote:
> > > > > > On Mon 25-07-16 20:07:11, Tetsuo Handa wrote:
[...]
> > > > > > > Then, what are advantages with allowing only OOM victims access to memory
> > > > > > > reserves after they left exit_mm()?
> > > > > > 
> > > > > > Because they might need it in order to move on... Say you want to close
> > > > > > all the files which might release considerable amount of memory or any
> > > > > > other post exit_mm() resources.
> > > > > 
> > > > > OOM victims might need memory reserves in order to move on, but non OOM victims
> > > > > might also need memory reserves in order to move on. And non OOM victims might
> > > > > be blocking OOM victims via locks.
> > > > 
> > > > Yes that might be true but OOM situations are rare events and quite
> > > > reduced in the scope. Considering all exiting tasks is more dangerous
> > > > because they might deplete those memory reserves easily.
> > > 
> > > Why do you assume that we grant all of memory reserves?
> > 
> > I've said deplete "those memory reserves". It would be just too easy to
> > exit many tasks at once and use up that memory.
> 
> But that will not be a problem unless an OOM event occurs.

And then it might make the problem just worse. I do not want to
speculate about adversary workloads but this just sounds like a bad
idea in general...

> Even if some
> portion of memory reserves are granted, killed/exiting tasks unlikely
> access memory reserves. If killed/exiting tasks need to deplete that
> portion of memory reserves, it is reasonable to select an OOM victim.
> 
> > 
> > > I'm suggesting that we grant portion of memory reserves.
> > 
> > Which doesn't solve anything because it will always be a finite resource
> > which can get depleted. This is basically the same as the oom victim
> > (ab)using reserves accept that OOM is much less likely and it is under
> > control of the kernel which task gets killed.
> 
> Given that OOM is much less likely event, maybe we even do not need to use
> task_struct->oom_reaper_list and instead we can use a global variable
> 
>   static struct mm_struct *current_oom_mm;
> 
> and wait for current_oom_mm to become NULL regardless of in which domain an
> OOM event occurred (as with we changed to use global oom_lock for preventing
> concurrent OOM killer invocations)?

Heh, this is very similar to what I used to have there in the beginning
and you have pushed to make it a list.

> Then, we can determine OOM_SCAN_ABORT by
> inspecting that variable. This change may defer invocation of OOM killer in
> different domains, but concurrent OOM events in different domains will be
> also much less likely?

Considering that there may be hundreds of memory cgroups configured then
I expect we will be pushed towards more parallelism in the future.

Anyway I think we went largely off topic.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
