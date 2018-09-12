Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 70CD98E0001
	for <linux-mm@kvack.org>; Tue, 11 Sep 2018 20:11:16 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r2-v6so77481pgp.3
        for <linux-mm@kvack.org>; Tue, 11 Sep 2018 17:11:16 -0700 (PDT)
Received: from out30-131.freemail.mail.aliyun.com (out30-131.freemail.mail.aliyun.com. [115.124.30.131])
        by mx.google.com with ESMTPS id b14-v6si22520517pgk.169.2018.09.11.17.11.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Sep 2018 17:11:14 -0700 (PDT)
Date: Tue, 11 Sep 2018 17:10:55 -0700
From: Liu Bo <bo.liu@linux.alibaba.com>
Subject: ext4 hang and per-memcg dirty throttling
Message-ID: <20180912001054.bu3x3xwukusnsa26@US-160370MP2.local>
Reply-To: bo.liu@linux.alibaba.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-ext4@vger.kernel.org
Cc: fengguang.wu@intel.com, tj@kernel.org, jack@suse.cz, cgroups@vger.kernel.org, gthelen@google.com, linux-mm@kvack.org, yang.shi@linux.alibaba.com

Hi,

With ext4's data=ordered mode and the underlying blk throttle setting, we
can easily run to hang,

1.
mount /dev/sdc /mnt -odata=ordered
2.
mkdir /sys/fs/cgroup/unified/cg
3.
echo "+io" > /sys/fs/cgroup/unified/cgroup.subtree_control
4.
echo "`cat /sys/block/sdc/dev` wbps=$((1 << 20))" > /sys/fs/cgroup/unified/cg/io.max
5.
echo $$ >  /sys/fs/cgroup/unified/cg/cgroup.procs
6.
// background dirtier
xfs_io -f -c "pwrite 0 1G" $M/dummy &
7.
echo $$ > /sys/fs/cgroup/unified/cgroup.procs
8.
// issue synchronous IO
for i in `seq 1 100`;
do
    xfs_io -f -s -c "pwrite 0 4k" $M/foo > /dev/null
done


And the hang is like

      [jbd2-sdc]
jbd2_journal_commit_transaction                              
  journal_submit_data_buffers
    # file 'dummy' has been written by writeback kthread
  journal_finish_inode_data_buffers
    # wait on page's writeback

Then all the operations of ext4 which need to start journal will have
to wait until journal committing transaction completes.

Since there is no per-memcg throttling, such as dirty ratio or dirty
bytes throttle, balance_dirty_pages() may not be able to slow down the
background dirtier task as expected.

I googled a little bit and found that Greg did the related work[1]
back in 2011, but seems the patch set didn't make it to kernel.

Now that we have writeback aware cgroup, is there any plan to push the
patch set again or are there any alternative solutions/suggestions?

[1]: https://lwn.net/Articles/455341/

thanks,
-liubo
