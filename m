Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DB3286B0071
	for <linux-mm@kvack.org>; Wed,  9 Jun 2010 22:47:47 -0400 (EDT)
Date: Thu, 10 Jun 2010 11:34:24 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [RFC][PATCH] memcg remove css_get/put per pages v2
Message-Id: <20100610113424.d1037621.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100609155940.dd121130.kamezawa.hiroyu@jp.fujitsu.com>
References: <20100608121901.3cab9bdf.kamezawa.hiroyu@jp.fujitsu.com>
	<20100609155940.dd121130.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

I can't find any trivial bugs from my review at the moment.
I'll do some tests.

Some minor commens.

On Wed, 9 Jun 2010 15:59:40 +0900, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Still RFC, added lkml to CC: list.
> ==
> From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> 
> Now, memory cgroup increments css(cgroup subsys state)'s reference
> count per a charged page. And the reference count is kept until
> the page is uncharged. But this has 2 bad effect. 
> 
>  1. Because css_get/put calls atoimic_inc()/dec, heavy call of them
>     on large smp will not scale well.
>  2. Because css's refcnt cannot be in a state as "ready-to-release",
>     cgroup's notify_on_release handler can't work with memcg.
> 
> This is a trial to remove css's refcnt per a page. Even if we remove
> refcnt, pre_destroy() does enough synchronization.
> 
> After this patch, it seems css_get() is still called in try_charge().
> But the logic is.
> 
>   1. task_lock(mm->owner)
There is no task_lock() in this version :)

(snip)
> @@ -4219,7 +4252,6 @@ static int mem_cgroup_do_precharge(unsig
>  		mc.precharge += count;
>  		VM_BUG_ON(test_bit(CSS_ROOT, &mem->css.flags));
>  		WARN_ON_ONCE(count > INT_MAX);
> -		__css_get(&mem->css, (int)count);
>  		return ret;
>  	}
>  one_by_one:
You can remove VM_BUG_ON() and WARN_ON_ONCE() here, too.

> @@ -4469,8 +4501,6 @@ static void mem_cgroup_clear_mc(void)
>  			 */
>  			res_counter_uncharge(&mc.to->res,
>  						PAGE_SIZE * mc.moved_swap);
> -			VM_BUG_ON(test_bit(CSS_ROOT, &mc.to->css.flags));
> -			__css_put(&mc.to->css, mc.moved_swap);
>  		}
>  		/* we've already done mem_cgroup_get(mc.to) */
>  
> 
And, you can remove "WARN_ON_ONCE(mc.moved_swap > INT_MAX)" at the beginning
of this block, too.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
