Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E0CE16B0047
	for <linux-mm@kvack.org>; Mon, 14 Dec 2009 23:47:58 -0500 (EST)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nBF4lu3p019674
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Tue, 15 Dec 2009 13:47:56 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 19D2545DE4E
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 13:47:56 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id E446D45DE4D
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 13:47:55 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id CC3DE1DB803C
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 13:47:55 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 880B01DB803A
	for <linux-mm@kvack.org>; Tue, 15 Dec 2009 13:47:55 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [BUGFIX][PATCH] oom-kill: fix NUMA consraint check with nodemask v4.2
In-Reply-To: <alpine.DEB.2.00.0912142025090.29243@chino.kir.corp.google.com>
References: <20091215103202.eacfd64e.kamezawa.hiroyu@jp.fujitsu.com> <alpine.DEB.2.00.0912142025090.29243@chino.kir.corp.google.com>
Message-Id: <20091215134319.CDD3.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Tue, 15 Dec 2009 13:47:54 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: kosaki.motohiro@jp.fujitsu.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

> On Tue, 15 Dec 2009, KAMEZAWA Hiroyuki wrote:
> 
> >     I'm now preparing more counters for mm's statistics. It's better to
> >     wait  and to see what we can do more. And other patches for total
> >     oom-killer improvement is under development.
> > 
> >     And, there is a compatibility problem.
> >     As David says, this may break some crazy software which uses
> >     fake_numa+cpuset+oom_killer+oom_adj for resource controlling.
> >    (even if I recommend them to use memcg rather than crazy tricks...)
> >     
> 
> That's not at all what I said.  I said using total_vm as a baseline allows 
> users to define when a process is to be considered "rogue," that is, using 
> more memory than expected.  Using rss would be inappropriate since it is 
> highly dynamic and depends on the state of the VM at the time of oom, 
> which userspace cannot possibly keep updated.
> 
> You consistently ignore that point: the power of /proc/pid/oom_adj to 
> influence when a process, such as a memory leaker, is to be considered as 
> a high priority for an oom kill.  It has absolutely nothing to do with 
> fake NUMA, cpusets, or memcg.

To compare vsz is only meaningful when the same program are compared.
But oom killer don't. To compare vsz between another program DONT detect
any memory leak.


> 
> >     2 ideas which I can think of now are..
> >     1) add sysctl_oom_calc_on_committed_memory 
> >        If this is set, use vm-size instead of rss.
> > 
> 
> I would agree only if the oom killer used total_vm as a the default, it is 
> long-standing and allows for the aforementioned capability that you lose 
> with rss.  I have no problem with the added sysctl to use rss as the 
> baseline when enabled.

Probably, nobody agree you. your opinion don't solve original issue.
kernel developer can't ignore bug report.


> 
> >     2) add /proc/<pid>/oom_guard_size
> >        This allows users to specify "valid/expected size" of a task.
> >        When
> >        #echo 10M > /proc/<pid>/oom_guard_size
> >        At OOM calculation, 10Mbytes is subtracted from rss size.
> >        (The best way is to estimate this automatically from vm_size..but...)
> 
> Expected rss is almost impossible to tune for cpusets that have a highly 
> dynamic set of mems, let alone without containment.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
