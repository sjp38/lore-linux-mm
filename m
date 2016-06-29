Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id D5F49828E1
	for <linux-mm@kvack.org>; Wed, 29 Jun 2016 15:34:41 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id v6so145970999vkb.2
        for <linux-mm@kvack.org>; Wed, 29 Jun 2016 12:34:41 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b102si4104569qkb.85.2016.06.29.12.34.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Jun 2016 12:34:41 -0700 (PDT)
Date: Wed, 29 Jun 2016 21:34:38 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160629193438.GA19110@redhat.com>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627092326.GD31799@dhcp22.suse.cz>
 <20160627210903.GB31239@redhat.com>
 <20160628102656.GB510@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160628102656.GB510@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On 06/28, Michal Hocko wrote:
>
> On Mon 27-06-16 23:09:04, Oleg Nesterov wrote:
> > On 06/27, Michal Hocko wrote:
> > >
> > > Yes this is really unfortunate. I am trying to converge to per mm
> > > behavior as much as possible. We are getting there slowly but not yet
> > > there.
> >
> > Yes, agreed, everything should be per-mm.
> >
> > Say wake_oom_reaper/oom_reap_task. It is simply ugly we pass task_struct
> > to oom_reap_task(), it should work with mm_struct. Again, this is because
> > of TIF_MEMDIE/exit_oom_victim.  Except pr_info(), but this is minor...
>
> I was also tempted to get back to the mm based queing but I think that
> the pr_info is quite useful.

It is, I agree. But this is solveable, I think. If nothing else, we can even
do another for_each_thread() loop and report all tasks which use this mm, or
we can pass pid/mm tuple. Lets discus this later, this is not that important.

> > As for memory reserve access, I feel that we should only set this flag
> > if task == current... but this needs more discussion.
>
> That would certainly be something to discuss. If we have other reliable
> way to detect the oom victim and when it terminates then TIF_MEMDIE on
> the current and only for memory reserves would be viable. Let's see
> whether we can keep the killed mm around and use it as an indicator.
> This would be a natural follow up cleanup.

Agreed, this looks certainly better than what we have now. Although I am
not sure I fully understand the details, but it seems that everything would
be better anyway ;)

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
