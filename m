Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 8625E6B02B4
	for <linux-mm@kvack.org>; Tue, 30 May 2017 00:29:50 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a66so81983476pfl.6
        for <linux-mm@kvack.org>; Mon, 29 May 2017 21:29:50 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id z70sor2700781pgd.190.2017.05.29.21.29.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 29 May 2017 21:29:49 -0700 (PDT)
Date: Mon, 29 May 2017 21:29:48 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: Re: [PATCH v2] mm/oom_kill: count global and memory cgroup oom
 kills
In-Reply-To: <149570810989.203600.9492483715840752937.stgit@buzz>
Message-ID: <alpine.DEB.2.10.1705292129170.9353@chino.kir.corp.google.com>
References: <149570810989.203600.9492483715840752937.stgit@buzz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Michal Hocko <mhocko@kernel.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrew Morton <akpm@linux-foundation.org>, Roman Guschin <guroan@gmail.com>

On Thu, 25 May 2017, Konstantin Khlebnikov wrote:

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 04c9143a8625..dd30a045ef5b 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -876,6 +876,11 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
>  	/* Get a reference to safely compare mm after task_unlock(victim) */
>  	mm = victim->mm;
>  	mmgrab(mm);
> +
> +	/* Raise event before sending signal: reaper must see this */

How is the oom reaper involved here?

> +	count_vm_event(OOM_KILL);
> +	mem_cgroup_count_vm_event(mm, OOM_KILL);
> +
>  	/*
>  	 * We should send SIGKILL before setting TIF_MEMDIE in order to prevent
>  	 * the OOM victim from depleting the memory reserves from the user

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
