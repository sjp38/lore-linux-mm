Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id CDBFD6B0032
	for <linux-mm@kvack.org>; Thu, 26 Mar 2015 07:05:42 -0400 (EDT)
Received: by wibgn9 with SMTP id gn9so79750186wib.1
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 04:05:42 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id n6si27575470wie.48.2015.03.26.04.05.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Mar 2015 04:05:41 -0700 (PDT)
Date: Thu, 26 Mar 2015 07:05:32 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch 03/12] mm: oom_kill: switch test-and-clear of known
 TIF_MEMDIE to clear
Message-ID: <20150326110532.GB18560@cmpxchg.org>
References: <1427264236-17249-1-git-send-email-hannes@cmpxchg.org>
 <1427264236-17249-4-git-send-email-hannes@cmpxchg.org>
 <alpine.DEB.2.10.1503252025230.16714@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1503252025230.16714@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Huang Ying <ying.huang@intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Chinner <david@fromorbit.com>, Michal Hocko <mhocko@suse.cz>, Theodore Ts'o <tytso@mit.edu>

Hi David,

On Wed, Mar 25, 2015 at 08:31:49PM -0700, David Rientjes wrote:
> On Wed, 25 Mar 2015, Johannes Weiner wrote:
> 
> > exit_oom_victim() already knows that TIF_MEMDIE is set, and nobody
> > else can clear it concurrently.  Use clear_thread_flag() directly.
> > 
> > Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> 
> For the oom killer, that's true because of task_lock(): we always only set 
> TIF_MEMDIE when there is a valid p->mm and it's cleared in the exit path 
> after the unlock, acting as a barrier, when p->mm is set to NULL so it's 
> no longer a valid victim.  So that part is fine.
> 
> The problem is the android low memory killer that does 
> mark_tsk_oom_victim() without the protection of task_lock(), it's just rcu 
> protected so the reference to the task itself is guaranteed to still be 
> valid.

But this is about *setting* it without a lock.  My point was that once
TIF_MEMDIE is actually set, the task owns it and nobody else can clear
it for them, so it's safe to test and clear non-atomically from the
task's own context.  Am I missing something?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
