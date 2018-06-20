Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 158426B0003
	for <linux-mm@kvack.org>; Wed, 20 Jun 2018 19:35:07 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 39-v6so628178ple.6
        for <linux-mm@kvack.org>; Wed, 20 Jun 2018 16:35:07 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id g14-v6si3310187plq.41.2018.06.20.16.35.04
        for <linux-mm@kvack.org>;
        Wed, 20 Jun 2018 16:35:05 -0700 (PDT)
Date: Thu, 21 Jun 2018 09:35:02 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: xfs: circular locking dependency between fs_reclaim and
 sb_internal [kernel 4.18]
Message-ID: <20180620233502.GP19934@dastard>
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

Fix the broken lockdep code?

Superblock freeze level accounting is not a lock. By the time a
freeze has got to the state where xfs_trans_alloc() would block,
we've already frozen new data writes and drained all the dirty
pages.  Hence if the filesystem is frozen down to the transaction
level, kswapd will never enter this path on the filesystem because
there will be no dirty pages to write back.

So this is a false positive.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
