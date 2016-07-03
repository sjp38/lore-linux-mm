Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D06206B0005
	for <linux-mm@kvack.org>; Sun,  3 Jul 2016 09:32:54 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id f89so364907353qtd.1
        for <linux-mm@kvack.org>; Sun, 03 Jul 2016 06:32:54 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id d198si1737722qka.153.2016.07.03.06.32.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Jul 2016 06:32:54 -0700 (PDT)
Date: Sun, 3 Jul 2016 15:32:49 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160703133249.GA28436@redhat.com>
References: <20160628101956.GA510@dhcp22.suse.cz>
 <20160629001353.GA9377@redhat.com>
 <20160629083314.GA27153@dhcp22.suse.cz>
 <20160629200108.GA19253@redhat.com>
 <20160630075904.GC18783@dhcp22.suse.cz>
 <201606301951.AAB26052.OtOOQMLHVFJSFF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606301951.AAB26052.OtOOQMLHVFJSFF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: mhocko@kernel.org, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On 06/30, Tetsuo Handa wrote:
>
> Michal Hocko wrote:
> > On Wed 29-06-16 22:01:08, Oleg Nesterov wrote:
>
> > > Btw, do we still need this list_for_each_entry(child, &t->children, sibling)
> > > loop in oom_kill_process() ?
> >
> > Well, to be honest, I don't know. This is a heuristic we have been doing
> > for a long time. I do not know how many times it really matters. It can
> > even be harmful in loads where children are created in the same pace OOM
> > killer is killing them. Not sure how likely is that though...
> > Let me think whether we can do something about that.
>
> I'm using that behavior in order to test almost OOM situation. ;)

Can you explain why do we want this behaviour?

Except, again, sysctl_oom_kill_allocating_task, see my reply to Michal.

> By the way, are you going to fix use_mm() race? Currently, we don't wake up
> OOM reaper if some kernel thread is holding a reference to that mm via
> use_mm(). But currently we can hit

Yes, and I already mention this race, and this is why I think we should not
skip kthreads.

> race. I think we need to make use_mm() fail after mark_oom_victim() is called.

Perhaps this makes sense anyway later, but I still think we do not really
care. I'll write another email...

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
