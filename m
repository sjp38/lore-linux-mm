Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id A47716B0003
	for <linux-mm@kvack.org>; Mon,  1 Oct 2018 15:23:29 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id x19-v6so18291738pfh.15
        for <linux-mm@kvack.org>; Mon, 01 Oct 2018 12:23:29 -0700 (PDT)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id e10-v6si12813080pgl.554.2018.10.01.12.23.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Oct 2018 12:23:28 -0700 (PDT)
Date: Mon, 1 Oct 2018 15:23:24 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: 4.14 backport request for dbdda842fe96f: "printk: Add console
 owner and waiter logic to load balance console writes"
Message-ID: <20181001152324.72a20bea@gandalf.local.home>
In-Reply-To: <20180927194601.207765-1-wonderfly@google.com>
References: <20180927194601.207765-1-wonderfly@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Wang <wonderfly@google.com>
Cc: stable@vger.kernel.org, pmladek@suse.com, Alexander.Levin@microsoft.com, akpm@linux-foundation.org, byungchul.park@lge.com, dave.hansen@intel.com, hannes@cmpxchg.org, jack@suse.cz, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mathieu.desnoyers@efficios.com, mgorman@suse.de, mhocko@kernel.org, pavel@ucw.cz, penguin-kernel@I-love.SAKURA.ne.jp, peterz@infradead.org, tj@kernel.org, torvalds@linux-foundation.org, vbabka@suse.cz, xiyou.wangcong@gmail.com, pfeiner@google.com

On Thu, 27 Sep 2018 12:46:01 -0700
Daniel Wang <wonderfly@google.com> wrote:

> Prior to this change, the combination of `softlockup_panic=1` and
> `softlockup_all_cpu_stacktrace=1` may result in a deadlock when the reboot path
> is trying to grab the console lock that is held by the stack trace printing
> path. What seems to be happening is that while there are multiple CPUs, only one
> of them is tasked to print the back trace of all CPUs. On a machine with many
> CPUs and a slow serial console (on Google Compute Engine for example), the stack
> trace printing routine hits a timeout and the reboot path kicks in. The latter
> then tries to print something else, but can't get the lock because it's still
> held by earlier printing path. This is easily reproducible on a VM with 16+
> vCPUs on Google Compute Engine - which is a very common scenario.
> 
> A quick repro is available at
> https://github.com/wonderfly/printk-deadlock-repro. The system hangs 3 seconds
> into executing repro.sh. Both deadlock analysis and repro are credits to Peter
> Feiner.
> 
> Note that I have read previous discussions on backporting this to stable [1].
> The argument for objecting the backport was that this is a non-trivial fix and
> is supported to prevent hypothetical soft lockups. What we are hitting is a real
> deadlock, in production, however. Hence this request.
> 
> [1] https://lore.kernel.org/lkml/20180409081535.dq7p5bfnpvd3xk3t@pathway.suse.cz/T/#u
> 
> Serial console logs leading up to the deadlock. As can be seen the stack trace
> was incomplete because the printing path hit a timeout.

I'm fine with having this backported.

-- Steve
