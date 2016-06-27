Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 99F5F828E1
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 13:55:19 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id m185so16985516qke.3
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 10:55:19 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 33si12602180qts.26.2016.06.27.10.55.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 10:55:18 -0700 (PDT)
Date: Mon, 27 Jun 2016 19:55:55 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
	TIF_MEMDIE
Message-ID: <20160627175555.GA24370@redhat.com>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20160624215627.GA1148@redhat.com> <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp> <20160627092326.GD31799@dhcp22.suse.cz> <20160627103609.GE31799@dhcp22.suse.cz> <20160627155119.GA17686@redhat.com> <20160627160616.GN31799@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160627160616.GN31799@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On 06/27, Michal Hocko wrote:
>
> On Mon 27-06-16 17:51:20, Oleg Nesterov wrote:
> >
> > Yes I agree, it would be nice to remove find_lock_task_mm(). And in
> > fact it would be nice to kill task_struct->mm (but this needs a lot
> > of cleanups). We probably want signal_struct->mm, but this is a bit
> > complicated (locking).
>
> Is there any hard requirement to reset task_struct::mm in the first
> place?

Well, at least the scheduler needs this. And we need to audit every
->mm != NULL check.

> I mean I could have added oom_mm pointer into the task_struct and that
> would guarantee that we always have a valid pointer when it is needed
> but having yet another mm pointer there.

and add another mmdrop(oom_mm) into free_task() ? This would be bad, we
do not want to delay __mmdrop()... Look, we even want to make the
free_thread_info() synchronous, so that we could free ->stack before the
final put_task_struct ;)

But could you remind why do you want this right now? I mean, the ability
to find ->mm with mm_count != 0 even if the user memory was already freed?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
