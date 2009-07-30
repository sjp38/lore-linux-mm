Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 3B4B96B004D
	for <linux-mm@kvack.org>; Thu, 30 Jul 2009 17:39:57 -0400 (EDT)
Date: Thu, 30 Jul 2009 23:39:56 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: Bug in kernel 2.6.31, Slow wb_kupdate writeout
Message-ID: <20090730213956.GH12579@kernel.dk>
References: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Chad Talbott <ctalbott@google.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, wfg@mail.ustc.edu.cn, Martin Bligh <mbligh@google.com>, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com
List-ID: <linux-mm.kvack.org>

On Tue, Jul 28 2009, Chad Talbott wrote:
> I run a simple workload on a 4GB machine which dirties a few largish
> inodes like so:
> 
> # seq 10 | xargs -P0 -n1 -i\{} dd if=/dev/zero of=/tmp/dump\{}
> bs=1024k count=100
> 
> While the dds are running data is written out at disk speed.  However,
> once the dds have run to completion and exited there is ~500MB of
> dirty memory left.  Background writeout then takes about 3 more
> minutes to clean memory at only ~3.3MB/s.  When I explicitly sync, I
> can see that the disk is capable of 40MB/s, which finishes off the
> files in ~10s. [1]
> 
> An interesting recent-ish change is "writeback: speed up writeback of
> big dirty files."  When I revert the change to __sync_single_inode the
> problem appears to go away and background writeout proceeds at disk
> speed.  Interestingly, that code is in the git commit [2], but not in
> the post to LKML. [3]  This is may not be the fix, but it makes this
> test behave better.

Can I talk you into trying the per-bdi writeback patchset? I just tried
your test on a 16gb machine, and the dd's finish immediately since it
wont trip the writeout at that percentage of dirty memory. The 1GB of
dirty memory is flushed when it gets too old, 30 seconds later in two
chunks of writeout running at disk speed.

http://lkml.org/lkml/2009/7/30/302

You can either use the git branch, or just download

http://kernel.dk/writeback-v13.patch

and apply that to -git (or -rc4) directly.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
