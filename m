Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 2B1496B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 00:22:23 -0400 (EDT)
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28smtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id n5F4MpCt013568
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 09:52:51 +0530
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n5F4Me7E1401002
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 09:52:41 +0530
Received: from d28av03.in.ibm.com (loopback [127.0.0.1])
	by d28av03.in.ibm.com (8.13.1/8.13.3) with ESMTP id n5F4MeKn009534
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 14:22:40 +1000
Message-ID: <4A35CC8F.3020906@linux.vnet.ibm.com>
Date: Mon, 15 Jun 2009 09:52:39 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: Low overhead patches for the memory cgroup controller (v4)
References: <b7dd123f0a15fff62150bc560747d7f0.squirrel@webmail-b.css.fujitsu.com> <20090515181639.GH4451@balbir.in.ibm.com> <20090518191107.8a7cc990.kamezawa.hiroyu@jp.fujitsu.com> <20090531235121.GA6120@balbir.in.ibm.com> <20090602085744.2eebf211.kamezawa.hiroyu@jp.fujitsu.com> <20090605053107.GF11755@balbir.in.ibm.com> <20090614183740.GD23577@balbir.in.ibm.com> <20090615111817.84123ea1.nishimura@mxp.nes.nec.co.jp> <4A35B936.70301@linux.vnet.ibm.com> <20090615120933.61941977.nishimura@mxp.nes.nec.co.jp> <4A35BE90.7000301@linux.vnet.ibm.com> <20090615124623.7a2138e4.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20090615124623.7a2138e4.nishimura@mxp.nes.nec.co.jp>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "lizf@cn.fujitsu.com" <lizf@cn.fujitsu.com>, "menage@google.com" <menage@google.com>, KOSAKI Motohiro <m-kosaki@ceres.dti.ne.jp>
List-ID: <linux-mm.kvack.org>

Daisuke Nishimura wrote:
> On Mon, 15 Jun 2009 08:52:56 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> Daisuke Nishimura wrote:
>>> On Mon, 15 Jun 2009 08:30:06 +0530, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>>>> Daisuke Nishimura wrote:
>>>>
>>>>>  	pc->mem_cgroup = mem;
>>>>>  	smp_wmb();
>>>>> -	pc->flags = pcg_default_flags[ctype];
>>>> pc->flags needs to be reset here, otherwise we have the danger the carrying over
>>>> older bits. I'll merge your changes and test.
>>>>
>>> hmm, why ?
>>>
>>> I do in my patch:
>>>
>>> +	switch (ctype) {
>>> +	case MEM_CGROUP_CHARGE_TYPE_CACHE:
>>> +	case MEM_CGROUP_CHARGE_TYPE_SHMEM:
>>> +		SetPageCgroupCache(pc);
>>> +		SetPageCgroupUsed(pc);
>>> +		break;
>>> +	case MEM_CGROUP_CHARGE_TYPE_MAPPED:
>>> +		ClearPageCgroupCache(pc);
>>> +		SetPageCgroupUsed(pc);
>>> +		break;
>>> +	default:
>>> +		break;
>>> +	}
>>>
>> Yes, I did that in the older code, what I was suggesting was just an additional
>> step to ensure that in the future if we add new flags, we don't end up with a
>> long list of initializations and clearing or if we forget to clear pc->flags and
>> reuse the page_cgroup, it might be a problem. My message was confusing, it
>> should have been resetting the pc->flags will provide protection for any future
>> addition of flags.
>>
> O.K. I see your point.
> 
> But we shouldn't touch PCG_ACCT_LRU flag here. IIUC, that's why we abandon
> pcg_default_flags[]. Please take care of it.
> 

I am keeping the pc->flags removed as in the earlier patch, but something to
keep in mind as we review further changes to the flags field.

>> I am testing your patch which is the modified version of v3 with your changes
>> and have your signed-off-by in it as well as I post v5. Is that OK?
>>
> Sure :)
> 

Just sending it out, now, Thanks!

-- 
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
