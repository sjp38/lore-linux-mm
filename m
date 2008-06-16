Message-ID: <48562894.5080307@openvz.org>
Date: Mon, 16 Jun 2008 12:47:16 +0400
From: Pavel Emelyanov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [PATCH 1/6] res_counter:  handle limit change
References: <4856231B.9050704@openvz.org> <48561B68.6060503@openvz.org> <48560A7C.9050501@openvz.org> <20080613182714.265fe6d2.kamezawa.hiroyu@jp.fujitsu.com> <20080613182924.c73fe9eb.kamezawa.hiroyu@jp.fujitsu.com> <33011576.1213601977563.kamezawa.hiroyu@jp.fujitsu.com> <11930674.1213604250738.kamezawa.hiroyu@jp.fujitsu.com> <11706925.1213605137616.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <11706925.1213605137616.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: kamezawa.hiroyu@jp.fujitsu.com
Cc: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, menage@google.com, balbir@linux.vnet.ibm.com, yamamoto@valinux.co.jp, nishimura@mxp.nes.nec.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

kamezawa.hiroyu@jp.fujitsu.com wrote:
> ----- Original Message -----
> 
>> kamezawa.hiroyu@jp.fujitsu.com wrote:
>>> ----- Original Message -----
>>>
>>>>> I think when I did all in memcg, someone will comment that "why do that
>>>>> all in memcg ? please implement generic one to avoid code duplication"
>>>> Hm... But we're choosing between
>>>>
>>>> sys_write->xxx_cgroup_write->res_counter_set_limit->xxx_cgroup_call
>>>>
>>>> and
>>>>
>>>> sys_write->xxx_cgroup_write->res_counter_set_limit
>>>>                           ->xxx_cgroup_call
>>>>
>>>> With the sizeof(void *)-bytes difference in res_counter, nNo?
>>>>
>>> I can't catch what you mean. What is res_counter_set_limit here ?
>> It's res_counter_resize_limit from your patch, sorry for the confusion.
>>
>>> (my patche's ?) and what is sizeof(void *)-bytes ?
>> I meant, that we have to add 4 bytes (8 on 64-bit arches) on the
>> struct res_counter to store the pointer on the res_counter_ops.
>>
> Okay, maye all you want is "don't increase the size of res_counter"

Actually no, what I want is not to put indirections level when
not required.

But keeping res_counter as small as possible is also my wish. :)

>>> Is it so strange to add following algorithm in res_counter?
>>> ==
>>> set_limit -> fail -> shrink -> set limit -> fail ->shrink
>>> -> success -> return 0
>>> ==
>>> I think this is enough generic.
>> It is, but my point is - we're calling the set_limit (this is a
>> res_counter_resize_limit from your patch, sorry for the confusion again)
>> routine right from the cgroup's write callback and thus can call
>> the desired "ops->shrink_usage" directly, w/o additional level of
>> indirection.
>>
> Hmm, to do that, I'd like to remove strategy function from res_counter.

Oops... I'm looking at 2.6.26-rc5-mm1's res_counter and don't see such.
I tried to follow the changes in res_counter, but it looks like I've
already missed something. 

What do you mean by "strategy function from res_counter"?

> Ok? 
> 
> Thanks,
> -Kame
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
