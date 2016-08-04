Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id E453E6B0253
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 09:54:35 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 1so147491850wmz.2
        for <linux-mm@kvack.org>; Thu, 04 Aug 2016 06:54:35 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id ek4si13730500wjd.140.2016.08.04.06.54.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 04 Aug 2016 06:54:34 -0700 (PDT)
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u74DsNEa009340
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 09:54:33 -0400
Received: from e28smtp06.in.ibm.com (e28smtp06.in.ibm.com [125.16.236.6])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24kxmhe5mc-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Thu, 04 Aug 2016 09:54:33 -0400
Received: from localhost
	by e28smtp06.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Thu, 4 Aug 2016 19:24:29 +0530
Received: from d28relay05.in.ibm.com (d28relay05.in.ibm.com [9.184.220.62])
	by d28dlp01.in.ibm.com (Postfix) with ESMTP id 29E0AE005E
	for <linux-mm@kvack.org>; Thu,  4 Aug 2016 19:28:50 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay05.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u74Dqlt17340058
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 19:22:47 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u74DsPKN029359
	for <linux-mm@kvack.org>; Thu, 4 Aug 2016 19:24:27 +0530
Date: Thu, 4 Aug 2016 19:24:14 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH 2/2] fadump: Disable deferred page struct initialisation
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1470143947-24443-1-git-send-email-srikar@linux.vnet.ibm.com>
 <1470143947-24443-3-git-send-email-srikar@linux.vnet.ibm.com>
 <1470201642.5034.3.camel@gmail.com>
 <20160803063538.GH6310@linux.vnet.ibm.com>
 <57A248A1.40807@intel.com>
 <20160804051035.GA11268@linux.vnet.ibm.com>
 <20160804102801.GJ2799@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20160804102801.GJ2799@techsingularity.net>
Message-Id: <20160804135414.GC11268@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Dave Hansen <dave.hansen@intel.com>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Michael Ellerman <mpe@ellerman.id.au>, mahesh@linux.vnet.ibm.com

* Mel Gorman <mgorman@techsingularity.net> [2016-08-04 11:28:01]:

> > > 
> > > Oh, and the dentry/inode caches are sized based on 100% of memory, not
> > > the 5% that's left after the fadump reservation?
> > 
> > Yes, the dentry/inode caches are sized based on the 100% memory.
> > 
> 
> By and large, I'm not a major fan of introducing an API to disable it for
> a single feature that is arch-specific because it's very heavy handed.
> There is no guarantee that the existence of fadump will cause a failure

okay.

> 
> If fadump is reserving memory and alloc_large_system_hash(HASH_EARLY)
> does not know about then then would an arch-specific callback for
> arch_reserved_kernel_pages() be more appropriate? fadump would need to
> return how many pages it reserved there. That would shrink the size of
> the inode and dentry hash tables when booting with 95% of memory
> reserved.
> 
> That approach would limit the impact to ppc64 and would be less costly than
> doing a memblock walk instead of using nr_kernel_pages for everyone else.
> 

I have posted a patch based on Mel and Dave's feedback

http://lkml.kernel.org/r/1470318165-2521-1-git-send-email-srikar@linux.vnet.ibm.com

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
