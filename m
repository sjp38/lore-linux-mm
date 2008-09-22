From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <28237198.1222095970373.kamezawa.hiroyu@jp.fujitsu.com>
Date: Tue, 23 Sep 2008 00:06:10 +0900 (JST)
Subject: Re: Re: Re: [PATCH 4/13] memcg: force_empty moving account
In-Reply-To: <1222095363.16700.15.camel@lappy.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <1222095363.16700.15.camel@lappy.programming.kicks-ass.net>
 <1222093420.16700.2.camel@lappy.programming.kicks-ass.net>
	 <20080922195159.41a9d2bc.kamezawa.hiroyu@jp.fujitsu.com>
	 <20080922200025.49ea6d70.kamezawa.hiroyu@jp.fujitsu.com>
	 <19184326.1222095015978.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, nishimura@mxp.nes.nec.co.jp, xemul@openvz.org, LKML <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

----- Original Message -----
>On Mon, 2008-09-22 at 23:50 +0900, kamezawa.hiroyu@jp.fujitsu.com wrote:
>> ----- Original Message -----
>> >> +			spin_lock_irqsave(&mz->lru_lock, flags);
>> >> +		} else {
>> >> +			unlock_page(page);
>> >> +			put_page(page);
>> >> +		}
>> >> +		if (atomic_read(&mem->css.cgroup->count) > 0)
>> >> +			break;
>> >>  	}
>> >>  	spin_unlock_irqrestore(&mz->lru_lock, flags);
>> >
>> >do _NOT_ use yield() ever! unless you know what you're doing, and
>> >probably not even then.
>> >
>> >NAK!
>> Hmm, sorry. cond_resched() is ok ?
>
>depends on what you want to do, please explain what you're trying to do.
>
Sorry again.

This force_empty is called only in following situation
 - there is no user threas in this cgroup.
 - a user tries to rmdir() this cgroup or explicitly type
   echo 1 > ../memory.force_empty.

force_empty() scans lru list of this cgroup and check page_cgroup on the
list one by one. Because there are no tasks in this group, force_empty can
see following racy condtions while scanning.

 - global lru tries to remove the page which pointed by page_cgroup 
   and it is not-on-LRU.
 - the page is locked by someone.
   ....find some lock contetion with invalidation/truncate.
 - in later patch, page_cgroup can be on pagevec(i added) and we have to drain
   it to remove from LRU.

In above situation, force_empty() have to wait for some event proceeds.

Hmm...detecting busy situation in loop and sleep in out-side-of-loop
is better ? Anyway, ok, I'll rewrite this.

BTW, sched.c::yield() is for what purpose now ?

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
