Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 895CE6B0071
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 22:53:53 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5A2rocs013359
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 10 Jun 2010 11:53:50 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 76A8E45DE79
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 11:53:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 535F545DE6E
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 11:53:50 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 35BE3E38004
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 11:53:50 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E7BDEE38001
	for <linux-mm@kvack.org>; Thu, 10 Jun 2010 11:53:49 +0900 (JST)
Date: Thu, 10 Jun 2010 11:49:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH] memcg remove css_get/put per pages v2
Message-Id: <20100610114929.1f3fc130.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100610113424.d1037621.nishimura@mxp.nes.nec.co.jp>
References: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
	<20100609155940.dd121130.kamezawa.hiroyu@jp.fujitsu.com>
	<20100610113424.d1037621.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Thu, 10 Jun 2010 11:34:24 +0900
Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:

> I can't find any trivial bugs from my review at the moment.
> I'll do some tests.
> 

Thank you for review.

> Some minor commens.
> 
> On Wed, 9 Jun 2010 15:59:40 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > Still RFC, added lkml to CC: list.
> > ==
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > Now, memory cgroup increments css(cgroup subsys state)'s reference
> > count per a charged page. And the reference count is kept until
> > the page is uncharged. But this has 2 bad effect. 
> > 
> >  1. Because css_get/put calls atoimic_inc()/dec, heavy call of them
> >     on large smp will not scale well.
> >  2. Because css's refcnt cannot be in a state as "ready-to-release",
> >     cgroup's notify_on_release handler can't work with memcg.
> > 
> > This is a trial to remove css's refcnt per a page. Even if we remove
> > refcnt, pre_destroy() does enough synchronization.
> > 
> > After this patch, it seems css_get() is still called in try_charge().
> > But the logic is.
> > 
> >   1. task_lock(mm->owner)
> There is no task_lock() in this version :)
> 
yes.


> (snip)
> > @@ -4219,7 +4252,6 @@ static int mem_cgroup_do_precharge(unsig
> >  		mc.precharge += count;
> >  		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
> >  		WARN_ON_ONCE(count > INT_MAX);
> > -		__css_get(&mem->css, (int)count);
> >  		return ret;
> >  	}
> >  one_by_one:
> You can remove VM_BUG_ON() and WARN_ON_ONCE() here, too.
> 
ok.


> > @@ -4469,8 +4501,6 @@ static void mem_cgroup_clear_mc(void)
> >  			 */
> >  			res_counter_uncharge(&mc.to->res,
> >  						PAGE_SIZE * mc.moved_swap);
> > -			VM_BUG_ON(test_bit(CSS_ROOT, &mc.to->css.flags));
> > -			__css_put(&mc.to->css, mc.moved_swap);
> >  		}
> >  		/* we've already done mem_cgroup_get(mc.to) */
> >  
> > 
> And, you can remove "WARN_ON_ONCE(mc.moved_swap > INT_MAX)" at the beginning
> of this block, too.
> 
Hmm. ok.
Ah...them, this patch fixes the limitation by "css's refcnt is int" problem.
sounds nice.

Thanks,
-Kmae

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
