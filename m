Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 5C4606B00A0
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 01:36:39 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2P62amM029867
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Mar 2009 15:02:36 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id EA1A845DD7E
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 15:02:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A8B9F45DD80
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 15:02:35 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 64DFBE0800C
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 15:02:35 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 075BEE08005
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 15:02:35 +0900 (JST)
Date: Wed, 25 Mar 2009 15:01:09 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-Id: <20090325150109.b127a7af.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090325055354.GK24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165735.27274.96091.sendpatchset@localhost.localdomain>
	<20090325135900.dc82f133.kamezawa.hiroyu@jp.fujitsu.com>
	<20090325052945.GI24227@balbir.in.ibm.com>
	<20090325143953.beba2e02.kamezawa.hiroyu@jp.fujitsu.com>
	<20090325055354.GK24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Mar 2009 11:23:54 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> > ==
> > +void res_counter_uncharge(struct res_counter *counter, unsigned long val,
> > +				bool *was_soft_limit_excess)
> >  {
> >  	unsigned long flags;
> >  	struct res_counter *c;
> > @@ -83,6 +94,9 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> >  	local_irq_save(flags);
> >  	for (c = counter; c != NULL; c = c->parent) {
> >  		spin_lock(&c->lock);
> > +		if (c == counter && was_soft_limit_excess)
> > +			*was_soft_limit_excess =
> > +				!res_counter_soft_limit_check_locked(c);
> >  		res_counter_uncharge_locked(c, val);
> >  		spin_unlock(&c->lock);
> >  	}
> > ==
> > Why just check "c == coutner" case is enough ?
> > 
> 
> This is a very good question, I think this check might not be
> necessary and can also be potentially buggy.
> 
I feel so, but can't think of good clean up.

Don't we remove this check at uncharge ? Anyway status can be updated at
  - charge().
  - reclaim

I'll seek this way in mine...

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
