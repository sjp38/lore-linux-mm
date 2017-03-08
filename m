Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 560E16B03BA
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 11:05:32 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id e5so63852156pgk.1
        for <linux-mm@kvack.org>; Wed, 08 Mar 2017 08:05:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id d5si3656801pgh.317.2017.03.08.08.05.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Mar 2017 08:05:31 -0800 (PST)
Received: from pps.filterd (m0098404.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v28Fws6u080677
	for <linux-mm@kvack.org>; Wed, 8 Mar 2017 11:05:30 -0500
Received: from e23smtp08.au.ibm.com (e23smtp08.au.ibm.com [202.81.31.141])
	by mx0a-001b2d01.pphosted.com with ESMTP id 292g4kqmyq-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Mar 2017 11:05:30 -0500
Received: from localhost
	by e23smtp08.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Thu, 9 Mar 2017 02:05:27 +1000
Received: from d23av04.au.ibm.com (d23av04.au.ibm.com [9.190.235.139])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v28G5He927984050
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 03:05:25 +1100
Received: from d23av04.au.ibm.com (localhost [127.0.0.1])
	by d23av04.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v28G4qh9006207
	for <linux-mm@kvack.org>; Thu, 9 Mar 2017 03:04:53 +1100
Subject: Re: [PATCH 0/6] Enable parallel page migration
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 8 Mar 2017 21:34:27 +0530
MIME-Version: 1.0
In-Reply-To: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <ef5efef8-a8c5-a4e7-ffc7-44176abec65c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

On 02/17/2017 04:54 PM, Anshuman Khandual wrote:
> 	This patch series is base on the work posted by Zi Yan back in
> November 2016 (https://lkml.org/lkml/2016/11/22/457) but includes some
> amount clean up and re-organization. This series depends on THP migration
> optimization patch series posted by Naoya Horiguchi on 8th November 2016
> (https://lwn.net/Articles/705879/). Though Zi Yan has recently reposted
> V3 of the THP migration patch series (https://lwn.net/Articles/713667/),
> this series is yet to be rebased.
> 
> 	Primary motivation behind this patch series is to achieve higher
> bandwidth of memory migration when ever possible using multi threaded
> instead of a single threaded copy. Did all the experiments using a two
> socket X86 sytsem (Intel(R) Xeon(R) CPU E5-2650). All the experiments
> here have same allocation size 4K * 100000 (which did not split evenly
> for the 2MB huge pages). Here are the results.
> 
> Vanilla:
> 
> Moved 100000 normal pages in 247.000000 msecs 1.544412 GBs
> Moved 100000 normal pages in 238.000000 msecs 1.602814 GBs
> Moved 195 huge pages in 252.000000 msecs 1.513769 GBs
> Moved 195 huge pages in 257.000000 msecs 1.484318 GBs
> 
> THP migration improvements:
> 
> Moved 100000 normal pages in 302.000000 msecs 1.263145 GBs
> Moved 100000 normal pages in 262.000000 msecs 1.455991 GBs
> Moved 195 huge pages in 120.000000 msecs 3.178914 GBs
> Moved 195 huge pages in 129.000000 msecs 2.957130 GBs
> 
> THP migration improvements + Multi threaded page copy:
> 
> Moved 100000 normal pages in 1589.000000 msecs 0.240069 GBs **
> Moved 100000 normal pages in 1932.000000 msecs 0.197448 GBs **
> Moved 195 huge pages in 54.000000 msecs 7.064254 GBs ***
> Moved 195 huge pages in 86.000000 msecs 4.435694 GBs ***
> 
> 
> **      Using multi threaded copy can be detrimental to performance if
> 	used for regular pages which are way too small. But then the
> 	framework provides the means to use it if some kernel/driver
> 	caller or user application wants to use it.
> 
> ***     These applications have used the new MPOL_MF_MOVE_MT flag while
> 	calling the system calls like mbind() and move_pages().
> 
> On POWER8 the improvements are similar when tested with a draft patch
> which enables migration at PMD level. Not putting out the results here
> as the kernel is not stable with the that draft patch and crashes some
> times. We are working on enabling PMD level migration on POWER8 and will
> test this series out thoroughly when its ready.
> 
> Patch Series Description::
> 
> Patch 1: Add new parameter to migrate_page_copy and copy_huge_page so
> 	 that it can differentiate between when to use single threaded
> 	 version (MIGRATE_ST) or multi threaded version (MIGRATE_MT).
> 
> Patch 2: Make migrate_mode types non-exclusive.
> 
> Patch 3: Add copy_pages_mthread function which does the actual multi
> 	 threaded copy. This involves splitting the copy work into
> 	 chunks, selecting threads and submitting copy jobs in the
> 	 work queues.
> 
> Patch 4: Add new migrate mode MIGRATE_MT to be used by higher level
> 	 migration functions.
> 
> Patch 5: Add new migration flag MPOL_MF_MOVE_MT for migration system
> 	 calls to be used in the user space.
> 
> Patch 6: Define global mt_page_copy tunable which turns on the multi
> 	 threaded page copy no matter what for all migrations on the
> 	 system.
> 
> Outstanding Issues::
> 
> Issue 1: The usefulness of the global multi threaded copy tunable i.e
> 	 vm.mt_page_copy. It makes sense and helps in validating the
> 	 framework. Should this be moved to debugfs instead ?
> 
> Issue 2: We choose nr_copythreads = 8 as maximum number of threads on
> 	 a node can be 8 on any architecture (Which is on POWER8 if
> 	 I am not missing any other arch which might have equal or
> 	 more number of threads per node). It just denotes max number
> 	 of threads and we will be adjusted based on cpumask_weight
> 	 value on destination node. Can we do better, suggestions ?
> 
> Issue 3: Multi threaded page migration works best with threads allocated
> 	 at different physical cores, not all in the same hyper-threaded
> 	 core. Work queues submitted jobs consume scheduler slots from
> 	 the given thread to execute the copy. This can interfere with
> 	 scheduling and affect some already running tasks on the system.
> 	 Should we be looking into arch topology information, scheduler
> 	 cpu idle details to decide on which threads to use before going
> 	 for multi threaded copy ? Abort multi threaded copy and fallback
> 	 to regular copy at times when the parameters are not good ?
> 
> Any comments, suggestions are welcome.

Hello Vlastimil/Michal/Minchan/Mel/Dave,

Apart from the comments from Naoya on a different thread posted by Zi
Yan, I did not get any more review comments on this series. Could you
please kindly have a look on the over all design and its benefits from
page migration performance point of view and let me know your views.
Thank you.

+ Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>


Regards
Anshuman


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
