Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id ADA566B0005
	for <linux-mm@kvack.org>; Wed, 18 May 2016 17:09:34 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id gw7so85756361pac.0
        for <linux-mm@kvack.org>; Wed, 18 May 2016 14:09:34 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b66si14468876pfa.42.2016.05.18.14.09.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 May 2016 14:09:33 -0700 (PDT)
Date: Wed, 18 May 2016 14:09:32 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v3] mm,oom: speed up select_bad_process() loop.
Message-Id: <20160518140932.6643b963e8d3fc49ff64df8d@linux-foundation.org>
In-Reply-To: <20160518141545.GI21654@dhcp22.suse.cz>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160518125138.GH21654@dhcp22.suse.cz>
	<201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
	<20160518141545.GI21654@dhcp22.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

On Wed, 18 May 2016 16:15:45 +0200 Michal Hocko <mhocko@kernel.org> wrote:

> > This patch adds a counter to signal_struct for tracking how many
> > TIF_MEMDIE threads are in a given thread group, and check it at
> > oom_scan_process_thread() so that select_bad_process() can use
> > for_each_process() rather than for_each_process_thread().
> 
> OK, this looks correct. Strictly speaking the patch is missing any note
> on _why_ this is needed or an improvement. I would add something like
> the following:
> "
> Although the original code was correct it was quite inefficient because
> each thread group was scanned num_threads times which can be a lot
> especially with processes with many threads. Even though the OOM is
> extremely cold path it is always good to be as effective as possible
> when we are inside rcu_read_lock() - aka unpreemptible context.
> "

This sounds quite rubbery to me.  Lots of code calls
for_each_process_thread() and presumably that isn't causing problems. 
We're bloating up the signal_struct to solve some problem on a
rarely-called slowpath with no evidence that there is actually a
problem to be solved.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
