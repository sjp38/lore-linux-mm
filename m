Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5ACA86B000E
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 12:30:24 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id b8-v6so2163611qto.16
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 09:30:24 -0700 (PDT)
Received: from EUR04-VI1-obe.outbound.protection.outlook.com (mail-eopbgr80122.outbound.protection.outlook.com. [40.107.8.122])
        by mx.google.com with ESMTPS id s66-v6si4530772qkb.305.2018.08.08.09.30.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Aug 2018 09:30:23 -0700 (PDT)
Subject: Re: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
From: Kirill Tkhai <ktkhai@virtuozzo.com>
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
 <20180808072040.GC27972@dhcp22.suse.cz>
 <d17e65bb-c114-55de-fb4e-e2f538779b92@virtuozzo.com>
 <20180808161330.GA22863@localhost>
 <f32ab99a-de28-b140-a7d0-027073055728@virtuozzo.com>
Message-ID: <b4b58edd-b317-6319-1306-7345aa0062b8@virtuozzo.com>
Date: Wed, 8 Aug 2018 19:30:13 +0300
MIME-Version: 1.0
In-Reply-To: <f32ab99a-de28-b140-a7d0-027073055728@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Josh Triplett <josh@joshtriplett.org>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 08.08.2018 19:23, Kirill Tkhai wrote:
> On 08.08.2018 19:13, Josh Triplett wrote:
>> On Wed, Aug 08, 2018 at 01:17:44PM +0300, Kirill Tkhai wrote:
>>> On 08.08.2018 10:20, Michal Hocko wrote:
>>>> On Tue 07-08-18 18:37:36, Kirill Tkhai wrote:
>>>>> This patch kills all CONFIG_SRCU defines and
>>>>> the code under !CONFIG_SRCU.
>>>>
>>>> The last time somebody tried to do this there was a pushback due to
>>>> kernel tinyfication. So this should really give some numbers about the
>>>> code size increase. Also why can't we make this depend on MMU. Is
>>>> anybody else than the reclaim asking for unconditional SRCU usage?
>>>
>>> I don't know one. The size numbers (sparc64) are:
>>>
>>> $ size image.srcu.disabled 
>>>    text	   data	    bss	    dec	    hex	filename
>>> 5117546	8030506	1968104	15116156	 e6a77c	image.srcu.disabled
>>> $ size image.srcu.enabled
>>>    text	   data	    bss	    dec	    hex	filename
>>> 5126175	8064346	1968104	15158625	 e74d61	image.srcu.enabled
>>> The difference is: 15158625-15116156 = 42469 ~41Kb
>>
>> 41k is a *substantial* size increase. However, can you compare
>> tinyconfig with and without this patch? That may have a smaller change.
> 
> $ size image.srcu.disabled
>    text	   data	    bss	    dec	    hex	filename
> 1105900	 195456	  63232	1364588	 14d26c	image.srcu.disabled
> 
> $ size image.srcu.enabled
>    text	   data	    bss	    dec	    hex	filename
> 1106960	 195528	  63232	1365720	 14d6d8	image.srcu.enabled
> 
> 1365720-1364588 = 1132 ~ 1Kb
 
1Kb is not huge size. It looks as not a big price for writing generic code
for only case (now some places have CONFIG_SRCU and !CONFIG_SRCU variants,
e.g. drivers/base/core.c). What do you think?
