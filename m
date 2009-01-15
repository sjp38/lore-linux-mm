Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 769066B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 23:53:34 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F4rWna018093
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 13:53:32 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8035545DD74
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 13:53:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 639FC45DD72
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 13:53:33 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CAA8D1DB803A
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 13:53:31 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4F8EA1DB803F
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 13:53:28 +0900 (JST)
Date: Thu, 15 Jan 2009 13:52:23 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
 obsolete
Message-Id: <20090115135223.1789e639.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090115041750.GE21516@balbir.in.ibm.com>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
	<20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
	<20090114135539.GA21516@balbir.in.ibm.com>
	<20090115122416.e15d88a7.kamezawa.hiroyu@jp.fujitsu.com>
	<20090115041750.GE21516@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Thu, 15 Jan 2009 09:47:50 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-15 12:24:16]:
> 
> > On Wed, 14 Jan 2009 19:25:39 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2009-01-14 17:51:21]:
> > > 
> > > > This is a new one. Please review.
> > > > 
> > > > ===
> > > > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > > 
> > > > mem_cgroup_get ensures that the memcg that has been got can be accessed
> > > > even after the directory has been removed, but it doesn't ensure that parents
> > > > of it can be accessed: parents might have been freed already by rmdir.
> > > > 
> > > > This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
> > > > climb up the tree.
> > > > 
> > > > Check if the memcg is obsolete, and don't call res_counter_uncharge when obsole.
> > > > 
> > > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > 
> > > I liked the earlier, EBUSY approach that ensured that parents could
> > > not go away if children exist. IMHO, the code has gotten too complex
> > > and has too many corner cases. Time to revisit it.
> > > 
> > 
> > But I don't like -EBUSY ;)
> > 
> > When rmdir() returns -EBUSY even if there are no (visible) children and tasks,
> > our customer will take kdump and send it to me "please explain this kernel bug"
> > 
> > I'm sure it will happen ;)
> >
> 
> OK, but memory.stat can show why the group is busy and with
> move_to_parent() such issues should not occur right? I'll relook at
> the code. Thanks for your input.
> 
Write a shell script as following ?
==
  TASKS=`cat /xxx/xxx/xxx/tasks`
  if [ -n $TASKS ]; then
	echo "there is alive tasks in group /xxx/xxx/xxx/"
  fi
  
  rmdir /xxx/xxx/xxx/
  CODE=$?
  if [ $CODE = EBUSY ]; then
	investigate why....
  fi
==
I don't want.

I think rmdir() should succeed everywhen "there are no tasks and children".
And that can be done.

With Paul's suggestion, I'll add wait_queue for rmdir of cgroup.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
