Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D34006B01B2
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 02:35:54 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5T6Zquf004330
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 29 Jun 2010 15:35:52 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E343045DE50
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 15:35:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id BCDBB45DE4E
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 15:35:51 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9C5361DB803B
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 15:35:51 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C2DE1DB8037
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 15:35:51 +0900 (JST)
Date: Tue, 29 Jun 2010 15:30:59 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [ATTEND][LSF/VM TOPIC] deterministic cgroup charging using file
  path
Message-Id: <20100629153059.c49db3b6.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTik3l5jZlxqmDkkHdEFle4MJFcKLh1kPVNrK6CyE@mail.gmail.com>
References: <AANLkTin2PcB6PwKnuazv3oAy6Arg8yntylVvdCj7Mzz-@mail.gmail.com>
	<20100628110327.8cb51c0e.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTik3l5jZlxqmDkkHdEFle4MJFcKLh1kPVNrK6CyE@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: lsf10-pc@lists.linuxfoundation.org, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 2010 22:31:03 -0700
Greg Thelen <gthelen@google.com> wrote:

> On Sun, Jun 27, 2010 at 7:03 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Fri, 25 Jun 2010 13:43:45 -0700
> > Greg Thelen <gthelen@google.com> wrote:

> >> /dev/cgroup/cg1/cg11 A # T1: want memory.limit = 30MB
> >> /dev/cgroup/cg1/cg12 A # T2: want memory.limit = 100MB
> >> /dev/cgroup/cg1 A  A  A  # want memory.limit = 1GB + 30MB + 100MB
> >>
> >> I have implemented a prototype that allows a file system hierarchy be charge a
> >> particular cgroup using a new bind mount option:
> >> + mount -t cgroup none /cgroup -o memory
> >> + mount --bind /tmp/db /tmp/db -o cgroup=/dev/cgroup/cg1
> >>
> >> Any accesses to files within /tmp/db are charged to /dev/cgroup/cg1. A Access to
> >> other files behave normally - they charge the cgroup of the current task.
> >>
> >
> > Interesting, but I want to use madvice() etc..for this kind of jobs, rather than
> > deep hooks into the kernel.
> >
> > madvise(addr, size, MEMORY_RECHAEGE_THIS_PAGES_TO_ME);
> >
> > Then, you can write a command as:
> >
> > A file_recharge [path name] [cgroup]
> > A - this commands move a file cache to specified cgroup.
> >
> > A daemon program which uses this command + inotify will give us much
> > flexible controls on file cache on memcg. Do you have some requirements
> > that this move-charge shouldn't be done in lazy manner ?
> >
> > Status:
> > We have codes for move-charge, inotify but have no code for new madvise.
> >
> >
> > Thanks,
> > -Kame
> 
> This is an interesting approach.  I like the idea of minimizing kernel
> changes.  I want to make sure I understand the idea using terms from
> my above example.
> 
> 1. The daemon establishes inotify() watches on /tmp/db and all sub
> directories to catch any accesses.
> 
> 2. If cg11(T1) is the first process to mmap a portion of a /tmp/db
> file (pages_1) then cg11 will be charged.  T1 will not use madvise()
> because cg11 does not want to be charged.  cg11 will be temporarily
> charged for pages_1.
> 
yes.

> 3. inotify() will inform the proposed daemon that T1 opened /tmp/db,
> so the daemon will use file_recharge, which runs the following within
> the cg1 cgroup:
> - fd = open("/tmp/db/.../path_to_file")
> - va = mmap(NULL, size=stat(fd).st_size, fd)
> - madvise(fd, va, st_size, MEMORY_RECHARGE_THIS_PAGES_TO_ME).  This
> will move the charge of pages_1 from cg11 to cg1.
> 
> Did I state this correctly?
> 
yes.


> I am concerned that the follow-on step does not move the pages to cg1:
> 4. T1 then touches more /tmp/db pages (pages_2) using the same mmap.
> This charges cg11.  I assume that inotify() would not notify the
> daemon for this case because the file is still open. 
you're right.

> So the pages will not be moved to cg1.  Or are you suggesting
> that inotify() enhanced to advertise charge events?

IIUC, now, inotify() doesn't support mmap. But it has read/write notification.
So, let's think about mmapped pages.

For easy implementation, I suggest file_recharge should map the whole file
and move them all under it. But maybe this is an answer you want.

If I write an _easy_ daemon, which will do...

==
  register inotify and add watches.
  The wathces will see OPEN and IN_DELETE_SELF.

  run 2 threads.

Thread1:
  while(1) {
      read() // check events from inotify.
      maintain opened-file information.
  }

Thread2:
  while (1) {
      check opend-file information.
      select a file // you may implement some scheduling, here.
      open,
      mmap
      mincore() .... checks the file is cached.
      madvice() 
      // if you want, touch pages and add Access bit to them.
      close(),

      sleep if necessary.
 }
==
batch-style cron-job rather than sleep will not be very bad for usual use.
But we may need some interface to implement something clever algorithm.


> If the number of directories within /tmp/db is large, then inotify()
> maybe expensive.  I don't think this is a problem.
> 
> Another worry I have is that if for some reason the daemon is started
> after the job, or if the daemon crashes and is restarted, then files
> may have been opened and charged to cg11 without the inotify being
> setup. 
yes.

> The daemon would have problems finding the pages that were
> charged to cg11 and need to be moved to cg1.  The daemon could scan
> the open file table of T1, but any files that are no longer opened may
> be charged to cg11 with no way for the daemon to find them.
> 

Above thread-1 can maintain "opened-file" database.
Or you can run a recovery-scirpt to open /proc/<xxxx>/fd of processes
to trigger OPEN events.

But yes, some in-kernel approach may be required. as...new interface to memcg
rather than madvise.

/memory.move_file_caches
- when you open this and write()/ioctl() file descriptor to this file,
  all on-memory pages of files will be moved to this cgroup.

Hmm...we may be able to add an interface to know last-pagecache-update time.
(Because access-time is tend to be omitted at mount....)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
