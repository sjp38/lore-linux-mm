Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 16E335F0001
	for <linux-mm@kvack.org>; Mon,  2 Feb 2009 23:41:31 -0500 (EST)
Received: from d23relay02.au.ibm.com (d23relay02.au.ibm.com [202.81.31.244])
	by e23smtp07.au.ibm.com (8.13.1/8.13.1) with ESMTP id n134fRiD027893
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 15:41:27 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay02.au.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id n134firi1134782
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 15:41:44 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n134fQgR024685
	for <linux-mm@kvack.org>; Tue, 3 Feb 2009 15:41:27 +1100
Date: Tue, 3 Feb 2009 10:11:23 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [-mm patch] Show memcg information during OOM
Message-ID: <20090203044123.GL918@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090202125240.GA918@balbir.in.ibm.com> <20090202215527.EC92.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20090202141705.GE918@balbir.in.ibm.com> <alpine.DEB.2.00.0902021235500.26971@chino.kir.corp.google.com> <20090202205434.GI918@balbir.in.ibm.com> <alpine.DEB.2.00.0902021256030.30674@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0902021256030.30674@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

* David Rientjes <rientjes@google.com> [2009-02-02 13:05:02]:

> On Tue, 3 Feb 2009, Balbir Singh wrote:
> 
> > David, I'd agree, but since we are under printk_ratelimit() and this
> > is a not-so-common path, does the log level matter much? If it does, I
> > don't mind using KERN_INFO.
> > 
> 
> It matters for parsing dmesg output; the only KERN_WARNING message from 
> the oom killer is normally the header.  There's a couple extra ones for 
> error conditions (that could certainly be changed to KERN_ERR), but only 
> in very rare circumstances.
> 
> As defined by include/linux/kernel.h:
> 
> 	#define KERN_WARNING	"<4>"	/* warning conditions			*/
> 	...
> 	#define KERN_INFO	"<6>"	/* informational			*/
> 
> The meminfo you are printing falls under the "informational" category, no?
> 
> While you're there, it might also be helpful to make another change 
> that would also help in parsing the output:
> 
> > diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> > index 8e4be9c..954b0d5 100644
> > --- a/mm/memcontrol.c
> > +++ b/mm/memcontrol.c
> > @@ -813,6 +813,25 @@ bool mem_cgroup_oom_called(struct task_struct *task)
> >  	rcu_read_unlock();
> >  	return ret;
> >  }
> > +
> > +void mem_cgroup_print_mem_info(struct mem_cgroup *memcg)
> > +{
> > +	if (!memcg)
> > +		return;
> > +
> > +	printk(KERN_WARNING "Memory cgroups's name %s\n",
> > +		memcg->css.cgroup->dentry->d_name.name);
> 
> This should be "cgroup's", but I don't think you want to print this on a 
> line by itself since the only system-wide synchronization here is a 
> read-lock on tasklist_lock and there could be two separate memcg's that 
> are oom.
> 
> So it's quite possible, though unlikely, that two seperate oom events 
> would have these messages merged together in the ring buffer, which would 
> make parsing impossible.
> 
> I think you probably want to add the name to each line you print, such as:
> 
> > +	printk(KERN_WARNING "Cgroup memory: usage %llu, limit %llu"
> > +		" failcnt %llu\n", res_counter_read_u64(&memcg->res, RES_USAGE),
> > +		res_counter_read_u64(&memcg->res, RES_LIMIT),
> > +		res_counter_read_u64(&memcg->res, RES_FAILCNT));
> 
> 	const char *name = memcg->css.cgroup->dentry->d_name.name;
> 
> 	printk(KERN_INFO "Cgroup %s memory: usage %llu, limit %llu"
> 			" failcount %llu\n", name, ...);
> 
> > +	printk(KERN_WARNING "Cgroup memory+swap: usage %llu, limit %llu "
> > +		"failcnt %llu\n",
> > +		res_counter_read_u64(&memcg->memsw, RES_USAGE),
> > +		res_counter_read_u64(&memcg->memsw, RES_LIMIT),
> > +		res_counter_read_u64(&memcg->memsw, RES_FAILCNT));
> 
> and
> 
> 	printk(KERN_INFO "Cgroup %s memory+swap: usage %llu, limit %llu "
> 		"failcnt %llu\n", name, ...);
> 
> > +}
>

Thanks for the review, I'll incorporate as much of it as possible in
the next version. 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
