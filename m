From: kamezawa.hiroyu@jp.fujitsu.com
Message-ID: <26479923.1212245220415.kamezawa.hiroyu@jp.fujitsu.com>
Date: Sat, 31 May 2008 23:47:00 +0900 (JST)
Subject: Re: Re: [RFC][PATCH 1/2] memcg: res_counter hierarchy
In-Reply-To: <48413482.5080409@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
References: <48413482.5080409@linux.vnet.ibm.com>
 <48407DC3.8060001@linux.vnet.ibm.com> <20080530104312.4b20cc60.kamezawa.hiroyu@jp.fujitsu.com> <20080530104515.9afefdbb.kamezawa.hiroyu@jp.fujitsu.com> <25360008.1212199156779.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@linux.vnet.ibm.com
Cc: kamezawa.hiroyu@jp.fujitsu.com, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, xemul@openvz.org, menage@google.com, yamamoto@valinux.co.jp, lizf@cn.fujitsu.com
List-ID: <linux-mm.kvack.org>

----- Original Message -----

>> One more problem is that it's hard to implement various kinds of hierarchy
>> policy. I believe there are other hierarhcy policies rather than OpenVZ
>> want to use. Kicking out functions to middleware AMAP is what I'm thinking
>> now.
>
>One way to manage hierarchies other than via limits is to use shares (please 
see
>the shares used by the cpu controller). Basically, what you've done with limi
ts
>is done with shares
>
Yes, I like _share_ rather than limits.

>If a parent has 100 shares, then it can decide how many to pass on to it's  c
hildren
>based on the shares of the child and your logic would work well. I propose
>assigning top level (high resolution) shares to the root of the cgroup and in
 a
>hierarchy passing them down to children and sharing it with them. Based on th
e
>shares, deduce the limit of each node in the hierarchy.
>
>What do you think?
>
As you wrote, a middleware can do controls based on share by limits.
And it seems much easier to implement it in userland rather than in the kernel
.

Here is an example. (just an example...)
Please point out if I'm misunderstanding "share".

root_level/                   = limit 1G.
          /child_A = share=30
          /child_B = share=15
          /child_C = share=5
(and assume there is no process under root_level for make explanation easy..)

0. At first, before starting to use memory, set all kernel_memory_limit.
root_level.limit = 1G
  child_A.limit=64M,usage=0
  child_B.limit=64M,usage=0
  child_C.limit=64M,usage=0
  free_resource=808M 

1. next, a process in child_C start to run and use memory of 600M.
root_level.limit = 1G
  child_A.limit=64M
  child_B.limit=64M
  child_C.limit=600M,usage=600M
  free_resource=272M

2. now, a process in child_A start tu run and use memory of 800M.
  child_A.limit=800M,usage=800M
  child_B.limit=64M,usage=0M
  child_C.limit=136M,usage=136M
  free_resouce=0,A:C=6:1

3.Finally, a process in child_B start. and use memory of 500M.
  child_A.limit=600M,usage=600M
  child_B.limit=300M,usage=300M
  child_C.limit=100M,usage=100M
  free_resouce=0, A:B:C=6:3:1

4. one more, a process in A exits.
  child_A.limit=64M, usage=0M
  child_B.limit=500M, usage=500M
  child_C.limit=436M, usage=436M
  free_resouce=0, B:C=3:1 (but B just want to use 500M)

This is only an example and the middleware can more pricise "limit"
contols by checking statistics of memory controller hierarchy based on
their own policy.

What I think now is what kind of statistics/notifier/controls are
necessary to implement shares in middleware. How pricise/quick work the
middleware can do is based on interfaces.
Maybe the middleware should know "how fast the application runs now" by
some kind of check or co-operative interface with the application.
But I'm not sure how the kernel can help it.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
