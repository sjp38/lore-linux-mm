Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f198.google.com (mail-yb0-f198.google.com [209.85.213.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5AA086B0253
	for <linux-mm@kvack.org>; Tue,  9 Aug 2016 10:26:07 -0400 (EDT)
Received: by mail-yb0-f198.google.com with SMTP id e125so11742848ybc.3
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 07:26:07 -0700 (PDT)
Received: from mail-yw0-x244.google.com (mail-yw0-x244.google.com. [2607:f8b0:4002:c05::244])
        by mx.google.com with ESMTPS id x84si5562675ybx.336.2016.08.09.07.26.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Aug 2016 07:26:06 -0700 (PDT)
Received: by mail-yw0-x244.google.com with SMTP id r9so574780ywg.2
        for <linux-mm@kvack.org>; Tue, 09 Aug 2016 07:26:06 -0700 (PDT)
Date: Tue, 9 Aug 2016 10:26:03 -0400
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH] cgroup_threadgroup_rwsem - affects scalability and
 OOM
Message-ID: <20160809142603.GE4906@mtj.duckdns.org>
References: <4717ef90-ca86-4a34-c63a-94b8b4bfaaec@gmail.com>
 <20160809062900.GD4906@mtj.duckdns.org>
 <0a7ffe43-c0c6-85df-9bc2-d00fc837e284@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0a7ffe43-c0c6-85df-9bc2-d00fc837e284@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: cgroups@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

Hello, Balbir.

On Tue, Aug 09, 2016 at 05:02:47PM +1000, Balbir Singh wrote:
> > Hmm? Where does mem_cgroup_iter grab cgroup_mutex?  cgroup_mutex nests
> > outside cgroup_threadgroup_rwsem or most other mutexes for that matter
> > and isn't exposed from cgroup core.
> > 
> 
> I based my theory on the code
> 
> mem_cgroup_iter -> css_next_descendant_pre which asserts
> 
> cgroup_assert_mutex_or_rcu_locked(), 
> 
> although you are right, we hold RCU lock while calling css_* routines.

That's "or".  The iterator can be called either with RCU lock or
cgroup_mutex.  cgroup core may use it under cgroup_mutex.  Everyone
else uses it with rcu.

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
