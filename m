Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9830E680FD0
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 03:08:51 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u63so13565500wmu.0
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 00:08:51 -0800 (PST)
Received: from mail-wm0-x241.google.com (mail-wm0-x241.google.com. [2a00:1450:400c:c09::241])
        by mx.google.com with ESMTPS id z104si4056118wrc.238.2017.02.15.00.08.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 00:08:50 -0800 (PST)
Received: by mail-wm0-x241.google.com with SMTP id u63so6876675wmu.2
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 00:08:50 -0800 (PST)
Date: Wed, 15 Feb 2017 09:08:47 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] oom_reaper: switch to struct list_head for reap queue
Message-ID: <20170215080847.GA28090@gmail.com>
References: <20170214150714.6195-1-asarai@suse.de>
 <20170214163005.GA2450@cmpxchg.org>
 <e876e49b-8b65-d827-af7d-cbf8aef97585@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e876e49b-8b65-d827-af7d-cbf8aef97585@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Aleksa Sarai <asarai@suse.de>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, cyphar@cyphar.com


* Aleksa Sarai <asarai@suse.de> wrote:

> >>Rather than implementing an open addressing linked list structure
> >>ourselves, use the standard list_head structure to improve consistency
> >>with the rest of the kernel and reduce confusion.
> >>
> >>Cc: Michal Hocko <mhocko@suse.com>
> >>Cc: Oleg Nesterov <oleg@redhat.com>
> >>Signed-off-by: Aleksa Sarai <asarai@suse.de>
> >>---
> >> include/linux/sched.h |  6 +++++-
> >> kernel/fork.c         |  4 ++++
> >> mm/oom_kill.c         | 24 +++++++++++++-----------
> >> 3 files changed, 22 insertions(+), 12 deletions(-)
> >>
> >>diff --git a/include/linux/sched.h b/include/linux/sched.h
> >>index e93594b88130..d8bcd0f8c5fe 100644
> >>--- a/include/linux/sched.h
> >>+++ b/include/linux/sched.h
> >>@@ -1960,7 +1960,11 @@ struct task_struct {
> >> #endif
> >> 	int pagefault_disabled;
> >> #ifdef CONFIG_MMU
> >>-	struct task_struct *oom_reaper_list;
> >>+	/*
> >>+	 * List of threads that have to be reaped by OOM (rooted at
> >>+	 * &oom_reaper_list in mm/oom_kill.c).
> >>+	 */
> >>+	struct list_head oom_reaper_list;
> >
> >This is an extra pointer to task_struct and more lines of code to
> >accomplish the same thing. Why would we want to do that?
> 
> I don't think it's more "actual" lines of code (I think the wrapping is
> inflating the line number count), but switching it means that it's more in
> line with other queues in the kernel (it took me a bit to figure out what
> was going on with oom_reaper_list beforehand).

It's still an extra pointer and extra generated code to do the same thing - a clear step backwards.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
