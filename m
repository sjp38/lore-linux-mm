Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 122256B01B6
	for <linux-mm@kvack.org>; Tue,  1 Jun 2010 20:49:45 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o520nhSF025447
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 2 Jun 2010 09:49:44 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id DF6BB45DE51
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:49:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id BB80745DE50
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:49:42 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 980DF1DB804E
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:49:42 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 4FA331DB8048
	for <linux-mm@kvack.org>; Wed,  2 Jun 2010 09:49:42 +0900 (JST)
Date: Wed, 2 Jun 2010 09:45:27 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][1/3] memcg clean up try charge
Message-Id: <20100602094527.776cc1ce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100601231914.6874165e.d-nishimura@mtf.biglobe.ne.jp>
References: <20100601182406.1ede3581.kamezawa.hiroyu@jp.fujitsu.com>
	<20100601231914.6874165e.d-nishimura@mtf.biglobe.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: nishimura@mxp.nes.nec.co.jp
Cc: Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, 1 Jun 2010 23:19:14 +0900
Daisuke Nishimura <d-nishimura@mtf.biglobe.ne.jp> wrote:

> On Tue, 1 Jun 2010 18:24:06 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> 
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > mem_cgroup_try_charge() has a big loop (doesn't fits in screee) and seems to be
> > hard to read. Most of routines are for slow paths. This patch moves codes out
> > from the loop and make it clear what's done.
> > 
> I like this cleanup :)
> 
> I have some comments for now.
> 
> > -	while (1) {
> > -		int ret = 0;
> > -		unsigned long flags = 0;
> > +	while (ret != CHARGE_OK) {
> > +		int nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> reset nr_oom_retries at the beginning of every loop ? :)

This initialization is done only once ;) 

> I think this line should be at the top of this function, and we should do like:
> 
But ok, will do that.


>                 case CHARGE_RETRY: /* not in OOM situation but retry */
> 			nr_oom_retries = MEM_CGROUP_RECLAIM_RETRIES;
> 			csize = PAGE_SIZE;
> 			break;
> 
> later.
> 
Hmmmmmmm. ok.


> > +		case CHARGE_NOMEM: /* OOM routine works */
> >  			if (!oom)
> >  				goto nomem;
> > -			if (mem_cgroup_handle_oom(mem_over_limit, gfp_mask)) {
> > -				nr_retries = MEM_CGROUP_RECLAIM_RETRIES;
> > -				continue;
> > -			}
> > -			/* When we reach here, current task is dying .*/
> > -			css_put(&mem->css);
> > +			/* If !oom, we never return -ENOMEM */
> s/!oom/oom ?   
> 

yes.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
