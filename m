Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B0286B0008
	for <linux-mm@kvack.org>; Tue,  2 Oct 2018 13:30:44 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id p23-v6so1839763otl.23
        for <linux-mm@kvack.org>; Tue, 02 Oct 2018 10:30:44 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w67-v6si8236826oia.255.2018.10.02.10.30.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 02 Oct 2018 10:30:43 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w92HUWXg034933
	for <linux-mm@kvack.org>; Tue, 2 Oct 2018 13:30:42 -0400
Received: from e06smtp04.uk.ibm.com (e06smtp04.uk.ibm.com [195.75.94.100])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2mv9udgv0y-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 02 Oct 2018 13:30:37 -0400
Received: from localhost
	by e06smtp04.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 2 Oct 2018 18:30:11 +0100
Date: Tue, 2 Oct 2018 23:00:05 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mm, numa: Migrate pages to local nodes quicker early
 in the lifetime of a task
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20181001100525.29789-1-mgorman@techsingularity.net>
 <20181001100525.29789-3-mgorman@techsingularity.net>
 <20181002124149.GB4593@linux.vnet.ibm.com>
 <20181002135459.GA7003@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20181002135459.GA7003@techsingularity.net>
Message-Id: <20181002173005.GD4593@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Jirka Hladky <jhladky@redhat.com>, Rik van Riel <riel@surriel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

> > 
> > This does have issues when using with workloads that access more shared faults
> > than private faults.
> > 
> 
> Not as such. It can have issues on workloads where memory is initialised
> by one thread, then additional threads are created and access the same
> memory. They are not necessarily shared once buffers are handed over. In
> such a case, migrating quickly is the right thing to do. If it's truely
> shared pages then there may be some unnecessary migrations early in the
> lifetime of the task but it'll settle down quickly enough.
> 

Do you have a workload recommendation to try for shared fault accesses.
I will try to get a DayTrader run in a day or two. There JVM and db threads
act on the same memory, I presume it might show some insights.

> Is it just numa01 that was affected for you? I ask because that particular
> workload is an averse workload on any machine with more than sockets and
> your machine description says it has 4 nodes. What it is testing is quite
> specific to 2-node machines.
> 

Agree, 

Some variations of numa01.sh where I have one process having threads equal
to number of cpus does regress but not as much as numa01.

./numa03.sh      Real:  484.84    555.51    518.59    22.91    -5.84277%
./numa03.sh      Sys:   44.41     64.40     53.24     6.65     -11.3824%
./numa03.sh      User:  51328.77  59429.39  55366.62  2744.39  -9.47912%


> > SPECJbb did show some small loss and gains.
> > 
> 
> That almost always shows small gains and losses so that's not too
> surprising.
> 

Okay.

> > Our numa grouping is not fast enough. It can take sometimes several
> > iterations before all the tasks belonging to the same group end up being
> > part of the group. With the current check we end up spreading memory faster
> > than we should hence hurting the chance of early consolidation.
> > 
> > Can we restrict to something like this?
> > 
> > if (p->numa_scan_seq >=MIN && p->numa_scan_seq <= MIN+4 &&
> >     (cpupid_match_pid(p, last_cpupid)))
> > 	return true;
> > 
> > meaning, we ran atleast MIN number of scans, and we find the task to be most likely
> > task using this page.
> > 
> 


> What's MIN? Assuming it's any type of delay, note that this will regress
> STREAM again because it's very sensitive to the starting state.
> 

I was thinking of MIN as 3 to give a chance for things to settle.
but that might not help STREAM as you pointed out.

Do you have a hint on which commit made STREAM regress?

if we want to prioritize STREAM like workloads (i.e private faults) one simpler
fix could be to change the quadtraic equation

from:
	if (!cpupid_pid_unset(last_cpupid) &&
				cpupid_to_nid(last_cpupid) != dst_nid)
		return false;
to:
	if (!cpupid_pid_unset(last_cpupid) &&
				cpupid_to_nid(last_cpupid) == dst_nid)
		return true;

i.e to say if the group tasks likely consolidated to a node or the task was
moved to a different node but access were private, just move the memory.

The drawback though is we keep pulling memory everytime the task moves
across nodes. (which is probably restricted for long running tasks to some
extent by your fix)

-- 
Thanks and Regards
Srikar Dronamraju
