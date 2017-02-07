Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 751856B0033
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 13:07:33 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id 204so159555937pfx.1
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 10:07:33 -0800 (PST)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id 68si4741127pft.186.2017.02.07.10.07.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Feb 2017 10:07:32 -0800 (PST)
Subject: Re: [RFC V2 12/12] mm: Tag VMA with VM_CDM flag explicitly during
 mbind(MPOL_BIND)
References: <20170130033602.12275-1-khandual@linux.vnet.ibm.com>
 <20170130033602.12275-13-khandual@linux.vnet.ibm.com>
 <26a17cd1-dd50-43b9-03b1-dd967466a273@intel.com>
 <e03e62e2-54fa-b0ce-0b58-5db7393f8e3c@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <bfb7f080-6f0a-743f-654b-54f41443e44a@intel.com>
Date: Tue, 7 Feb 2017 10:07:28 -0800
MIME-Version: 1.0
In-Reply-To: <e03e62e2-54fa-b0ce-0b58-5db7393f8e3c@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, dan.j.williams@intel.com

On 01/30/2017 08:36 PM, Anshuman Khandual wrote:
> On 01/30/2017 11:24 PM, Dave Hansen wrote:
>> On 01/29/2017 07:35 PM, Anshuman Khandual wrote:
>>> +		if ((new_pol->mode == MPOL_BIND)
>>> +			&& nodemask_has_cdm(new_pol->v.nodes))
>>> +			set_vm_cdm(vma);
>> So, if you did:
>>
>> 	mbind(addr, PAGE_SIZE, MPOL_BIND, all_nodes, ...);
>> 	mbind(addr, PAGE_SIZE, MPOL_BIND, one_non_cdm_node, ...);
>>
>> You end up with a VMA that can never have KSM done on it, etc...  Even
>> though there's no good reason for it.  I guess /proc/$pid/smaps might be
>> able to help us figure out what was going on here, but that still seems
>> like an awful lot of damage.
> 
> Agreed, this VMA should not remain tagged after the second call. It does
> not make sense. For this kind of scenarios we can re-evaluate the VMA
> tag every time the nodemask change is attempted. But if we are looking for
> some runtime re-evaluation then we need to steal some cycles are during
> general VMA processing opportunity points like merging and split to do
> the necessary re-evaluation. Should do we do these kind two kinds of
> re-evaluation to be more optimal ?

I'm still unconvinced that you *need* detection like this.  Scanning big
VMAs is going to be really painful.

I thought I asked before but I can't find it in this thread.  But, we
have explicit interfaces for disabling KSM and khugepaged.  Why do we
need implicit ones like this in addition to those?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
