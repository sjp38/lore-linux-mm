Date: Tue, 31 Jul 2007 16:09:43 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: make swappiness safer to use
Message-Id: <20070731160943.30e9c13a.akpm@linux-foundation.org>
In-Reply-To: <20070731215228.GU6910@v2.random>
References: <20070731215228.GU6910@v2.random>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrea Arcangeli <andrea@suse.de>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Martin Bligh <mbligh@mbligh.org>
List-ID: <linux-mm.kvack.org>

On Tue, 31 Jul 2007 23:52:28 +0200
Andrea Arcangeli <andrea@suse.de> wrote:

> I think the prev_priority can also be nuked since it wastes 4 bytes
> per zone (that would be an incremental patch but I wait the
> nr_scan_[in]active to be nuked first for similar reasons). Clearly
> somebody at some point noticed how broken that thing was and they had
> to add min(priority, prev_priority) to give it some reliability, but
> they didn't go the last mile to nuke prev_priority too. Calculating
> distress only in function of not-racy priority is correct and sure
> more than enough without having to add randomness into the equation.

I don't recall seeing any such patch and I suspect it'd cause problems
anyway.

If we were to base swap_tendency purely on sc->priority then the VM would
incorrectly fail to deactivate mapped pages until the scanning had reached
a sufficiently high (ie: low) scanning priority.

The net effect would be that each time some process runs
shrink_active_list(), some pages would be incorrectly retained on the
active list and after a while, the code wold start moving mapped pages down
to the inactive list.

In fact, I think that was (effectively) the behaviour which we had in
there, and it caused problems with some worklaod which Martin was looking
at and things got better when we fixed it.


Anyway, we can say more if we see the patch (or, more accurately, the
analysis which comes with that patch).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
