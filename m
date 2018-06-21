Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5193E6B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 20:15:15 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 70-v6so686013plc.1
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 17:15:15 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id s1-v6si2928945pgb.486.2018.06.20.17.15.13
        for <linux-mm@kvack.org>;
        Wed, 20 Jun 2018 17:15:14 -0700 (PDT)
Date: Thu, 21 Jun 2018 10:15:09 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: xfs: circular locking dependency between fs_reclaim and
 sb_internal [kernel 4.18]
Message-ID: <20180621001509.GQ19934@dastard>
References: <8fda53b0-9d86-943b-e8b4-fd9d6553f010@i-love.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8fda53b0-9d86-943b-e8b4-fd9d6553f010@i-love.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Dave Chinner <dchinner@redhat.com>, linux-xfs@vger.kernel.org, linux-mm@kvack.org, Omar Sandoval <osandov@fb.com>

On Wed, Jun 20, 2018 at 08:25:51PM +0900, Tetsuo Handa wrote:
> I'm hitting below lockdep warning (essentially same with
> http://lkml.kernel.org/r/1518666178.6070.25.camel@gmail.com ) as of commit
> ba4dbdedd3edc279 ("Merge tag 'jfs-4.18' of git://github.com/kleikamp/linux-shaggy")
> on linux.git . I think that this became visible by commit 93781325da6e07af
> ("lockdep: fix fs_reclaim annotation") which went to 4.18-rc1. What should we do?
> 
> [   63.207781] 
> [   63.471926] ======================================================
> [   64.432812] WARNING: possible circular locking dependency detected
> [   64.948272] 4.18.0-rc1+ #594 Tainted: G                T
> [   65.512546] ------------------------------------------------------
> [   65.519722] kswapd0/79 is trying to acquire lock:
> [   65.525792] 00000000f3581fab (sb_internal){.+.+}, at: xfs_trans_alloc+0xe0/0x120 [xfs]
> [   66.034497] 
> [   66.034497] but task is already holding lock:
> [   66.661024] 00000000c7665973 (fs_reclaim){+.+.}, at: __fs_reclaim_acquire+0x0/0x30
> [   67.554480] 
> [   67.554480] which lock already depends on the new lock.
> [   67.554480] 
> [   68.760085] 
> [   68.760085] the existing dependency chain (in reverse order) is:
> [   69.258520] 
> [   69.258520] -> #1 (fs_reclaim){+.+.}:
> [   69.623516] 
> [   69.623516] -> #0 (sb_internal){.+.+}:

BTW, where's the stack trace that was recorded when this ordering
was seen? Normally lockdep gives us all the relevant stack traces in
a report, and without this trace to tell us where it saw this order,
this bug report is mostly useless because we don't know what
inversion it has recorded and is complaining about.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
