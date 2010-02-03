Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id BC8B46B007D
	for <linux-mm@kvack.org>; Wed,  3 Feb 2010 14:53:32 -0500 (EST)
Received: by bwz9 with SMTP id 9so367089bwz.10
        for <linux-mm@kvack.org>; Wed, 03 Feb 2010 11:53:31 -0800 (PST)
From: John Kacur <jkacur@redhat.com>
Subject: [RFC][PATCH] vmscan: Unbalanced local_irq_disable and enable
Date: Wed,  3 Feb 2010 20:53:20 +0100
Message-Id: <1265226801-6199-1-git-send-email-jkacur@redhat.com>
Sender: owner-linux-mm@kvack.org
To: lkml <linux-kernel@vger.kernel.org>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan.kim@gmail.com>, linux-mm@kvack.org, Steven@kvack.org, "Rostedt <rostedt"@goodmis.org, John Kacur <jkacur@redhat.com>
List-ID: <linux-mm.kvack.org>

I was inspecting this code as I was trying to port some -rt patches to 
2.6.33-rcX and it looks quite unusual. It is possible that it is working as
designed and there is nothing wrong with it, so I would like your comments.

Normally a call to local_irq_disable() would be balanced by a call to
local_irq_enable(). Furthermore a call to spin_lock() would be balanced by
a call to spin_unlock() and not to spin_unlock_irq()

However, the call to spin_unlock_irq() will call local_irq_enable()
so that will take care of the unbalanced local_irq_disable.
Still it seems strange.

The patch that I am providing here, is what I think the code SHOULD look like
just based on inspection, it is not at all well testing, I'm just providing
it to illustrate what at least looks wrong with the current code.

Thanks

John Kacur (1):
  vmscan: balance local_irq_disable() and local_irq_enable()

 mm/vmscan.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
