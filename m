Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 767B56B0003
	for <linux-mm@kvack.org>; Wed,  8 Aug 2018 06:17:56 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o18-v6so1402260qtp.13
        for <linux-mm@kvack.org>; Wed, 08 Aug 2018 03:17:56 -0700 (PDT)
Received: from EUR03-VE1-obe.outbound.protection.outlook.com (mail-eopbgr50109.outbound.protection.outlook.com. [40.107.5.109])
        by mx.google.com with ESMTPS id v4-v6si838440qkc.270.2018.08.08.03.17.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 08 Aug 2018 03:17:55 -0700 (PDT)
Subject: Re: [PATCH RFC 01/10] rcu: Make CONFIG_SRCU unconditionally enabled
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365625652.19074.8434946780002619802.stgit@localhost.localdomain>
 <20180808072040.GC27972@dhcp22.suse.cz>
From: Kirill Tkhai <ktkhai@virtuozzo.com>
Message-ID: <d17e65bb-c114-55de-fb4e-e2f538779b92@virtuozzo.com>
Date: Wed, 8 Aug 2018 13:17:44 +0300
MIME-Version: 1.0
In-Reply-To: <20180808072040.GC27972@dhcp22.suse.cz>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, chris@chris-wilson.co.uk, penguin-kernel@I-love.SAKURA.ne.jp, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 08.08.2018 10:20, Michal Hocko wrote:
> On Tue 07-08-18 18:37:36, Kirill Tkhai wrote:
>> This patch kills all CONFIG_SRCU defines and
>> the code under !CONFIG_SRCU.
> 
> The last time somebody tried to do this there was a pushback due to
> kernel tinyfication. So this should really give some numbers about the
> code size increase. Also why can't we make this depend on MMU. Is
> anybody else than the reclaim asking for unconditional SRCU usage?

I don't know one. The size numbers (sparc64) are:

$ size image.srcu.disabled 
   text	   data	    bss	    dec	    hex	filename
5117546	8030506	1968104	15116156	 e6a77c	image.srcu.disabled
$ size image.srcu.enabled
   text	   data	    bss	    dec	    hex	filename
5126175	8064346	1968104	15158625	 e74d61	image.srcu.enabled
The difference is: 15158625-15116156 = 42469 ~41Kb

Please, see the measurement details to my answer to Stephen.

> Btw. I totaly agree with Steven. This is a very poor changelog. It is
> trivial to see what the patch does but it is far from clear why it is
> doing that and why we cannot go other ways.
We possibly can go another way, and there is comment to [2/10] about this.
Percpu rwsem may be used instead, the only thing, it is worse, is it will
make shrink_slab() wait unregistering shrinkers, while srcu-based
implementation does not require this. This may be not a big problem.
But, if SRCU is real problem for embedded people, I really don't want they
hate me in the future because of this, so please CC someone if you know :)

Kirill
