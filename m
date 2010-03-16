Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 2C1896B01F9
	for <linux-mm@kvack.org>; Mon, 15 Mar 2010 20:04:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o2G04705006059
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Tue, 16 Mar 2010 09:04:07 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E951045DE67
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:04:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B3B0445DE63
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:04:06 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 973771DB8044
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:04:06 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4A5901DB8038
	for <linux-mm@kvack.org>; Tue, 16 Mar 2010 09:04:06 +0900 (JST)
Date: Tue, 16 Mar 2010 09:00:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] memcg: oom notifier
Message-Id: <20100316090027.95a8943d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100315145420.07f2bbe5.akpm@linux-foundation.org>
References: <20100312143137.f4cf0a04.kamezawa.hiroyu@jp.fujitsu.com>
	<20100312143435.e648e361.kamezawa.hiroyu@jp.fujitsu.com>
	<20100315145420.07f2bbe5.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kirill@shutemov.name" <kirill@shutemov.name>
List-ID: <linux-mm.kvack.org>

On Mon, 15 Mar 2010 14:54:20 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Fri, 12 Mar 2010 14:34:35 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > +static int mem_cgroup_oom_register_event(struct cgroup *cgrp,
> > +	struct cftype *cft, struct eventfd_ctx *eventfd, const char *args)
> > +{
> > +	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
> > +	struct mem_cgroup_eventfd_list *event;
> > +	int type = MEMFILE_TYPE(cft->private);
> > +	int ret = -ENOMEM;
> > +
> > +	BUG_ON(type != _OOM_TYPE);
> > +
> > +	mutex_lock(&memcg_oom_mutex);
> > +
> > +	event = kmalloc(sizeof(*event),	GFP_KERNEL);
> > +	if (!event)
> > +		goto unlock;
> > +
> > +	event->eventfd = eventfd;
> > +	list_add(&event->list, &memcg->oom_notify);
> > +
> > +	/* already in OOM ? */
> > +	if (atomic_read(&memcg->oom_lock))
> > +		eventfd_signal(eventfd, 1);
> > +	ret = 0;
> > +unlock:
> > +	mutex_unlock(&memcg_oom_mutex);
> > +
> > +	return ret;
> > +}
> 
> We can move that kmalloc() outside the lock.  It's more scalable and the
> code's cleaner.
> 
Agreed. Thank you for pointing out.


-Kame


> --- a/mm/memcontrol.c~memcg-oom-notifier-fix
> +++ a/mm/memcontrol.c
> @@ -3603,27 +3603,23 @@ static int mem_cgroup_oom_register_event
>  	struct mem_cgroup *memcg = mem_cgroup_from_cont(cgrp);
>  	struct mem_cgroup_eventfd_list *event;
>  	int type = MEMFILE_TYPE(cft->private);
> -	int ret = -ENOMEM;
>  
>  	BUG_ON(type != _OOM_TYPE);
>  
> -	mutex_lock(&memcg_oom_mutex);
> -
>  	event = kmalloc(sizeof(*event),	GFP_KERNEL);
>  	if (!event)
> -		goto unlock;
> +		return -ENOMEM;
>  
> +	mutex_lock(&memcg_oom_mutex);
>  	event->eventfd = eventfd;
>  	list_add(&event->list, &memcg->oom_notify);
>  
>  	/* already in OOM ? */
>  	if (atomic_read(&memcg->oom_lock))
>  		eventfd_signal(eventfd, 1);
> -	ret = 0;
> -unlock:
>  	mutex_unlock(&memcg_oom_mutex);
>  
> -	return ret;
> +	return 0;
>  }
>  
>  static int mem_cgroup_oom_unregister_event(struct cgroup *cgrp,
> _
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
