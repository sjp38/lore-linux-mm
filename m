Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 82DFF6B007E
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 07:32:06 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id d10so14111992oby.1
        for <linux-mm@kvack.org>; Thu, 02 Jun 2016 04:32:06 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id s20si31800ots.224.2016.06.02.04.32.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 02 Jun 2016 04:32:05 -0700 (PDT)
Subject: Re: [PATCH 4/6] mm, oom: skip vforked tasks from being selected
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464613556-16708-5-git-send-email-mhocko@kernel.org>
	<201606012312.BIF26006.MLtFVQSJOHOFOF@I-love.SAKURA.ne.jp>
	<20160601142502.GY26601@dhcp22.suse.cz>
	<201606021945.AFH26572.OJMVLFOHFFtOSQ@I-love.SAKURA.ne.jp>
	<20160602112057.GI1995@dhcp22.suse.cz>
In-Reply-To: <20160602112057.GI1995@dhcp22.suse.cz>
Message-Id: <201606022031.BIB56744.OFSFQOOtLJMFVH@I-love.SAKURA.ne.jp>
Date: Thu, 2 Jun 2016 20:31:57 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org

Michal Hocko wrote:
> OK, but the memory is allocated on behalf of the parent already, right?

What does "the memory is allocated on behalf of the parent already" mean?
The memory used for argv[]/envp[] may not yet be visible from mm_struct when
the OOM killer is invoked.

> And the patch doesn't prevent parent from being selected and the vfroked
> child being killed along the way as sharing the mm with it. So what
> exactly this patch changes for this test case? What am I missing?

If the parent is OOM_SCORE_ADJ_MIN and vfork()ed child doing execve()
with large argv[]/envp[] is not OOM_SCORE_ADJ_MIN, we should not hesitate
to OOM-kill vfork()ed child even if the parent is not OOM-killable.

	vfork()
	set_oom_adj()
	exec()

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
