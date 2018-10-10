Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9EF666B0008
	for <linux-mm@kvack.org>; Wed, 10 Oct 2018 04:59:48 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id l51-v6so2780961edc.14
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 01:59:48 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h6-v6si2288841ejc.83.2018.10.10.01.59.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 10 Oct 2018 01:59:47 -0700 (PDT)
Date: Wed, 10 Oct 2018 10:59:45 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: INFO: rcu detected stall in shmem_fault
Message-ID: <20181010085945.GC5873@dhcp22.suse.cz>
References: <000000000000dc48d40577d4a587@google.com>
 <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201810100012.w9A0Cjtn047782@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: syzbot <syzbot+77e6b28a7a7106ad0def@syzkaller.appspotmail.com>, hannes@cmpxchg.org, akpm@linux-foundation.org, guro@fb.com, kirill.shutemov@linux.intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rientjes@google.com, syzkaller-bugs@googlegroups.com, yang.s@alibaba-inc.com

On Wed 10-10-18 09:12:45, Tetsuo Handa wrote:
> syzbot is hitting RCU stall due to memcg-OOM event.
> https://syzkaller.appspot.com/bug?id=4ae3fff7fcf4c33a47c1192d2d62d2e03efffa64

This is really interesting. If we do not have any eligible oom victim we
simply force the charge (allow to proceed and go over the hard limit)
and break the isolation. That means that the caller gets back to running
and realease all locks take on the way. I am wondering how come we are
seeing the RCU stall. Whole is holding the rcu lock? Certainly not the
charge patch and neither should the caller because you have to be in a
sleepable context to trigger the OOM killer. So there must be something
more going on.

> What should we do if memcg-OOM found no killable task because the allocating task
> was oom_score_adj == -1000 ? Flooding printk() until RCU stall watchdog fires 
> (which seems to be caused by commit 3100dab2aa09dc6e ("mm: memcontrol: print proper
> OOM header when no eligible victim left") because syzbot was terminating the test
> upon WARN(1) removed by that commit) is not a good behavior.

We definitely want to inform about ineligible oom victim. We might
consider some rate limiting for the memcg state but that is a valuable
information to see under normal situation (when you do not have floods
of these situations).
-- 
Michal Hocko
SUSE Labs
