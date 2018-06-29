Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f198.google.com (mail-ot0-f198.google.com [74.125.82.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3B2CA6B000D
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 10:36:04 -0400 (EDT)
Received: by mail-ot0-f198.google.com with SMTP id o3-v6so5811419otl.16
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 07:36:04 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id w204-v6si3086861oig.335.2018.06.29.07.36.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 07:36:02 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
 <20180621073142.GA10465@dhcp22.suse.cz>
 <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
 <20180626170345.GA3593@linux.vnet.ibm.com>
 <20180627072207.GB32348@dhcp22.suse.cz>
 <20180627143125.GW3593@linux.vnet.ibm.com>
 <20180628113942.GD32348@dhcp22.suse.cz>
 <20180628213105.GP3593@linux.vnet.ibm.com>
 <20180629090419.GD13860@dhcp22.suse.cz>
 <20180629125218.GX3593@linux.vnet.ibm.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <bf76c93d-37d6-5f1e-4e5a-122089997fd9@i-love.sakura.ne.jp>
Date: Fri, 29 Jun 2018 23:35:48 +0900
MIME-Version: 1.0
In-Reply-To: <20180629125218.GX3593@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com, Michal Hocko <mhocko@kernel.org>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 2018/06/29 21:52, Paul E. McKenney wrote:
> The effect of RCU's current OOM code is to speed up callback invocation
> by at most a few seconds (assuming no stalled CPUs, in which case
> it is not possible to speed up callback invocation).
> 
> Given that, I should just remove RCU's OOM code entirely?

out_of_memory() will start selecting an OOM victim without calling
get_page_from_freelist() since rcu_oom_notify() does not set non-zero
value to "freed" field.

I think that rcu_oom_notify() needs to wait for completion of callback
invocations (possibly with timeout in case there are stalling CPUs) and
set non-zero value to "freed" field if pending callbacks did release memory.

However, what will be difficult to tell is whether invocation of pending callbacks
did release memory. Lack of last second get_page_from_freelist() call after
blocking_notifier_call_chain(&oom_notify_list, 0, &freed) forces rcu_oom_notify()
to set appropriate value (i.e. zero or non-zero) to "freed" field.

We have tried to move really last second get_page_from_freelist() call to inside
out_of_memory() after blocking_notifier_call_chain(&oom_notify_list, 0, &freed).
But that proposal was not accepted...

We could move blocking_notifier_call_chain(&oom_notify_list, 0, &freed) to
before last second get_page_from_freelist() call (and this is what this patch
is trying to do) which would allow rcu_oom_notify() to always return 0...
or update rcu_oom_notify() to use shrinker API...
