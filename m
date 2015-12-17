Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f178.google.com (mail-io0-f178.google.com [209.85.223.178])
	by kanga.kvack.org (Postfix) with ESMTP id E666D4402ED
	for <linux-mm@kvack.org>; Thu, 17 Dec 2015 14:55:11 -0500 (EST)
Received: by mail-io0-f178.google.com with SMTP id o67so66790328iof.3
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 11:55:11 -0800 (PST)
Received: from mail-ig0-x229.google.com (mail-ig0-x229.google.com. [2607:f8b0:4001:c05::229])
        by mx.google.com with ESMTPS id h10si9536748ioe.141.2015.12.17.11.55.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Dec 2015 11:55:11 -0800 (PST)
Received: by mail-ig0-x229.google.com with SMTP id m11so19945199igk.1
        for <linux-mm@kvack.org>; Thu, 17 Dec 2015 11:55:11 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20151217130223.GE18625@dhcp22.suse.cz>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
	<20151216165035.38a4d9b84600d6348a3cf4bf@linux-foundation.org>
	<20151217130223.GE18625@dhcp22.suse.cz>
Date: Thu, 17 Dec 2015 11:55:11 -0800
Message-ID: <CA+55aFxkzeqtxDY8KyR_FA+WKNkQXEHVA_zO8XhW6rqRr778Zw@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Dec 17, 2015 at 5:02 AM, Michal Hocko <mhocko@kernel.org> wrote:
> Ups. You are right. I will go with msleep_interruptible(100).

I don't think that's right.

If a signal happens, that loop is now (again) just busy-looping. That
doesn't sound right, although with the maximum limit of 10 attempts,
maybe it's fine - the thing is technically "busylooping", but it will
definitely not busy-loop for very long.

So maybe that code is fine, but I think the signal case might at least
merit a comment?

Also, if you actually do want UNINTERRUPTIBLE (no reaction to signals
at all), but don't want to be seen as being "load" on the system, you
can use TASK_IDLE, which is a combination of TASK_UNINTERRUPTIBLE |
TASK_NOLOAD.

Because if you sleep interruptibly, you do generally need to handle
signals (although that limit count may make it ok in this case).

There's basically three levels:

 - TASK_UNINTERRUPTIBLE: no signal handling at all

 - TASK_KILLABLE: no normal signal handling, but ok to be killed
(needs to check fatal_signal_pending() and exit)

 - TASK_INTERRUPTIBLE: will react to signals

(and then that TASK_IDLE thing that is semantically the same as
uninterruptible, but doesn't count against the load average).

The main use for TASK_KILLABLE is in places where expected semantics
do not allow a EINTR return, but we know that because the process is
about to be killed, we can ignore that, for the simple reason that
nobody will ever *see* the EINTR.

Btw, I think you might want to re-run your test-case after this
change, since the whole "busy loop vs actually sleeping" might just
have changed the result..

              Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
