Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id 75CAE6B0038
	for <linux-mm@kvack.org>; Wed, 25 Nov 2015 06:54:23 -0500 (EST)
Received: by pabfh17 with SMTP id fh17so57430384pab.0
        for <linux-mm@kvack.org>; Wed, 25 Nov 2015 03:54:23 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id ff10si753749pab.240.2015.11.25.03.54.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 25 Nov 2015 03:54:22 -0800 (PST)
Subject: Re: [PATCH] mm, vmstat: Allow WQ concurrency to discover memory reclaim doesn't make any progress
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1447936253-18134-1-git-send-email-mhocko@kernel.org>
	<20151124154448.ac124e62528db313279224ef@linux-foundation.org>
	<20151125110705.GC27283@dhcp22.suse.cz>
In-Reply-To: <20151125110705.GC27283@dhcp22.suse.cz>
Message-Id: <201511252054.DEC87052.MSLVJHFQtOFOFO@I-love.SAKURA.ne.jp>
Date: Wed, 25 Nov 2015 20:54:13 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, akpm@linux-foundation.org
Cc: tj@kernel.org, clameter@sgi.com, arekm@maven.pl, linux-mm@kvack.org, linux-kernel@vger.kernel.org, js1304@gmail.com, cl@linux.com

Michal Hocko wrote:
> Anyway I think that the issue is not solely theoretical. WQ_MEM_RECLAIM
> is simply not working if the allocation path doesn't sleep currently and
> my understanding of what Tejun claims [2] is that that reimplementing WQ
> concurrency would be too intrusive and lacks sufficient justification
> because other kernel paths do sleep. This patch tries to reduce the
> sleep only to worker threads which should not cause any problems to
> regular tasks.

I received many unexplained hangup/reboot reports from customers when I was
working at support center. But we can't answer whether real people ever hit
this problem because we have no watchdog for memory allocation stalls.
I want one like http://lkml.kernel.org/r/201511250024.AAE78692.QVOtFFOSFOMLJH@I-love.SAKURA.ne.jp
as I wrote off-list ( "mm,oom: The reason why I continue proposing timeout
based approach." ). It will help with judging when we tackle TIF_MEMDIE
livelock problem.

What I can say is that RHEL6 (a 2.6.32-based distro) backported the
wait_iff_congested() changes and therefore people might really hit
this problem.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
