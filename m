Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id D78016B0387
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:56:28 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id e137so4547395itc.0
        for <linux-mm@kvack.org>; Tue, 21 Feb 2017 21:56:28 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id k39si501195ioi.190.2017.02.21.21.56.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Feb 2017 21:56:28 -0800 (PST)
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1M5mrb8019768
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:56:27 -0500
Received: from e23smtp07.au.ibm.com (e23smtp07.au.ibm.com [202.81.31.140])
	by mx0b-001b2d01.pphosted.com with ESMTP id 28rv2s9w2f-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 00:56:27 -0500
Received: from localhost
	by e23smtp07.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 22 Feb 2017 15:56:22 +1000
Received: from d23relay10.au.ibm.com (d23relay10.au.ibm.com [9.190.26.77])
	by d23dlp03.au.ibm.com (Postfix) with ESMTP id C89F53578056
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 16:56:19 +1100 (EST)
Received: from d23av05.au.ibm.com (d23av05.au.ibm.com [9.190.234.119])
	by d23relay10.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v1M5uBKI30801928
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 16:56:19 +1100
Received: from d23av05.au.ibm.com (localhost [127.0.0.1])
	by d23av05.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v1M5tlm3027311
	for <linux-mm@kvack.org>; Wed, 22 Feb 2017 16:55:47 +1100
Subject: Re: [PATCH 0/6] Enable parallel page migration
References: <20170217112453.307-1-khandual@linux.vnet.ibm.com>
 <20170222050425.GB9967@balbir.ozlabs.ibm.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 22 Feb 2017 11:25:13 +0530
MIME-Version: 1.0
In-Reply-To: <20170222050425.GB9967@balbir.ozlabs.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <4efb25de-e036-4015-e764-70b4c911ca67@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dave.hansen@intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu

On 02/22/2017 10:34 AM, Balbir Singh wrote:
> On Fri, Feb 17, 2017 at 04:54:47PM +0530, Anshuman Khandual wrote:
>> 	This patch series is base on the work posted by Zi Yan back in
>> November 2016 (https://lkml.org/lkml/2016/11/22/457) but includes some
>> amount clean up and re-organization. This series depends on THP migration
>> optimization patch series posted by Naoya Horiguchi on 8th November 2016
>> (https://lwn.net/Articles/705879/). Though Zi Yan has recently reposted
>> V3 of the THP migration patch series (https://lwn.net/Articles/713667/),
>> this series is yet to be rebased.
>>
>> 	Primary motivation behind this patch series is to achieve higher
>> bandwidth of memory migration when ever possible using multi threaded
>> instead of a single threaded copy. Did all the experiments using a two
>> socket X86 sytsem (Intel(R) Xeon(R) CPU E5-2650). All the experiments
>> here have same allocation size 4K * 100000 (which did not split evenly
>> for the 2MB huge pages). Here are the results.
>>
>> Vanilla:
>>
>> Moved 100000 normal pages in 247.000000 msecs 1.544412 GBs
>> Moved 100000 normal pages in 238.000000 msecs 1.602814 GBs
>> Moved 195 huge pages in 252.000000 msecs 1.513769 GBs
>> Moved 195 huge pages in 257.000000 msecs 1.484318 GBs
>>
>> THP migration improvements:
>>
>> Moved 100000 normal pages in 302.000000 msecs 1.263145 GBs
> 
> Is there a decrease here for normal pages?

Yeah.

> 
>> Moved 100000 normal pages in 262.000000 msecs 1.455991 GBs
>> Moved 195 huge pages in 120.000000 msecs 3.178914 GBs
>> Moved 195 huge pages in 129.000000 msecs 2.957130 GBs
>>
>> THP migration improvements + Multi threaded page copy:
>>
>> Moved 100000 normal pages in 1589.000000 msecs 0.240069 GBs **
> 
> Ditto?

Yeah, I have already mentioned about this after these data in
the cover letter. This new flag is controlled from user space
while invoking the system calls. Users should be careful in
using it for scenarios where its useful and avoid it for cases
where it hurts.

> 
>> Moved 100000 normal pages in 1932.000000 msecs 0.197448 GBs **
>> Moved 195 huge pages in 54.000000 msecs 7.064254 GBs ***
>> Moved 195 huge pages in 86.000000 msecs 4.435694 GBs ***
>>
> 
> Could you also comment on the CPU utilization impact of these
> patches. 

Yeah, it really makes sense to analyze this impact. I have mentioned
about this in the outstanding issues section of the series. But what
exactly we need to analyze from CPU utilization impact point of view
? Like whats the probability that the work queue requested jobs will
throw some tasks from the run queue and make them starve for some
more time ? Could you please give some details on this ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
