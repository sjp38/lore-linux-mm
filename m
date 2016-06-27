Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id D85406B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 16:39:41 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id e187so46570023vkb.0
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 13:39:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z189si18889590qke.10.2016.06.27.13.39.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 13:39:40 -0700 (PDT)
Date: Mon, 27 Jun 2016 22:40:17 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
	TIF_MEMDIE
Message-ID: <20160627204016.GA31239@redhat.com>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20160624215627.GA1148@redhat.com> <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, linux-mm@kvack.org, mhocko@suse.com, vdavydov@virtuozzo.com, rientjes@google.com

On 06/25, Tetsuo Handa wrote:
>
> Oleg Nesterov wrote:
> > And in any case I don't understand this patch but I have to admit that
> > I failed to force myself to read the changelog and the actual change ;)
> > In any case I agree that we should not set MMF_MEMDIE if ->mm == NULL,
> > and if we ensure this then I do not understand why we can't rely on
> > MMF_OOM_REAPED. Ignoring the obvious races, if ->oom_victims != 0 then
> > find_lock_task_mm() should succed.
>
> Since we are using
>
>   mm = current->mm;
>   current->mm = NULL;
>   __mmput(mm); (may block for unbounded period waiting for somebody else's memory allocation)
>   exit_oom_victim(current);
>
> sequence, we won't be able to make find_lock_task_mm(tsk) != NULL when
> tsk->signal->oom_victims != 0 unless we change this sequence.

Ah, but this is clear, note the "Ignoring the obvious races" above.
Can't we fix this race? I am a bit lost, but iirc we want this anyway
to ensure that we do not set TIF_MEMDIE if ->mm == NULL ?

Hmm. Although I am not sure I really understand the "may block for
unbounded period ..." above. Do you mean khugepaged_exit?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
