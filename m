Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f178.google.com (mail-ig0-f178.google.com [209.85.213.178])
	by kanga.kvack.org (Postfix) with ESMTP id BD2316B0253
	for <linux-mm@kvack.org>; Sun, 20 Sep 2015 14:05:05 -0400 (EDT)
Received: by igcpb10 with SMTP id pb10so65515363igc.1
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 11:05:05 -0700 (PDT)
Received: from mail-io0-x22b.google.com (mail-io0-x22b.google.com. [2607:f8b0:4001:c06::22b])
        by mx.google.com with ESMTPS id i10si14615863ioo.115.2015.09.20.11.05.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Sep 2015 11:05:05 -0700 (PDT)
Received: by ioii196 with SMTP id i196so100705732ioi.3
        for <linux-mm@kvack.org>; Sun, 20 Sep 2015 11:05:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150920125642.GA2104@redhat.com>
References: <1442512783-14719-1-git-send-email-kwalker@redhat.com>
	<20150919150316.GB31952@redhat.com>
	<CA+55aFwkvbMrGseOsZNaxgP3wzDoVjkGasBKFxpn07SaokvpXA@mail.gmail.com>
	<20150920125642.GA2104@redhat.com>
Date: Sun, 20 Sep 2015 11:05:04 -0700
Message-ID: <CA+55aFyajHq2W9HhJWbLASFkTx_kLSHtHuY6mDHKxmoW-LnVEw@mail.gmail.com>
Subject: Re: can't oom-kill zap the victim's memory?
From: Linus Torvalds <torvalds@linux-foundation.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Kyle Walker <kwalker@redhat.com>, Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov@parallels.com>, linux-mm <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Stanislav Kozina <skozina@redhat.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>

On Sun, Sep 20, 2015 at 5:56 AM, Oleg Nesterov <oleg@redhat.com> wrote:
>
> In this case the workqueue thread will block.

What workqueue thread?

   pagefault_out_of_memory ->
      out_of_memory ->
         oom_kill_process

as far as I can tell, this can be called by any task. Now, that
pagefault case should only happen when the page fault comes from user
space, but we also have

   __alloc_pages_slowpath ->
      __alloc_pages_may_oom ->
         out_of_memory ->
            oom_kill_process

which can be called from just about any context (but atomic
allocations will never get here, so it can schedule etc).

So what's your point? Explain again just how do you guarantee that you
can take the mmap_sem.

                       Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
