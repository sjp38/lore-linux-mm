Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 22A406B007D
	for <linux-mm@kvack.org>; Wed, 13 Nov 2013 12:28:03 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id fb1so755968pad.10
        for <linux-mm@kvack.org>; Wed, 13 Nov 2013 09:28:02 -0800 (PST)
Received: from psmtp.com ([74.125.245.131])
        by mx.google.com with SMTP id bc2si24666541pad.129.2013.11.13.09.28.01
        for <linux-mm@kvack.org>;
        Wed, 13 Nov 2013 09:28:01 -0800 (PST)
Date: Wed, 13 Nov 2013 18:29:18 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v6] mm, oom: Fix race when selecting process to kill
Message-ID: <20131113172918.GA20145@redhat.com>
References: <CANMivWaXE=bn4fhvGdz3cPwN+CZpWwrWqmU1BKX8o+vE2JawOw@mail.gmail.com> <1384363093-8025-1-git-send-email-snanda@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384363093-8025-1-git-send-email-snanda@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sameer Nanda <snanda@chromium.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, rusty@rustcorp.com.au, semenzato@google.com, murzin.v@gmail.com, dserrg@gmail.com, msb@chromium.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/13, Sameer Nanda wrote:
>
> The selection of the process to be killed happens in two spots:
> first in select_bad_process and then a further refinement by
> looking for child processes in oom_kill_process. Since this is
> a two step process, it is possible that the process selected by
> select_bad_process may get a SIGKILL just before oom_kill_process
> executes. If this were to happen, __unhash_process deletes this
> process from the thread_group list. This results in oom_kill_process
> getting stuck in an infinite loop when traversing the thread_group
> list of the selected process.
>
> Fix this race by adding a pid_alive check for the selected process
> with tasklist_lock held in oom_kill_process.

I am fine with this patch as well, but honestly I'd prefer the previous
v5. I won't argue though.

> +/*
> + * Careful: while_each_thread is not RCU safe. Callers should hold
> + * read_lock(tasklist_lock) across while_each_thread loops.
> + */

(tasklist_lock or siglock, in fact but this doesn't matter).

This is not that simple, even tasklist_lock can't help if the task is
already dead.

Oh. Yes, sorry. I promised to send the patches "soon" many times, but
still didn't find the time.

Perhaps I should try to start with the "make this all less buggy" changes,
the "complete" fix needs to change the callers as well.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
