Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f173.google.com (mail-ig0-f173.google.com [209.85.213.173])
	by kanga.kvack.org (Postfix) with ESMTP id D987B6B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 11:33:59 -0400 (EDT)
Received: by igbkq10 with SMTP id kq10so15548718igb.0
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 08:33:59 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g8si7314548igh.103.2015.10.08.08.33.57
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 08 Oct 2015 08:33:58 -0700 (PDT)
Subject: Re: Can't we use timeout based OOM warning/killing?
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201509260114.ADI35946.OtHOVFOMJQFLFS@I-love.SAKURA.ne.jp>
	<201509290118.BCJ43256.tSFFFMOLHVOJOQ@I-love.SAKURA.ne.jp>
	<20151002123639.GA13914@dhcp22.suse.cz>
	<201510031502.BJD59536.HFJMtQOOLFFVSO@I-love.SAKURA.ne.jp>
	<CA+55aFy5QBd-T2WXr5s4oAxcC1UoSjkFnd8v5f26LYzrtyFqAg@mail.gmail.com>
In-Reply-To: <CA+55aFy5QBd-T2WXr5s4oAxcC1UoSjkFnd8v5f26LYzrtyFqAg@mail.gmail.com>
Message-Id: <201510090033.AGG81243.FJOHOLOSQMVtFF@I-love.SAKURA.ne.jp>
Date: Fri, 9 Oct 2015 00:33:44 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: torvalds@linux-foundation.org
Cc: cl@linux.com, linux-kernel@vger.kernel.org, mhocko@kernel.org, kwalker@redhat.com, oleg@redhat.com, vdavydov@parallels.com, skozina@redhat.com, linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org

Linus Torvalds wrote:
> Because another thing that tends to affect this is that oom without swap is
> very different from oom with lots of swap, so different people will see
> very different issues. If you have some particular case you want to check,
> and could make a VM image for it, maybe that would get more mm people
> looking at it and agreeing about the issues.

I was working at support center for troubleshooting RHEL systems. I saw
many trouble cases where customer's servers hung up / rebooted unexpectedly.
In most cases, their servers hung up without OOM killer messages. (I saw
few cases where OOM killer messages are discovered by analyzing vmcore.)

No messages are recorded to log files such as /var/log/messages and
/var/log/sa/ when their servers hung up. According to /var/log/sa/ ,
there was little free memory just before their servers hung up.
I suspected that something memory related problem happened and suggested
customers to install serial console or netconsole in case the kernel was
printing some messages, but I don't know whether they were able to install
serial console or netconsole into their production systems.

The origin of this OOM livelock discussion was a local OOM-DoS vulnerability
which exists since Linux 2.0. When I tested this vulnerability on RHEL 7,
I saw strange stalls on XFS. The discussion went to public by developing
a reproducer which does not make use of the vulnerability. We recognized
the "too small to fail" memory-allocation rule. I tested various corner
cases using variants of the reproducer. I realized that we have race window
where the memory allocation can fall into infinite loop without OOM killer
messages.

I made a hypothesis that customer's servers hit a race where __GFP_FS
allocations are blocked at too_many_isolated() or unkillable locks in
direct reclaim paths whereas !__GFP_FS allocations are retrying forever
without calling out_of_memory(). But even if they install serial console
or netconsole, we are currently emitting no warning messages. The timeout
based OOM warning corresponds to check_memalloc_delay() in
http://marc.info/?l=linux-kernel&m=143239201905479 . The timeout based
OOM warning is not only for stalls after an OOM victim was chosen but also
for stalls before an OOM victim is chosen.

Whether we should call out_of_memory() upon timeout might depend on
hardware / ram / swap / workload etc. But I think that whether we can
have a mechanism for warning about possible OOM livelock is independent.
Thus, I think that making a VM image is not helpful.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
