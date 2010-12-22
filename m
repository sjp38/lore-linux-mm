Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 6FC3B6B0089
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 04:04:42 -0500 (EST)
Received: from kpbe20.cbf.corp.google.com (kpbe20.cbf.corp.google.com [172.25.105.84])
	by smtp-out.google.com with ESMTP id oBM94ehX013854
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 01:04:40 -0800
Received: from pwj5 (pwj5.prod.google.com [10.241.219.69])
	by kpbe20.cbf.corp.google.com with ESMTP id oBM94dJA026857
	for <linux-mm@kvack.org>; Wed, 22 Dec 2010 01:04:39 -0800
Received: by pwj5 with SMTP id 5so233332pwj.1
        for <linux-mm@kvack.org>; Wed, 22 Dec 2010 01:04:38 -0800 (PST)
Date: Wed, 22 Dec 2010 01:04:34 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch] memcg: add oom killer delay
In-Reply-To: <20101222174829.226ef641.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1012220057590.25848@chino.kir.corp.google.com>
References: <alpine.DEB.2.00.1012212318140.22773@chino.kir.corp.google.com> <20101221235924.b5c1aecc.akpm@linux-foundation.org> <20101222171749.06ef5559.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1012220043040.24462@chino.kir.corp.google.com>
 <20101222174829.226ef641.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Divyesh Shah <dpshah@google.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 22 Dec 2010, KAMEZAWA Hiroyuki wrote:

> > > seems to be hard to use. No one can estimate "milisecond" for avoidling
> > > OOM-kill. I think this is very bad. Nack to this feature itself.
> > > 
> > 
> > There's no estimation that is really needed, we simply need to be able to 
> > stall long enough that we'll eventually kill "something" if userspace 
> > fails to act.
> > 
> 
> Why we have to think of usermode failure by mis configuration or user mode bug ?
> It's a work of Middleware in usual.
> Please make libcgroup or libvirt more useful.
> 

It's a general concern for users who wish to defer the kernel oom killer 
unless userspace chooses not to act or cannot act and the only way to do 
that without memory.oom_delay is to set all memcgs to have 
memory.oom_control of 1.  memory.oom_control of 1 is equivalent to 
OOM_DISABLE for all attached tasks and if all tasks are assigned non-root 
memcg for resource isolation (and the sum of those memcgs' limits equals 
system RAM), we always get memcg oom kills instead of system wide oom 
kills.  The difference in this case is that with the memcg oom kills, the 
kernel livelocks whereas the system wide oom kills would panic the machine 
since all eligible tasks are OOM_DISABLE, the equivalent of all memcgs 
having memory.oom_control of 1.

Since the kernel has opened this possibility up by disabling oom killing 
without giving userspace any other chance of deferring the oom killer, we 
need a way to preserve the machine by having a fallback plan if userspace 
cannot act.  The other possibility would be to panic if all memcgs have 
memory.oom_control of 1 and the sum of their limits equals the machine's 
memory capacity.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
