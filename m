Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 825826B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 17:08:29 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id z36so152998085qtb.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 14:08:29 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s22si18936946qki.249.2016.06.27.14.08.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 14:08:27 -0700 (PDT)
Date: Mon, 27 Jun 2016 23:09:04 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] mm,oom: use per signal_struct flag rather than clear
	TIF_MEMDIE
Message-ID: <20160627210903.GB31239@redhat.com>
References: <1466766121-8164-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp> <20160624215627.GA1148@redhat.com> <201606251444.EGJ69787.FtMOFJOLSHFQOV@I-love.SAKURA.ne.jp> <20160627092326.GD31799@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160627092326.GD31799@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, vdavydov@virtuozzo.com, rientjes@google.com

On 06/27, Michal Hocko wrote:
>
> Yes this is really unfortunate. I am trying to converge to per mm
> behavior as much as possible. We are getting there slowly but not yet
> there.

Yes, agreed, everything should be per-mm.

Say wake_oom_reaper/oom_reap_task. It is simply ugly we pass task_struct
to oom_reap_task(), it should work with mm_struct. Again, this is because
of TIF_MEMDIE/exit_oom_victim.  Except pr_info(), but this is minor...

> So the flag acts
> both as memory reserve access key and the exclusion.

Yes, and this should be separeted imo.

As for memory reserve access, I feel that we should only set this flag
if task == current... but this needs more discussion.

> I am not sure
> setting the flag to all threads in the same thread group would help all
> that much. Processes sharing the mm outside of the thread group should
> behave in a similar way. The general reluctance to give access to all
> threads was to prevent from thundering herd effect which is more likely
> that way.

Agreed, that is why I said it is not that simple.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
