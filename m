Message-ID: <48561B68.6060503@openvz.org>
Date: Mon, 16 Jun 2008 11:51:04 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] res_counter:  handle limit change
References: <48560A7C.9050501@openvz.org> <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com> <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com> <33011576.1213601977563.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <33011576.1213601977563.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, menage@google.com, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

kamezawa.hiroyu@jp.fujitsu.com wrote:
> ----- Original Message -----
>>> +	 * registered callbacks etc...for res_counter.
>>> +	 */
>>> +	struct res_counter_ops ops;
>>> +	/*
> Now, write to limit is done in following path.
> sys_write() -> write_func of subsys -> write in res_counter -> 
> strategy callback -> set limit -> return
> 
> Because stragety callback is called in res_counter, we can only do 
> something after set-limit without callback. So res_counter should call
> another callback before set-limit if it can fail.
> 
>> Why would we need such? All res_counter.limit update comes via the appropiate
>> cgroup's files, so it can do whatever it needs w/o any callbacks?
>>
> 
> First reason is that this allows us to implement generic algorithm to
> handle limit change. Second is that generic algorithm can be a stack of
> functions. I don't like to pass function pointers through several stack
> of functions. (And this design allow the code to be much easier to read.
> My first version used an argument of function pointer but it was verrry ugly.)
> 
> I think when I did all in memcg, someone will comment that "why do that
> all in memcg ? please implement generic one to avoid code duplication"

Hm... But we're choosing between

sys_write->xxx_cgroup_write->res_counter_set_limit->xxx_cgroup_call

and

sys_write->xxx_cgroup_write->res_counter_set_limit
                           ->xxx_cgroup_call

With the sizeof(void *)-bytes difference in res_counter, nNo?

>> And (if we definitely need one) isn't it better to make it a
>> 	struct res_counter_ops *ops;
>> pointer?
>>
> My first version did that. When I added hierarchy_model to ops(see later patch
> ), I made use of copy of ops. But maybe you're right. Keeping 
> res_counter small is important. I'll use pointer in v5.  
> 
> Thanks,
> -Kame-
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
