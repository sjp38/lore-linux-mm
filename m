Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by e28esmtp04.in.ibm.com (8.13.1/8.13.1) with ESMTP id m034GBif024767
	for <linux-mm@kvack.org>; Thu, 3 Jan 2008 09:46:11 +0530
Received: from d28av05.in.ibm.com (d28av05.in.ibm.com [9.184.220.67])
	by d28relay04.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m034GBPs889026
	for <linux-mm@kvack.org>; Thu, 3 Jan 2008 09:46:11 +0530
Received: from d28av05.in.ibm.com (loopback [127.0.0.1])
	by d28av05.in.ibm.com (8.13.1/8.13.3) with ESMTP id m034GB2R020624
	for <linux-mm@kvack.org>; Thu, 3 Jan 2008 04:16:11 GMT
Date: Thu, 3 Jan 2008 09:46:06 +0530
From: Dhaval Giani <dhaval@linux.vnet.ibm.com>
Subject: Re: 2.6.22-stable causes oomkiller to be invoked
Message-ID: <20080103041606.GC26166@linux.vnet.ibm.com>
Reply-To: Dhaval Giani <dhaval@linux.vnet.ibm.com>
References: <20071217045904.GB31386@linux.vnet.ibm.com> <Pine.LNX.4.64.0712171143280.12871@schroedinger.engr.sgi.com> <20071217120720.e078194b.akpm@linux-foundation.org> <Pine.LNX.4.64.0712171222470.29500@schroedinger.engr.sgi.com> <20071221044508.GA11996@linux.vnet.ibm.com> <Pine.LNX.4.64.0712261258050.16862@schroedinger.engr.sgi.com> <20071228101109.GB5083@linux.vnet.ibm.com> <Pine.LNX.4.64.0801021237330.21526@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0801021346580.3778@schroedinger.engr.sgi.com> <20080103035942.GB26166@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080103035942.GB26166@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, htejun@gmail.com, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Balbir Singh <balbir@in.ibm.com>, maneesh@linux.vnet.ibm.com, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jan 03, 2008 at 09:29:42AM +0530, Dhaval Giani wrote:
> On Wed, Jan 02, 2008 at 01:54:12PM -0800, Christoph Lameter wrote:
> > Just traced it again on my system: It is okay for the number of pages on 
> > the quicklist to reach the high count that we see (although the 16 bit 
> > limits are weird. You have around 4GB of memory in the system?). Up to 
> > 1/16th of free memory of a node can be allocated for quicklists (this 
> > allows the effective shutting down and restarting of large amounts of 
> > processes)
> > 
> > The problem may be that this is run on a HIGHMEM system and the 
> > calculation of allowable pages on the quicklists does not take into 
> > account that highmem pages are not usable for quicklists (not sure about 
> > ZONE_MOVABLE on i386. Maybe we need to take that into account as well?)
> > 
> > Here is a patch that removes the HIGHMEM portion from the calculation. 
> > Does this change anything:
> > 
> 
> Yep. This one hits it. I don't see the obvious signs of the oom
> happening in the 5 mins I have run the script. I will let it run for
> some more time.
> 

Yes, no oom even after 20 mins of running (which is double the normal
time for the oom to occur), also no changes in free lowmem.

Thanks for the fix. Feel free to add a 

Tested-by: Dhaval Giani <dhaval@linux.vnet.ibm.com>

-- 
regards,
Dhaval

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
