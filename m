Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id A68276B00AE
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 20:18:50 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so9788949pab.33
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 17:18:50 -0800 (PST)
Received: from psmtp.com ([74.125.245.138])
        by mx.google.com with SMTP id yl8si4172981pab.118.2013.11.05.17.18.48
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 17:18:49 -0800 (PST)
Received: by mail-pa0-f45.google.com with SMTP id kp14so9755067pab.18
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 17:18:47 -0800 (PST)
Date: Tue, 5 Nov 2013 17:18:45 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH] mm, oom: Fix race when selecting process to kill
In-Reply-To: <1383693987-14171-1-git-send-email-snanda@chromium.org>
Message-ID: <alpine.DEB.2.02.1311051715090.29471@chino.kir.corp.google.com>
References: <1383693987-14171-1-git-send-email-snanda@chromium.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sameer Nanda <snanda@chromium.org>
Cc: akpm@linux-foundation.org, mhocko@suse.cz, hannes@cmpxchg.org, rusty@rustcorp.com.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, 5 Nov 2013, Sameer Nanda wrote:

> The selection of the process to be killed happens in two spots -- first
> in select_bad_process and then a further refinement by looking for
> child processes in oom_kill_process. Since this is a two step process,
> it is possible that the process selected by select_bad_process may get a
> SIGKILL just before oom_kill_process executes. If this were to happen,
> __unhash_process deletes this process from the thread_group list. This
> then results in oom_kill_process getting stuck in an infinite loop when
> traversing the thread_group list of the selected process.
> 
> Fix this race by holding the tasklist_lock across the calls to both
> select_bad_process and oom_kill_process.
> 
> Change-Id: I8f96b106b3257b5c103d6497bac7f04f4dff4e60
> Signed-off-by: Sameer Nanda <snanda@chromium.org>

Nack, we had to avoid taking tasklist_lock for this duration since it 
stalls out forks and exits on other cpus trying to take the writeside with 
irqs disabled to avoid watchdog problems.

What kernel version are you patching?  If you check the latest Linus tree, 
we hold a reference to the task_struct of the chosen process before 
calling oom_kill_process() so the hypothesis would seem incorrect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
