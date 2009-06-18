Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 919C16B005A
	for <linux-mm@kvack.org>; Wed, 17 Jun 2009 23:20:51 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n5I3LRbE027694
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 18 Jun 2009 12:21:27 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 6A2C545DE56
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 12:21:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 22DE145DE55
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 12:21:27 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id DFAD71DB8038
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 12:21:26 +0900 (JST)
Received: from ml12.s.css.fujitsu.com (ml12.s.css.fujitsu.com [10.249.87.102])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 896F11DB805F
	for <linux-mm@kvack.org>; Thu, 18 Jun 2009 12:21:26 +0900 (JST)
Message-ID: <d6b6721529fe5ebef019b4893f8b9177.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20090618120335.d6431cb7.nishimura@mxp.nes.nec.co.jp>
References: <20090612143346.68e1f006.nishimura@mxp.nes.nec.co.jp>
    <20090612151924.2d305ce8.kamezawa.hiroyu@jp.fujitsu.com>
    <20090615115021.c79444cb.nishimura@mxp.nes.nec.co.jp>
    <20090615120213.e9a3bd1d.kamezawa.hiroyu@jp.fujitsu.com>
    <20090615171715.53743dce.kamezawa.hiroyu@jp.fujitsu.com>
    <20090616114735.c7a91b8b.nishimura@mxp.nes.nec.co.jp>
    <20090616140050.4172f988.kamezawa.hiroyu@jp.fujitsu.com>
    <20090616153810.fd710c5b.nishimura@mxp.nes.nec.co.jp>
    <20090616154820.c9065809.kamezawa.hiroyu@jp.fujitsu.com>
    <20090616174436.5a4b6577.kamezawa.hiroyu@jp.fujitsu.com>
    <20090618120335.d6431cb7.nishimura@mxp.nes.nec.co.jp>
Date: Thu, 18 Jun 2009 12:21:25 +0900 (JST)
Subject: Re: [RFC][BUGFIX] memcg: rmdir doesn't return
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Li Zefan <lizf@cn.fujitsu.com>, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> On Tue, 16 Jun 2009 17:44:36 +0900, KAMEZAWA Hiroyuki
>> +	/*
>> +	 * css_put/get is provided for subsys to grab refcnt to css. In
>> typical
>> +	 * case, subsystem has no reference after pre_destroy(). But, under
>> +	 * hierarchy management, some *temporal* refcnt can be hold.
>> +	 * To avoid returning -EBUSY to a user, waitqueue is used. If subsys
>> +	 * is really busy, it should return -EBUSY at pre_destroy(). wake_up
>> +	 * is called when css_put() is called and refcnt goes down to 0.
>> +	 *
>> +	 * Subsys can check CGRP_WAIT_ON_RMDIR bit by itself to know
>> +	 * it's under ongoing rmdir() or not. Because css_tryget() returns
>> false
>> +	 * only after css->refcnt returns 0, checking this bit is useful when
>> +	 * css' refcnt seems to be not temporal.
>> +	 */
>> +	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>> +	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
>> +
> I'm sorry if I misunderstand something.
>
> Preparing waitq here means force_empty would be called with
> TASK_INTERRUPTIBLE,
> so current can sleep with TASK_INTRRUPTIBLE by cond_resched().
>
Ah...you're right.

> Can we ensure that it can be waken up, especially in case we are not under
> memory pressure ?
>
Hmm. I'll modify here.

lag between
 pre_destroy-> check css's ref -> sleep
 css_tryget -> charge to res_counter
is an enemy anyway. Adding "retry_rmdir()" as previous one is a choice..
(I wonder we should stop css_get/put against page_cgroup ...
 but that change will be too large for bugfix)

>>  	mutex_lock(&cgroup_mutex);
>> -	if (atomic_read(&cgrp->count) != 0) {
>> -		mutex_unlock(&cgroup_mutex);
>> -		return -EBUSY;
>> -	}
>> -	if (!list_empty(&cgrp->children)) {
>> +	if (atomic_read(&cgrp->count) != 0 || !list_empty(&cgrp->children)) {
>>  		mutex_unlock(&cgroup_mutex);
>> +		finish_wait(&cgroup_rmdir_waitq, &wait);
>> +		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>>  		return -EBUSY;
>>  	}
>>  	mutex_unlock(&cgroup_mutex);
>> @@ -2683,25 +2696,20 @@ again:
>>  	 * that rmdir() request comes.
>>  	 */
>>  	ret = cgroup_call_pre_destroy(cgrp);
>> -	if (ret)
>> +	if (ret) {
>> +		finish_wait(&cgroup_rmdir_waitq, &wait);
>> +		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>>  		return ret;
>> +	}
>>
>>  	mutex_lock(&cgroup_mutex);
>>  	parent = cgrp->parent;
>>  	if (atomic_read(&cgrp->count) || !list_empty(&cgrp->children)) {
>>  		mutex_unlock(&cgroup_mutex);
>> +		finish_wait(&cgroup_rmdir_waitq, &wait);
>> +		clear_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>>  		return -EBUSY;
>>  	}
>> -	/*
>> -	 * css_put/get is provided for subsys to grab refcnt to css. In
>> typical
>> -	 * case, subsystem has no reference after pre_destroy(). But, under
>> -	 * hierarchy management, some *temporal* refcnt can be hold.
>> -	 * To avoid returning -EBUSY to a user, waitqueue is used. If subsys
>> -	 * is really busy, it should return -EBUSY at pre_destroy(). wake_up
>> -	 * is called when css_put() is called and refcnt goes down to 0.
>> -	 */
>> -	set_bit(CGRP_WAIT_ON_RMDIR, &cgrp->flags);
>> -	prepare_to_wait(&cgroup_rmdir_waitq, &wait, TASK_INTERRUPTIBLE);
>>
>>  	if (!cgroup_clear_css_refs(cgrp)) {
>>  		mutex_unlock(&cgroup_mutex);
>> Index: linux-2.6.30.org/mm/memcontrol.c
>> ===================================================================
>> --- linux-2.6.30.org.orig/mm/memcontrol.c
>> +++ linux-2.6.30.org/mm/memcontrol.c
>> @@ -1338,6 +1338,7 @@ __mem_cgroup_commit_charge_swapin(struct
>>  		return;
>>  	if (!ptr)
>>  		return;
>> +	css_get(&ptr->css);
> What's the purpose of this css_get ?
> Can you add a comment ?
>
memcg's css->refcnt can be go down to 0 while commit. So, access to
memcg->css.cgroup can be invalid.


>>  	pc = lookup_page_cgroup(page);
>>  	mem_cgroup_lru_del_before_commit_swapcache(page);
>>  	__mem_cgroup_commit_charge(ptr, pc, ctype);
>> @@ -1367,8 +1368,14 @@ __mem_cgroup_commit_charge_swapin(struct
>>  		}
>>  		rcu_read_unlock();
>>  	}
>> -	/* add this page(page_cgroup) to the LRU we want. */
>> -
>> +	/*
>> +	 * Because we charged against a cgroup which is obtained by record
>> +	 * in swap_cgroup, not by task, there is a possibility that someone is
>> +	 * waiting for rmdir. This happens when a swap entry is shared
>> +	 * among cgroups. After wakeup, pre_destroy() will be called again.
>> +	 */
>> +	cgroup_wakeup_rmdir_waiters(&ptr->css.cgroup);
> '&' must be removed here.
>
maybe reflesh miss, sorry.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
