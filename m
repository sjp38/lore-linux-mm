Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 3BB809000BD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 07:03:41 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id C88123EE0C0
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 20:03:36 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AF00445DE9E
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 20:03:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 79F3C45DEAD
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 20:03:36 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 619661DB8041
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 20:03:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 26C7A1DB803B
	for <linux-mm@kvack.org>; Mon, 26 Sep 2011 20:03:36 +0900 (JST)
Date: Mon, 26 Sep 2011 20:02:47 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH v3 6/7] tcp buffer limitation: per-cgroup limit
Message-Id: <20110926200247.c80f7e47.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <4E7DDB82.3030802@parallels.com>
References: <1316393805-3005-1-git-send-email-glommer@parallels.com>
	<1316393805-3005-7-git-send-email-glommer@parallels.com>
	<CAHH2K0Yuji2_2pMdzEaMvRx0KE7OOaoEGT+OK4gJgTcOPKuT9g@mail.gmail.com>
	<4E7DDB82.3030802@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Greg Thelen <gthelen@google.com>, linux-kernel@vger.kernel.org, paul@paulmenage.org, lizf@cn.fujitsu.com, ebiederm@xmission.com, davem@davemloft.net, netdev@vger.kernel.org, linux-mm@kvack.org, kirill@shutemov.name

On Sat, 24 Sep 2011 10:30:42 -0300
Glauber Costa <glommer@parallels.com> wrote:

> On 09/22/2011 03:01 AM, Greg Thelen wrote:
> > On Sun, Sep 18, 2011 at 5:56 PM, Glauber Costa<glommer@parallels.com>  wrote:
> >> +static inline bool mem_cgroup_is_root(struct mem_cgroup *mem)
> >> +{
> >> +       return (mem == root_mem_cgroup);
> >> +}
> >> +
> >
> > Why are you adding a copy of mem_cgroup_is_root().  I see one already
> > in v3.0.  Was it deleted in a previous patch?
> 
> Already answered by another good samaritan.
> 
> >> +static int tcp_write_maxmem(struct cgroup *cgrp, struct cftype *cft, u64 val)
> >> +{
> >> +       struct mem_cgroup *sg = mem_cgroup_from_cont(cgrp);
> >> +       struct mem_cgroup *parent = parent_mem_cgroup(sg);
> >> +       struct net *net = current->nsproxy->net_ns;
> >> +       int i;
> >> +
> >> +       if (!cgroup_lock_live_group(cgrp))
> >> +               return -ENODEV;
> >
> > Why is cgroup_lock_live_cgroup() needed here?  Does it protect updates
> > to sg->tcp_prot_mem[*]?
> >
> >> +static u64 tcp_read_maxmem(struct cgroup *cgrp, struct cftype *cft)
> >> +{
> >> +       struct mem_cgroup *sg = mem_cgroup_from_cont(cgrp);
> >> +       u64 ret;
> >> +
> >> +       if (!cgroup_lock_live_group(cgrp))
> >> +               return -ENODEV;
> >
> > Why is cgroup_lock_live_cgroup() needed here?  Does it protect updates
> > to sg->tcp_max_memory?
> 
> No, that is not my understanding. My understanding is this lock is 
> needed to protect against the cgroup just disappearing under our nose.
> 

Hm. reference count of dentry for cgroup isn't enough ?

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
