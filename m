Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f177.google.com (mail-pf0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 238AD6B0038
	for <linux-mm@kvack.org>; Wed, 16 Dec 2015 19:50:37 -0500 (EST)
Received: by mail-pf0-f177.google.com with SMTP id n128so2096150pfn.0
        for <linux-mm@kvack.org>; Wed, 16 Dec 2015 16:50:37 -0800 (PST)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id w74si8438931pfi.130.2015.12.16.16.50.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Dec 2015 16:50:36 -0800 (PST)
Date: Wed, 16 Dec 2015 16:50:35 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Message-Id: <20151216165035.38a4d9b84600d6348a3cf4bf@linux-foundation.org>
In-Reply-To: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, 15 Dec 2015 19:36:15 +0100 Michal Hocko <mhocko@kernel.org> wrote:

> From: Michal Hocko <mhocko@suse.com>
> 
> This is based on the idea from Mel Gorman discussed during LSFMM 2015 and
> independently brought up by Oleg Nesterov.
> 
> The OOM killer currently allows to kill only a single task in a good
> hope that the task will terminate in a reasonable time and frees up its
> memory.  Such a task (oom victim) will get an access to memory reserves
> via mark_oom_victim to allow a forward progress should there be a need
> for additional memory during exit path.
>
> ...
>
> +static void oom_reap_vmas(struct mm_struct *mm)
> +{
> +	int attempts = 0;
> +
> +	while (attempts++ < 10 && !__oom_reap_vmas(mm))
> +		schedule_timeout(HZ/10);

schedule_timeout() in state TASK_RUNNING doesn't do anything.  Use
msleep() or msleep_interruptible().  I can't decide which is more
appropriate - it only affects the load average display.

Which prompts the obvious question: as the no-operativeness of this
call wasn't noticed in testing, why do we have it there...

I guess it means that the __oom_reap_vmas() success rate is nice and
high ;)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
