Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 41A2D6B026F
	for <linux-mm@kvack.org>; Tue, 25 Oct 2016 16:01:44 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id gg9so30306546pac.6
        for <linux-mm@kvack.org>; Tue, 25 Oct 2016 13:01:44 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id i84si22338875pfi.299.2016.10.25.13.01.42
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 25 Oct 2016 13:01:43 -0700 (PDT)
Subject: Re: [RFC 5/8] mm: Add new flag VM_CDM for coherent device memory
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <1477283517-2504-6-git-send-email-khandual@linux.vnet.ibm.com>
 <580E4704.1040104@intel.com> <87pomojkvu.fsf@linux.vnet.ibm.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580FBA19.9050504@intel.com>
Date: Tue, 25 Oct 2016 13:01:29 -0700
MIME-Version: 1.0
In-Reply-To: <87pomojkvu.fsf@linux.vnet.ibm.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, bsingharora@gmail.com

On 10/25/2016 12:20 PM, Aneesh Kumar K.V wrote:
> Dave Hansen <dave.hansen@intel.com> writes:
>> On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
>>> VMAs containing coherent device memory should be marked with VM_CDM. These
>>> VMAs need to be identified in various core kernel paths and this new flag
>>> will help in this regard.
>>
>> ... and it's sticky?  So if a VMA *ever* has one of these funky pages in
>> it, it's stuck being VM_CDM forever?  Never to be merged with other
>> VMAs?  Never to see the light of autonuma ever again?
>>
>> What if a 100TB VMA has one page of fancy pants device memory, and the
>> rest normal vanilla memory?  Do we really want to consider the whole
>> thing fancy?
> 
> This definitely needs fine tuning. I guess we should look at this as
> possibly stating that, coherent device would like to not participate in
> auto numa balancing
...

Right, in this one, particular case you don't want NUMA balancing.  But,
if you have to take an _explicit_ action to even get access to this
coherent memory (setting a NUMA policy), why keeps that explicit action
from also explicitly disabling NUMA migration?

I really don't think we should tie together the isolation aspect with
anything else, including NUMA balancing.

For instance, on x86, we have the ability for devices to grok the CPU's
page tables, including doing faults.  There's very little to stop us
from doing things like autonuma.

> One possible option is to use a software pte bit (may be steal
> _PAGE_DEVMAP) and prevent a numa pte setup from change_prot_numa().
> ie, if the pfn backing the pte is from coherent device we don't allow
> that to be converted to a prot none pte for numa faults ?

Why would you need to tag individual pages, especially if the VMA has a
policy set on it that disallows migration?

But, even if you did need to identify individual pages from the PTE, you
can easily do:

	page_to_nid(pfn_to_page(pte_pfn(pte)))

and then tell if the node is a fancy-pants device node.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
