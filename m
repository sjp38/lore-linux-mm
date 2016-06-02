Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA9076B0253
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 08:56:00 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id w16so23809409lfd.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 05:56:00 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id n124si1264818wma.8.2016.06.02.05.55.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 02 Jun 2016 05:55:59 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id a136so15664891wme.0
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 05:55:59 -0700 (PDT)
Date: Thu, 2 Jun 2016 14:55:57 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 4/6] mm, oom: skip vforked tasks from being selected
Message-ID: <20160602125556.GO1995@dhcp22.suse.cz>
References: <1464613556-16708-5-git-send-email-mhocko@kernel.org>
 <201606012312.BIF26006.MLtFVQSJOHOFOF@I-love.SAKURA.ne.jp>
 <20160601142502.GY26601@dhcp22.suse.cz>
 <201606021945.AFH26572.OJMVLFOHFFtOSQ@I-love.SAKURA.ne.jp>
 <20160602112057.GI1995@dhcp22.suse.cz>
 <201606022031.BIB56744.OFSFQOOtLJMFVH@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606022031.BIB56744.OFSFQOOtLJMFVH@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

On Thu 02-06-16 20:31:57, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > OK, but the memory is allocated on behalf of the parent already, right?
> 
> What does "the memory is allocated on behalf of the parent already" mean?

It means that vforked task cannot allocate a new memory directly. Sure
it can get a copy of what parent already has allocated during execve but
that is under control of the parent. If the parent is OOM_SCORE_ADJ_MIN
then it should better be careful how it spawns new tasks.

> The memory used for argv[]/envp[] may not yet be visible from mm_struct when
> the OOM killer is invoked.
>
> > And the patch doesn't prevent parent from being selected and the vfroked
> > child being killed along the way as sharing the mm with it. So what
> > exactly this patch changes for this test case? What am I missing?
> 
> If the parent is OOM_SCORE_ADJ_MIN and vfork()ed child doing execve()
> with large argv[]/envp[] is not OOM_SCORE_ADJ_MIN, we should not hesitate
> to OOM-kill vfork()ed child even if the parent is not OOM-killable.
> 
> 	vfork()
> 	set_oom_adj()
> 	exec()

Well the whole point of this patch is to not select such a task because
it makes only very limitted sense. It cannot really free much memory -
well except when parent is doing something realy stupid which I am not
really sure we should care about.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
