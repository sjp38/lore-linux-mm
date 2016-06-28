Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id D4A9F6B0253
	for <linux-mm@kvack.org>; Tue, 28 Jun 2016 06:26:59 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id l184so9163992lfl.3
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 03:26:59 -0700 (PDT)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id wu4si33736149wjb.14.2016.06.28.03.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 28 Jun 2016 03:26:58 -0700 (PDT)
Received: by mail-wm0-f43.google.com with SMTP id a66so20685877wme.0
        for <linux-mm@kvack.org>; Tue, 28 Jun 2016 03:26:58 -0700 (PDT)
Date: Tue, 28 Jun 2016 12:26:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
 TIF_MEMDIE
Message-ID: <20160628102656.GB510@dhcp22.suse.cz>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <20160624215627.GA1148@redhat.com>
 <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp>
 <20160627092326.GD31799@dhcp22.suse.cz>
 <20160627210903.GB31239@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160627210903.GB31239@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On Mon 27-06-16 23:09:04, Oleg Nesterov wrote:
> On 06/27, Michal Hocko wrote:
> >
> > Yes this is really unfortunate. I am trying to converge to per mm
> > behavior as much as possible. We are getting there slowly but not yet
> > there.
> 
> Yes, agreed, everything should be per-mm.
> 
> Say wake_oom_reaper/oom_reap_task. It is simply ugly we pass task_struct
> to oom_reap_task(), it should work with mm_struct. Again, this is because
> of TIF_MEMDIE/exit_oom_victim.  Except pr_info(), but this is minor...

I was also tempted to get back to the mm based queing but I think that
the pr_info is quite useful. Both the back off and the successful
reaping can tell us more about how all the machinery works.
 
> > So the flag acts
> > both as memory reserve access key and the exclusion.
> 
> Yes, and this should be separeted imo.

I would love to.

> As for memory reserve access, I feel that we should only set this flag
> if task == current... but this needs more discussion.

That would certainly be something to discuss. If we have other reliable
way to detect the oom victim and when it terminates then TIF_MEMDIE on
the current and only for memory reserves would be viable. Let's see
whether we can keep the killed mm around and use it as an indicator.
This would be a natural follow up cleanup.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
