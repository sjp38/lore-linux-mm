Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 883896B004D
	for <linux-mm@kvack.org>; Sat, 10 Oct 2009 22:37:39 -0400 (EDT)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n9B2baBg032306
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sun, 11 Oct 2009 11:37:37 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7BEB72AEA81
	for <linux-mm@kvack.org>; Sun, 11 Oct 2009 11:37:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 59DB91EF081
	for <linux-mm@kvack.org>; Sun, 11 Oct 2009 11:37:36 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3E8BBE1800B
	for <linux-mm@kvack.org>; Sun, 11 Oct 2009 11:37:36 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id EEE00E1800A
	for <linux-mm@kvack.org>; Sun, 11 Oct 2009 11:37:35 +0900 (JST)
Message-ID: <72e9a96ea399491948f396dab01b4c77.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <20091009165002.629a91d2.akpm@linux-foundation.org>
References: <20091009165826.59c6f6e3.kamezawa.hiroyu@jp.fujitsu.com>
    <20091009170105.170e025f.kamezawa.hiroyu@jp.fujitsu.com>
    <20091009165002.629a91d2.akpm@linux-foundation.org>
Date: Sun, 11 Oct 2009 11:37:35 +0900 (JST)
Subject: Re: [PATCH 2/2] memcg: coalescing charge by percpu (Oct/9)
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, h-shimamoto@ct.jp.nec.com, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Fri, 9 Oct 2009 17:01:05 +0900
> KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
>
>> +static void drain_all_stock_async(void)
>> +{
>> +	int cpu;
>> +	/* This function is for scheduling "drain" in asynchronous way.
>> +	 * The result of "drain" is not directly handled by callers. Then,
>> +	 * if someone is calling drain, we don't have to call drain more.
>> +	 * Anyway, work_pending() will catch if there is a race. We just do
>> +	 * loose check here.
>> +	 */
>> +	if (atomic_read(&memcg_drain_count))
>> +		return;
>> +	/* Notify other cpus that system-wide "drain" is running */
>> +	atomic_inc(&memcg_drain_count);
>> +	get_online_cpus();
>> +	for_each_online_cpu(cpu) {
>> +		struct memcg_stock_pcp *stock = &per_cpu(memcg_stock, cpu);
>> +		if (work_pending(&stock->work))
>> +			continue;
>> +		INIT_WORK(&stock->work, drain_local_stock);
>> +		schedule_work_on(cpu, &stock->work);
>> +	}
>> + 	put_online_cpus();
>> +	atomic_dec(&memcg_drain_count);
>> +	/* We don't wait for flush_work */
>> +}
>
> It's unusual to run INIT_WORK() each time we use a work_struct.
> Usually we will run INIT_WORK a single time, then just repeatedly use
> that structure.  Because after the work has completed, it is still in a
> ready-to-use state.
>
> Running INIT_WORK() repeatedly against the same work_struct adds a risk
> that we'll scribble on an in-use work_struct, which would make a big
> mess.
>
Ah, ok. I'll prepare a fix. (And I think atomic_dec/inc placement is not
very good....I'll do total review, again.)

Thank you for review.

Regards,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
