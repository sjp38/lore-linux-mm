Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 817F66B0253
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 03:17:46 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id 128so137717330pfz.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:17:46 -0700 (PDT)
Received: from mail-pf0-x241.google.com (mail-pf0-x241.google.com. [2607:f8b0:400e:c00::241])
        by mx.google.com with ESMTPS id m6si8614104pgc.41.2016.10.25.00.17.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Oct 2016 00:17:45 -0700 (PDT)
Received: by mail-pf0-x241.google.com with SMTP id 128so18785790pfz.1
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 00:17:45 -0700 (PDT)
Subject: Re: [RFC 3/8] mm: Isolate coherent device memory nodes from HugeTLB
 allocation paths
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-4-git-send-email-khandual@linux.vnet.ibm.com>
 <580E41F0.20601@intel.com> <87d1ipawsm.fsf@linux.vnet.ibm.com>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <5f9f43c1-115f-e3fe-fca2-37e6c1eed73f@gmail.com>
Date: Tue, 25 Oct 2016 18:17:26 +1100
MIME-Version: 1.0
In-Reply-To: <87d1ipawsm.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org



On 25/10/16 15:15, Aneesh Kumar K.V wrote:
> Dave Hansen <dave.hansen@intel.com> writes:
> 
>> On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
>>> This change is part of the isolation requiring coherent device memory nodes
>>> implementation.
>>>
>>> Isolation seeking coherent device memory node requires allocation isolation
>>> from implicit memory allocations from user space. Towards that effect, the
>>> memory should not be used for generic HugeTLB page pool allocations. This
>>> modifies relevant functions to skip all coherent memory nodes present on
>>> the system during allocation, freeing and auditing for HugeTLB pages.
>>
>> This seems really fragile.  You had to hit, what, 18 call sites?  What
>> are the odds that this is going to stay working?
> 
> 
> I guess a better approach is to introduce new node_states entry such
> that we have one that excludes coherent device memory numa nodes. One
> possibility is to add N_SYSTEM_MEMORY and N_MEMORY.
> 
> Current N_MEMORY becomes N_SYSTEM_MEMORY and N_MEMORY includes
> system and device/any other memory which is coherent.
> 

I thought of this as well, but I would rather see N_COHERENT_MEMORY
as a flag. The idea being that some device memory is a part of
N_MEMORY, but N_COHERENT_MEMORY gives it additional attributes

> All the isolation can then be achieved based on the nodemask_t used for
> allocation. So for allocations we want to avoid from coherent device we
> use N_SYSTEM_MEMORY mask or a derivative of that and where we are ok to
> allocate from CDM with fallbacks we use N_MEMORY.
> 

I suspect its going to be easier to exclude N_COHERENT_MEMORY.

> All nodes zonelist will have zones from the coherent device nodes but we
> will not end up allocating from coherent device node zone due to the
> node mask used.
> 
> 
> This will also make sure we end up allocating from the correct coherent
> device numa node in the presence of multiple of them based on the
> distance of the coherent device node from the current executing numa
> node.
> 

The idea is good overall, but I think its going to be good to document
the exclusions with the flags

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
