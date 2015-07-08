Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 8646A6B0038
	for <linux-mm@kvack.org>; Wed,  8 Jul 2015 09:04:27 -0400 (EDT)
Received: by wiwl6 with SMTP id l6so344120630wiw.0
        for <linux-mm@kvack.org>; Wed, 08 Jul 2015 06:04:27 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e8si3810356wjf.156.2015.07.08.06.04.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 08 Jul 2015 06:04:25 -0700 (PDT)
From: Michal Hocko <mhocko@suse.com>
Subject: [PATCH 2/4] oom: Do not invoke oom notifiers on sysrq+f
Date: Wed,  8 Jul 2015 15:04:19 +0200
Message-Id: <1436360661-31928-3-git-send-email-mhocko@suse.com>
In-Reply-To: <1436360661-31928-1-git-send-email-mhocko@suse.com>
References: <1436360661-31928-1-git-send-email-mhocko@suse.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: David Rientjes <rientjes@google.com>, Jakob Unterwurzacher <jakobunt@gmail.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>

From: Michal Hocko <mhocko@suse.cz>

A github user rfjakob has reported the following issue via IRC.
<rfjakob> Manually triggering the OOM killer does not work anymore in 4.0.5
<rfjakob> This is what it looks like: https://gist.github.com/rfjakob/346b7dc611fc3cdf4011
<rfjakob> Basically, what happens is that the GPU driver frees some memory, that satisfies the OOM killer
<rfjakob> But the memory is allocated immediately again, and in the, no processes are killed no matter how often you trigger the oom killer
<rfjakob> "in the end"

Quoting from the github:
"
[19291.202062] sysrq: SysRq : Manual OOM execution
[19291.208335] Purging GPU memory, 74399744 bytes freed, 8728576 bytes still pinned.
[19291.390767] sysrq: SysRq : Manual OOM execution
[19291.396792] Purging GPU memory, 74452992 bytes freed, 8728576 bytes still pinned.
[19291.560349] sysrq: SysRq : Manual OOM execution
[19291.566018] Purging GPU memory, 75489280 bytes freed, 8728576 bytes still pinned.
[19291.729944] sysrq: SysRq : Manual OOM execution
[19291.735686] Purging GPU memory, 74399744 bytes freed, 8728576 bytes still pinned.
[19291.918637] sysrq: SysRq : Manual OOM execution
[19291.924299] Purging GPU memory, 74403840 bytes freed, 8728576 bytes still pinned.
"

The issue is that sysrq+f (force_kill) gets confused by the regular OOM
heuristic which tries to prevent from OOM killer if some of the oom
notifier can relase a memory. The heuristic doesn't make much sense for
the sysrq+f path because this one is used by the administrator to kill
a memory hog.

Reported-by: Jakob Unterwurzacher <jakobunt@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/oom_kill.c | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f2737d66f66a..0b1b0b25f928 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -661,10 +661,12 @@ bool out_of_memory(struct zonelist *zonelist, gfp_t gfp_mask,
 	if (oom_killer_disabled)
 		return false;
 
-	blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
-	if (freed > 0)
-		/* Got some memory back in the last second. */
-		goto out;
+	if (!force_kill) {
+		blocking_notifier_call_chain(&oom_notify_list, 0, &freed);
+		if (freed > 0)
+			/* Got some memory back in the last second. */
+			goto out;
+	}
 
 	/*
 	 * If current has a pending SIGKILL or is exiting, then automatically
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
