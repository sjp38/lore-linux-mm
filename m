Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx174.postini.com [74.125.245.174])
	by kanga.kvack.org (Postfix) with SMTP id 5610F6B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 21:00:31 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7754F3EE0AE
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 11:00:28 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 59E7445DE52
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 11:00:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3739045DE50
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 11:00:28 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 26AEB1DB803E
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 11:00:28 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id C35821DB802F
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 11:00:27 +0900 (JST)
Date: Mon, 5 Dec 2011 10:59:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v7 02/10] foundations of per-cgroup memory pressure
 controlling.
Message-Id: <20111205105916.eeb55989.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4ED90F06.102@parallels.com>
References: <1322611021-1730-1-git-send-email-glommer@parallels.com>
	<1322611021-1730-3-git-send-email-glommer@parallels.com>
	<20111130094305.9c69ecd8.kamezawa.hiroyu@jp.fujitsu.com>
	<4ED90F06.102@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org

On Fri, 2 Dec 2011 15:46:46 -0200
Glauber Costa <glommer@parallels.com> wrote:

> 
> >>   static void proto_seq_printf(struct seq_file *seq, struct proto *proto)
> >>   {
> >> +	struct mem_cgroup *memcg = mem_cgroup_from_task(current);
> >> +
> >>   	seq_printf(seq, "%-9s %4u %6d  %6ld   %-3s %6u   %-3s  %-10s "
> >>   			"%2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c %2c\n",
> >>   		   proto->name,
> >>   		   proto->obj_size,
> >>   		   sock_prot_inuse_get(seq_file_net(seq), proto),
> >> -		   proto->memory_allocated != NULL ? atomic_long_read(proto->memory_allocated) : -1L,
> >> -		   proto->memory_pressure != NULL ? *proto->memory_pressure ? "yes" : "no" : "NI",
> >> +		   sock_prot_memory_allocated(proto, memcg),
> >> +		   sock_prot_memory_pressure(proto, memcg),
> >
> > I wonder I should say NO, here. (Networking guys are ok ??)
> >
> > IIUC, this means there is no way to see aggregated sockstat of all system.
> > And the result depends on the cgroup which the caller is under control.
> >
> > I think you should show aggregated sockstat(global + per-memcg) here and
> > show per-memcg ones via /cgroup interface or add private_sockstat to show
> > per cgroup summary.
> >
> 
> Hi Kame,
> 
> Yes, the statistics displayed depends on which cgroup you live.
> Also, note that the parent cgroup here is always updated (even when 
> use_hierarchy is set to 0). So it is always possible to grab global 
> statistics, by being in the root cgroup.
> 
> For the others, I believe it to be a question of naturalization. Any 
> tool that is fetching these values is likely interested in the amount of 
> resources available/used. When you are on a cgroup, the amount of 
> resources available/used changes, so that's what you should see.
> 
> Also brings the point of resource isolation: if you shouldn't interfere 
> with other set of process' resources, there is no reason for you to see 
> them in the first place.
> 
> So given all that, I believe that whenever we talk about resources in a 
> cgroup, we should talk about cgroup-local ones.

But you changes /proc/ information without any arguments with other guys.
If you go this way, you should move this patch as independent add-on patch
and discuss what this should be. For example, /proc/meminfo doesn't reflect
memcg's information (for now). And scheduler statiscits in /proc/stat doesn't
reflect cgroup's information.

So, please discuss the problem in open way. This issue is not only related to
this patch but also to other cgroups. Sneaking this kind of _big_ change in
a middle of complicated patch series isn't good.

In short, could you divide this patch into a independent patch and discuss
again ? If we agree the general diection should go this way, other guys will
post patches for cpu, memory, blkio, etc.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
