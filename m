Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 5E62F6B006A
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 23:46:03 -0500 (EST)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n0F4jtSM000516
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 10:15:55 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0F4k0Vq2576618
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 10:16:00 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n0F4jtnP004029
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:45:55 +1100
Date: Thu, 15 Jan 2009 10:15:57 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
	obsolete
Message-ID: <20090115044557.GG21516@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp> <20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp> <20090114135539.GA21516@balbir.in.ibm.com> <20090115122416.e15d88a7.kamezawa.hiroyu@jp.fujitsu.com> <20090115041750.GE21516@balbir.in.ibm.com> <20090115134114.dba6b83a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090115134114.dba6b83a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-15 13:41:14]:

> On Thu, 15 Jan 2009 09:47:50 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-15 12:24:16]:
> 
> > > But I don't like -EBUSY ;)
> > > 
> > > When rmdir() returns -EBUSY even if there are no (visible) children and tasks,
> > > our customer will take kdump and send it to me "please explain this kernel bug"
> > > 
> > > I'm sure it will happen ;)
> > >
> > 
> > OK, but memory.stat can show why the group is busy and with
> > move_to_parent() such issues should not occur right? I'll relook at
> > the code. Thanks for your input.
> > 
> 
> There was a design choice at swap_cgroup.
> 
> At rmdir, there may be used swap entry in memcg. (mem->memsw.usage can be > 0)
>   1. update all records in swap cgroup
>   2. just ignore account from swap, we can treat then at swap-in.
> 
> I implemented "2" by refcnt.
> 
> To do "1", we have to scan all used swap_cgroup but I don't want to scan all
> swap_cgroup entry at rmdir. It's heavy job.
> (*) To reduce memory usage by swap_cgroup, swap_cgroup just have a pointer to memcg
> (**) I implemented swap_cgroup as statically allocated array because I don't want
>     any dynamic memory allocation at swap-out and want to avoid unnecessary memory
>     usage.

Fair enough, but I don't like that we don't have any checks for

If parent still has children, parent should not go away. The
problem that Daisuke-San is seeing.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
