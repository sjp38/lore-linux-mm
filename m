Received: from austin.ibm.com (netmail1.austin.ibm.com [9.53.250.96])
	by mg03.austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id NAA17692
	for <linux-mm@kvack.org>; Thu, 19 Apr 2001 13:27:41 -0500
Received: from baldur.austin.ibm.com (baldur.austin.ibm.com [9.53.230.118])
	by austin.ibm.com (AIX4.3/8.9.3/8.9.3) with ESMTP id NAA26838
	for <linux-mm@kvack.org>; Thu, 19 Apr 2001 13:25:45 -0500
Received: from baldur (localhost.austin.ibm.com [127.0.0.1])
	by baldur.austin.ibm.com (8.12.0.Beta7/8.11.3) with ESMTP id f3JIPjWm013141
	for <linux-mm@kvack.org>; Thu, 19 Apr 2001 13:25:46 -0500
Date: Thu, 19 Apr 2001 13:25:45 -0500
From: Dave McCracken <dmc@austin.ibm.com>
Subject: Re: suspend processes at load (was Re: a simple OOM ...)
Message-ID: <7370000.987704745@baldur>
In-Reply-To: <l03130303b704a08b5dde@[192.168.239.105]>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--On Thursday, April 19, 2001 15:03:28 +0100 Jonathan Morton 
<chromi@cyberspace.org> wrote:

> My proposal is to introduce a better approximation to LRU in the VM,
> solely for the purpose of determining the working set.  No alterations to
> the page replacement policy are needed per se, except to honour the
> "allowed working set" for each process as calculated below.
>
> (...)
>
> - Calculate the total physical quota for all processes as the sum of all
> working sets (plus unswappable memory such as kernel, mlock(), plus a
> small chunk to handle buffers, cache, etc.)
> - If this total is within the physical memory of the system, the physical
> quota for each process is the same as it's working set.  (fast common
> case) - Otherwise, locate the process with the largest quota and remove
> it from the total quota.  Add in "a few" pages to ensure this process
> always has *some* memory to work in.  Repeat this step until the physical
> quota is within physical memory or no processes remain.
> - Any remaining processes after this step get their full working set as
> physical quota.  Processes removed from the list get equal share of
> (remaining physical memory, minus the chunk for buffers, cache and so on).

It appears to me that the end result of all this is about the same as 
suspending a few selected processes.  Under your algorithm the processes 
that have no guaranteed working set make no real progress and the others 
get to run.  It seems like a significant amount of additional overhead to 
end up with the same result.  Additionally, those processes will be 
generating large numbers of page faults as they fight over the scrap of 
memory they have.  Using the suspension algorithm they'll be removed 
entirely from running, this freeing up resources for the remaining 
processes.

Dave McCracken

======================================================================
Dave McCracken          IBM Linux Base Kernel Team      1-512-838-3059
dmc@austin.ibm.com                                      T/L   678-3059

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
