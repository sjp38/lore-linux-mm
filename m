Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f178.google.com (mail-pf0-f178.google.com [209.85.192.178])
	by kanga.kvack.org (Postfix) with ESMTP id 646506B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 18:15:38 -0500 (EST)
Received: by mail-pf0-f178.google.com with SMTP id e65so31150593pfe.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 15:15:38 -0800 (PST)
Received: from mail-pf0-x235.google.com (mail-pf0-x235.google.com. [2607:f8b0:400e:c00::235])
        by mx.google.com with ESMTPS id qc8si4958221pac.39.2016.01.21.15.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 15:15:37 -0800 (PST)
Received: by mail-pf0-x235.google.com with SMTP id q63so31959436pfb.1
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 15:15:37 -0800 (PST)
Date: Thu, 21 Jan 2016 15:15:35 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm,oom: Re-enable OOM killer using timers.
In-Reply-To: <201601212044.AFD30275.OSFFOFJHMVLOQt@I-love.SAKURA.ne.jp>
Message-ID: <alpine.DEB.2.10.1601211513550.9813@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1601141500370.22665@chino.kir.corp.google.com> <201601151936.IJJ09362.OOFLtVFJHSFQMO@I-love.SAKURA.ne.jp> <alpine.DEB.2.10.1601191502230.7346@chino.kir.corp.google.com> <201601202336.BJC04687.FOFVOQJOLSFtMH@I-love.SAKURA.ne.jp>
 <alpine.DEB.2.10.1601201538070.18155@chino.kir.corp.google.com> <201601212044.AFD30275.OSFFOFJHMVLOQt@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: hannes@cmpxchg.org, mhocko@kernel.org, akpm@linux-foundation.org, mgorman@suse.de, torvalds@linux-foundation.org, oleg@redhat.com, hughd@google.com, andrea@kernel.org, riel@redhat.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 21 Jan 2016, Tetsuo Handa wrote:

> I consider phases for managing system-wide OOM events as follows.
> 
>   (1) Design and use a system with appropriate memory capacity in mind.
> 
>   (2) When (1) failed, the OOM killer is invoked. The OOM killer selects
>       an OOM victim and allow that victim access to memory reserves by
>       setting TIF_MEMDIE to it.
> 
>   (3) When (2) did not solve the OOM condition, start allowing all tasks
>       access to memory reserves by your approach.
> 
>   (4) When (3) did not solve the OOM condition, start selecting more OOM
>       victims by my approach.
> 
>   (5) When (4) did not solve the OOM condition, trigger the kernel panic.
> 

This was all mentioned previously, and I suggested that the panic only 
occur when memory reserves have been depleted, otherwise there is still 
the potential for the livelock to be solved.  That is a patch that would 
apply today, before any of this work, since we never want to loop 
endlessly in the page allocator when memory reserves are fully depleted.

This is all really quite simple.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
