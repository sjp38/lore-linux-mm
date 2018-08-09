Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 505F86B0007
	for <linux-mm@kvack.org>; Thu,  9 Aug 2018 06:39:28 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id b8-v6so5225854oib.4
        for <linux-mm@kvack.org>; Thu, 09 Aug 2018 03:39:28 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id g84-v6si4246703oia.172.2018.08.09.03.39.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Aug 2018 03:39:27 -0700 (PDT)
Subject: Re: [PATCH RFC v2 02/10] mm: Make shrink_slab() lockless
References: <153365347929.19074.12509495712735843805.stgit@localhost.localdomain>
 <153365626605.19074.16202958374930777592.stgit@localhost.localdomain>
 <591d2063-0511-103d-bef6-dd35f55afe32@virtuozzo.com>
 <4ceb948c-7ce7-0db3-17d8-82ef1e6e47cc@virtuozzo.com>
 <20180809071418.GA24884@dhcp22.suse.cz>
 <cf7ba095-8be9-ead8-5422-59fa1f3bb07d@virtuozzo.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <7b746367-e4bc-0e64-4e27-14fd7f06ba8f@i-love.sakura.ne.jp>
Date: Thu, 9 Aug 2018 19:37:32 +0900
MIME-Version: 1.0
In-Reply-To: <cf7ba095-8be9-ead8-5422-59fa1f3bb07d@virtuozzo.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kirill Tkhai <ktkhai@virtuozzo.com>
Cc: Michal Hocko <mhocko@kernel.org>, akpm@linux-foundation.org, gregkh@linuxfoundation.org, rafael@kernel.org, viro@zeniv.linux.org.uk, darrick.wong@oracle.com, paulmck@linux.vnet.ibm.com, josh@joshtriplett.org, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, jiangshanlai@gmail.com, hughd@google.com, shuah@kernel.org, robh@kernel.org, ulf.hansson@linaro.org, aspriel@gmail.com, vivek.gautam@codeaurora.org, robin.murphy@arm.com, joe@perches.com, heikki.krogerus@linux.intel.com, sfr@canb.auug.org.au, vdavydov.dev@gmail.com, chris@chris-wilson.co.uk, aryabinin@virtuozzo.com, willy@infradead.org, ying.huang@intel.com, shakeelb@google.com, jbacik@fb.com, mingo@kernel.org, mhiramat@kernel.org, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org

On 2018/08/09 18:21, Kirill Tkhai wrote:
> 2)SRCU. Pros are there are no the above problems; we will have completely unlocked and
>   scalable shrink_slab(). We will also have a possibility to avoid unregistering delays,
>   like I did for superblock shrinker. There will be full scalability.
>   Cons is enabling SRCU.
> 

How unregistering delays can be avoided? Since you traverse all shrinkers
using one shrinker_srcu, synchronize_srcu(&shrinker_srcu) will block
unregistering threads until longest inflight srcu_read_lock() user calls
srcu_read_unlock().

Unless you use per shrinker counter like below, I wonder whether
unregistering delays can be avoided...

  https://marc.info/?l=linux-mm&m=151060909613004
  https://marc.info/?l=linux-mm&m=151060909713005
