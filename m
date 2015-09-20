Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 4ACC66B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 15:07:38 -0400 (EDT)
Received: by pacfv12 with SMTP id fv12so97906704pac.2
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 12:07:38 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id et1si31963305pbb.49.2015.09.20.12.07.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 12:07:37 -0700 (PDT)
Received: by padhy16 with SMTP id hy16so95965768pad.1
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 12:07:37 -0700 (PDT)
Subject: Re: can't oom-kill zap the victim's memory?
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
 <20150919150316.GB31952@redhat.com>
 <CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
 <20150920125642.GA2104@redhat.com>
 <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
From: Raymond Jennings <shentino@gmail.com>
Message-ID: <55FF03F4.6000904@gmail.com>
Date: Sun, 20 Sep 2015 12:07:32 -0700
MIME-Version: 1.0
In-Reply-To: <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>
Cc: Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On 09/20/15 11:05, Linus Torvalds wrote:
> On Sun, Sep 20, 2015 at 5:56 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>> In this case the workqueue thread will block.
> What workqueue thread?
>
>     pagefault_out_of_memory ->
>        out_of_memory ->
>           oom_kill_process
>
> as far as I can tell, this can be called by any task. Now, that
> pagefault case should only happen when the page fault comes from user
> space, but we also have
>
>     __alloc_pages_slowpath ->
>        __alloc_pages_may_oom ->
>           out_of_memory ->
>              oom_kill_process
>
> which can be called from just about any context (but atomic
> allocations will never get here, so it can schedule etc).

I think in this case the oom killer should just slap a SIGKILL on the 
task and then back out, and whatever needed the memory should just wait 
patiently for the sacrificial lamb to commit seppuku.

Which, btw, we should IMO encourage ASAP in the context of the lamb by 
having anything potentially locky or semaphory pay attention to if the 
task in question has a fatal signal pending, and if so, drop everything 
and run like hell so that the task can cough up any locks or semaphores.
> So what's your point? Explain again just how do you guarantee that you
> can take the mmap_sem.
>
>                         Linus
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

Also, I observed that a task in the middle of dumping core doesn't 
respond to signals while it's dumping, and I would guess that might be 
the case even if the task receives a SIGKILL from the OOM handler.  Just 
a potential observation.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
