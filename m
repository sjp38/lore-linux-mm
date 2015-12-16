Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 217546B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 18:35:15 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id v86so19806462pfa.2
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 15:35:15 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id v17si8063868pfi.244.2015.12.16.15.35.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 15:35:14 -0800 (PST)
Date: Wed, 16 Dec 2015 15:35:13 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/3] OOM detection rework v4
Message-Id: <20151216153513.e432dc70e035e5d07984710c@linux-foundation.org>
In-Reply-To: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
References: <1450203586-10959-1-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Hillf Danton <hillf.zj@alibaba-inc.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Tue, 15 Dec 2015 19:19:43 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> This is an attempt to make the OOM detection more deterministic and
> easier to follow because each reclaimer basically tracks its own
> progress which is implemented at the page allocator layer rather spread
> out between the allocator and the reclaim. The more on the implementation
> is described in the first patch.

We've been futzing with this stuff for many years and it still isn't
working well.  This makes me expect that the new implementation will
take a long time to settle in.

To aid and accelerate this process I suggest we lard this code up with
lots of debug info, so when someone reports an issue we have the best
possible chance of understanding what went wrong.

This is easy in the case of oom-too-early - it's all slowpath code and
we can just do printk(everything).  It's not so easy in the case of
oom-too-late-or-never.  The reporter's machine just hangs or it
twiddles thumbs for five minutes then goes oom.  But there are things
we can do here as well, such as:

- add an automatic "nearly oom" detection which detects when things
  start going wrong and turns on diagnostics (this would need an enable
  knob, possibly in debugfs).

- forget about an autodetector and simply add a debugfs knob to turn on
  the diagnostics.

- sprinkle tracepoints everywhere and provide a set of
  instructions/scripts so that people who know nothing about kernel
  internals or tracing can easily gather the info we need to understand
  issues.

- add a sysrq key to turn on diagnostics.  Pretty essential when the
  machine is comatose and doesn't respond to keystrokes.

- something else

So...  please have a think about it?  What can we add in here to make it
as easy as possible for us (ie: you ;)) to get this code working well? 
At this time, too much developer support code will be better than too
little.  We can take it out later on.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
