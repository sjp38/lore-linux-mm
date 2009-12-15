Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 468276B0044
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 23:30:46 -0500 (EST)
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id nBF4UgJi000732
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 20:30:42 -0800
Received: from pxi10 (pxi10.prod.google.com [10.243.27.10])
	by kpbe15.cbf.corp.google.com with ESMTP id nBF4UNMV005471
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 20:30:41 -0800
Received: by pxi10 with SMTP id 10so2678760pxi.13
        for <linux-mm@kvack.org>; Mon, 14 Dec 2009 20:30:40 -0800 (PST)
Date: Mon, 14 Dec 2009 20:30:37 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask
 v4.2
In-Reply-To: <20091215103202.eacfd64e.kamezawa.hiroyu@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.0912142025090.29243@chino.kir.corp.google.com>
References: <20091110162121.361B.A69D9226@jp.fujitsu.com> <20091110163419.361E.A69D9226@jp.fujitsu.com> <20091110164055.a1b44a4b.kamezawa.hiroyu@jp.fujitsu.com> <20091110170338.9f3bb417.nishimura@mxp.nes.nec.co.jp> <20091110171704.3800f081.kamezawa.hiroyu@jp.fujitsu.com>
 <20091111112404.0026e601.kamezawa.hiroyu@jp.fujitsu.com> <20091111134514.4edd3011.kamezawa.hiroyu@jp.fujitsu.com> <20091111142811.eb16f062.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911102155580.2924@chino.kir.corp.google.com>
 <20091111152004.3d585cee.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911102224440.6652@chino.kir.corp.google.com> <20091111153414.3c263842.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911171609370.12532@chino.kir.corp.google.com>
 <20091118095824.076c211f.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0911171725050.13760@chino.kir.corp.google.com> <20091214171632.0b34d833.akpm@linux-foundation.org> <20091215103202.eacfd64e.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 15 Dec 2009, KAMEZAWA Hiroyuki wrote:

>     I'm now preparing more counters for mm's statistics. It's better to
>     wait  and to see what we can do more. And other patches for total
>     oom-killer improvement is under development.
> 
>     And, there is a compatibility problem.
>     As David says, this may break some crazy software which uses
>     fake_numa+cpuset+oom_killer+oom_adj for resource controlling.
>    (even if I recommend them to use memcg rather than crazy tricks...)
>     

That's not at all what I said.  I said using total_vm as a baseline allows 
users to define when a process is to be considered "rogue," that is, using 
more memory than expected.  Using rss would be inappropriate since it is 
highly dynamic and depends on the state of the VM at the time of oom, 
which userspace cannot possibly keep updated.

You consistently ignore that point: the power of /proc/pid/oom_adj to 
influence when a process, such as a memory leaker, is to be considered as 
a high priority for an oom kill.  It has absolutely nothing to do with 
fake NUMA, cpusets, or memcg.

>     2 ideas which I can think of now are..
>     1) add sysctl_oom_calc_on_committed_memory 
>        If this is set, use vm-size instead of rss.
> 

I would agree only if the oom killer used total_vm as a the default, it is 
long-standing and allows for the aforementioned capability that you lose 
with rss.  I have no problem with the added sysctl to use rss as the 
baseline when enabled.

>     2) add /proc/<pid>/oom_guard_size
>        This allows users to specify "valid/expected size" of a task.
>        When
>        #echo 10M > /proc/<pid>/oom_guard_size
>        At OOM calculation, 10Mbytes is subtracted from rss size.
>        (The best way is to estimate this automatically from vm_size..but...)

Expected rss is almost impossible to tune for cpusets that have a highly 
dynamic set of mems, let alone without containment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
