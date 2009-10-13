Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id B0C296B00B8
	for <linux-mm@kvack.org>; Tue, 13 Oct 2009 03:58:59 -0400 (EDT)
Date: Tue, 13 Oct 2009 16:57:19 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH 2/2] memcg: coalescing charge by percpu (Oct/9)
Message-Id: <20091013165719.c5781bfa.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <72e9a96ea399491948f396dab01b4c77.squirrel@webmail-b.css.fujitsu.com>
References: <20091009165826.59c6f6e3.kamezawa.hiroyu@jp.fujitsu.com>
	<20091009170105.170e025f.kamezawa.hiroyu@jp.fujitsu.com>
	<20091009165002.629a91d2.akpm@linux-foundation.org>
	<72e9a96ea399491948f396dab01b4c77.squirrel@webmail-b.css.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, h-shimamoto@ct.jp.nec.com, linux-kernel@vger.kernel.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Sun, 11 Oct 2009 11:37:35 +0900 (JST), "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> Andrew Morton wrote:
> > On Fri, 9 Oct 2009 17:01:05 +0900
> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >
> >> +static void drain_all_stock_async(void)
> >> +{
> >> +	int cpu;
> >> +	/* This function is for scheduling "drain" in asynchronous way.
> >> +	 * The result of "drain" is not directly handled by callers. Then,
> >> +	 * if someone is calling drain, we don't have to call drain more.
> >> +	 * Anyway, work_pending() will catch if there is a race. We just do
> >> +	 * loose check here.
> >> +	 */
> >> +	if (atomic_read(&memcg_drain_count))
> >> +		return;
> >> +	/* Notify other cpus that system-wide "drain" is running */
> >> +	atomic_inc(&memcg_drain_count);
Shouldn't we use atomic_inc_not_zero() ?
(Do you mean this problem by "is not very good" below ?)


Thanks,
Daisuke Nishimura.

> >> +	get_online_cpus();
> >> +	for_each_online_cpu(cpu) {
> >> +		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
> >> +		if (work_pending(&stock->work))
> >> +			continue;
> >> +		INIT_WORK(&stock->work, drain_local_stock);
> >> +		schedule_work_on(cpu, &stock->work);
> >> +	}
> >> + 	put_online_cpus();
> >> +	atomic_dec(&memcg_drain_count);
> >> +	/* We don't wait for flush_work */
> >> +}
> >
> > It's unusual to run INIT_WORK() each time we use a work_struct.
> > Usually we will run INIT_WORK a single time, then just repeatedly use
> > that structure.  Because after the work has completed, it is still in a
> > ready-to-use state.
> >
> > Running INIT_WORK() repeatedly against the same work_struct adds a risk
> > that we'll scribble on an in-use work_struct, which would make a big
> > mess.
> >
> Ah, ok. I'll prepare a fix. (And I think atomic_dec/inc placement is not
> very good....I'll do total review, again.)
> 
> Thank you for review.
> 
> Regards,
> -Kame
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
