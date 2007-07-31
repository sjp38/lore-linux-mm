Date: Mon, 30 Jul 2007 17:01:38 -0700
From: Ravikiran G Thirumalai <kiran@scalex86.org>
Subject: Re: [rfc] [patch] mm: zone_reclaim fix for pseudo file systems
Message-ID: <20070731000138.GA32468@localdomain>
References: <20070727232753.GA10311@localdomain> <20070730132314.f6c8b4e1.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070730132314.f6c8b4e1.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Christoph Lameter <clameter@engr.sgi.com>, shai@scalex86.org
List-ID: <linux-mm.kvack.org>

On Mon, Jul 30, 2007 at 01:23:14PM -0700, Andrew Morton wrote:
>On Fri, 27 Jul 2007 16:27:53 -0700
>Ravikiran G Thirumalai <kiran@scalex86.org> wrote:
>
>> Don't go into zone_reclaim if there are no reclaimable pages.
>> 
>> While using RAMFS as scratch space for some tests, we found one of the
>> processes got into zone reclaim, and got stuck trying to reclaim pages
>> from a zone.
>
>Would like to see an expanded definition of "stuck", please ;)

Well, we were running a multiprocess finite element analysis HPC benchmark,
and one of the processes went into 'system' and the benchmark never completed.
Of course this happens only when we use ramfs for scratch IO.  What I mean
is, on invoking 'top', we could see that one of the process was spending
all its time in system - 100% system, for a compute benchmark which should
not be spending any time in the system at all.

>
>ie: let's see the bug report before we see the fix?
>
>>  On examination of the code, we found that the VM was fooled
>> into believing that the zone had reclaimable pages, when it actually had
>> RAMFS backed pages, which could not be written back to the disk.
>> 
>> Fix this by adding a zvc "NR_PSEUDO_FS_PAGES" for file pages with no
>> backing store, and using this counter to determine if reclaim is possible.
>> 
>> Patch tested,on 2.6.22.  Fixes the above mentioned problem.
>
>The (cheesy) way in which reclaim currently handles this sort of thing is
>to scan like mad, then to eventually set zone->all_unreclaimable.  Once
>that has been set, the kernel will reduce the amount of scanning effort it
>puts into that zone by a very large amount.  If the zone later comes back
>to life, all_unreclaimable gets cleared and things proceed as normal.

I see.  But this obviously does not work in this case.  I have noticed the
process getting into 'system' and staying there for hours.  I have never
noticed the app complete.  Perhaps because I did not wait long enough.
So do you think a more aggressive auto setting/unsetting of 'all_unreclaimable'
is a better approach?

> ...
>It is a numa-specific change which adds overhead to non-NUMA builds :(

I can (and will) place it with other NUMA specific counters, so the non-NUMA
builds will not have any overhead.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
