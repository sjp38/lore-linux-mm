Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id EB6656B025F
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 06:30:01 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f126so13915960wma.3
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 03:30:01 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id s133si3555454wms.104.2016.06.28.03.30.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jun 2016 03:30:00 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id a66so20801997wme.0
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 03:30:00 -0700 (PDT)
Date: Tue, 28 Jun 2016 12:29:59 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160628102959.GC510@dhcp22.suse.cz>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627204016.GA31239@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160627204016.GA31239@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On Mon 27-06-16 22:40:17, Oleg Nesterov wrote:
> On 06/25, Tetsuo Handa wrote:
> >
> > Oleg Nesterov wrote:
> > > And in any case I don't understand this patch but I have to admit that
> > > I failed to force myself to read the changelog and the actual change ;)
> > > In any case I agree that we should not set MMF_MEMDIE if ->mm == NULL,
> > > and if we ensure this then I do not understand why we can't rely on
> > > MMF_OOM_REAPED. Ignoring the obvious races, if ->oom_victims != 0 then
> > > find_lock_task_mm() should succed.
> >
> > Since we are using
> >
> >   mm = current->mm;
> >   current->mm = NULL;
> >   __mmput(mm); (may block for unbounded period waiting for somebody else's memory allocation)
> >   exit_oom_victim(current);
> >
> > sequence, we won't be able to make find_lock_task_mm(tsk) != NULL when
> > tsk->signal->oom_victims != 0 unless we change this sequence.
> 
> Ah, but this is clear, note the "Ignoring the obvious races" above.
> Can't we fix this race? I am a bit lost, but iirc we want this anyway
> to ensure that we do not set TIF_MEMDIE if ->mm == NULL ?

This is not about a race it is about not reaching exit_oom_victim and
unblock the oom killer from selecting another victim.

> Hmm. Although I am not sure I really understand the "may block for
> unbounded period ..." above. Do you mean khugepaged_exit?

__mmput->exit_aio can wait for IO to complete and who knows what that
might depend on. Who knows how many others are lurking there.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
