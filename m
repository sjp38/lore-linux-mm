Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id DB1D76B009B
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 01:15:42 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n2P5fJKf005789
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 25 Mar 2009 14:41:19 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B0D045DE57
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:41:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 2C18645DE58
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:41:19 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 12FC41DB805F
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:41:19 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id BA58F1DB805D
	for <linux-mm@kvack.org>; Wed, 25 Mar 2009 14:41:18 +0900 (JST)
Date: Wed, 25 Mar 2009 14:39:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/5] Memory controller soft limit organize cgroups (v7)
Message-Id: <20090325143953.beba2e02.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090325052945.GI24227@balbir.in.ibm.com>
References: <20090319165713.27274.94129.sendpatchset@localhost.localdomain>
	<20090319165735.27274.96091.sendpatchset@localhost.localdomain>
	<20090325135900.dc82f133.kamezawa.hiroyu@jp.fujitsu.com>
	<20090325052945.GI24227@balbir.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: balbir@linux.vnet.ibm.com
Cc: linux-mm@kvack.org, YAMAMOTO Takashi <yamamoto@valinux.co.jp>, lizf@cn.fujitsu.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, 25 Mar 2009 10:59:47 +0530
Balbir Singh <balbir@linux.vnet.ibm.com> wrote:

> * KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> [2009-03-25 13:59:00]:

> > > @@ -75,7 +85,8 @@ void res_counter_uncharge_locked(struct res_counter *counter, unsigned long val)
> > >  	counter->usage -= val;
> > >  }
> > >  
> > > -void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> > > +void res_counter_uncharge(struct res_counter *counter, unsigned long val,
> > > +				bool *was_soft_limit_excess)
> > >  {
> > >  	unsigned long flags;
> > >  	struct res_counter *c;
> > > @@ -83,6 +94,9 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
> > >  	local_irq_save(flags);
> > >  	for (c = counter; c != NULL; c = c->parent) {
> > >  		spin_lock(&c->lock);
> > > +		if (c == counter && was_soft_limit_excess)
> > > +			*was_soft_limit_excess =
> > > +				!res_counter_soft_limit_check_locked(c);
> > >  		res_counter_uncharge_locked(c, val);
> > >  		spin_unlock(&c->lock);
> > >  	}
> > Does this work as intended ?
> > Assume following hierarchy
> > 
> >    A/  softlimit=1G usage=300M
> >      B/ softlimit=200M usage=300M.
> >      C/ softlimit=800M usage=0M
> > 
> > *was_soft_limit_excess will be false and no tree update, forever.
> >
> 
> No.. was_soft_limit_excess checks the soft limit before uncharge to
> see if we were over soft limit, when a page gets uncharged from B,
> since B is over soft limit and on tree, we will update the tree. Why
> do you say that was_soft_limit_excess will return false? 
> 
my eyes tend to be buggy. ok, change the question.

==
+void res_counter_uncharge(struct res_counter *counter, unsigned long val,
+				bool *was_soft_limit_excess)
 {
 	unsigned long flags;
 	struct res_counter *c;
@@ -83,6 +94,9 @@ void res_counter_uncharge(struct res_counter *counter, unsigned long val)
 	local_irq_save(flags);
 	for (c = counter; c != NULL; c = c->parent) {
 		spin_lock(&c->lock);
+		if (c == counter && was_soft_limit_excess)
+			*was_soft_limit_excess =
+				!res_counter_soft_limit_check_locked(c);
 		res_counter_uncharge_locked(c, val);
 		spin_unlock(&c->lock);
 	}
==
Why just check "c == coutner" case is enough ?

Thanks,
-Kame





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
