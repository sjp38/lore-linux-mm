Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 5F2A86B003D
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 00:59:19 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id n2D4wwBN020567
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:28:58 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n2D4wu4a2867256
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 10:28:56 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id n2D4wmvj019443
	for <linux-mm@kvack.org>; Fri, 13 Mar 2009 15:58:48 +1100
Date: Fri, 13 Mar 2009 10:28:43 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/4] Memory controller soft limit interface (v5)
Message-ID: <20090313045843.GC16897@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <20090312175603.17890.52593.sendpatchset@localhost.localdomain> <20090312175620.17890.69177.sendpatchset@localhost.localdomain> <20090312155905.81a3415a.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20090312155905.81a3415a.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com, kosaki.motohiro@jp.fujitsu.com, riel@redhat.com, kamezawa.hiroyu@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

* Andrew Morton <akpm@linux-foundation.org> [2009-03-12 15:59:05]:

> On Thu, 12 Mar 2009 23:26:20 +0530
> Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> 
> > +/**
> > + * Get the difference between the usage and the soft limit
> > + * @cnt: The counter
> > + *
> > + * Returns 0 if usage is less than or equal to soft limit
> > + * The difference between usage and soft limit, otherwise.
> > + */
> > +static inline unsigned long long
> > +res_counter_soft_limit_excess(struct res_counter *cnt)
> > +{
> > +	unsigned long long excess;
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&cnt->lock, flags);
> > +	if (cnt->usage <= cnt->soft_limit)
> > +		excess = 0;
> > +	else
> > +		excess = cnt->usage - cnt->soft_limit;
> > +	spin_unlock_irqrestore(&cnt->lock, flags);
> > +	return excess;
> > +}
> >
> > ...
> >  
> > +static inline bool res_counter_check_under_soft_limit(struct res_counter *cnt)
> > +{
> > +	bool ret;
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&cnt->lock, flags);
> > +	ret = res_counter_soft_limit_check_locked(cnt);
> > +	spin_unlock_irqrestore(&cnt->lock, flags);
> > +	return ret;
> > +}
> >
> > ...
> >
> > +static inline int
> > +res_counter_set_soft_limit(struct res_counter *cnt,
> > +				unsigned long long soft_limit)
> > +{
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&cnt->lock, flags);
> > +	cnt->soft_limit = soft_limit;
> > +	spin_unlock_irqrestore(&cnt->lock, flags);
> > +	return 0;
> > +}
> 
> These functions look too large to be inlined?
>

I'll send a patch to fix it and move them to res_counter.c 

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
