Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f70.google.com (mail-pa0-f70.google.com [209.85.220.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2E2366B0274
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 15:20:51 -0400 (EDT)
Received: by mail-pa0-f70.google.com with SMTP id gg9so29567138pac.6
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 12:20:51 -0700 (PDT)
Received: from mx0a-001b2d01.pphosted.com (mx0a-001b2d01.pphosted.com. [148.163.156.1])
        by mx.google.com with ESMTPS id z80si22104955pfj.251.2016.10.25.12.20.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 12:20:50 -0700 (PDT)
Received: from pps.filterd (m0098399.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u9PJJTsZ145931
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 15:20:49 -0400
Received: from e35.co.us.ibm.com (e35.co.us.ibm.com [32.97.110.153])
	by mx0a-001b2d01.pphosted.com with ESMTP id 26ad0fa6h2-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 15:20:49 -0400
Received: from localhost
	by e35.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Tue, 25 Oct 2016 13:20:49 -0600
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: Re: [RFC 5/8] mm: Add new flag VM_CDM for coherent device memory
In-Reply-To: <580E4704.1040104@intel.com>
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com> <1477283517-2504-6-git-send-email-khandual@linux.vnet.ibm.com> <580E4704.1040104@intel.com>
Date: Wed, 26 Oct 2016 00:50:37 +0530
MIME-Version: 1.0
Content-Type: text/plain
Message-Id: <87pomojkvu.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

Dave Hansen <dave.hansen@intel.com> writes:

> On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
>> VMAs containing coherent device memory should be marked with VM_CDM. These
>> VMAs need to be identified in various core kernel paths and this new flag
>> will help in this regard.
>
> ... and it's sticky?  So if a VMA *ever* has one of these funky pages in
> it, it's stuck being VM_CDM forever?  Never to be merged with other
> VMAs?  Never to see the light of autonuma ever again?
>
> What if a 100TB VMA has one page of fancy pants device memory, and the
> rest normal vanilla memory?  Do we really want to consider the whole
> thing fancy?

This definitely needs fine tuning. I guess we should look at this as
possibly stating that, coherent device would like to not participate in
auto numa balancing, because it is difficult to update the core kernel
about access patters within the coherent device. This can result in core
kernel always trying to migrate pages from coherent device to system ram
even though we have large number of access within coherent device.


One possible option is to use a software pte bit (may be steal
_PAGE_DEVMAP) and prevent a numa pte setup from change_prot_numa().
ie, if the pfn backing the pte is from coherent device we don't allow
that to be converted to a prot none pte for numa faults ?


-aneesh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
