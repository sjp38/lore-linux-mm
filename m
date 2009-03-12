Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 022AF6B004D
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 00:00:07 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2C405YP000553
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 12 Mar 2009 13:00:05 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EC99F45DD85
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:00:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C322045DD84
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:00:04 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 157FAE08004
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:00:04 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 07C3AE08010
	for <linux-mm@kvack.org>; Thu, 12 Mar 2009 13:00:02 +0900 (JST)
Date: Thu, 12 Mar 2009 12:58:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/5] add softlimit to res_counter
Message-Id: <20090312125839.3b01e20c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090312035444.GC23583@balbir.in.ibm.com>
References: <20090312095247.bf338fe8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312095612.4a7758e1.kamezawa.hiroyu@jp.fujitsu.com>
	<20090312035444.GC23583@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Thu, 12 Mar 2009 09:24:44 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

>
> > +int res_counter_set_softlimit(struct res_counter *cnt, unsigned long long val)
> > +{
> > +	unsigned long flags;
> > +
> > +	spin_lock_irqsave(&cnt->lock, flags);
> > +	cnt->softlimit = val;
> > +	spin_unlock_irqrestore(&cnt->lock, flags);
> > +	return 0;
> > +}
> > +
> > +bool res_counter_check_under_softlimit(struct res_counter *cnt)
> > +{
> > +	struct res_counter *c;
> > +	unsigned long flags;
> > +	bool ret = true;
> > +
> > +	local_irq_save(flags);
> > +	for (c = cnt; ret && c != NULL; c = c->parent) {
> > +		spin_lock(&c->lock);
> > +		if (c->softlimit < c->usage)
> > +			ret = false;
> 
> So if a child was under the soft limit and the parent is *not*, we
> _override_ ret and return false?
> 
yes. If you don't want this behavior I'll rename this to
res_counter_check_under_softlimit_hierarchical().


> > +		spin_unlock(&c->lock);
> > +	}
> > +	local_irq_restore(flags);
> > +	return ret;
> > +}
> 
> Why is the check_under_softlimit hierarchical? 

At checking whether a mem_cgroup is a candidate for softlimit-reclaim,
we need to check all parents.

> BTW, this patch is buggy. See above.
> 

Not buggy. Just meets my requiremnt.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
