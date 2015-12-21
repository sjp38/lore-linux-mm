Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f50.google.com (mail-wm0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id DFAD66B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 15:38:52 -0500 (EST)
Received: by mail-wm0-f50.google.com with SMTP id l126so84814334wml.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 12:38:52 -0800 (PST)
Received: from mail-wm0-x22b.google.com (mail-wm0-x22b.google.com. [2a00:1450:400c:c09::22b])
        by mx.google.com with ESMTPS id f187si38252869wmd.4.2015.12.21.12.38.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 12:38:51 -0800 (PST)
Received: by mail-wm0-x22b.google.com with SMTP id p187so83286188wmp.0
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 12:38:51 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
References: <1450204575-13052-1-git-send-email-mhocko@kernel.org>
From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 21 Dec 2015 15:38:21 -0500
Message-ID: <CAP=VYLoGcqXvX8ORTmLH9u5s3p2u5f7qqBy14-U4gUdRTF6C5g@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm, oom: introduce oom reaper
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, David Rientjes <rientjes@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Hugh Dickins <hughd@google.com>, Andrea Argangeli <andrea@kernel.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Dec 15, 2015 at 1:36 PM, Michal Hocko <mhocko@kernel.org> wrote:
> From: Michal Hocko <mhocko@suse.com>
>
> This is based on the idea from Mel Gorman discussed during LSFMM 2015 and
> independently brought up by Oleg Nesterov.
>

[...]

Since this is built-in always, can we....

> diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> index 5314b206caa5..48025a21f8c4 100644
> --- a/mm/oom_kill.c
> +++ b/mm/oom_kill.c
> @@ -35,6 +35,11 @@
>  #include <linux/freezer.h>
>  #include <linux/ftrace.h>
>  #include <linux/ratelimit.h>
> +#include <linux/kthread.h>
> +#include <linux/module.h>

...use <linux/init.h> instead above, and then...

> +
> +#include <asm/tlb.h>
> +#include "internal.h"
>

[...]

> +                * Make sure our oom reaper thread will get scheduled when
> +                * ASAP and that it won't get preempted by malicious userspace.
> +                */
> +               sched_setscheduler(oom_reaper_th, SCHED_FIFO, &param);
> +       }
> +       return 0;
> +}
> +module_init(oom_init)

...use one of the non-modular initcalls here?   I'm trying to clean up most of
the non-modular uses of modular macros etc. since:

 (1) it is easy to accidentally code up an unused module_exit function
 (2) it can be misleading when reading the source, thinking it can be
      modular when the Makefile and/or Kconfig prohibit it
 (3) it requires the include of the module.h header file which in turn
     includes nearly everything else, thus increasing CPP overhead.

I figured no point in sending a follow on patch since this came in via
the akpm tree into next and that gets rebased/updated regularly.

Thanks,
Paul.
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
