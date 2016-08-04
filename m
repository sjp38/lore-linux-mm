Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 80F4D6B0005
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 17:46:51 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so480607876pfd.3
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 14:46:51 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id m6si16534194pfi.52.2016.08.04.14.46.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 14:46:50 -0700 (PDT)
Date: Thu, 4 Aug 2016 14:46:49 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH/RFC] mm, oom: Fix uninitialized ret in
 task_will_free_mem()
Message-Id: <20160804144649.7ac4727ad0d93097c4055610@linux-foundation.org>
In-Reply-To: <178c5e9b-b92d-b62b-40a9-ee98b10d6bce@I-love.SAKURA.ne.jp>
References: <1470255599-24841-1-git-send-email-geert@linux-m68k.org>
	<178c5e9b-b92d-b62b-40a9-ee98b10d6bce@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 4 Aug 2016 21:28:13 +0900 Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> wrote:

> > 
> > Fixes: 1af8bb43269563e4 ("mm, oom: fortify task_will_free_mem()")
> > Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
> > ---
> > Untested. I'm not familiar with the code, hence the default value of
> > true was deducted from the logic in the loop (return false as soon as
> > __task_will_free_mem() has returned false).
> 
> I think ret = true is correct. Andrew, please send to linux.git.

task_will_free_mem() is too hard to understand.

We're examining task "A":

: 	for_each_process(p) {
: 		if (!process_shares_mm(p, mm))
: 			continue;
: 		if (same_thread_group(task, p))
: 			continue;

So here, we've found a process `p' which shares A's mm and which does
not share A's thread group.

: 		ret = __task_will_free_mem(p);

And here we check to see if killing `p' would free up memory.

: 		if (!ret)
: 			break;

If killing `p' will not free memory then give up the scan of all
processes because <reasons>, and we decide that killing `A' will
not free memory either, because some other task is holding onto
A's memory anyway.

: 	}

And if no task is found to be sharing A's mm while not sharing A's
thread group then fall through and decide to kill A.  In which case the
patch to return `true' is correct.

Correctish?  Maybe.  Can we please get some comments in there to
demystify the decision-making?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
