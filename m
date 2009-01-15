Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 824596B005C
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 23:17:55 -0500 (EST)
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28smtp09.in.ibm.com (8.13.1/8.13.1) with ESMTP id n0F44cb5001832
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 09:34:38 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n0F4Fwhm1937446
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 09:45:58 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id n0F4HlBw007303
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 15:17:48 +1100
Date: Thu, 15 Jan 2009 09:47:50 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
	obsolete
Message-ID: <20090115041750.GE21516@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp> <20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp> <20090114135539.GA21516@balbir.in.ibm.com> <20090115122416.e15d88a7.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090115122416.e15d88a7.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

* KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-01-15 12:24:16]:

> On Wed, 14 Jan 2009 19:25:39 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > * Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2009-01-14 17:51:21]:
> > 
> > > This is a new one. Please review.
> > > 
> > > ===
> > > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > > 
> > > mem_cgroup_get ensures that the memcg that has been got can be accessed
> > > even after the directory has been removed, but it doesn't ensure that parents
> > > of it can be accessed: parents might have been freed already by rmdir.
> > > 
> > > This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
> > > climb up the tree.
> > > 
> > > Check if the memcg is obsolete, and don't call res_counter_uncharge when obsole.
> > > 
> > > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > I liked the earlier, EBUSY approach that ensured that parents could
> > not go away if children exist. IMHO, the code has gotten too complex
> > and has too many corner cases. Time to revisit it.
> > 
> 
> But I don't like -EBUSY ;)
> 
> When rmdir() returns -EBUSY even if there are no (visible) children and tasks,
> our customer will take kdump and send it to me "please explain this kernel bug"
> 
> I'm sure it will happen ;)
>

OK, but memory.stat can show why the group is busy and with
move_to_parent() such issues should not occur right? I'll relook at
the code. Thanks for your input.

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
