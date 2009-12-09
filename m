Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id DB40A60079C
	for <linux-mm@kvack.org>; Wed,  9 Dec 2009 16:32:47 -0500 (EST)
Subject: VFS and IMA API patch series please pull
From: Eric Paris <eparis@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 09 Dec 2009 16:25:52 -0500
Message-Id: <1260393952.3344.18.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-cachefs@redhat.com, ecryptfs-devel@lists.launchpad.net, linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org, linux-arch@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-security-module@vger.kernel.org
Cc: rdunlap@xenotime.net, zohar@linux.vnet.ibm.com, eparis@redhat.com, jmorris@namei.org, serue@us.ibm.com, dhowells@redhat.com, steved@redhat.com, tiwai@suse.de, viro@zeniv.linux.org.uk, tyhicks@linux.vnet.ibm.com, kirkland@canonical.com, akpm@linux-foundation.org, npiggin@suse.de, wli@holomorphy.com, mel@csn.ul.ie, shuber2@gmail.com, dsmith@redhat.com, jack@suse.cz, jmalicki@metacarta.com, hch@lst.de, bfields@fieldses.org, neilb@suse.de, agruen@suse.de, john@johnmccutchan.com, rlove@rlove.org, ebiederm@xmission.com, heiko.carstens@de.ibm.com, penguin-kernel@I-love.SAKURA.ne.jp, miklos@szeredi.hu, jens.axboe@oracle.com, arnd@arndb.de, drepper@redhat.com, a.p.zijlstra@chello.nl, Trond.Myklebust@netapp.com, matthew@wil.cx, hooanon05@yahoo.co.jp, mingo@elte.hu, rusty@rustcorp.com.au, penberg@cs.helsinki.fi, clg@fr.ibm.com, hugh.dickins@tiscali.co.uk, vapier@gentoo.org, kamezawa.hiroyu@jp.fujitsu.com, nishimura@mxp.nes.nec.co.jp, davem@davemloft.net, eric.dumazet@gmail.com, sgrubb@redhat.com
List-ID: <linux-mm.kvack.org>

I've sent this patch series out a couple of times but at now 18 patches
long and all having received acks I don't want to send the whole series
again.  I have a version based of off linus' tree including all of the
ACKs I received on list and which has been run through the LTP test
suite successfully.  This series basically does two things.

1) removes all users of get_empty_filp() and init_file()
2) reworks the ima API to hide it under the LSM and remove its hooks
into individual filesystems (shmem, pipes, hugetables, ecrypts, nfs,
networking, ?afs?).

This repo contains all of the patches including those which actually
make init_file() static and remove init_file() from the headers.  They
remove the EXPORT_SYMBOL for those as well.  If a deprecation is
required for out of tree kernel code they can still be exported but that
out of tree code will now certainly fail to work with IMA and will
result in (harmless) printk spam.

I'm not sure who the best person to pull this would be.  VFS maintainer?
Al?  Should I just send straight to Linus?  I'm not sure what the best
path is.  All of the individual fs changes have been acked by their
respective maintainers and the IMA work has been acked by the IMA
maintainer.  The only patches without CLEAR acks and review are the two
which remove the get_empty_filp() and init_file() calls.

The following changes since commit 2b876f95d03e226394b5d360c86127cbefaf614b:
  Linus Torvalds (1):
        Merge branches 'timers-for-linus-ntp' and 'irq-core-for-linus' of git://git.kernel.org/.../tip/linux-2.6-tip

are available in the git repository at:

  git://git.infradead.org/users/eparis/vfsima.git master

Eric Paris (14):
      shmem: do not call fput_filp on an initialized filp
      shmem: use alloc_file instead of init_file
      pipes: use alloc-file instead of duplicating code
      inotify: use alloc_file instead of doing it internally
      networking: rework socket to fd mapping using alloc-file
      vfs: make init-file static
      fs: move get_empty_filp() deffinition to internal.h
      ima: valid return code from ima_inode_alloc
      ima: only insert at inode creation time
      ima: initialize ima before inodes can be allocated
      IMA: clean up the IMA counts updating code
      ima: call ima_inode_free ima_inode_free
      ima: move ima hooks to __dentry_open for easier ima API
      ima: rename ima_path_check to ima_file_check

Mimi Zohar (4):
      ima: Fix refcnt bug in get_path_measurement
      security: move ima_file_check() to lsm hook
      ima: limit imbalance msg
      ima: rename PATH_CHECK to FILE_CHECK

 Documentation/ABI/testing/ima_policy |   12 +-
 fs/cachefiles/rdwr.c                 |    2 -
 fs/ecryptfs/main.c                   |    3 -
 fs/file_table.c                      |   81 +++++------
 fs/hugetlbfs/inode.c                 |    2 -
 fs/internal.h                        |    1 +
 fs/namei.c                           |   35 +----
 fs/nfsd/vfs.c                        |   14 --
 fs/notify/inotify/inotify_user.c     |   23 +-
 fs/open.c                            |    9 +-
 fs/pipe.c                            |   21 +--
 include/asm-generic/fcntl.h          |    8 +
 include/linux/file.h                 |    3 -
 include/linux/fs.h                   |    7 +-
 include/linux/ima.h                  |   16 +--
 init/main.c                          |    2 +-
 ipc/mqueue.c                         |    2 -
 ipc/shm.c                            |    2 -
 mm/shmem.c                           |   25 ++--
 net/socket.c                         |  123 ++++++----------
 security/integrity/ima/ima.h         |    6 +-
 security/integrity/ima/ima_api.c     |    4 +-
 security/integrity/ima/ima_iint.c    |   84 ++---------
 security/integrity/ima/ima_main.c    |  273 +++++++++++++++++-----------------
 security/integrity/ima/ima_policy.c  |   19 ++-
 security/security.c                  |    8 +-
 26 files changed, 324 insertions(+), 461 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
