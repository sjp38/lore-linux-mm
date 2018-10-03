Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f72.google.com (mail-ot1-f72.google.com [209.85.210.72])
	by kanga.kvack.org (Postfix) with ESMTP id 05DD76B000D
	for <linux-mm@kvack.org>; Wed,  3 Oct 2018 09:16:01 -0400 (EDT)
Received: by mail-ot1-f72.google.com with SMTP id s68so3657426ota.11
        for <linux-mm@kvack.org>; Wed, 03 Oct 2018 06:16:01 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f12si633712oti.282.2018.10.03.06.15.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Oct 2018 06:15:59 -0700 (PDT)
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w93DDvfn162167
	for <linux-mm@kvack.org>; Wed, 3 Oct 2018 09:15:59 -0400
Received: from e06smtp07.uk.ibm.com (e06smtp07.uk.ibm.com [195.75.94.103])
	by mx0b-001b2d01.pphosted.com with ESMTP id 2mvw29v0qg-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 03 Oct 2018 09:15:59 -0400
Received: from localhost
	by e06smtp07.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 3 Oct 2018 14:15:57 +0100
Date: Wed, 3 Oct 2018 18:45:49 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] mm, numa: Migrate pages to local nodes quicker early
 in the lifetime of a task
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20181001100525.29789-1-mgorman@techsingularity.net>
 <20181001100525.29789-3-mgorman@techsingularity.net>
 <20181002124149.GB4593@linux.vnet.ibm.com>
 <20181002135459.GA7003@techsingularity.net>
 <20181002173005.GD4593@linux.vnet.ibm.com>
 <20181002182248.GB7003@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20181002182248.GB7003@techsingularity.net>
Message-Id: <20181003131549.GB4488@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Jirka Hladky <jhladky@redhat.com>, Rik van Riel <riel@surriel.com>, LKML <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>

> > if we want to prioritize STREAM like workloads (i.e private faults) one simpler
> > fix could be to change the quadtraic equation
> > 
> > from:
> > 	if (!cpupid_pid_unset(last_cpupid) &&
> > 				cpupid_to_nid(last_cpupid) != dst_nid)
> > 		return false;
> > to:
> > 	if (!cpupid_pid_unset(last_cpupid) &&
> > 				cpupid_to_nid(last_cpupid) == dst_nid)
> > 		return true;
> > 
> > i.e to say if the group tasks likely consolidated to a node or the task was
> > moved to a different node but access were private, just move the memory.
> > 
> > The drawback though is we keep pulling memory everytime the task moves
> > across nodes. (which is probably restricted for long running tasks to some
> > extent by your fix)
> > 
> 
> This has way more consequences as it changes the behaviour for the entire
> lifetime of the workload. It could cause excessive migrations in the case
> where a machine is almost fully utilised and getting load balanced or in
> cases where tasks are pulled frequently cross-node (e.g. worker thread
> model or a pipelined computation).
> 
> I'm only looking to address the case where the load balancer spreads a
> workload early and the memory should move to the new node quickly. If it
> turns out there are cases where that decision is wrong, it gets remedied
> quickly but if your proposal is ever wrong, the system doesn't recover.
> 

Agree.

-- 
Thanks and Regards
Srikar Dronamraju
