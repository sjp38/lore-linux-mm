Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 10D50828E1
	for <linux-mm@kvack.org>; Thu, 30 Jun 2016 04:07:40 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id g18so54729166lfg.2
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 01:07:40 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id bi9si2942766wjc.90.2016.06.30.01.07.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 30 Jun 2016 01:07:38 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id c82so20622079wme.3
        for <linux-mm@kvack.org>; Thu, 30 Jun 2016 01:07:38 -0700 (PDT)
Date: Thu, 30 Jun 2016 10:07:37 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160630080736.GD18783@dhcp22.suse.cz>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627092326.GD31799@dhcp22.suse.cz>
 <20160627103609.GE31799@dhcp22.suse.cz>
 <20160627155119.GA17686@redhat.com>
 <20160627160616.GN31799@dhcp22.suse.cz>
 <20160627175555.GA24370@redhat.com>
 <20160628101956.GA510@dhcp22.suse.cz>
 <20160629201409.GB19253@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160629201409.GB19253@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On Wed 29-06-16 22:14:09, Oleg Nesterov wrote:
> On 06/28, Michal Hocko wrote:
> >
> > On Mon 27-06-16 19:55:55, Oleg Nesterov wrote:
> > > On 06/27, Michal Hocko wrote:
> > > >
> > > > On Mon 27-06-16 17:51:20, Oleg Nesterov wrote:
> > > > >
> > > > > Yes I agree, it would be nice to remove find_lock_task_mm(). And in
> > > > > fact it would be nice to kill task_struct->mm (but this needs a lot
> > > > > of cleanups). We probably want signal_struct->mm, but this is a bit
> > > > > complicated (locking).
> > > >
> > > > Is there any hard requirement to reset task_struct::mm in the first
> > > > place?
> > >
> > > Well, at least the scheduler needs this.
> >
> > Could you point me to where it depends on that? I mean if we are past
> > exit_mm then we have unmapped the address space most probably but why
> > should we care about that in the scheduler? There shouldn't be any
> > further access to the address space by that point. I can see that
> > context_switch() checks task->mm but it should just work when it sees it
> > non NULL, right?
> 
> But who will do the final mmdrop() then? I am not saying this is impossible
> to change, say we do this in finish_task_switch(TASK_DEAD) or even in
> free_task(), but we do not want this?

I thought it could be done somewhere in release_task after we unhash
the process but then we would need something for the exlusion (possibly
task_lock) to handle races when the oom killer sees a task while it is
being unhashed. I guess it should be doable...
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
