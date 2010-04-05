Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1E79B6B01EE
	for <linux-mm@kvack.org>; Mon,  5 Apr 2010 19:01:17 -0400 (EDT)
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id o35N1AMx013116
	for <linux-mm@kvack.org>; Mon, 5 Apr 2010 16:01:11 -0700
Received: from pwj10 (pwj10.prod.google.com [10.241.219.74])
	by kpbe17.cbf.corp.google.com with ESMTP id o35N17gn002434
	for <linux-mm@kvack.org>; Mon, 5 Apr 2010 16:01:09 -0700
Received: by pwj10 with SMTP id 10so3063558pwj.40
        for <linux-mm@kvack.org>; Mon, 05 Apr 2010 16:01:07 -0700 (PDT)
Date: Mon, 5 Apr 2010 16:01:04 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] memcg: make oom killer a no-op when no killable task
 can be found
In-Reply-To: <20100405154923.23228529.akpm@linux-foundation.org>
Message-ID: <alpine.DEB.2.00.1004051552400.27040@chino.kir.corp.google.com>
References: <20100328145528.GA14622@desktop> <20100328162821.GA16765@redhat.com> <alpine.DEB.2.00.1003281341590.30570@chino.kir.corp.google.com> <20100329140633.GA26464@desktop> <alpine.DEB.2.00.1003291259400.14859@chino.kir.corp.google.com>
 <20100330142923.GA10099@desktop> <alpine.DEB.2.00.1003301326490.5234@chino.kir.corp.google.com> <20100331095714.9137caab.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.1003302302420.22316@chino.kir.corp.google.com> <20100331151356.673c16c0.kamezawa.hiroyu@jp.fujitsu.com>
 <20100331063007.GN3308@balbir.in.ibm.com> <alpine.DEB.2.00.1003302331001.839@chino.kir.corp.google.com> <alpine.DEB.2.00.1003310007450.9287@chino.kir.corp.google.com> <alpine.DEB.2.00.1004041627100.7198@chino.kir.corp.google.com>
 <20100405143059.3b56862f.akpm@linux-foundation.org> <alpine.DEB.2.00.1004051533170.20683@chino.kir.corp.google.com> <20100405154923.23228529.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, anfei <anfei.zhou@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, nishimura@mxp.nes.nec.co.jp, Balbir Singh <balbir@linux.vnet.ibm.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 5 Apr 2010, Andrew Morton wrote:

> > This patch applies cleanly on mmotm-2010-03-24-14-48 and I don't see 
> > anything that has been added since then that touches 
> > mem_cgroup_out_of_memory().
> 
> I'm working on another mmotm at present.
> 

Nothing else you've merged since mmotm-2010-03-24-14-48 has touched 
mem_cgroup_out_of_memory() that I've been cc'd on.  This patch should 
apply cleanly.

> > I haven't seen any outstanding compatibility issues raised.  The only 
> > thing that isn't backwards compatible is consolidating 
> > /proc/sys/vm/oom_kill_allocating_task and /proc/sys/vm/oom_dump_tasks into 
> > /proc/sys/vm/oom_kill_quick.  We can do that because we've enabled 
> > oom_dump_tasks by default so that systems that use both of these tunables 
> > need to now disable oom_dump_tasks to avoid the costly tasklist scan.  
> 
> This can break stuff, as I've already described - if a startup tool is
> correctly checking its syscall return values and a /procfs file
> vanishes, the app may bail out and not work.
> 

This is not the first time we have changed or obsoleted tunables in 
/proc/sys/vm.  If a startup tool really is really bailing out depending on 
whether echo 1 > /proc/sys/vm/oom_kill_allocating_task succeeds, it should 
be fixed regardless because you're not protecting anything by doing that 
since you can't predict what task is allocating memory at the time of oom.  
Those same startup tools will need to disable /proc/sys/vm/oom_dump_tasks 
if we are to remove the consolidation into oom_kill_quick and maintain two 
seperate VM sysctls that are always used together by the same users.

Nobody can even cite a single example of oom_kill_allocating_task being 
used in practice, yet we want to unnecessarily maintain these two seperate 
sysctls forever because it's possible that a buggy startup tool cares 
about the return value of enabling it?

> Others had other objections, iirc.
> 

I'm all ears.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
