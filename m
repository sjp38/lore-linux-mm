Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 9BEBC6B0262
	for <linux-mm@kvack.org>; Sat, 21 May 2016 00:07:57 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u185so225510326oie.3
        for <linux-mm@kvack.org>; Fri, 20 May 2016 21:07:57 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x53si11126273otx.167.2016.05.20.21.07.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 May 2016 21:07:56 -0700 (PDT)
Subject: Re: zone_reclaimable() leads to livelock in __alloc_pages_slowpath()
References: <20160520202817.GA22201@redhat.com>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <237e1113-fca7-51c7-1271-fb48398fd599@I-love.SAKURA.ne.jp>
Date: Sat, 21 May 2016 13:07:37 +0900
MIME-Version: 1.0
In-Reply-To: <20160520202817.GA22201@redhat.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 2016/05/21 5:28, Oleg Nesterov wrote:
> Hello,
> 
> Recently I hit the problem, _sometimes_ the system just hangs in OOM situation.
> Surprisingly, this time OOM-killer is innocent ;) and finally I can reproduce
> this more-or-less reliably just running
> 
> 	#include <stdlib.h>
> 	#include <string.h>
> 
> 	int main(void)
> 	{
> 		for (;;) {
> 			void *p = malloc(1024 * 1024);
> 			memset(p, 0, 1024 * 1024);
> 		}
> 	}
> 
> in a loop on the otherwise idle system. 512m RAM, one CPU (but CONFIG_SMP=y),
> no swap, and only one user-space process (apart from test-case above), /bin/sh
> runnning as init with pid==1. I am attaching my .config just in case, but I
> think the problem is not really specific to this configuration.
> 
> --------------------------------------------------------------------------------
> It spins in __alloc_pages_slowpath() forever, __alloc_pages_may_oom() is never
> called, it doesn't react to SIGKILL, etc.
> 
> This is because zone_reclaimable() is always true in shrink_zones(), and the
> problem goes away if I comment out this code
> 
> 	if (global_reclaim(sc) &&
> 	    !reclaimable && zone_reclaimable(zone))
> 		reclaimable = true;
> 
> in shrink_zones() which otherwise returns this "true" every time, and thus
> __alloc_pages_slowpath() always sees did_some_progress != 0.
> 

Michal Hocko's OOM detection rework patchset that removes that code was sent
to Linus 4 hours ago. ( https://marc.info/?l=linux-mm-commits&m=146378862415399 )
Please wait for a few days and try reproducing using linux.git .

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
