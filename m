Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2F62B6B006A
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 23:42:26 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F4gK7L013396
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 13:42:20 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1000645DD81
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 13:42:20 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CF67245DD7B
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 13:42:19 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 72F551DB8045
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 13:42:19 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E9A431DB8041
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 13:42:18 +0900 (JST)
Date: Thu, 15 Jan 2009 13:41:14 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
 obsolete
Message-Id: <20090115134114.dba6b83a.kamezawa.hiroyu@jp.fujitsu.com>
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

There was a design choice at swap_cgroup.

At rmdir, there may be used swap entry in memcg. (mem->memsw.usage can be > 0)
  1. update all records in swap cgroup
  2. just ignore account from swap, we can treat then at swap-in.

I implemented "2" by refcnt.

To do "1", we have to scan all used swap_cgroup but I don't want to scan all
swap_cgroup entry at rmdir. It's heavy job.
(*) To reduce memory usage by swap_cgroup, swap_cgroup just have a pointer to memcg
(**) I implemented swap_cgroup as statically allocated array because I don't want
    any dynamic memory allocation at swap-out and want to avoid unnecessary memory
    usage.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
