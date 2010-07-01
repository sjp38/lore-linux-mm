Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 7CEF06B01AC
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 02:37:49 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o616bk9R019349
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 1 Jul 2010 15:37:47 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D4E545DE6F
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 15:37:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A2A445DE60
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 15:37:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 540891DB803F
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 15:37:46 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 01B991DB8037
	for <linux-mm@kvack.org>; Thu,  1 Jul 2010 15:37:46 +0900 (JST)
Date: Thu, 1 Jul 2010 15:33:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [ATTEND][LSF/VM TOPIC] deterministic cgroup charging using file
  path
Message-Id: <20100701153303.0c5d6a2b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTik1eArS38wVYmnTNDal1AmLbWmvDCTH2Uv_95Dm@mail.gmail.com>
References: <AANLkTin2PcB6PwKnuazv3oAy6Arg8yntylVvdCj7Mzz-@mail.gmail.com>
	<20100628110327.8cb51c0e.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTik3l5jZlxqmDkkHdEFle4MJFcKLh1kPVNrK6CyE@mail.gmail.com>
	<20100629153059.c49db3b6.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTik1eArS38wVYmnTNDal1AmLbWmvDCTH2Uv_95Dm@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Greg Thelen <gthelen@google.com>
Cc: lsf10-pc@lists.linuxfoundation.org, linux-mm@kvack.org, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Ying Han <yinghan@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jun 2010 21:16:43 -0700
Greg Thelen <gthelen@google.com> wrote:

> > ==
> > A register inotify and add watches.
> > A The wathces will see OPEN and IN_DELETE_SELF.
> >
> > A run 2 threads.
> >
> > Thread1:
> > A while(1) {
> > A  A  A read() // check events from inotify.
> > A  A  A maintain opened-file information.
> > A }
> >
> > Thread2:
> > A while (1) {
> > A  A  A check opend-file information.
> > A  A  A select a file // you may implement some scheduling, here.
> > A  A  A open,
> > A  A  A mmap
> > A  A  A mincore() .... checks the file is cached.
> > A  A  A madvice()
> > A  A  A // if you want, touch pages and add Access bit to them.
> > A  A  A close(),
> >
> > A  A  A sleep if necessary.
> > A }
> > ==
> > batch-style cron-job rather than sleep will not be very bad for usual use.
> > But we may need some interface to implement something clever algorithm.
> 
> I have to collect some data about expected usages of this feature.  I
> will have more information tomorrow.  Depending on the how quickly the
> charges need to be corrected or the number of opened files, this
> daemon may end up doing a lot of polling to correct memory charges.
> 
maybe. but many applications works with a-lot-of-jobs without special
kernel support.



> >> If the number of directories within /tmp/db is large, then inotify()
> >> maybe expensive. A I don't think this is a problem.
> >>
> >> Another worry I have is that if for some reason the daemon is started
> >> after the job, or if the daemon crashes and is restarted, then files
> >> may have been opened and charged to cg11 without the inotify being
> >> setup.
> > yes.
> >
> >> The daemon would have problems finding the pages that were
> >> charged to cg11 and need to be moved to cg1. A The daemon could scan
> >> the open file table of T1, but any files that are no longer opened may
> >> be charged to cg11 with no way for the daemon to find them.
> >>
> >
> > Above thread-1 can maintain "opened-file" database.
> > Or you can run a recovery-scirpt to open /proc/<xxxx>/fd of processes
> > to trigger OPEN events.
> 
> If a file has been unlinked, then the OPEN events would need to scan
> /proc/xxx/fd to find an open file handle to open.  This is probably a
> corner case, but I wanted to mention it.
> 
sure.

> > But yes, some in-kernel approach may be required. as...new interface to memcg
> > rather than madvise.
> >
> > /memory.move_file_caches
> > - when you open this and write()/ioctl() file descriptor to this file,
> > A all on-memory pages of files will be moved to this cgroup.
> 
> Are you suggesting that this move_file_caches interface would
> associate the given file, dentry, or inode with the cgroup so that
> future charges are charged to the intended cgroup?  Or (I suspect)
> that the daemon would this need to be periodically use this routine to
> correct any incorrect charges.
> 
My idea is for recharging instead of mincode()+madise().


> > Hmm...we may be able to add an interface to know last-pagecache-update time.
> > (Because access-time is tend to be omitted at mount....)
> 
> Are you thinking that we could introduce a cgroup-wide attribute
> (maybe a timestamp, or increasing sequence number, or even just a bit)
> that would be set whenever a cgroup statistic (page cache usage in
> this case) was updated?  This bit would be cleared whenever all needed
> migrations occurred.  The daemon could poll this bit to know if any
> migrations were needed.

Now, memory cgroup has "threshold" cgroup notifier. 
I think it's useful in this case.

> 
> Another aspect that I am thinking would have to be added to the daemon
> would be oom handling.  If cg11 is charged for non-reclaimable files
> (tmpfs) that belong to cg1, then the task may oom.  The daemon would
> have to listen for oom and then immediately migration the charge from
> cg11 to cg1 to lower memory pressure in cg11.
> 

Now, memory cgroup has an interface to disable-oom-kill + oom-notifier.
I think it's useful.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
