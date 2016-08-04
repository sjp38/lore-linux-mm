Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFD96B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 01:25:40 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id 33so126316557lfw.1
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 22:25:40 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id q63si2123168wmd.131.2016.08.03.22.25.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 22:25:39 -0700 (PDT)
Received: from pps.filterd (m0098413.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u745OOXW123841
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 01:25:37 -0400
Received: from e23smtp05.au.ibm.com (e23smtp05.au.ibm.com [202.81.31.147])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24kkahsrry-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:25:37 -0400
Received: from localhost
	by e23smtp05.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 15:25:34 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id CE4503578056
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 15:25:30 +1000 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u745PUMx27721910
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 15:25:30 +1000
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u745PUZZ007593
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 15:25:30 +1000
Date: Thu, 4 Aug 2016 10:55:26 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm: Allow disabling deferred struct page
 initialisation
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
 <1470143947-24443-2-git-send-email-srikar@linux.vnet.ibm.com>
 <57A0E1D1.8020608@intel.com>
 <20160803063808.GI6310@linux.vnet.ibm.com>
 <57A23547.1070207@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <57A23547.1070207@intel.com>
Message-Id: <20160804052526.GB11268@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, linuxppc-dev@lists.ozlabs.org, mahesh@linux.vnet.ibm.com, hbathini@linux.vnet.ibm.com

* Dave Hansen <dave.hansen@intel.com> [2016-08-03 11:17:43]:

> On 08/02/2016 11:38 PM, Srikar Dronamraju wrote:
> > * Dave Hansen <dave.hansen@intel.com> [2016-08-02 11:09:21]:
> >> On 08/02/2016 06:19 AM, Srikar Dronamraju wrote:
> >>> Kernels compiled with CONFIG_DEFERRED_STRUCT_PAGE_INIT will initialise
> >>> only certain size memory per node. The certain size takes into account
> >>> the dentry and inode cache sizes. However such a kernel when booting a
> >>> secondary kernel will not be able to allocate the required amount of
> >>> memory to suffice for the dentry and inode caches. This results in
> >>> crashes like the below on large systems such as 32 TB systems.
> >>
> >> What's a "secondary kernel"?
> >>
> > I mean the kernel thats booted to collect the crash, On fadump, the
> > first kernel acts as the secondary kernel i.e the same kernel is booted
> > to collect the crash.
> 
> OK, but I'm still not seeing what the problem is.  You've said that it
> crashes and that it crashes during inode/dentry cache allocation.
> 
> But, *why* does the same kernel image crash in when it is used as a
> "secondary kernel"?
> 

I guess you already got it. But let me try to explain it again.

Lets say we have a 32 TB system with 16 nodes each node having 2T of
memory. We are assuming deferred page initialisation is configured.

When the regular kernel boots,
1. It reserves 5% of the memory for fadump.
2. It initializes 8GB per node, i.e 128GB
3. It allocated dentry/inode cache which is around 16GB.
4. It then kicks the parallel page struct initialization.

Now lets say kernel crashed and fadump was triggered.

1. The same kernel boots in the 5% reserved space which is 1600GB
2. It reserves the rest 95% memory.
3. It tries to initialize 8GB per node but can only initialize 8GB.
	(since except for 1st node the rest nodes are all reserved)
4. It tries to allocate dentry/inode cache of 16GB but fails.
	(tries to reclaim but reclaim needs spinlock 
	and spinlock is not yet initialized.)

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
