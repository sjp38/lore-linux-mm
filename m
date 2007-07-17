In-reply-to: <20070614215817.389524447@chello.nl> (message from Peter Zijlstra
	on Thu, 14 Jun 2007 23:58:17 +0200)
Subject: Re: [PATCH 00/17] per device dirty throttling -v7
References: <20070614215817.389524447@chello.nl>
Message-Id: <E1IAk16-00007f-00@dorka.pomaz.szeredi.hu>
From: Miklos Szeredi <miklos@szeredi.hu>
Date: Tue, 17 Jul 2007 12:10:52 +0200
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: a.p.zijlstra@chello.nl
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, miklos@szeredi.hu, akpm@linux-foundation.org, neilb@suse.de, dgc@sgi.com, tomoki.sekiyama.qu@hitachi.com, nikita@clusterfs.com, trond.myklebust@fys.uio.no, yingchao.zhou@gmail.com, andrea@suse.de
List-ID: <linux-mm.kvack.org>

> Latest version of the per bdi dirty throttling patches.
> 
> Most of the changes since last time are little cleanups and more
> detail in the split out of the floating proportion into their
> own little lib.
> 
> Patches are against 2.6.22-rc4-mm2
> 
> A rollup of all this against 2.6.21 is available here:
>   http://programming.kicks-ass.net/kernel-patches/balance_dirty_pages/2.6.21-per_bdi_dirty_pages.patch
> 
> This patch-set passes the starve an USB stick test..

I've done some testing of several problem cases.

1) fuse writable mmap patches + bash_shared_mapping
2) writes in a setup involving a loop dev
  a) ext3 over loop over ext3
  b) ext3 over loop over fuse-passthrough over ext3
  c) ext3 over loop over ntfs-3g

Without the patch, in all the cases I've seen deadlocks or long
stalls.  With the patch, I could not reproduce this in any of the
cases.  As predicted, the patch is performing well in this respect :)

2a is the simplest to reproduce (2.6.22, dual core, 1GB ram)

  dd if=/dev/zero of=/tmp/p5 bs=1M seek=4999 count=1
  mkfs.ext3 -F /tmp/p5
  mkdir /tmp/m5
  mount -oloop /tmp/p5 /tmp/m5
  dd if=/dev/zero of=/tmp/m5/foo bs=1M count=4000

The second dd can stall for indefinite amounts of time.  Kicking it
with sync can get it moving, but it relapses after some time.

Even with the per-device-throttling patch, case 2 shows an nr_dirty
elevated far above the 10% limit, reaching 40% or higher.  I believe,
this is due to a missing balance_dirty_pages() call in the loop
device.  And indeed the anomaly can be solved by adding this patch:

  http://lkml.org/lkml/2007/3/24/101

Miklos

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
