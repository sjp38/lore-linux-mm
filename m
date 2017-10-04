Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4A29B6B0253
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 16:50:02 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id g18so10709890itg.1
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 13:50:02 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id j140si13090802ioj.384.2017.10.04.13.50.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 04 Oct 2017 13:50:01 -0700 (PDT)
Subject: Re: [PATCH 1/2] Revert "vmalloc: back off when the current task is
 killed"
References: <20171003225504.GA966@cmpxchg.org>
 <20171004185813.GA2136@cmpxchg.org> <20171004185906.GB2136@cmpxchg.org>
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Message-ID: <ab688e7c-75c1-e942-ef44-44615d9fb394@I-love.SAKURA.ne.jp>
Date: Thu, 5 Oct 2017 05:49:43 +0900
MIME-Version: 1.0
In-Reply-To: <20171004185906.GB2136@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On 2017/10/05 3:59, Johannes Weiner wrote:
> But the justification to make that vmalloc() call fail like this isn't
> convincing, either. The patch mentions an OOM victim exhausting the
> memory reserves and thus deadlocking the machine. But the OOM killer
> is only one, improbable source of fatal signals. It doesn't make sense
> to fail allocations preemptively with plenty of memory in most cases.

By the time the current thread reaches do_exit(), fatal_signal_pending(current)
should become false. As far as I can guess, the source of fatal signal will be
tty_signal_session_leader(tty, exit_session) which is called just before
tty_ldisc_hangup(tty, cons_filp != NULL) rather than the OOM killer. I don't
know whether it is possible to make fatal_signal_pending(current) true inside
do_exit() though...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
