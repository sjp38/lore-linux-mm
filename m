Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id AAF0B6B0253
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 01:41:13 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id f5so476918930pgi.1
        for <linux-mm@kvack.org>; Tue, 31 Jan 2017 22:41:13 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l26si17273165pfg.54.2017.01.31.22.41.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 31 Jan 2017 22:41:12 -0800 (PST)
Received: from pps.filterd (m0098410.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v116ccKH092234
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 01:41:12 -0500
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28akc22qry-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 01 Feb 2017 01:41:12 -0500
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 1 Feb 2017 12:11:08 +0530
Received: from d28relay07.in.ibm.com (d28relay07.in.ibm.com [9.184.220.158])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 874441258021
	for <linux-mm@kvack.org>; Wed,  1 Feb 2017 12:12:50 +0530 (IST)
Received: from d28av03.in.ibm.com (d28av03.in.ibm.com [9.184.220.65])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v116e8go20250662
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 12:10:08 +0530
Received: from d28av03.in.ibm.com (localhost [127.0.0.1])
	by d28av03.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v116f32c012766
	for <linux-mm@kvack.org>; Wed, 1 Feb 2017 12:11:04 +0530
Subject: Re: [RFC V2 03/12] mm: Change generic FALLBACK zonelist creation
 process
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-4-khandual@linux.vnet.ibm.com>
 <07bd439c-6270-b219-227b-4079d36a2788@intel.com>
 <434aa74c-e917-490e-85ab-8c67b1a82d95@linux.vnet.ibm.com>
 <f1521ecc-e2a2-7368-07b7-7af6c0e88cc6@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 1 Feb 2017 12:10:55 +0530
MIME-Version: 1.0
In-Reply-To: <f1521ecc-e2a2-7368-07b7-7af6c0e88cc6@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <654e5b6f-4b23-671e-87ee-1ee83e3cc9a6@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/31/2017 07:27 AM, Dave Hansen wrote:
> On 01/30/2017 05:36 PM, Anshuman Khandual wrote:
>>> Let's say we had a CDM node with 100x more RAM than the rest of the
>>> system and it was just as fast as the rest of the RAM.  Would we still
>>> want it isolated like this?  Or would we want a different policy?
>>
>> But then the other argument being, dont we want to keep this 100X more
>> memory isolated for some special purpose to be utilized by specific
>> applications ?
> 
> I was thinking that in this case, we wouldn't even want to bother with
> having "system RAM" in the fallback lists.  A device who got its memory

System RAM is in the fallback list of the CDM node for the following
purpose.

If the user asks explicitly through mbind() and there is insufficient
memory on the CDM node to fulfill the request. Then it is better to
fallback on a system RAM memory node than to fail the request. This is
in line with expectations from the mbind() call. There are other ways
for the user space like /proc/pid/numa_maps to query about from where
exactly a given page has come from in the runtime.

But keeping options open I have noted down this in the cover letter.

"
FALLBACK zonelist creation:

CDM node's FALLBACK zonelist can also be changed to accommodate other CDM
memory zones along with system RAM zones in which case they can be used as
fallback options instead of first depending on the system RAM zones when
it's own memory falls insufficient during allocation.
"

> usage off by 1% could start to starve the rest of the system.  A sane

Did not get this point. Could you please elaborate more on this ?

> policy in this case might be to isolate the "system RAM" from the device's.

Hmm.

> 
>>> Why do we need this hard-coded along with the cpuset stuff later in the
>>> series.  Doesn't taking a node out of the cpuset also take it out of the
>>> fallback lists?
>>
>> There are two mutually exclusive approaches which are described in
>> this patch series.
>>
>> (1) zonelist modification based approach
>> (2) cpuset restriction based approach
>>
>> As mentioned in the cover letter,
> 
> Well, I'm glad you coded both of them up, but now that we have them how
> to we pick which one to throw to the wolves?  Or, do we just merge both
> of them and let one bitrot? ;)

I am just trying to see how each isolation method stack up from benefit
and cost point of view, so that we can have informed debate about their
individual merit. Meanwhile I have started looking at if the core buddy
allocator __alloc_pages_nodemask() and its interaction with nodemask at
various stages can also be modified to implement the intended solution.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
