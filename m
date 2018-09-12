Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id C47658E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 08:11:32 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id k16-v6so789651ede.6
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 05:11:32 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id g25-v6si1129447edp.145.2018.09.12.05.11.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 05:11:31 -0700 (PDT)
Date: Wed, 12 Sep 2018 14:11:30 +0200
From: Jan Kara <jack@suse.cz>
Subject: Re: ext4 hang and per-memcg dirty throttling
Message-ID: <20180912121130.GF7782@quack2.suse.cz>
References: <20180912001054.bu3x3xwukusnsa26@US-160370MP2.local>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912001054.bu3x3xwukusnsa26@US-160370MP2.local>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Liu Bo <bo.liu@linux.alibaba.com>
Cc: linux-ext4@vger.kernel.org, fengguang.wu@intel.com, tj@kernel.org, jack@suse.cz, cgroups@vger.kernel.org, gthelen@google.com, linux-mm@kvack.org, yang.shi@linux.alibaba.com

Hi!

On Tue 11-09-18 17:10:55, Liu Bo wrote:
> With ext4's data=ordered mode and the underlying blk throttle setting, we
> can easily run to hang,
> 
> 1.
> mount /dev/sdc /mnt -odata=ordered
> 2.
> mkdir /sys/fs/cgroup/unified/cg
> 3.
> echo "+io" > /sys/fs/cgroup/unified/cgroup.subtree_control
> 4.
> echo "`cat /sys/block/sdc/dev` wbps=$((1 << 20))" > /sys/fs/cgroup/unified/cg/io.max
> 5.
> echo $$ >  /sys/fs/cgroup/unified/cg/cgroup.procs
> 6.
> // background dirtier
> xfs_io -f -c "pwrite 0 1G" $M/dummy &
> 7.
> echo $$ > /sys/fs/cgroup/unified/cgroup.procs
> 8.
> // issue synchronous IO
> for i in `seq 1 100`;
> do
>     xfs_io -f -s -c "pwrite 0 4k" $M/foo > /dev/null
> done
> 
> 
> And the hang is like
> 
>       [jbd2-sdc]
> jbd2_journal_commit_transaction                              
>   journal_submit_data_buffers
>     # file 'dummy' has been written by writeback kthread
>   journal_finish_inode_data_buffers
>     # wait on page's writeback

Yes, I guess you're speaking about the one Chris Mason mentioned [1].
Essentially it's a priority inversion where jbd2 thread gets blocked behind
writeback done on behalf of a heavily restricted process. It actually is
not related to dirty throttling or anything like that. And the solution for
this priority inversion is to use unwritten extents for writeback
unconditionally as I wrote in that thread. The core of this is implemented
and hidden behind dioread_nolock mount option but it needs some serious
polishing work and testing...

[1] https://marc.info/?l=linux-fsdevel&m=151688776319077

								Honza
-- 
Jan Kara <jack@suse.com>
SUSE Labs, CR
