Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3EC6B0033
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 23:36:32 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so488749854pfx.1
        for <linux-mm@kvack.org>; Mon, 30 Jan 2017 20:36:32 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id l61si14752728plb.309.2017.01.30.20.36.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 30 Jan 2017 20:36:31 -0800 (PST)
Received: from pps.filterd (m0098393.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v0V4Xnkf022175
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 23:36:31 -0500
Received: from e28smtp07.in.ibm.com (e28smtp07.in.ibm.com [125.16.236.7])
	by mx0a-001b2d01.pphosted.com with ESMTP id 28a6qpe708-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 30 Jan 2017 23:36:31 -0500
Received: from localhost
	by e28smtp07.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Tue, 31 Jan 2017 10:06:27 +0530
Received: from d28relay07.in.ibm.com (d28relay07.in.ibm.com [9.184.220.158])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id CC8B9125801D
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 10:08:10 +0530 (IST)
Received: from d28av07.in.ibm.com (d28av07.in.ibm.com [9.184.220.146])
	by d28relay07.in.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id v0V4ZUH717301678
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 10:05:30 +0530
Received: from d28av07.in.ibm.com (localhost [127.0.0.1])
	by d28av07.in.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id v0V4aO4Q016277
	for <linux-mm@kvack.org>; Tue, 31 Jan 2017 10:06:25 +0530
Subject: Re: [RFC V2 12/12] mm: Tag VMA with VM_CDM flag explicitly during
 mbind(MPOL_BIND)
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-13-khandual@linux.vnet.ibm.com>
 <26a17cd1-dd50-43b9-03b1-dd967466a273@intel.com>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Tue, 31 Jan 2017 10:06:22 +0530
MIME-Version: 1.0
In-Reply-To: <26a17cd1-dd50-43b9-03b1-dd967466a273@intel.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <e03e62e2-54fa-b0ce-0b58-5db7393f8e3c@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/30/2017 11:24 PM, Dave Hansen wrote:
> On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
>> +		if ((new_pol->mode == MPOL_BIND)
>> +			&& nodemask_has_cdm(new_pol->v.nodes))
>> +			set_vm_cdm(vma);
> So, if you did:
> 
> 	mbind(addr, PAGE_SIZE, MPOL_BIND, all_nodes, ...);
> 	mbind(addr, PAGE_SIZE, MPOL_BIND, one_non_cdm_node, ...);
> 
> You end up with a VMA that can never have KSM done on it, etc...  Even
> though there's no good reason for it.  I guess /proc/$pid/smaps might be
> able to help us figure out what was going on here, but that still seems
> like an awful lot of damage.

Agreed, this VMA should not remain tagged after the second call. It does
not make sense. For this kind of scenarios we can re-evaluate the VMA
tag every time the nodemask change is attempted. But if we are looking for
some runtime re-evaluation then we need to steal some cycles are during
general VMA processing opportunity points like merging and split to do
the necessary re-evaluation. Should do we do these kind two kinds of
re-evaluation to be more optimal ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
