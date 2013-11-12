Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 2AF2E6B00B4
	for <linux-mm@kvack.org>; Tue, 12 Nov 2013 15:00:46 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id kp14so7053942pab.32
        for <linux-mm@kvack.org>; Tue, 12 Nov 2013 12:00:45 -0800 (PST)
Received: from psmtp.com ([74.125.245.109])
        by mx.google.com with SMTP id o3si420856pbs.143.2013.11.12.12.00.44
        for <linux-mm@kvack.org>;
        Tue, 12 Nov 2013 12:00:44 -0800 (PST)
Date: Tue, 12 Nov 2013 21:01:56 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v4] mm, oom: Fix race when selecting process to kill
Message-ID: <20131112200156.GA9820@redhat.com>
References: <20131109151639.GB14249@redhat.com> <1384215717-2389-1-git-send-email-snanda@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1384215717-2389-1-git-send-email-snanda@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sameer Nanda <snanda@chromium.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, rientjes@google.com, hannes@cmpxchg.org, rusty@rustcorp.com.au, semenzato@google.com, murzin.v@gmail.com, dserrg@gmail.com, msb@chromium.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 11/11, Sameer Nanda wrote:
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

OK, looks correct to me. Thanks.


Yes, this is a step backwards, hopefully we will revert this patch soon.
I am starting to think something like while_each_thread_lame_but_safe()
makes sense before we really fix this nasty (and afaics not simple)
problem with with while_each_thread() (which should die).

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
