Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6AC5B82F64
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 00:44:46 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id w128so21082592pfd.3
        for <linux-mm@kvack.org>; Mon, 29 Aug 2016 21:44:46 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id qy6si43115999pab.154.2016.08.29.21.44.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 29 Aug 2016 21:44:43 -0700 (PDT)
Received: from pps.filterd (m0098396.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7U4hvwr078351
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 00:44:43 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2553620ddn-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 00:44:42 -0400
Received: from localhost
	by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 30 Aug 2016 14:44:40 +1000
Received: from d23relay08.au.ibm.com (d23relay08.au.ibm.com [9.185.71.33])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 9F7C32CE8056
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 14:44:38 +1000 (EST)
Received: from d23av06.au.ibm.com (d23av06.au.ibm.com [9.190.235.151])
	by d23relay08.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7U4icVp3473714
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 14:44:38 +1000
Received: from d23av06.au.ibm.com (localhost [127.0.0.1])
	by d23av06.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7U4icGC030008
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 14:44:38 +1000
Date: Tue, 30 Aug 2016 10:14:25 +0530
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: [PATCH] thp: reduce usage of huge zero page's atomic counter
References: <b7e47f2c-8aac-156a-f627-a50db31220f8@intel.com>        <20160829155021.2a85910c3d6b16a7f75ffccd@linux-foundation.org>        <36b76a95-5025-ac64-0862-b98b2ebdeaf7@intel.com> <20160829203916.6a2b45845e8fb0c356cac17d@linux-foundation.org>
In-Reply-To: <20160829203916.6a2b45845e8fb0c356cac17d@linux-foundation.org>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <57C50F29.4070309@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Aaron Lu <aaron.lu@intel.com>
Cc: Linux Memory Management List <linux-mm@kvack.org>, "'Kirill A. Shutemov'" <kirill.shutemov@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Huang Ying <ying.huang@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Jerome Marchand <jmarchan@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-kernel@vger.kernel.org

On 08/30/2016 09:09 AM, Andrew Morton wrote:
> On Tue, 30 Aug 2016 11:09:15 +0800 Aaron Lu <aaron.lu@intel.com> wrote:
> 
>>>> Case used for test on Haswell EP:
>>>> usemem -n 72 --readonly -j 0x200000 100G
>>>> Which spawns 72 processes and each will mmap 100G anonymous space and
>>>> then do read only access to that space sequentially with a step of 2MB.
>>>>
>>>> perf report for base commit:
>>>>     54.03%  usemem   [kernel.kallsyms]   [k] get_huge_zero_page
>>>> perf report for this commit:
>>>>      0.11%  usemem   [kernel.kallsyms]   [k] mm_get_huge_zero_page
>>>
>>> Does this mean that overall usemem runtime halved?
>>
>> Sorry for the confusion, the above line is extracted from perf report.
>> It shows the percent of CPU cycles executed in a specific function.
>>
>> The above two perf lines are used to show get_huge_zero_page doesn't
>> consume that much CPU cycles after applying the patch.
>>
>>>
>>> Do we have any numbers for something which is more real-wordly?
>>
>> Unfortunately, no real world numbers.
>>
>> We think the global atomic counter could be an issue for performance
>> so I'm trying to solve the problem.
> 
> So, umm, we don't actually know if the patch is useful to anyone?

On a POWER system it improves the CPU consumption of the above mentioned
function a little bit. Dont think its going to improve actual throughput
of the workload substantially.

0.07%  usemem  [kernel.vmlinux]  [k] mm_get_huge_zero_page

to

0.01%  usemem  [kernel.vmlinux]  [k] mm_get_huge_zero_page

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
