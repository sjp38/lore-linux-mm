Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 25C276B0033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 09:15:01 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id an2so33253654wjc.3
        for <linux-mm@kvack.org>; Wed, 08 Feb 2017 06:15:01 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id f38si9262840wrf.325.2017.02.08.06.14.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 08 Feb 2017 06:14:59 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v18EEq3W144241
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 09:14:58 -0500
Received: from e28smtp02.in.ibm.com (e28smtp02.in.ibm.com [125.16.236.2])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28g1rw83yj-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Wed, 08 Feb 2017 09:14:57 -0500
Received: from localhost
	by e28smtp02.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Wed, 8 Feb 2017 19:44:13 +0530
Received: from d28relay04.in.ibm.com (d28relay04.in.ibm.com [9.184.220.61])
	by d28dlp02.in.ibm.com (Postfix) with ESMTP id 355523940033
	for <linux-mm@kvack.org>; Wed,  8 Feb 2017 19:44:10 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay04.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v18EEAiU43384868
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 19:44:10 +0530
Received: from d28av01.in.ibm.com (localhost [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v18EE8Y4005094
	for <linux-mm@kvack.org>; Wed, 8 Feb 2017 19:44:09 +0530
Subject: Re: [RFC V2 12/12] mm: Tag VMA with VM_CDM flag explicitly during
 mbind(MPOL_BIND)
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-13-khandual@linux.vnet.ibm.com>
 <26a17cd1-dd50-43b9-03b1-dd967466a273@intel.com>
 <e03e62e2-54fa-b0ce-0b58-5db7393f8e3c@linux.vnet.ibm.com>
 <bfb7f080-6f0a-743f-654b-54f41443e44a@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Wed, 8 Feb 2017 19:43:54 +0530
MIME-Version: 1.0
In-Reply-To: <bfb7f080-6f0a-743f-654b-54f41443e44a@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <941c2b32-7bd8-56e7-a8d5-c103cab121d1@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 02/07/2017 11:37 PM, Dave Hansen wrote:
>> On 01/30/2017 11:24 PM, Dave Hansen wrote:
>>> On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
>>>> +		if ((new_pol->mode == MPOL_BIND)
>>>> +			&& nodemask_has_cdm(new_pol->v.nodes))
>>>> +			set_vm_cdm(vma);
>>> So, if you did:
>>>
>>> 	mbind(addr, PAGE_SIZE, MPOL_BIND, all_nodes, ...);
>>> 	mbind(addr, PAGE_SIZE, MPOL_BIND, one_non_cdm_node, ...);
>>>
>>> You end up with a VMA that can never have KSM done on it, etc...  Even
>>> though there's no good reason for it.  I guess /proc/$pid/smaps might be
>>> able to help us figure out what was going on here, but that still seems
>>> like an awful lot of damage.
>> Agreed, this VMA should not remain tagged after the second call. It does
>> not make sense. For this kind of scenarios we can re-evaluate the VMA
>> tag every time the nodemask change is attempted. But if we are looking for
>> some runtime re-evaluation then we need to steal some cycles are during
>> general VMA processing opportunity points like merging and split to do
>> the necessary re-evaluation. Should do we do these kind two kinds of
>> re-evaluation to be more optimal ?
> I'm still unconvinced that you *need* detection like this.  Scanning big
> VMAs is going to be really painful.
> 
> I thought I asked before but I can't find it in this thread.  But, we
> have explicit interfaces for disabling KSM and khugepaged.  Why do we
> need implicit ones like this in addition to those?

Missed the discussion we had on this last time around I think. My bad, sorry
about that. IIUC we can disable KSM through madvise() call, in fact I guess
its disabled by default and need to be enabled. We can just have a similar
interface to disable auto NUMA for a specific VMA or we can handle it page
by page basis with something like this.

diff --git a/mm/memory.c b/mm/memory.c
index 1099d35..101dfd9 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3518,6 +3518,9 @@ static int do_numa_page(struct vm_fault *vmf)
                goto out;
        }
 
+       if (is_cdm_node(page_to_nid(page)))
+               goto out;
+
        /* Migrate to the requested node */
        migrated = migrate_misplaced_page(page, vma, target_nid);
        if (migrated) {

I am still looking into these aspects. BTW have posted the minimum set of
CDM patches which defines and isolates CDM node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
