Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id BFBD86B0078
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 14:37:59 -0400 (EDT)
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o8OIMrHa028688
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 14:22:53 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o8OIbq1a328886
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 14:37:52 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o8OIbpZq018435
	for <linux-mm@kvack.org>; Fri, 24 Sep 2010 14:37:51 -0400
Subject: Re: Linux swapping with MySQL/InnoDB due to NUMA architecture
 imbalanced allocations?
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <AANLkTim1R7-FVwofw-otpGCcHqQHLDwaTYYWFS1ZhSoW@mail.gmail.com>
References: <AANLkTim1R7-FVwofw-otpGCcHqQHLDwaTYYWFS1ZhSoW@mail.gmail.com>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Fri, 24 Sep 2010 11:37:49 -0700
Message-ID: <1285353469.3292.14042.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jeremy Cole <jeremy@jcole.us>
Cc: Linux Memory Management <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-09-23 at 15:29 -0700, Jeremy Cole wrote:
> 1. Is it plausible that Linux for whatever reason needs memory to be
> in Node 0, and chooses to page out used memory to make room, rather
> than choosing to drop some of the cache in Node 1 and use that memory?
>  I think this is true, but maybe I've missed something important.

Your situation sounds pretty familiar.  It happens a lot when
applications are moved over to a NUMA system for the first time.  Your
interleaving solution is a decent one, although teaching the database
about NUMA is a much better long-term approach.

As far as the decisions about running reclaim or swapping versus going
to another node for an allocation, take a look at the
"zone_reclaim_mode" bits in Documentation/sysctl/vm.txt .  It does a
decent job of explaining what we do.

Most users new to NUMA systems just prefer to "echo 0 >
zone_reclaim_mode".  I've also run into a fair number of "tuning" guides
that say to do this.  It will make the allocator act a lot more like if
NUMA wasn't there.  It isn't as _optimized_ for NUMA locality then, but
it does tend to let you allocate memory more freely.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
