Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7387A6B03FE
	for <linux-mm@kvack.org>; Thu,  6 Apr 2017 04:55:36 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id a80so2622457wrc.19
        for <linux-mm@kvack.org>; Thu, 06 Apr 2017 01:55:36 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 136si28185583wmw.28.2017.04.06.01.55.34
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 06 Apr 2017 01:55:35 -0700 (PDT)
Date: Thu, 6 Apr 2017 10:55:30 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Is it safe for kthreadd to drain_all_pages?
Message-ID: <20170406085529.GF5497@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1704051331420.4288@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed 05-04-17 13:59:49, Hugh Dickins wrote:
> Hi Mel,
> 
> I suspect that it's not safe for kthreadd to drain_all_pages();
> but I haven't studied flush_work() etc, so don't really know what
> I'm talking about: hoping that you will jump to a realization.
> 
> 4.11-rc has been giving me hangs after hours of swapping load.  At
> first they looked like memory leaks ("fork: Cannot allocate memory");
> but for no good reason I happened to do "cat /proc/sys/vm/stat_refresh"
> before looking at /proc/meminfo one time, and the stat_refresh stuck
> in D state, waiting for completion of flush_work like many kworkers.
> kthreadd waiting for completion of flush_work in drain_all_pages().
> 
> But I only noticed that pattern later: originally tried to bisect
> rc1 before rc2 came out, but underestimated how long to wait before
> deciding a stage good - I thought 12 hours, but would now say 2 days.
> Too late for bisection, I suspect your drain_all_pages() changes.

Yes, this is a fallout from Mel's changes. I was about to say that
my follow up fixes which made this flushing to the single WQ with rescuer
fixed that but it seems that
http://www.ozlabs.org/~akpm/mmotm/broken-out/mm-move-pcp-and-lru-pcp-drainging-into-single-wq.patch
didn't make it to the Linus tree. Could you re-test with this one?
While your change is obviously correct I think the above should address
it as well and it is more generic. If it works then I will ask Andrew to
send the above to Linus (along with its follow up
mm-move-pcp-and-lru-pcp-drainging-into-single-wq-fix.patch)
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
