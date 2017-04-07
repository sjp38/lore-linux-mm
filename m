Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7BC906B03A7
	for <linux-mm@kvack.org>; Fri,  7 Apr 2017 12:25:44 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id r129so76532755pgr.18
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 09:25:44 -0700 (PDT)
Received: from mail-pg0-x235.google.com (mail-pg0-x235.google.com. [2607:f8b0:400e:c05::235])
        by mx.google.com with ESMTPS id v17si5577959pgi.136.2017.04.07.09.25.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 07 Apr 2017 09:25:43 -0700 (PDT)
Received: by mail-pg0-x235.google.com with SMTP id 81so71158942pgh.2
        for <linux-mm@kvack.org>; Fri, 07 Apr 2017 09:25:43 -0700 (PDT)
Date: Fri, 7 Apr 2017 09:25:33 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Is it safe for kthreadd to drain_all_pages?
In-Reply-To: <alpine.LSU.2.11.1704061134240.17094@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1704070914520.1566@eggly.anvils>
References: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils> <20170406130614.a6ygueggpwseqysd@techsingularity.net> <alpine.LSU.2.11.1704061134240.17094@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 6 Apr 2017, Hugh Dickins wrote:
> On Thu, 6 Apr 2017, Mel Gorman wrote:
> > On Wed, Apr 05, 2017 at 01:59:49PM -0700, Hugh Dickins wrote:
> > > Hi Mel,
> > > 
> > > I suspect that it's not safe for kthreadd to drain_all_pages();
> > > but I haven't studied flush_work() etc, so don't really know what
> > > I'm talking about: hoping that you will jump to a realization.
> > > 
> > 
> > You're right, it's not safe. If kthreadd is creating the workqueue
> > thread to do the drain and it'll recurse into itself.
> > 
> > > 4.11-rc has been giving me hangs after hours of swapping load.  At
> > > first they looked like memory leaks ("fork: Cannot allocate memory");
> > > but for no good reason I happened to do "cat /proc/sys/vm/stat_refresh"
> > > before looking at /proc/meminfo one time, and the stat_refresh stuck
> > > in D state, waiting for completion of flush_work like many kworkers.
> > > kthreadd waiting for completion of flush_work in drain_all_pages().
> > > 
> > 
> > It's asking itself to do work in all likelihood.
> > 
> > > Patch below has been running well for 36 hours now:
> > > a bit too early to be sure, but I think it's time to turn to you.
> > > 
> > 
> > I think the patch is valid but like Michal, would appreciate if you
> > could run the patch he linked to see if it also side-steps the same
> > problem. 
> > 
> > Good spot!
> 
> Thank you both for explanations, and direction to the two "drainging"
> patches.  I've put those on to 4.11-rc5 (and double-checked that I've
> taken mine off), and set it going.  Fine so far but much too soon to
> tell - mine did 56 hours with clean /var/log/messages before I switched,
> so I demand no less of Michal's :).  I'll report back tomorrow and the
> day after (unless badness appears sooner once I'm home).

24 hours so far, and with a clean /var/log/messages.  Not conclusive
yet, and of course I'll leave it running another couple of days, but
I'm increasingly sure that it works as you intended: I agree that

mm-move-pcp-and-lru-pcp-drainging-into-single-wq.patch
mm-move-pcp-and-lru-pcp-drainging-into-single-wq-fix.patch

should go to Linus as soon as convenient.  Though I think the commit
message needs something a bit stronger than "Quite annoying though".
Maybe add a line:

Fixes serious hang under load, observed repeatedly on 4.11-rc.

Thanks!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
