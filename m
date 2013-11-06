Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0F0E26B00B0
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 20:25:16 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id rr4so1805064pbb.11
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 17:25:16 -0800 (PST)
Received: from psmtp.com ([74.125.245.198])
        by mx.google.com with SMTP id gn4si15299106pbc.51.2013.11.05.17.25.14
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 17:25:15 -0800 (PST)
Received: by mail-ie0-f180.google.com with SMTP id e14so15822875iej.25
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 17:25:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.02.1311051715090.29471@chino.kir.corp.google.com>
References: <1383693987-14171-1-git-send-email-snanda@chromium.org>
	<alpine.DEB.2.02.1311051715090.29471@chino.kir.corp.google.com>
Date: Tue, 5 Nov 2013 17:25:13 -0800
Message-ID: <CAA25o9SFZW7JxDQGv+h43EMSS3xH0eXy=LoHO_Psmk_n3dxqoA@mail.gmail.com>
Subject: Re: [PATCH] mm, oom: Fix race when selecting process to kill
From: Luigi Semenzato <semenzato@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Sameer Nanda <snanda@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, mhocko@suse.cz, Johannes Weiner <hannes@cmpxchg.org>, rusty@rustcorp.com.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

It's not enough to hold a reference to the task struct, because it can
still be taken out of the circular list of threads.  The RCU
assumptions don't hold in that case.

On Tue, Nov 5, 2013 at 5:18 PM, David Rientjes <rientjes@google.com> wrote:
> On Tue, 5 Nov 2013, Sameer Nanda wrote:
>
>> The selection of the process to be killed happens in two spots -- first
>> in select_bad_process and then a further refinement by looking for
>> child processes in oom_kill_process. Since this is a two step process,
>> it is possible that the process selected by select_bad_process may get a
>> SIGKILL just before oom_kill_process executes. If this were to happen,
>> __unhash_process deletes this process from the thread_group list. This
>> then results in oom_kill_process getting stuck in an infinite loop when
>> traversing the thread_group list of the selected process.
>>
>> Fix this race by holding the tasklist_lock across the calls to both
>> select_bad_process and oom_kill_process.
>>
>> Change-Id: I8f96b106b3257b5c103d6497bac7f04f4dff4e60
>> Signed-off-by: Sameer Nanda <snanda@chromium.org>
>
> Nack, we had to avoid taking tasklist_lock for this duration since it
> stalls out forks and exits on other cpus trying to take the writeside with
> irqs disabled to avoid watchdog problems.
>
> What kernel version are you patching?  If you check the latest Linus tree,
> we hold a reference to the task_struct of the chosen process before
> calling oom_kill_process() so the hypothesis would seem incorrect.
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
