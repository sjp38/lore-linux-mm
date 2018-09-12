Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id 13E748E0001
	for <linux-mm@kvack.org>; Wed, 12 Sep 2018 15:20:26 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id e124-v6so1383078pgc.11
        for <linux-mm@kvack.org>; Wed, 12 Sep 2018 12:20:26 -0700 (PDT)
Received: from out4436.biz.mail.alibaba.com (out4436.biz.mail.alibaba.com. [47.88.44.36])
        by mx.google.com with ESMTPS id p12-v6si1863995pls.53.2018.09.12.12.20.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Sep 2018 12:20:24 -0700 (PDT)
Date: Wed, 12 Sep 2018 12:19:42 -0700
From: Liu Bo <bo.liu@linux.alibaba.com>
Subject: Re: ext4 hang and per-memcg dirty throttling
Message-ID: <20180912191940.ka6rdgprgfbs7mec@US-160370MP2.local>
Reply-To: bo.liu@linux.alibaba.com
References: <20180912001054.bu3x3xwukusnsa26@US-160370MP2.local>
 <20180912121130.GF7782@quack2.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180912121130.GF7782@quack2.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-ext4@vger.kernel.org, fengguang.wu@intel.com, tj@kernel.org, cgroups@vger.kernel.org, gthelen@google.com, linux-mm@kvack.org, yang.shi@linux.alibaba.com

On Wed, Sep 12, 2018 at 02:11:30PM +0200, Jan Kara wrote:
> Hi!
> 
> On Tue 11-09-18 17:10:55, Liu Bo wrote:
> > With ext4's data=ordered mode and the underlying blk throttle setting, we
> > can easily run to hang,
> > 
> > 1.
> > mount /dev/sdc /mnt -odata=ordered
> > 2.
> > mkdir /sys/fs/cgroup/unified/cg
> > 3.
> > echo "+io" > /sys/fs/cgroup/unified/cgroup.subtree_control
> > 4.
> > echo "`cat /sys/block/sdc/dev` wbps=$((1 << 20))" > /sys/fs/cgroup/unified/cg/io.max
> > 5.
> > echo $$ >  /sys/fs/cgroup/unified/cg/cgroup.procs
> > 6.
> > // background dirtier
> > xfs_io -f -c "pwrite 0 1G" $M/dummy &
> > 7.
> > echo $$ > /sys/fs/cgroup/unified/cgroup.procs
> > 8.
> > // issue synchronous IO
> > for i in `seq 1 100`;
> > do
> >     xfs_io -f -s -c "pwrite 0 4k" $M/foo > /dev/null
> > done
> > 
> > 
> > And the hang is like
> > 
> >       [jbd2-sdc]
> > jbd2_journal_commit_transaction                              
> >   journal_submit_data_buffers
> >     # file 'dummy' has been written by writeback kthread
> >   journal_finish_inode_data_buffers
> >     # wait on page's writeback
> 
> Yes, I guess you're speaking about the one Chris Mason mentioned [1].

Exactly.

> Essentially it's a priority inversion where jbd2 thread gets blocked behind
> writeback done on behalf of a heavily restricted process. It actually is
> not related to dirty throttling or anything like that. And the solution for
> this priority inversion is to use unwritten extents for writeback
> unconditionally as I wrote in that thread. The core of this is implemented
> and hidden behind dioread_nolock mount option but it needs some serious
> polishing work and testing...

Thank you so much for the details, so setting extent to unwritten and
then converting it in endio does work and keeps the data=ordered
semantic but I have to say the name, "dioread_nolock", is really
confusing...

thanks,
-liubo
> 
> [1] https://marc.info/?l=linux-fsdevel&m=151688776319077
> 
> 								Honza
> -- 
> Jan Kara <jack@suse.com>
> SUSE Labs, CR
