Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f52.google.com (mail-wm0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 0C33F6B0256
	for <linux-mm@kvack.org>; Tue, 24 Nov 2015 04:47:12 -0500 (EST)
Received: by wmuu63 with SMTP id u63so88304827wmu.0
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:47:11 -0800 (PST)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id v124si25449748wme.117.2015.11.24.01.47.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 24 Nov 2015 01:47:10 -0800 (PST)
Received: by wmec201 with SMTP id c201so18240428wme.1
        for <linux-mm@kvack.org>; Tue, 24 Nov 2015 01:47:10 -0800 (PST)
Date: Tue, 24 Nov 2015 10:47:09 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, oom: Give __GFP_NOFAIL allocations access to memory
 reserves
Message-ID: <20151124094708.GA29472@dhcp22.suse.cz>
References: <1447249697-13380-1-git-send-email-mhocko@kernel.org>
 <5651BB43.8030102@suse.cz>
 <20151123092925.GB21050@dhcp22.suse.cz>
 <5652DFCE.3010201@suse.cz>
 <20151123101345.GF21050@dhcp22.suse.cz>
 <alpine.DEB.2.10.1511231320160.30886@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.10.1511231320160.30886@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon 23-11-15 13:26:49, David Rientjes wrote:
> On Mon, 23 Nov 2015, Michal Hocko wrote:
[...]
> > I am not sure I follow you here. The point of the warning is to warn
> > when the oom killer is disbaled (out_of_memory returns false) _and_ the
> > request is __GFP_NOFAIL because we simply cannot guarantee any forward
> > progress and just a use of the allocation flag is not supproted.
> > 
> 
> I don't think the WARN_ONCE() above is helpful for a few reasons:
> 
>  - it suggests that min_free_kbytes is the best way to work around such 
>    issues and gives kernel developers a free pass to just say "raise
>    min_free_kbytes" rather than reducing their reliance on __GFP_NOFAIL,

I disagree. Users are quite sensitive to warnings with backtraces in the
log from my experience and they report them. And while the log shows the
code path which triggers the issue which can help us to change the code
it also gives a useful hint on how to reduce this issue until we are
able to either fix a bug or a permanent configuration if we are not able
to get rid of it for whatever reason.

Besides that there is no other reliable warning that we are getting
_really_ short on memory unlike when the allocation failure is
allowed. OOM killer report might be missing because there was no actual
killing happening.
 
>  - raising min_free_kbytes is not immediately actionable without memory
>    freeing to fix any oom issue, and

true but it can be done to reduce chances for the issue to reappear.

>  - it relies on the earlier warning to dump the state of memory and 
>    doesn't add any significant information to help understand how seperate
>    occurrences are similar or different.

The information is quite valuable even without OOM killer report IMHO.
 
> I think the WARN_ONCE() should just be removed.

I do not insist on keeping it but I really think it might be useful
while it doesn't seem to cause any confusion IMHO. So unless there is a
strong reason to not include it I would prefer keeping it.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
