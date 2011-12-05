Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id BC8E76B004F
	for <linux-mm@kvack.org>; Sun,  4 Dec 2011 21:03:16 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E49FA3EE0AE
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 11:03:14 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CB61745DE7E
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 11:03:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A959D45DECA
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 11:03:14 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3AE121DB8041
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 11:03:14 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.240.81.145])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E40A51DB8042
	for <linux-mm@kvack.org>; Mon,  5 Dec 2011 11:03:13 +0900 (JST)
Date: Mon, 5 Dec 2011 11:01:58 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v7 04/10] tcp memory pressure controls
Message-Id: <20111205110158.8a2e270f.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4ED91188.6030503@parallels.com>
References: <1322611021-1730-1-git-send-email-glommer@parallels.com>
	<1322611021-1730-5-git-send-email-glommer@parallels.com>
	<20111130104943.d9b210ee.kamezawa.hiroyu@jp.fujitsu.com>
	<4ED91188.6030503@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, gthelen@google.com, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name, avagin@parallels.com, devel@openvz.org, eric.dumazet@gmail.com, cgroups@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>

On Fri, 2 Dec 2011 15:57:28 -0200
Glauber Costa <glommer@parallels.com> wrote:

> On 11/29/2011 11:49 PM, KAMEZAWA Hiroyuki wrote:
> >
> >> -static struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
> >> +struct mem_cgroup *mem_cgroup_from_cont(struct cgroup *cont)
> >>   {
> >>   	return container_of(cgroup_subsys_state(cont,
> >>   				mem_cgroup_subsys_id), struct mem_cgroup,
> >> @@ -4717,14 +4732,27 @@ static int register_kmem_files(struct cgroup *cont, struct cgroup_subsys *ss)
> >>
> >>   	ret = cgroup_add_files(cont, ss, kmem_cgroup_files,
> >>   			       ARRAY_SIZE(kmem_cgroup_files));
> >> +
> >> +	if (!ret)
> >> +		ret = mem_cgroup_sockets_init(cont, ss);
> >>   	return ret;
> >>   };
> >
> > You does initizalication here. The reason what I think is
> > 1. 'proto_list' is not available at createion of root cgroup and
> >      you need to delay set up until mounting.
> >
> > If so, please add comment or find another way.
> > This seems not very clean to me.
> 
> Yes, we do can run into some ordering issues. A part of the 
> initialization can be done earlier. But I preferred to move it all later
> instead of creating two functions for it. But I can change that if you 
> want, no big deal.
> 

Hmm. please add comments about the 'issue'. It will help readers.


> >> +	tcp->tcp_prot_mem[0] = sysctl_tcp_mem[0];
> >> +	tcp->tcp_prot_mem[1] = sysctl_tcp_mem[1];
> >> +	tcp->tcp_prot_mem[2] = sysctl_tcp_mem[2];
> >> +	tcp->tcp_memory_pressure = 0;
> >
> > Question:
> >
> > Is this value will be updated when an admin chages sysctl ?
> 
> yes.
> 
> > I guess, this value is set at system init script or some which may
> > happen later than mounting cgroup.
> > I don't like to write a guideline 'please set sysctl val before
> > mounting cgroup'
> 
> Agreed.
> 
> This code is in patch 6 (together with the limiting):
> 
> +#ifdef CONFIG_CGROUP_MEM_RES_CTLR_KMEM
> +       rcu_read_lock();
> +       memcg = mem_cgroup_from_task(current);
> +
> +       tcp_prot_mem(memcg, vec[0], 0);
> +       tcp_prot_mem(memcg, vec[1], 1);
> +       tcp_prot_mem(memcg, vec[2], 2);
> +       rcu_read_unlock();
> +#endif
> 
> tcp_prot_mem is just a wrapper around the assignment so we can access 
> memcg's inner fields.
> 


Ok. sysctl and cgroup are updated at the same time.
thank you.
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
