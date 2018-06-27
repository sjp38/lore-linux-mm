Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9A9FC6B000A
	for <linux-mm@kvack.org>; Wed, 27 Jun 2018 06:52:34 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id y123-v6so1227884oie.5
        for <linux-mm@kvack.org>; Wed, 27 Jun 2018 03:52:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id l14-v6si1161092oig.22.2018.06.27.03.52.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 27 Jun 2018 03:52:33 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
 <20180621073142.GA10465@dhcp22.suse.cz>
 <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
 <20180626170345.GA3593@linux.vnet.ibm.com>
 <f40d85e0-1d90-2261-99a4-4db315df4860@i-love.sakura.ne.jp>
 <20180626235014.GS3593@linux.vnet.ibm.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <c0aeb719-ccb7-46c7-2ad9-b0630bf4d542@i-love.sakura.ne.jp>
Date: Wed, 27 Jun 2018 19:52:23 +0900
MIME-Version: 1.0
In-Reply-To: <20180626235014.GS3593@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 2018/06/27 8:50, Paul E. McKenney wrote:
> On Wed, Jun 27, 2018 at 05:10:48AM +0900, Tetsuo Handa wrote:
>> As far as I can see,
>>
>> -	atomic_set(&oom_callback_count, 1);
>> +	atomic_inc(&oom_callback_count);
>>
>> should be sufficient.
> 
> I don't see how that helps.  For example, suppose that two tasks
> invoked rcu_oom_notify() at about the same time.  Then they could
> both see oom_callback_count equal to zero, both atomically increment
> oom_callback_count, then both do the IPI invoking rcu_oom_notify_cpu()
> on each online CPU.
> 
> So far, so good.  But rcu_oom_notify_cpu() enqueues a per-CPU RCU
> callback, and enqueuing the same callback twice in quick succession
> would fatally tangle RCU's callback lists.
> 
> What am I missing here?
> 
> 							Thanx, Paul

You are pointing out that "number of rsp->call() is called" > "number of
rcu_oom_callback() is called" can happen if concurrently called, aren't you?
Then, you are not missing anything. You will need to use something equivalent
to oom_lock even if you can convert rcu_oom_notify() to use shrinkers.
