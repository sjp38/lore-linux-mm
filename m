Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 36CBA6B0266
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 00:11:52 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id q143-v6so2792876pgq.12
        for <linux-mm@kvack.org>; Tue, 09 Oct 2018 21:11:52 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u132-v6sor18472760pgb.68.2018.10.09.21.11.51
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 09 Oct 2018 21:11:51 -0700 (PDT)
Date: Tue, 9 Oct 2018 21:11:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: INFO: rcu detected stall in shmem_fault
In-Reply-To: <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
Message-ID: <alpine.DEB.2.21.1810092106190.83503@chino.kir.corp.google.com>
References: <000000000000dc48d40577d4a587@google.com> <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, yang.s@alibaba-inc.com

On Wed, 10 Oct 2018, Tetsuo Handa wrote:

> syzbot is hitting RCU stall due to memcg-OOM event.
> https://syzkaller.appspot.com/bug?id=4ae3fff7fcf4c33a47c1192d2d62d2e03efffa64
> 
> What should we do if memcg-OOM found no killable task because the allocating task
> was oom_score_adj == -1000 ? Flooding printk() until RCU stall watchdog fires 
> (which seems to be caused by commit 3100dab2aa09dc6e ("mm: memcontrol: print proper
> OOM header when no eligible victim left") because syzbot was terminating the test
> upon WARN(1) removed by that commit) is not a good behavior.
> 

Not printing anything would be the obvious solution but the ideal solution 
would probably involve

 - adding feedback to the memcg oom killer that there are no killable 
   processes,

 - adding complete coverage for memcg_oom_recover() in all uncharge paths
   where the oom memcg's page_counter is decremented, and

 - having all processes stall until memcg_oom_recover() is called so 
   looping back into try_charge() has a reasonable expectation to succeed.
