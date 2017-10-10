Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7B6F16B025E
	for <linux-mm@kvack.org>; Tue, 10 Oct 2017 08:47:17 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f15so15939470qtf.1
        for <linux-mm@kvack.org>; Tue, 10 Oct 2017 05:47:17 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g82si1848820ioa.256.2017.10.10.05.47.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 10 Oct 2017 05:47:15 -0700 (PDT)
Subject: Re: [PATCH] vmalloc: back off only when the current task is OOM killed
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1507633133-5720-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171010115436.nzgo4ewodx5pyrw7@dhcp22.suse.cz>
In-Reply-To: <20171010115436.nzgo4ewodx5pyrw7@dhcp22.suse.cz>
Message-Id: <201710102147.IGJ90612.OQSFMFLVtOOJFH@I-love.SAKURA.ne.jp>
Date: Tue, 10 Oct 2017 21:47:02 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, akpm@linux-foundation.org, alan@llwyncelyn.cymru, hch@lst.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

Michal Hocko wrote:
> On Tue 10-10-17 19:58:53, Tetsuo Handa wrote:
> > Commit 5d17a73a2ebeb8d1 ("vmalloc: back off when the current task is
> > killed") revealed two bugs [1] [2] that were not ready to fail vmalloc()
> > upon SIGKILL. But since the intent of that commit was to avoid unlimited
> > access to memory reserves, we should have checked tsk_is_oom_victim()
> > rather than fatal_signal_pending().
> > 
> > Note that even with commit cd04ae1e2dc8e365 ("mm, oom: do not rely on
> > TIF_MEMDIE for memory reserves access"), it is possible to trigger
> > "complete depletion of memory reserves"
> 
> How would that be possible? OOM victims are not allowed to consume whole
> reserves and the vmalloc context would have to do something utterly
> wrong like PF_MEMALLOC to make this happen. Protecting from such a code
> is simply pointless.

Oops. I was confused when writing that part.
Indeed, "complete" was demonstrated without commit cd04ae1e2dc8e365.

> 
> > and "extra OOM kills due to depletion of memory reserves"
> 
> and this is simply the case for the most vmalloc allocations because
> they are not reflected in the oom selection so if there is a massive
> vmalloc consumer it is very likely that we will kill a large part the
> userspace before hitting the user context on behalf which the vmalloc
> allocation is performed.

If there is a massive alloc_page() loop it is as well very likely that
we will kill a large part the userspace before hitting the user context
on behalf which the alloc_page() allocation is performed.

I think that massive vmalloc() consumers should be (as well as massive
alloc_page() consumers) careful such that they will be chosen as first OOM
victim, for vmalloc() does not abort as soon as an OOM occurs. Thus, I used
set_current_oom_origin()/clear_current_oom_origin() when I demonstrated
"complete" depletion.

> 
> I have tried to explain this is not really needed before but you keep
> insisting which is highly annoying. The patch as is is not harmful but
> it is simply _pointless_ IMHO.

Then, how can massive vmalloc() consumers become careful?
Explicitly use __vmalloc() and pass __GFP_NOMEMALLOC ?
Then, what about adding some comment like "Never try to allocate large
memory using plain vmalloc(). Use __vmalloc() with __GFP_NOMEMALLOC." ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
