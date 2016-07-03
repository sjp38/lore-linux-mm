Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D29A16B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 09:24:53 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id v18so361343445qtv.0
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 06:24:53 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x63si1730397qke.12.2016.07.03.06.24.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 06:24:53 -0700 (PDT)
Date: Sun, 3 Jul 2016 15:24:48 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160703132448.GB28267@redhat.com>
References: <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627092326.GD31799@dhcp22.suse.cz>
 <20160627103609.GE31799@dhcp22.suse.cz>
 <20160627155119.GA17686@redhat.com>
 <20160627160616.GN31799@dhcp22.suse.cz>
 <20160627175555.GA24370@redhat.com>
 <20160628101956.GA510@dhcp22.suse.cz>
 <20160629201409.GB19253@redhat.com>
 <20160630080736.GD18783@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160630080736.GD18783@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On 06/30, Michal Hocko wrote:
>
> On Wed 29-06-16 22:14:09, Oleg Nesterov wrote:
> > On 06/28, Michal Hocko wrote:
> > >
> > >
> > > Could you point me to where it depends on that? I mean if we are past
> > > exit_mm then we have unmapped the address space most probably but why
> > > should we care about that in the scheduler? There shouldn't be any
> > > further access to the address space by that point. I can see that
> > > context_switch() checks task->mm but it should just work when it sees it
> > > non NULL, right?
> >
> > But who will do the final mmdrop() then? I am not saying this is impossible
> > to change, say we do this in finish_task_switch(TASK_DEAD) or even in
> > free_task(), but we do not want this?
>
> I thought it could be done somewhere in release_task after we unhash
> the process

No, we can't do this. Note that release_task() can be called right after
exit_notify() by its parent ot by the exiting thread itself. It can still
run after that and it needs ->active_mm.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
