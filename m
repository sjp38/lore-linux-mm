Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A9C9C6B02A4
	for <linux-mm@kvack.org>; Thu, 22 Jul 2010 15:01:11 -0400 (EDT)
Date: Fri, 23 Jul 2010 05:01:00 +1000
From: Nick Piggin <npiggin@kernel.dk>
Subject: VFS scalability git tree
Message-ID: <20100722190100.GA22269@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Frank Mayhar <fmayhar@google.com>, John Stultz <johnstul@us.ibm.com>
List-ID: <linux-mm.kvack.org>

I'm pleased to announce I have a git tree up of my vfs scalability work.

git://git.kernel.org/pub/scm/linux/kernel/git/npiggin/linux-npiggin.git
http://git.kernel.org/?p=linux/kernel/git/npiggin/linux-npiggin.git

Branch vfs-scale-working

The really interesting new item is the store-free path walk, (43fe2b)
which I've re-introduced. It has had a complete redesign, it has much
better performance and scalability in more cases, and is actually sane
code now.

What this does is to allow parallel name lookups to walk down common
elements without any cacheline bouncing between them.  It can walk
across many interesting cases such as mount points, back up '..', and
negative dentries of most filesystems. It does so without requiring any
atomic operations or any stores at all to hared data.  This also makes
it very fast in serial performance (path walking is nearly twice as fast
on my Opteron).

In cases where it cannot continue the RCU walk (eg. dentry does not
exist), then it can in most cases take a reference on the farthest
element it has reached so far, and then continue on with a regular
refcount-based path walk. My first attempt at this simply dropped
everything and re-did the full refcount based walk.

I've also been working on stress testing, bug fixing, cutting down
'XXX'es, and improving changelogs and comments.

Most filesystems are untested (it's too large a job to do comprehensive
stress tests on everything), but none have known issues (except nilfs2).
Ext2/3, nfs, nfsd, and ram based filesystems seem to work well,
ext4/btrfs/xfs/autofs4 have had light testing.

I've never had filesystem corruption when testing these patches (only
lockups or other bugs). But standard disclaimer: they may eat your data.

Summary of a few numbers I've run. google's socket teardown workload
runs 3-4x faster on my 2 socket Opteron. Single thread git diff runs 20%
on same machine. 32 node Altix runs dbench on ramfs 150x faster (100MB/s
up to 15GB/s).

At this point, I would be very interested in reviewing, correctness
testing on different configurations, and of course benchmarking.

Thanks,
Nick

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
