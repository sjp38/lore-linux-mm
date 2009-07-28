Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id B93A86B004F
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 15:11:35 -0400 (EDT)
Received: from spaceape10.eur.corp.google.com (spaceape10.eur.corp.google.com [172.28.16.144])
	by smtp-out.google.com with ESMTP id n6SJBZqM019319
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 20:11:36 +0100
Received: from wf-out-1314.google.com (wfg24.prod.google.com [10.142.7.24])
	by spaceape10.eur.corp.google.com with ESMTP id n6SJBIAF029889
	for <linux-mm@kvack.org>; Tue, 28 Jul 2009 12:11:33 -0700
Received: by wf-out-1314.google.com with SMTP id 24so70539wfg.7
        for <linux-mm@kvack.org>; Tue, 28 Jul 2009 12:11:32 -0700 (PDT)
MIME-Version: 1.0
Date: Tue, 28 Jul 2009 12:11:31 -0700
Message-ID: <1786ab030907281211x6e432ba6ha6afe9de73f24e0c@mail.gmail.com>
Subject: Bug in kernel 2.6.31, Slow wb_kupdate writeout
From: Chad Talbott <ctalbott@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, wfg@mail.ustc.edu.cn, Martin Bligh <mbligh@google.com>, Michael Rubin <mrubin@google.com>, Andrew Morton <akpm@google.com>, sandeen@redhat.com
List-ID: <linux-mm.kvack.org>

I run a simple workload on a 4GB machine which dirties a few largish
inodes like so:

# seq 10 | xargs -P0 -n1 -i\{} dd if=/dev/zero of=/tmp/dump\{}
bs=1024k count=100

While the dds are running data is written out at disk speed.  However,
once the dds have run to completion and exited there is ~500MB of
dirty memory left.  Background writeout then takes about 3 more
minutes to clean memory at only ~3.3MB/s.  When I explicitly sync, I
can see that the disk is capable of 40MB/s, which finishes off the
files in ~10s. [1]

An interesting recent-ish change is "writeback: speed up writeback of
big dirty files."  When I revert the change to __sync_single_inode the
problem appears to go away and background writeout proceeds at disk
speed.  Interestingly, that code is in the git commit [2], but not in
the post to LKML. [3]  This is may not be the fix, but it makes this
test behave better.

Thanks,
Chad

[1] I've plotted the dirty memory from /proc/meminfo and disk write
speed from iostat at
http://sites.google.com/site/cwtlinux/2-6-31-writeback-bug
[2] git commit:
http://mirror.celinuxforum.org/gitstat/commit-detail.php?commit=8bc3be2751b4f74ab90a446da1912fd8204d53f7
[3] LKML post: http://marc.info/?l=linux-kernel&m=119131601130372&w=2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
