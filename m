Message-ID: <46AFC676.4030907@mbligh.org>
Date: Tue, 31 Jul 2007 16:32:06 -0700
From: Martin Bligh <mbligh@mbligh.org>
MIME-Version: 1.0
Subject: Re: make swappiness safer to use
References: <20070731215228.GU6910@v2.random> <20070731160943.30e9c13a.akpm@linux-foundation.org>
In-Reply-To: <20070731160943.30e9c13a.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Arcangeli <andrea@suse.de>, linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> On Tue, 31 Jul 2007 23:52:28 +0200
> Andrea Arcangeli <andrea@suse.de> wrote:
> 
>> I think the prev_priority can also be nuked since it wastes 4 bytes
>> per zone (that would be an incremental patch but I wait the
>> nr_scan_[in]active to be nuked first for similar reasons). Clearly
>> somebody at some point noticed how broken that thing was and they had
>> to add min(priority, prev_priority) to give it some reliability, but

Yeah, that was me.

>> they didn't go the last mile to nuke prev_priority too. Calculating
>> distress only in function of not-racy priority is correct and sure
>> more than enough without having to add randomness into the equation.
> 
> I don't recall seeing any such patch and I suspect it'd cause problems
> anyway.
> 
> If we were to base swap_tendency purely on sc->priority then the VM would
> incorrectly fail to deactivate mapped pages until the scanning had reached
> a sufficiently high (ie: low) scanning priority.
> 
> The net effect would be that each time some process runs
> shrink_active_list(), some pages would be incorrectly retained on the
> active list and after a while, the code wold start moving mapped pages down
> to the inactive list.
> 
> In fact, I think that was (effectively) the behaviour which we had in
> there, and it caused problems with some worklaod which Martin was looking
> at and things got better when we fixed it.

I think I described it reasonably in the changelog ... if not, IIRC the
issue was that one task was doing an "easy" reclaim (e.g they could
do wait, writeback etc) and one was doing a "hard" reclaim (eg no
writeback) and the one having an easy time would set prio back to
def_priority. So having a local variable made way more sense to me.

It's a race condition that's bloody hard to recreate, and very hard to
prove anything on. I did publish exact traces of what happened at the
time if anyone wants to go back and look.

> Anyway, we can say more if we see the patch (or, more accurately, the
> analysis which comes with that patch).

I must say, I don't see what's wrong with killing it and having it
local. We're rotating the list all the time, IIRC ... so if we start
off with only 1/2^12th of the list ... does it matter? we'll just
crank it up higher fairly quickly. Not sure why we want to start
with the same chunk size we did last time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
