Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id E21AD8D003B
	for <linux-mm@kvack.org>; Mon, 11 Apr 2011 23:24:50 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id CE6EF3EE0AE
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 12:24:47 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B4B2B45DE4D
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 12:24:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 937CE45DE55
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 12:24:47 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 801AE1DB803A
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 12:24:47 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 36AA91DB802C
	for <linux-mm@kvack.org>; Tue, 12 Apr 2011 12:24:47 +0900 (JST)
Date: Tue, 12 Apr 2011 12:17:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [Lsf] IO less throttling and cgroup aware writeback
Message-Id: <20110412121758.02d52668.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20110408012556.GU31057@dastard>
References: <20110401214947.GE6957@dastard>
	<20110405131359.GA14239@redhat.com>
	<20110405225639.GB31057@dastard>
	<BANLkTikDPHcpjmb-EAiX+MQcu7hfE730DQ@mail.gmail.com>
	<20110406153954.GB18777@redhat.com>
	<xr937hb7568t.fsf@gthelen.mtv.corp.google.com>
	<20110406233602.GK31057@dastard>
	<20110407192424.GE27778@redhat.com>
	<20110407234249.GE30279@dastard>
	<xr93ei5dzhfs.fsf@gthelen.mtv.corp.google.com>
	<20110408012556.GU31057@dastard>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Greg Thelen <gthelen@google.com>, Vivek Goyal <vgoyal@redhat.com>, Curt Wohlgemuth <curtw@google.com>, James Bottomley <James.Bottomley@hansenpartnership.com>, lsf@lists.linux-foundation.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On Fri, 8 Apr 2011 11:25:56 +1000
Dave Chinner <david@fromorbit.com> wrote:

> On Thu, Apr 07, 2011 at 05:59:35PM -0700, Greg Thelen wrote:
> > cc: linux-mm
> > 
> > Dave Chinner <david@fromorbit.com> writes:

> > If we later find that this supposed uncommon shared inode case is
> > important then we can either implement the previously described lru
> > scanning in mem_cgroup_balance_dirty_pages() or consider extending the
> > bdi/memcg/inode data structures (perhaps with a memcg_mapping) to
> > describe such sharing.
> 
> Hmm, another idea I just had. What we're trying to avoid is needing
> to a) track inodes in multiple lists, and b) scanning to find
> something appropriate to write back.
> 
> Rather than tracking at page or inode granularity, how about
> tracking "associated" memcgs at the memcg level? i.e. when we detect
> an inode is already dirty in another memcg, link the current memcg
> to the one that contains the inode. Hence if we get a situation
> where a memcg is throttling with no dirty inodes, it can quickly
> find and start writeback in an "associated" memcg that it _knows_
> contain shared dirty inodes. Once we've triggered writeback on an
> associated memcg, it is removed from the list....
> 

Thank you for an idea. I think we can start from following.

 0. add some feature to set 'preferred inode' for memcg.
    I think
      fadvise(fd, MAKE_THIF_FILE_UNDER_MY_MEMCG)
    or
      echo fd > /memory.move_file_here
    can be added. 

 1. account dirty pages for a memcg. as Greg does.
 2. at the same time, account dirty pages made dirty by threads in a memcg.
    (to check which internal/external thread made page dirty.)
 3. calculate internal/external dirty pages gap.
 
 With gap, we can have several choices.

 4-a. If it exceeds some thresh, do some notify.
      userland daemon can decide to move pages to some memcg or not.
      (Of coruse, if the _shared_ dirty can be caught before making page dirty,
       user daemon can move inode before making it dirty by inotify().)

      I like helps of userland because it can be more flexible than kernel,
      it can eat config files.

 4-b. set some flag to memcg as 'this memcg is dirty busy because of some extarnal
      threads'. When a page is newly dirtied, check the thread's memcg.
      If the memcg of a thread and a page is different from each other,
      write a memo as 'please check this memcgid , too' in task_struct and
      do double-memcg-check in balance_dirty_pages().
      (How to clear per-task flag is difficult ;)

      I don't want to handle 3-100 threads does shared write case..;)
      we'll need 4-a.
 

Thanks,
-Kame








--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
