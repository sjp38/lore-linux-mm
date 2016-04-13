Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id DA786828DF
	for <linux-mm@kvack.org>; Wed, 13 Apr 2016 09:28:05 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id er2so5053826pad.3
        for <linux-mm@kvack.org>; Wed, 13 Apr 2016 06:28:05 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id 71si6261059pfy.175.2016.04.13.06.28.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 13 Apr 2016 06:28:04 -0700 (PDT)
Subject: Re: [PATCH] oom: consider multi-threaded tasks in task_will_free_mem
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1460452756-15491-1-git-send-email-mhocko@kernel.org>
	<570E27D6.9060908@I-love.SAKURA.ne.jp>
	<20160413130858.GI14351@dhcp22.suse.cz>
In-Reply-To: <20160413130858.GI14351@dhcp22.suse.cz>
Message-Id: <201604132227.BDI51567.VMOFOHFOLQtSFJ@I-love.SAKURA.ne.jp>
Date: Wed, 13 Apr 2016 22:27:52 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > The whole thread group is going down does not mean we make sure that
> > we will send SIGKILL to other thread groups sharing the same memory which
> > is possibly holding mmap_sem for write, does it?
> 
> And the patch description doesn't say anything about processes sharing
> mm. This is supposed to be a minor fix of an obviously suboptimal
> behavior of task_will_free_mem. Can we stick to the proposed patch,
> please?
> 
> If we really do care about processes sharing mm _that_much_ then it
> should be handled in the separate patch.

I do care. The OOM reaper cannot work unless SIGKILL is sent to a thread
which is holding mmap_sem for write. Thus, sending SIGKILL to all thread
groups sharing the mm is needed by your down_write_killable(&mm->mmap_sem)
changes. Like I wrote at
http://lkml.kernel.org/r/201604092300.BDI39040.FFSQLJOMHOOVtF@I-love.SAKURA.ne.jp ,
we cannot fix that problem unless you accept the slowpath.

I don't like you don't explain your approach for handling the slowpath.
If you explain your approach for handling the slowpath and I agree on
your approach, I will also agree on the proposed patches.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
