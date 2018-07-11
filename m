Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id CA39A6B0003
	for <linux-mm@kvack.org>; Wed, 11 Jul 2018 04:59:11 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n2-v6so9707772edr.5
        for <linux-mm@kvack.org>; Wed, 11 Jul 2018 01:59:11 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r15-v6si64166edo.320.2018.07.11.01.59.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Jul 2018 01:59:10 -0700 (PDT)
Date: Wed, 11 Jul 2018 10:59:08 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: remove sleep from under oom_lock
Message-ID: <20180711085908.GC20050@dhcp22.suse.cz>
References: <20180709074706.30635-1-mhocko@kernel.org>
 <alpine.DEB.2.21.1807091548280.125566@chino.kir.corp.google.com>
 <20180710094341.GD14284@dhcp22.suse.cz>
 <alpine.DEB.2.21.1807101152410.9234@chino.kir.corp.google.com>
 <alpine.DEB.2.21.1807101411480.29772@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1807101411480.29772@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue 10-07-18 14:12:28, David Rientjes wrote:
> On Tue, 10 Jul 2018, David Rientjes wrote:
> 
> > I think it's better, thanks.  However, does it address the question about 
> > why __oom_reap_task_mm() needs oom_lock protection?  Perhaps it would be 
> > helpful to mention synchronization between reaping triggered from 
> > oom_reaper and by exit_mmap().
> > 
> 
> Actually, can't we remove the need to take oom_lock in exit_mmap() if 
> __oom_reap_task_mm() can do a test and set on MMF_UNSTABLE and, if already 
> set, bail out immediately?

I think we do not really depend on oom_lock anymore in
__oom_reap_task_mm.  The race it was original added for (mmget_not_zero
vs. exit path) is no longer a problem. I didn't really get to evaluate
it deeper though. There are just too many things going on in parallel.

Tetsuo was proposing some patches to remove the lock but those patches
had some other problems. If we have a simple patch to remove the
oom_lock from the oom reaper then I will review it. I am not sure I can
come up with a patch myself in few days.
-- 
Michal Hocko
SUSE Labs
