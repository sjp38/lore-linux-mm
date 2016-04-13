Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 25979828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 09:45:23 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id n3so79238388wmn.0
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 06:45:23 -0700 (PDT)
Received: from mail-wm0-f65.google.com (mail-wm0-f65.google.com. [74.125.82.65])
        by mx.google.com with ESMTPS id bh5si39928924wjb.83.2016.04.13.06.45.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Apr 2016 06:45:21 -0700 (PDT)
Received: by mail-wm0-f65.google.com with SMTP id a140so14139697wma.2
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 06:45:21 -0700 (PDT)
Date: Wed, 13 Apr 2016 15:45:20 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] oom: consider multi-threaded tasks in task_will_free_mem
Message-ID: <20160413134520.GK14351@dhcp22.suse.cz>
References: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
 <570E27D6.9060908@I-love.SAKURA.ne.jp>
 <20160413130858.GI14351@dhcp22.suse.cz>
 <201604132227.BDI51567.VMOFOHFOLQtSFJ@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201604132227.BDI51567.VMOFOHFOLQtSFJ@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed 13-04-16 22:27:52, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > The whole thread group is going down does not mean we make sure that
> > > we will send SIGKILL to other thread groups sharing the same memory which
> > > is possibly holding mmap_sem for write, does it?
> > 
> > And the patch description doesn't say anything about processes sharing
> > mm. This is supposed to be a minor fix of an obviously suboptimal
> > behavior of task_will_free_mem. Can we stick to the proposed patch,
> > please?
> > 
> > If we really do care about processes sharing mm _that_much_ then it
> > should be handled in the separate patch.
> 
> I do care.

then feel free to post a patch. I believe such a change should be
handled in a separate patch. I have intentionally layed out the code
in a way to allow further checks easily.

Separate processes sharing the same mm have lower priority for me
because I do not know of any recent userspace which would use this
strange threading model or do you have anything specific in mind which
would make it more real-life? We will get to this eventually.

> The OOM reaper cannot work unless SIGKILL is sent to a thread
> which is holding mmap_sem for write. Thus, sending SIGKILL to all thread
> groups sharing the mm is needed by your down_write_killable(&mm->mmap_sem)
> changes. Like I wrote at
> http://lkml.kernel.org/r/201604092300.BDI39040.FFSQLJOMHOOVtF@I-love.SAKURA.ne.jp ,
> we cannot fix that problem unless you accept the slowpath.
> 
> I don't like you don't explain your approach for handling the slowpath.
> If you explain your approach for handling the slowpath and I agree on
> your approach, I will also agree on the proposed patches.

I would much appreciate if you _stopped_ conflating different things
together. This is just generating a lot of fuzz and slows the overal
progress.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
