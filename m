Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 064BF6B006A
	for <linux-mm@kvack.org>; Wed, 14 Jan 2009 22:25:26 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n0F3PM0W025588
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 15 Jan 2009 12:25:24 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F279745DE57
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 12:25:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D073045DE51
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 12:25:21 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B61D21DB8043
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 12:25:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 689141DB803B
	for <linux-mm@kvack.org>; Thu, 15 Jan 2009 12:25:21 +0900 (JST)
Date: Thu, 15 Jan 2009 12:24:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 5/4] memcg: don't call res_counter_uncharge when
 obsolete
Message-Id: <20090115122416.e15d88a7.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090114135539.GA21516@balbir.in.ibm.com>
References: <20090113184533.6ffd2af9.nishimura@mxp.nes.nec.co.jp>
	<20090114175121.275ecd59.nishimura@mxp.nes.nec.co.jp>
	<20090114135539.GA21516@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelyanov <xemul@openvz.org>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Wed, 14 Jan 2009 19:25:39 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> [2009-01-14 17:51:21]:
> 
> > This is a new one. Please review.
> > 
> > ===
> > From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > 
> > mem_cgroup_get ensures that the memcg that has been got can be accessed
> > even after the directory has been removed, but it doesn't ensure that parents
> > of it can be accessed: parents might have been freed already by rmdir.
> > 
> > This causes a bug in case of use_hierarchy==1, because res_counter_uncharge
> > climb up the tree.
> > 
> > Check if the memcg is obsolete, and don't call res_counter_uncharge when obsole.
> > 
> > Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> 
> I liked the earlier, EBUSY approach that ensured that parents could
> not go away if children exist. IMHO, the code has gotten too complex
> and has too many corner cases. Time to revisit it.
> 

But I don't like -EBUSY ;)

When rmdir() returns -EBUSY even if there are no (visible) children and tasks,
our customer will take kdump and send it to me "please explain this kernel bug"

I'm sure it will happen ;)

-Kame



> -- 
> 	Balbir
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
