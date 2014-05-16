Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f174.google.com (mail-we0-f174.google.com [74.125.82.174])
	by kanga.kvack.org (Postfix) with ESMTP id BF0FF6B006E
	for <linux-mm@kvack.org>; Fri, 16 May 2014 09:52:40 -0400 (EDT)
Received: by mail-we0-f174.google.com with SMTP id k48so2650238wev.33
        for <linux-mm@kvack.org>; Fri, 16 May 2014 06:52:40 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id v6si915903wiz.20.2014.05.16.06.52.38
        for <linux-mm@kvack.org>;
        Fri, 16 May 2014 06:52:39 -0700 (PDT)
Date: Fri, 16 May 2014 15:51:37 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: [PATCH 1/1] ptrace: task_clear_jobctl_trapping()->wake_up_bit()
	needs mb()
Message-ID: <20140516135137.GB19210@redhat.com>
References: <1399974350-11089-1-git-send-email-mgorman@suse.de> <1399974350-11089-20-git-send-email-mgorman@suse.de> <20140513125313.GR23991@suse.de> <20140513141748.GD2485@laptop.programming.kicks-ass.net> <20140514161152.GA2615@redhat.com> <20140514161755.GQ30445@twins.programming.kicks-ass.net> <20140516135116.GA19210@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140516135116.GA19210@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, David Howells <dhowells@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Vlastimil Babka <vbabka@suse.cz>, Jan Kara <jack@suse.cz>, Michal Hocko <mhocko@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Paul McKenney <paulmck@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

__wake_up_bit() checks waitqueue_active() and thus the caller needs
mb() as wake_up_bit() documents, fix task_clear_jobctl_trapping().

Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 kernel/signal.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/kernel/signal.c b/kernel/signal.c
index c2a8542..f4c4119 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -277,6 +277,7 @@ void task_clear_jobctl_trapping(struct task_struct *task)
 {
 	if (unlikely(task->jobctl & JOBCTL_TRAPPING)) {
 		task->jobctl &= ~JOBCTL_TRAPPING;
+		smp_mb();	/* advised by wake_up_bit() */
 		wake_up_bit(&task->jobctl, JOBCTL_TRAPPING_BIT);
 	}
 }
-- 
1.5.5.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
