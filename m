Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id D70356B0044
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 03:05:02 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA68503Q025669
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 6 Nov 2009 17:05:00 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id A8A5E45DE6E
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:04:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 7D64A45DE60
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:04:59 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 405E81DB803A
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:04:59 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C368C1DB803B
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 17:04:58 +0900 (JST)
Date: Fri, 6 Nov 2009 17:02:25 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH -mmotm 2/8] memcg: move memcg_tasklist mutex
Message-Id: <20091106170225.0e8bd880.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091106164934.b34d342f.nishimura@mxp.nes.nec.co.jp>
References: <20091106141011.3ded1551.nishimura@mxp.nes.nec.co.jp>
	<20091106141149.9c7e94d5.nishimura@mxp.nes.nec.co.jp>
	<20091106145459.351b407f.kamezawa.hiroyu@jp.fujitsu.com>
	<20091106164934.b34d342f.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, Paul Menage <menage@google.com>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Nov 2009 16:49:34 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> If there is no such a lock:
> 
>   Assume cgroup foo has exceeded its limit and is about to triggering oom.
>   1. Process A, which has been in cgroup baa and uses large memory,
>      is just moved to cgroup foo. Process A can be the candidates for being killed.
>   2. Process B, which has been in cgroup foo and uses large memory,
>      is just moved from cgroup foo. Process B can be excluded from the candidates for
>      being killed. 
> 
> Hmm, but considering more, those race window exist anyway even if we holds a lock,
> because try_charge decides wether it should trigger oom or not outside of the lock.
> 
yes, that's point.


> If this recharge feature is enabled, I think those problems might be avoided by doing like:
> 
> __mem_cgroup_try_charge()
> {
> 	...
> 	if (oom) {
> 		mutex_lock(&memcg_tasklist);
> 		if (unlikely(mem_cgroup_check_under_limit)) {
> 			mutex_unlock(&memcg_tasklist);
> 			continue
> 		}
> 		mem_cgroup_out_of_memory();
> 		mutex_unlock(&memcg_tasklist);
> 		record_last_oom();
> 	}
> 	...
> }
> 
> but it makes codes more complex and the recharge feature isn't necessarily enabled.
> 
> Well, I personally think we can remove these locks completely and make codes simpler.
> What do you think ?

I myself vote for removing this lock ;)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
