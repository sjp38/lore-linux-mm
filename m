Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 793C7280256
	for <linux-mm@kvack.org>; Thu,  3 Nov 2016 23:46:13 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id l66so17196735pfl.7
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 20:46:13 -0700 (PDT)
Received: from mail-pf0-x22f.google.com (mail-pf0-x22f.google.com. [2607:f8b0:400e:c00::22f])
        by mx.google.com with ESMTPS id 123si13465297pgb.296.2016.11.03.20.46.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 20:46:12 -0700 (PDT)
Received: by mail-pf0-x22f.google.com with SMTP id i88so43012373pfk.2
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 20:46:12 -0700 (PDT)
Date: Thu, 3 Nov 2016 20:46:04 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: Softlockup during memory allocation
In-Reply-To: <89ee3413-71a3-403d-48fa-af325d40f8db@suse.cz>
Message-ID: <alpine.LSU.2.11.1611032013440.5863@eggly.anvils>
References: <e3177ea6-a921-dac9-f4f3-952c14e2c4df@kyup.com> <89ee3413-71a3-403d-48fa-af325d40f8db@suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Nikolay Borisov <kernel@kyup.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux MM <linux-mm@kvack.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Wed, 2 Nov 2016, Vlastimil Babka wrote:
> On 11/01/2016 09:12 AM, Nikolay Borisov wrote:
> > In addition to that I believe there is something wrong
> > with the NR_PAGES_SCANNED stats since they are being negative. 
> > I haven't looked into the code to see how this value is being 
> > synchronized and if there is a possibility of it temporary going negative. 
> 
> This is because there's a shared counter and percpu diffs, and crash
> only looks at the shared counter.

Actually no, as I found when adding vmstat_refresh().  Coincidentally,
I spent some of last weekend trying to understand why, then wrote a
long comment about it (we thought it might be responsible for a hang).
Let me share that comment; but I was writing about an earlier release,
so some of the "zone"s have become "node"s since then - and I'm not
sure whether my comment is comprehensible to anyone but the writer!

This comment attempts to explain the NR_PAGES_SCANNED underflow.  I doubt
it's crucial to the bug in question: it's unsightly, and it may double the
margin of error involved in using per-cpu accounting, but I don't think it
makes a crucial difference to the approximation already inherent there.
If that approximation is a problem, we could consider reverting the commit
0d5d823ab4e "mm: move zone->pages_scanned into a vmstat counter" which
introduced it; or perhaps we could reconsider the stat_threshold
calculation on small zones (if that would make a difference -
I've not gone so far as to think about the hang itself).

The NR_PAGES_SCANNED underflow does not come from any race: it comes from
the way free_pcppages_bulk() and free_one_page() attempt to reset the
counter to 0 by __mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned)
with a "fuzzy" nr_scanned obtained from zone_page_state(zone,
NR_PAGES_SCANNED).

Normally __mod_zone_page_state() is used to adjust a counter by a certain
well-known amount, but here it is being used with an approximate amount -
the cheaply-visible approximate total, before correction by per-cpu diffs
(and getting that total from zone_page_state_snapshot() instead would
defeat most of the optimization of using per-cpu here, if not regress
it to worse than the global per-zone counter used before).

The problem starts on an occasion when nr_scanned there is perhaps
perfectly correct, but (factoring in the current cpu diff) is less than
the stat_threshold: __mod_zone_page_state() then updates the cpu diff and
doesn't touch the globally visible counter - but the negative diff implies
that the globally visible counter is larger than the correct value.  Then
later that too-large value is fed back into __mod_zone_pages_state() as if
it were correct, tending towards underflow of the full counter.  (Or the
same could all happen in reverse, with the "reset to 0" leaving a positive
residue in the full counter.)

This would be more serious (unbounded) without the periodic
refresh_cpu_vm_stats(): which every second folds the per-cpu diffs
back into the cheaply-visible totals.  When the diffs are 0, then
free_pcppages_bulk() and free_one_page() will properly reset the total to
0, even if the value it had before was incorrect (negative or positive).

I can eliminate the negative NR_PAGES_SCANNED reports by a one-line change
to __mod_zone_page_state(), to stop ever putting a negative into the
per-cpu diff for NR_PAGES_SCANNED; or by copying most of
__mod_zone_page_state() to a separate __reset_zone_page_state(), called
only on NR_PAGES_SCANNED, again avoiding the negative diffs.  But as I said
in the first paragraph, I doubt the underflow is worse in effect than the
approximation already inherent in the per-cpu counting here.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
