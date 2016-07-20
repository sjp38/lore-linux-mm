Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 874366B0005
	for <linux-mm@kvack.org>; Wed, 20 Jul 2016 09:39:06 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id r97so32807091lfi.2
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 06:39:06 -0700 (PDT)
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com. [74.125.82.50])
        by mx.google.com with ESMTPS id i83si4089036wma.27.2016.07.20.06.39.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 20 Jul 2016 06:39:05 -0700 (PDT)
Received: by mail-wm0-f50.google.com with SMTP id i5so69397501wmg.0
        for <linux-mm@kvack.org>; Wed, 20 Jul 2016 06:39:05 -0700 (PDT)
Date: Wed, 20 Jul 2016 15:39:03 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: oom-reaper choosing wrong processes.
Message-ID: <20160720133903.GO11249@dhcp22.suse.cz>
References: <20160718231850.GA23178@codemonkey.org.uk>
 <20160719090857.GB9490@dhcp22.suse.cz>
 <20160719153335.GA11863@codemonkey.org.uk>
 <20160720070923.GC11249@dhcp22.suse.cz>
 <20160720132304.GA11434@codemonkey.org.uk>
 <20160720133337.GA12457@codemonkey.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160720133337.GA12457@codemonkey.org.uk>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@codemonkey.org.uk>
Cc: linux-mm@kvack.org

On Wed 20-07-16 09:33:37, Dave Jones wrote:
> On Wed, Jul 20, 2016 at 09:23:04AM -0400, Dave Jones wrote:
>  
>  >  > so this task has been already oom reaped and so oom_badness will ignore
>  >  > it (it simply doesn't make any sense to select this task because it
>  >  > has been already killed or exiting and oom reaped as well). Others might
>  >  > be in a similar position or they might have passed exit_mm->tsk->mm = NULL
>  >  > so they are ignored by the oom killer as well.
>  > 
>  > I feel like I'm still missing something.  Why isn't "wait for the already reaped trinity tasks to exit"
>  > the right thing to do here (as my diff forced it to do), instead of "pick even more victims even
>  > though we've already got some reaped processes that haven't exited"
>  > 
>  > Not killing systemd-journald allowed the machine to keep running just fine.
>  > If I hadn't have patched that out, it would have been killed unnecessarily.
> 
> nm, I figured it out. As Tetsuo pointed out, I was leaking a task struct,
> so those already reaped trinity processes would never truly 'exit'.

Leaked task_struct would leak some memory but they shouldn't have any
effect on the task visibility to the oom killer. Tasks are basically
visible until they are unhashed from the task_list. But the leak could
indeed have some other side effects - like pinning a lot of memory and
so the OOM kill wouldn't be sufficient to make a forward progress.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
