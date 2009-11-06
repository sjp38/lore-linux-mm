Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id C55A36B004D
	for <linux-mm@kvack.org>; Fri,  6 Nov 2009 13:44:42 -0500 (EST)
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id nA6IieOl008751
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Sat, 7 Nov 2009 03:44:40 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id D607D45DE4F
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 03:44:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id AB3A845DE3E
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 03:44:39 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 8D3E51DB8038
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 03:44:39 +0900 (JST)
Received: from ml11.s.css.fujitsu.com (ml11.s.css.fujitsu.com [10.249.87.101])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 3B7C01DB803F
	for <linux-mm@kvack.org>; Sat,  7 Nov 2009 03:44:36 +0900 (JST)
Message-ID: <6aea93183b4d3582d4e3f1550f4695fe.squirrel@webmail-b.css.fujitsu.com>
In-Reply-To: <alpine.DEB.1.10.0911061220410.5187@V090114053VZO-1>
References: <20091106175242.6e13ee29.kamezawa.hiroyu@jp.fujitsu.com>
    <20091106175545.b97ee867.kamezawa.hiroyu@jp.fujitsu.com>
    <alpine.DEB.1.10.0911061220410.5187@V090114053VZO-1>
Date: Sat, 7 Nov 2009 03:44:35 +0900 (JST)
Subject: Re: [PATCH 2/2] memcg : rewrite percpu countings with new
 interfaces
From: "KAMEZAWA Hiroyuki" <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-2022-jp
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Christoph Lameter wrote:
> On Fri, 6 Nov 2009, KAMEZAWA Hiroyuki wrote:
>> -		__mem_cgroup_stat_reset_safe(cpustat, MEMCG_EVENTS);
>> +		__this_cpu_write(mem->cpustat->count[MEMCG_EVENTS], 0);
>>  		ret = true;
>>  	}
>> -	put_cpu();
>>  	return ret;
>
> If you want to use the __this_cpu_xx versions then you need to manage
> preempt on your own.
>
Ah, I see. I understand I haven't understood.

> You need to keep preempt_disable/enable here because otherwise the per
> cpu variable zeroed may be on a different cpu than the per cpu variable
> where you got the value from.
>
Thank you. I think I can do well in the next version.


>> +static s64 mem_cgroup_read_stat(struct mem_cgroup *mem,
>> +		enum mem_cgroup_stat_index idx)
>> +{
>> +	struct mem_cgroup_stat_cpu *cstat;
>> +	int cpu;
>> +	s64 ret = 0;
>> +
>> +	for_each_possible_cpu(cpu) {
>> +		cstat = per_cpu_ptr(mem->cpustat, cpu);
>> +		ret += cstat->count[idx];
>> +	}
>
> 	== ret += per_cpu(mem->cpustat->cstat->count[idx], cpu)
>
Hmm, Hmm. Will use that.

>>  static void mem_cgroup_swap_statistics(struct mem_cgroup *mem,
>>  					 bool charge)
>>  {
>>  	int val = (charge) ? 1 : -1;
>> -	struct mem_cgroup_stat *stat = &mem->stat;
>> -	struct mem_cgroup_stat_cpu *cpustat;
>> -	int cpu = get_cpu();
>>
>> -	cpustat = &stat->cpustat[cpu];
>> -	__mem_cgroup_stat_add_safe(cpustat, MEMCG_NR_SWAP, val);
>> -	put_cpu();
>> +	__this_cpu_add(mem->cpustat->count[MEMCG_NR_SWAP], val);
>>  }
>
> You do not disable preempt on your own so you have to use
>
> 	this_cpu_add()
>
> There is no difference between __this_cpu_add and this_cpu_add on x86 but
> they will differ on platforms that do not have atomic per cpu
> instructions. The fallback for this_cpu_add is to protect the add with
> preempt_disable()/enable. The fallback fro __this_cpu_add is just to rely
> on the caller to ensure that preempt is disabled somehow.
>
Ok.


>> -	/*
>> -	 * Preemption is already disabled, we don't need get_cpu()
>> -	 */
>> -	cpu = smp_processor_id();
>> -	stat = &mem->stat;
>> -	cpustat = &stat->cpustat[cpu];
>> -
>> -	__mem_cgroup_stat_add_safe(cpustat, MEMCG_NR_FILE_MAPPED, val);
>> +	__this_cpu_add(mem->cpustat->count[MEMCG_NR_FILE_MAPPED], val);
>
> Remove __
>
>
>> @@ -1650,16 +1597,11 @@ static int mem_cgroup_move_account(struc
>>
>>  	page = pc->page;
>>  	if (page_mapped(page) && !PageAnon(page)) {
>> -		cpu = smp_processor_id();
>>  		/* Update mapped_file data for mem_cgroup "from" */
>> -		stat = &from->stat;
>> -		cpustat = &stat->cpustat[cpu];
>> -		__mem_cgroup_stat_add_safe(cpustat, MEMCG_NR_FILE_MAPPED, -1);
>> +		__this_cpu_dec(from->cpustat->count[MEMCG_NR_FILE_MAPPED]);
>
> You can keep it here since the context already has preempt disabled it
> seems.
>
Thank you for kindly review.

Regards,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
