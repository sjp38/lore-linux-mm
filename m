Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 7939C6B0047
	for <linux-mm@kvack.org>; Tue,  5 Jan 2010 23:06:11 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o064691O004096
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 6 Jan 2010 13:06:09 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 05CB445DE4D
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 13:06:09 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D9C3D45DE51
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 13:06:08 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id BDA39E38002
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 13:06:08 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E8F21DB8038
	for <linux-mm@kvack.org>; Wed,  6 Jan 2010 13:06:08 +0900 (JST)
Date: Wed, 6 Jan 2010 13:02:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Shared page accounting for memory cgroup
Message-Id: <20100106130258.a918e047.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100104005030.GG16187@balbir.in.ibm.com>
References: <20091229182743.GB12533@balbir.in.ibm.com>
	<20100104085108.eaa9c867.kamezawa.hiroyu@jp.fujitsu.com>
	<20100104000752.GC16187@balbir.in.ibm.com>
	<20100104093528.04846521.kamezawa.hiroyu@jp.fujitsu.com>
	<20100104005030.GG16187@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Mon, 4 Jan 2010 06:20:31 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-04 09:35:28]:
> 
> > On Mon, 4 Jan 2010 05:37:52 +0530
> > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > 
> > > * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2010-01-04 08:51:08]:
> > > 
> > > > On Tue, 29 Dec 2009 23:57:43 +0530
> > > > Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> > > > 
> > > > > Hi, Everyone,
> > > > > 
> > > > > I've been working on heuristics for shared page accounting for the
> > > > > memory cgroup. I've tested the patches by creating multiple cgroups
> > > > > and running programs that share memory and observed the output.
> > > > > 
> > > > > Comments?
> > > > 
> > > > Hmm? Why we have to do this in the kernel ?
> > > >
> > > 
> > > For several reasons that I can think of
> > > 
> > > 1. With task migration changes coming in, getting consistent data free of races
> > > is going to be hard.
> > 
> > Hmm, Let's see real-worlds's "ps" or "top" command. Even when there are no guarantee
> > of error range of data, it's still useful.
> 
> Yes, my concern is this
> 
> 1. I iterate through tasks and calculate RSS
> 2. I look at memory.usage_in_bytes
> 
> If the time in user space between 1 and 2 is large I get very wrong
> results, specifically if the workload is changing its memory usage
> drastically.. no?
> 
No. If it takes long time, locking fork()/exit() for such long time is the bigger
issue.
I recommend you to add memacct subsystem to sum up RSS of all processes's RSS counting
under a cgroup.  Althoght it may add huge costs in page fault path but implementation
will be very simple and will not hurt realtime ops.
There will be no terrible race, I guess.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
