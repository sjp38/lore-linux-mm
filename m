Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 363D06B0047
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 06:40:10 -0500 (EST)
Date: Thu, 28 Jan 2010 12:39:15 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 28 of 30] memcg huge memory
Message-ID: <20100128113915.GH24242@random.random>
References: <patchbomb.1264054824@v2.random>
 <4c405faf58cfe5d1aa6e.1264054852@v2.random>
 <20100121161601.6612fd79.kamezawa.hiroyu@jp.fujitsu.com>
 <20100121160807.GB5598@random.random>
 <20100122091317.39db5546.kamezawa.hiroyu@jp.fujitsu.com>
 <4B602304.9000709@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4B602304.9000709@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Andi Kleen <andi@firstfloor.org>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Wed, Jan 27, 2010 at 04:57:00PM +0530, Balbir Singh wrote:
> On Friday 22 January 2010 05:43 AM, KAMEZAWA Hiroyuki wrote:
> > 
> >> Now the only real pain remains in the LRU list accounting, I tried to
> >> solve it but found no clean way that didn't require mess all over
> >> vmscan.c. So for now hugepages in lru are accounted as 4k pages
> >> ;). Nothing breaks just stats won't be as useful to the admin...
> >>
> > Hmm, interesting/important problem...I keep it in my mind.
> 
> I hope the memcg accounting is not broken, I see you do the right thing
> while charging pages. The patch overall seems alright. Could you please
> update the Documentation/cgroups/memory.txt file as well with what these
> changes mean and memcg_tests.txt to indicate how to test the changes?

Where exactly does that memory.txt go into the implementation details?
Grepping the function names I changed over that file leads to
nothing. It doesn't seem to be covering internals at all. The other
file only place that shows some function names I could see needing an
update is this:

     At try_charge(), there are no flags to say "this page is
     charged".
     at this point, usage += PAGE_SIZE.

     At commit(), the function checks the page should be charged or
     not
     and set flags or avoid charging.(usage -= PAGE_SIZE)

     At cancel(), simply usage -= PAGE_SIZE.

but it won't go into much more details than this, so I can only
imagine to add this, explaining how the real page size is obtained and
if I would go into the compound page accounting explanation that
probably would bring it to a detail level that file didn't have in the
first place.

But again I'm very confused on what exactly you expect me to update on
that file, so if below isn't ok best would be that you send me a patch
to integrate with your signoff. That would be the preferred way to me.

Thanks!
Andrea

diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
--- a/Documentation/cgroups/memory.txt
+++ b/Documentation/cgroups/memory.txt
@@ -4,6 +4,10 @@ NOTE: The Memory Resource Controller has
 to as the memory controller in this document. Do not confuse memory controller
 used here with the memory controller that is used in hardware.
 
+NOTE: When in this documentation we refer to PAGE_SIZE, we actually
+mean the real page size of the page being accounted which is bigger than
+PAGE_SIZE for compound pages.
+
 Salient features
 
 a. Enable control of Anonymous, Page Cache (mapped and unmapped) and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
