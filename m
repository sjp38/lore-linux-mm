Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 85B6B6B025E
	for <linux-mm@kvack.org>; Sat,  7 Oct 2017 03:59:43 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v78so17768673pgb.4
        for <linux-mm@kvack.org>; Sat, 07 Oct 2017 00:59:43 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 3si2763071plp.335.2017.10.07.00.59.41
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 07 Oct 2017 00:59:42 -0700 (PDT)
Date: Sat, 7 Oct 2017 09:59:36 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 1/2] Revert "vmalloc: back off when the current task is
 killed"
Message-ID: <20171007075936.nldmvdt6nhujufec@dhcp22.suse.cz>
References: <20171004231821.GA3610@cmpxchg.org>
 <20171005075704.enxdgjteoe4vgbag@dhcp22.suse.cz>
 <55d8bf19-3f29-6264-f954-8749ea234efd@I-love.SAKURA.ne.jp>
 <ceb25fb9-de4d-e401-6d6d-ce240705483c@I-love.SAKURA.ne.jp>
 <20171007025131.GA12944@cmpxchg.org>
 <201710071305.GJF12474.HSOtLFFJVQFOOM@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201710071305.GJF12474.HSOtLFFJVQFOOM@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, alan@llwyncelyn.cymru, hch@lst.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Sat 07-10-17 13:05:24, Tetsuo Handa wrote:
> Johannes Weiner wrote:
> > On Sat, Oct 07, 2017 at 11:21:26AM +0900, Tetsuo Handa wrote:
> > > On 2017/10/05 19:36, Tetsuo Handa wrote:
> > > > I don't want this patch backported. If you want to backport,
> > > > "s/fatal_signal_pending/tsk_is_oom_victim/" is the safer way.
> > > 
> > > If you backport this patch, you will see "complete depletion of memory reserves"
> > > and "extra OOM kills due to depletion of memory reserves" using below reproducer.
> > > 
> > > ----------
> > > #include <linux/module.h>
> > > #include <linux/slab.h>
> > > #include <linux/oom.h>
> > > 
> > > static char *buffer;
> > > 
> > > static int __init test_init(void)
> > > {
> > > 	set_current_oom_origin();
> > > 	buffer = vmalloc((1UL << 32) - 480 * 1048576);
> > 
> > That's not a reproducer, that's a kernel module. It's not hard to
> > crash the kernel from within the kernel.
> > 
> 
> When did we agree that "reproducer" is "userspace program" ?
> A "reproducer" is a program that triggers something intended.

This way of argumentation is just ridiculous. I can construct whatever
code to put kernel on knees and there is no way around it.

The patch in question was supposed to mitigate a theoretical problem
while it caused a real issue seen out there. That is a reason to
revert the patch. Especially when a better mitigation has been put
in place. You are right that replacing fatal_signal_pending by
tsk_is_oom_victim would keep the original mitigation in pre-cd04ae1e2dc8
kernels but I would only agree to do that if the mitigated problem was
real. And this doesn't seem to be the case. If any of the stable kernels
regresses due to the revert I am willing to put a mitigation in place.
 
> Year by year, people are spending efforts for kernel hardening.
> It is silly to say that "It's not hard to crash the kernel from
> within the kernel." when we can easily mitigate.

This is true but we do not spread random hacks around for problems that
are not real and there are better ways to address them. In this
particular case cd04ae1e2dc8 was a better way to address the problem in
general without spreading tsk_is_oom_victim all over the place.
 
> Even with cd04ae1e2dc8, there is no point with triggering extra
> OOM kills by needlessly consuming memory reserves.

Yet again you are making unfounded claims and I am really fed up
arguing discussing that any further.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
