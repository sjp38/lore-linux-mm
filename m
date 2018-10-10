Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 50B996B0007
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 05:02:41 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id x44-v6so2760064edd.17
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 02:02:41 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o15-v6si3590090edq.447.2018.10.10.02.02.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 02:02:40 -0700 (PDT)
Date: Wed, 10 Oct 2018 11:02:38 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: INFO: rcu detected stall in shmem_fault
Message-ID: <20181010090238.GD5873@dhcp22.suse.cz>
References: <000000000000dc48d40577d4a587@google.com>
 <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
 <alpine.DEB.2.21.1810092106190.83503@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.21.1810092106190.83503@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, syzkaller-bugs@googlegroups.com, yang.s@alibaba-inc.com

On Tue 09-10-18 21:11:48, David Rientjes wrote:
> On Wed, 10 Oct 2018, Tetsuo Handa wrote:
> 
> > syzbot is hitting RCU stall due to memcg-OOM event.
> > https://syzkaller.appspot.com/bug?id=4ae3fff7fcf4c33a47c1192d2d62d2e03efffa64
> > 
> > What should we do if memcg-OOM found no killable task because the allocating task
> > was oom_score_adj == -1000 ? Flooding printk() until RCU stall watchdog fires 
> > (which seems to be caused by commit 3100dab2aa09dc6e ("mm: memcontrol: print proper
> > OOM header when no eligible victim left") because syzbot was terminating the test
> > upon WARN(1) removed by that commit) is not a good behavior.
> > 
> 
> Not printing anything would be the obvious solution but the ideal solution 
> would probably involve
> 
>  - adding feedback to the memcg oom killer that there are no killable 
>    processes,

We already have that - out_of_memory == F

>  - adding complete coverage for memcg_oom_recover() in all uncharge paths
>    where the oom memcg's page_counter is decremented, and

Could you elaborate?

>  - having all processes stall until memcg_oom_recover() is called so 
>    looping back into try_charge() has a reasonable expectation to succeed.

You cannot stall in the charge path waiting for others to make a forward
progress because we would be back to oom deadlocks when nobody can make
forward progress due to lock dependencies.

Right now we simply force the charge and allow for further progress when
situation like this happen because this shouldn't happen unless the
memcg is misconfigured badly.
-- 
Michal Hocko
SUSE Labs
