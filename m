Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E1CB6B0038
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 14:52:47 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id c130so20577353ioe.19
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 11:52:47 -0700 (PDT)
Received: from mail-it0-x231.google.com (mail-it0-x231.google.com. [2607:f8b0:4001:c0b::231])
        by mx.google.com with ESMTPS id 23si2695807iou.225.2017.04.06.11.52.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 06 Apr 2017 11:52:46 -0700 (PDT)
Received: by mail-it0-x231.google.com with SMTP id 19so10908519itj.1
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 11:52:46 -0700 (PDT)
Date: Thu, 6 Apr 2017 11:52:43 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Is it safe for kthreadd to drain_all_pages?
In-Reply-To: <20170406130614.a6ygueggpwseqysd@techsingularity.net>
Message-ID: <alpine.LSU.2.11.1704061134240.17094@eggly.anvils>
References: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils> <20170406130614.a6ygueggpwseqysd@techsingularity.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 6 Apr 2017, Mel Gorman wrote:
> On Wed, Apr 05, 2017 at 01:59:49PM -0700, Hugh Dickins wrote:
> > Hi Mel,
> > 
> > I suspect that it's not safe for kthreadd to drain_all_pages();
> > but I haven't studied flush_work() etc, so don't really know what
> > I'm talking about: hoping that you will jump to a realization.
> > 
> 
> You're right, it's not safe. If kthreadd is creating the workqueue
> thread to do the drain and it'll recurse into itself.
> 
> > 4.11-rc has been giving me hangs after hours of swapping load.  At
> > first they looked like memory leaks ("fork: Cannot allocate memory");
> > but for no good reason I happened to do "cat /proc/sys/vm/stat_refresh"
> > before looking at /proc/meminfo one time, and the stat_refresh stuck
> > in D state, waiting for completion of flush_work like many kworkers.
> > kthreadd waiting for completion of flush_work in drain_all_pages().
> > 
> 
> It's asking itself to do work in all likelihood.
> 
> > Patch below has been running well for 36 hours now:
> > a bit too early to be sure, but I think it's time to turn to you.
> > 
> 
> I think the patch is valid but like Michal, would appreciate if you
> could run the patch he linked to see if it also side-steps the same
> problem. 
> 
> Good spot!

Thank you both for explanations, and direction to the two "drainging"
patches.  I've put those on to 4.11-rc5 (and double-checked that I've
taken mine off), and set it going.  Fine so far but much too soon to
tell - mine did 56 hours with clean /var/log/messages before I switched,
so I demand no less of Michal's :).  I'll report back tomorrow and the
day after (unless badness appears sooner once I'm home).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
