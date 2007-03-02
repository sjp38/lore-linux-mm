Received: from sd0208e0.au.ibm.com (d23rh904.au.ibm.com [202.81.18.202])
	by ausmtp04.au.ibm.com (8.13.8/8.13.8) with ESMTP id l221u0aE326788
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 12:56:00 +1100
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.250.237])
	by sd0208e0.au.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l221h7Da146354
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 12:43:08 +1100
Received: from d23av04.au.ibm.com (loopback [127.0.0.1])
	by d23av04.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l221dZ7b005942
	for <linux-mm@kvack.org>; Fri, 2 Mar 2007 12:39:36 +1100
Message-ID: <45E78053.6010000@in.ibm.com>
Date: Fri, 02 Mar 2007 07:09:31 +0530
From: Balbir Singh <balbir@in.ibm.com>
Reply-To: balbir@in.ibm.com
MIME-Version: 1.0
Subject: Re: The performance and behaviour of the anti-fragmentation related
 patches
References: <20070301101249.GA29351@skynet.ie> <20070301160915.6da876c5.akpm@linux-foundation.org>
In-Reply-To: <20070301160915.6da876c5.akpm@linux-foundation.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mel@skynet.ie>, npiggin@suse.de, clameter@engr.sgi.com, mingo@elte.hu, jschopp@austin.ibm.com, arjan@infradead.org, torvalds@linux-foundation.org, mbligh@mbligh.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andrew Morton wrote:
> So some urgent questions are: how are we going to do mem hotunplug and
> per-container RSS?
> 
> 
> 
> Our basic unit of memory management is the zone.  Right now, a zone maps
> onto some hardware-imposed thing.  But the zone-based MM works *well*.  I
> suspect that a good way to solve both per-container RSS and mem hotunplug
> is to split the zone concept away from its hardware limitations: create a
> "software zone" and a "hardware zone".  All the existing page allocator and
> reclaim code remains basically unchanged, and it operates on "software
> zones".  Each software zones always lies within a single hardware zone. 
> The software zones are resizeable.  For per-container RSS we give each
> container one (or perhaps multiple) resizeable software zones.
> 
> For memory hotunplug, some of the hardware zone's software zones are marked
> reclaimable and some are not; DIMMs which are wholly within reclaimable
> zones can be depopulated and powered off or removed.
> 
> NUMA and cpusets screwed up: they've gone and used nodes as their basic
> unit of memory management whereas they should have used zones.  This will
> need to be untangled.
> 
> 
> Anyway, that's just a shot in the dark.  Could be that we implement unplug
> and RSS control by totally different means.  But I do wish that we'd sort
> out what those means will be before we potentially complicate the story a
> lot by adding antifragmentation.
> 

Paul Menage had suggested something very similar in response to the RFC
for memory controllers I sent out and it was suggested that we create
small zones (roughly 64 MB) to avoid the issue of a zone/node not being
a shareable across containers. Even with a small size, there are some 
issues. The following thread has the details discussed.

	http://lkml.org/lkml/2006/10/30/120

RSS accounting is very easy (with minimal changes to the core mm),
supplemented with an efficient per-container reclaimer, it should be
easy to implement a  good per-container RSS controller.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
