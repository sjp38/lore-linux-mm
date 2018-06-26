Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 168C86B0006
	for <linux-mm@kvack.org>; Tue, 26 Jun 2018 16:11:07 -0400 (EDT)
Received: by mail-ot0-f197.google.com with SMTP id q6-v6so5492420otf.20
        for <linux-mm@kvack.org>; Tue, 26 Jun 2018 13:11:07 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id p48-v6si361965otc.322.2018.06.26.13.11.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 Jun 2018 13:11:05 -0700 (PDT)
Subject: Re: [PATCH] mm,oom: Bring OOM notifier callbacks to outside of OOM
 killer.
References: <1529493638-6389-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.21.1806201528490.16984@chino.kir.corp.google.com>
 <20180621073142.GA10465@dhcp22.suse.cz>
 <2d8c3056-1bc2-9a32-d745-ab328fd587a1@i-love.sakura.ne.jp>
 <20180626170345.GA3593@linux.vnet.ibm.com>
From: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Message-ID: <f40d85e0-1d90-2261-99a4-4db315df4860@i-love.sakura.ne.jp>
Date: Wed, 27 Jun 2018 05:10:48 +0900
MIME-Version: 1.0
In-Reply-To: <20180626170345.GA3593@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: paulmck@linux.vnet.ibm.com
Cc: Michal Hocko <mhocko@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org

On 2018/06/27 2:03, Paul E. McKenney wrote:
> There are a lot of ways it could be made concurrency safe.  If you need
> me to do this, please do let me know.
> 
> That said, the way it is now written, if you invoke rcu_oom_notify()
> twice in a row, the second invocation will wait until the memory from
> the first invocation is freed.  What do you want me to do if you invoke
> me concurrently?
> 
> 1.	One invocation "wins", waits for the earlier callbacks to
> 	complete, then encourages any subsequent callbacks to be
> 	processed more quickly.  The other invocations return
> 	immediately without doing anything.
> 
> 2.	The invocations serialize, with each invocation waiting for
> 	the callbacks from previous invocation (in mutex_lock() order
> 	or some such), and then starting a new round.
> 
> 3.	Something else?
> 
> 							Thanx, Paul

As far as I can see,

-	atomic_set(&oom_callback_count, 1);
+	atomic_inc(&oom_callback_count);

should be sufficient.
