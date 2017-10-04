Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 332846B0253
	for <linux-mm@kvack.org>; Wed,  4 Oct 2017 17:00:37 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id g10so9404436wrg.2
        for <linux-mm@kvack.org>; Wed, 04 Oct 2017 14:00:37 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o92si5463979eda.547.2017.10.04.14.00.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 04 Oct 2017 14:00:34 -0700 (PDT)
Date: Wed, 4 Oct 2017 17:00:27 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 1/2] Revert "vmalloc: back off when the current task is
 killed"
Message-ID: <20171004210027.GA2973@cmpxchg.org>
References: <20171003225504.GA966@cmpxchg.org>
 <20171004185813.GA2136@cmpxchg.org>
 <20171004185906.GB2136@cmpxchg.org>
 <ab688e7c-75c1-e942-ef44-44615d9fb394@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ab688e7c-75c1-e942-ef44-44615d9fb394@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Andrew Morton <akpm@linux-foundation.org>, Alan Cox <alan@llwyncelyn.cymru>, Christoph Hellwig <hch@lst.de>, Michal Hocko <mhocko@suse.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Oct 05, 2017 at 05:49:43AM +0900, Tetsuo Handa wrote:
> On 2017/10/05 3:59, Johannes Weiner wrote:
> > But the justification to make that vmalloc() call fail like this isn't
> > convincing, either. The patch mentions an OOM victim exhausting the
> > memory reserves and thus deadlocking the machine. But the OOM killer
> > is only one, improbable source of fatal signals. It doesn't make sense
> > to fail allocations preemptively with plenty of memory in most cases.
> 
> By the time the current thread reaches do_exit(), fatal_signal_pending(current)
> should become false. As far as I can guess, the source of fatal signal will be
> tty_signal_session_leader(tty, exit_session) which is called just before
> tty_ldisc_hangup(tty, cons_filp != NULL) rather than the OOM killer. I don't
> know whether it is possible to make fatal_signal_pending(current) true inside
> do_exit() though...

It's definitely not the OOM killer, the memory situation looks fine
when this happens. I didn't look closer where the signal comes from.

That said, we trigger this issue fairly easily. We tested the revert
over night on a couple thousand machines, and it fixed the issue
(whereas the control group still saw the crashes).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
