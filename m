Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id CD0516B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 01:10:46 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id p85so126110576lfg.3
        for <linux-mm@kvack.org>; Wed, 03 Aug 2016 22:10:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f9si2078304wmg.96.2016.08.03.22.10.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Aug 2016 22:10:45 -0700 (PDT)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7458vIB089609
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 01:10:43 -0400
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com [202.81.31.145])
	by mx0a-001b2d01.pphosted.com with ESMTP id 24kkak15fx-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 01:10:43 -0400
Received: from localhost
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 15:10:40 +1000
Received: from d23relay09.au.ibm.com (d23relay09.au.ibm.com [9.185.63.181])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 727462BB0059
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 15:10:38 +1000 (EST)
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay09.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u745AcJv29753576
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 15:10:38 +1000
Received: from d23av02.au.ibm.com (localhost [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u745AbUF010327
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 15:10:38 +1000
Date: Thu, 4 Aug 2016 10:40:35 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] fadump: Disable deferred page struct initialisation
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
 <1470143947-24443-3-git-send-email-srikar@linux.vnet.ibm.com>
 <1470201642.5034.3.camel@gmail.com>
 <20160803063538.GH6310@linux.vnet.ibm.com>
 <57A248A1.40807@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <57A248A1.40807@intel.com>
Message-Id: <20160804051035.GA11268@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, mahesh@linux.vnet.ibm.com

* Dave Hansen <dave.hansen@intel.com> [2016-08-03 12:40:17]:

> On 08/02/2016 11:35 PM, Srikar Dronamraju wrote:
> > On a regular kernel with CONFIG_FADUMP and fadump configured, 5% of the
> > total memory is reserved for booting the kernel on crash.  On crash,
> > fadump kernel reserves the 95% memory and boots into the 5% memory that
> > was reserved for it. It then parses the reserved 95% memory to collect
> > the dump.
> > 
> > The problem is not about the amount of memory thats reserved for fadump
> > kernel. Even if we increase/decrease, we will still end up with the same
> > issue.
> 
> Oh, and the dentry/inode caches are sized based on 100% of memory, not
> the 5% that's left after the fadump reservation?

Yes, the dentry/inode caches are sized based on the 100% memory.

> 
> Is the deferred initialization kicked in progress at the time we do the
> dentry/inode allocations?  Can waiting a bit let the allocation succeed?
> 

Right now deferred initialisation kicks in after dentry/inode
allocations.

Can we defer the cache allocations till deferred
initialisation? I dont know. But if we can that could potentially solve
the problem. May be Mel or somebody might be able answer if we can defer
dentry/inode cache allocations till deferred initialisation kicks in.

The other idea is to detect nodes whose memory is reserved and allocate
extra memory from the nodes where memory is not yet reserved.

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
