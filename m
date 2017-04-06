Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 05FD66B040D
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 09:06:17 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id g7so6071201wrd.16
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 06:06:16 -0700 (PDT)
Received: from outbound-smtp03.blacknight.com (outbound-smtp03.blacknight.com. [81.17.249.16])
        by mx.google.com with ESMTPS id g16si2950858wmg.76.2017.04.06.06.06.15
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 06:06:15 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp03.blacknight.com (Postfix) with ESMTPS id E41F699344
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 13:06:14 +0000 (UTC)
Date: Thu, 6 Apr 2017 14:06:14 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: Is it safe for kthreadd to drain_all_pages?
Message-ID: <20170406130614.a6ygueggpwseqysd@techsingularity.net>
References: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Apr 05, 2017 at 01:59:49PM -0700, Hugh Dickins wrote:
> Hi Mel,
> 
> I suspect that it's not safe for kthreadd to drain_all_pages();
> but I haven't studied flush_work() etc, so don't really know what
> I'm talking about: hoping that you will jump to a realization.
> 

You're right, it's not safe. If kthreadd is creating the workqueue
thread to do the drain and it'll recurse into itself.

> 4.11-rc has been giving me hangs after hours of swapping load.  At
> first they looked like memory leaks ("fork: Cannot allocate memory");
> but for no good reason I happened to do "cat /proc/sys/vm/stat_refresh"
> before looking at /proc/meminfo one time, and the stat_refresh stuck
> in D state, waiting for completion of flush_work like many kworkers.
> kthreadd waiting for completion of flush_work in drain_all_pages().
> 

It's asking itself to do work in all likelihood.

> Patch below has been running well for 36 hours now:
> a bit too early to be sure, but I think it's time to turn to you.
> 

I think the patch is valid but like Michal, would appreciate if you
could run the patch he linked to see if it also side-steps the same
problem. 

Good spot!

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
