Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id AF2676B0003
	for <linux-mm@kvack.org>; Wed, 13 Jun 2018 09:29:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id z9-v6so1308701pfe.23
        for <linux-mm@kvack.org>; Wed, 13 Jun 2018 06:29:49 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z3-v6si2404084pgn.365.2018.06.13.06.29.48
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Jun 2018 06:29:48 -0700 (PDT)
Date: Wed, 13 Jun 2018 15:29:44 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [rfc patch] mm, oom: fix unnecessary killing of additional
 processes
Message-ID: <20180613132944.GL13364@dhcp22.suse.cz>
References: <20180525072636.GE11881@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805251227380.158701@chino.kir.corp.google.com>
 <20180528081345.GD1517@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805301357100.150424@chino.kir.corp.google.com>
 <20180531063212.GF15278@dhcp22.suse.cz>
 <alpine.DEB.2.21.1805311400260.74563@chino.kir.corp.google.com>
 <20180601074642.GW15278@dhcp22.suse.cz>
 <alpine.DEB.2.21.1806042100200.71129@chino.kir.corp.google.com>
 <20180605085707.GV19202@dhcp22.suse.cz>
 <56138495-fd91-62f8-464a-db9960bfeb28@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56138495-fd91-62f8-464a-db9960bfeb28@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 13-06-18 22:20:49, Tetsuo Handa wrote:
> On 2018/06/05 17:57, Michal Hocko wrote:
> >> For this reason, we see testing harnesses often oom killed immediately 
> >> after running a unittest that stresses reclaim or compaction by inducing a 
> >> system-wide oom condition.  The harness spawns the unittest which spawns 
> >> an antagonist memory hog that is intended to be oom killed.  When memory 
> >> is mlocked or there are a large number of threads faulting memory for the 
> >> antagonist, the unittest and the harness itself get oom killed because the 
> >> oom reaper sets MMF_OOM_SKIP; this ends up happening a lot on powerpc.  
> >> The memory hog has mm->mmap_sem readers queued ahead of a writer that is 
> >> doing mmap() so the oom reaper can't grab the sem quickly enough.
> > 
> > How come the writer doesn't back off. mmap paths should be taking an
> > exclusive mmap sem in killable sleep so it should back off. Or is the
> > holder of the lock deep inside mmap path doing something else and not
> > backing out with the exclusive lock held?
> > 
>  
> Here is an example where the writer doesn't back off.
> 
>   http://lkml.kernel.org/r/20180607150546.1c7db21f70221008e14b8bb8@linux-foundation.org
> 
> down_write_killable(&mm->mmap_sem) is nothing but increasing the possibility of
> successfully back off. There is no guarantee that the owner of that exclusive
> mmap sem will not be blocked by other unkillable waits.

but we are talking about mmap() path here. Sure there are other paths
which might need a back off while the lock is held and that should be
addressed if possible but this is not really related to what David wrote
above and I tried to understand.

-- 
Michal Hocko
SUSE Labs
