Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 73E656B0071
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 19:18:37 -0500 (EST)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oB10IZuH010502
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 1 Dec 2010 09:18:35 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id ED11145DE51
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:18:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id CB9DB45DE50
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:18:34 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id A340D1DB8012
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:18:34 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 56F991DB8017
	for <linux-mm@kvack.org>; Wed,  1 Dec 2010 09:18:34 +0900 (JST)
Date: Wed, 1 Dec 2010 09:12:55 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] Add kswapd descriptor.
Message-Id: <20101201091255.7099d6bd.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTinWqyMrLdw9bBuog03vy3pLz9NVu3s8QBfTMrL3@mail.gmail.com>
References: <1291099785-5433-1-git-send-email-yinghan@google.com>
	<1291099785-5433-2-git-send-email-yinghan@google.com>
	<20101130160838.4c66febf.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinWqyMrLdw9bBuog03vy3pLz9NVu3s8QBfTMrL3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Ying Han <yinghan@google.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux.com>, Wu Fengguang <fengguang.wu@intel.com>, Andi Kleen <ak@linux.intel.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 30 Nov 2010 12:17:33 -0800
Ying Han <yinghan@google.com> wrote:

> > At the 1st look, this just seem to increase the size of changes....
> >
> > IMHO, implementing background-reclaim-for-memcg is cleaner than reusing kswapd..
> > kswapd has tons of unnecessary checks.
> 
> Sorry I am not aware of "background-reclaim-for-memcg", can you
> specify little bit more? Also,
> the unnecessary checks here refers to the kswapd() or balance_pgdat()?
> If the latter one, the
> logic is not being shared at all included in patch/3.
> 
Yes, now I read patch/3 and I'm sorry to say that.


Some nits.

At 1st. I just coudln't undestand idea of array of kswapd descriptor.
Hmm, dynamic allocation isn't possible ? as

==
struct kswapd_param {
	pg_data_t	*pgdat;
	struct mem_cgroup *memcg;
	struct wait_queue *waitq;
};


int kswapd_run(int nid, struct mem_cgroup *memcg)
{
	struct kswapd_param *param;

	param = kzalloc(); /* freed by kswapd */

	if (!memcg) { /* per-node kswapd */
		param->pgdat = NODE_DATA(nid);
		if (param->pgdat->kswapd)
			return;
		pgdat->kswapd = kthread_run(param);
		..../* fatal error check */
		return;
	}
		
	/* per-memcg kswapd */
	kthread_run(param);
}
==

Secondaly, I think some macro is necessary.

How about
==
#define is_node_kswapd(param)	(!param->memcg)

int kswapd(void *p)
{
	struct kswapd_param *param = p;

	if (is_node_kswapd(param))
		param->waitq = &param->pgdat->kswapd_wait;
	else
		param->waitq = mem_cgroup_get_kswapd_waitq(param->memcg);
		/* Here, we can notify the memcg which thread is for yours. */


or some ?

I think a macro like scanning_global_lru() is necessary.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
