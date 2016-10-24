Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CAD566B0262
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 15:36:12 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n18so20929603pfe.7
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 12:36:12 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id k17si784873pgh.279.2016.10.24.12.36.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 24 Oct 2016 12:36:12 -0700 (PDT)
Subject: Re: [RFC 0/8] Define coherent device memory node
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <580E4D2D.2070408@intel.com>
 <6f96676c-c1cb-c08b-1dea-8d6e6c6c3c68@nvidia.com>
From: Dave Hansen <dave.hansen@intel.com>
Message-ID: <580E62AB.8040303@intel.com>
Date: Mon, 24 Oct 2016 12:36:11 -0700
MIME-Version: 1.0
In-Reply-To: <6f96676c-c1cb-c08b-1dea-8d6e6c6c3c68@nvidia.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Nellans <dnellans@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

On 10/24/2016 11:32 AM, David Nellans wrote:
> On 10/24/2016 01:04 PM, Dave Hansen wrote:
>> If you *really* don't want a "cdm" page to be migrated, then why isn't
>> that policy set on the VMA in the first place?  That would keep "cdm"
>> pages from being made non-cdm.  And, why would autonuma ever make a
>> non-cdm page and migrate it in to cdm?  There will be no NUMA access
>> faults caused by the devices that are fed to autonuma.
>>
> Pages are desired to be migrateable, both into (starting cpu zone
> movable->cdm) and out of (starting cdm->cpu zone movable) but only
> through explicit migration, not via autonuma.

OK, and is there a reason that the existing mbind code plus NUMA
policies fails to give you this behavior?

Does autonuma somehow override strict NUMA binding?

>  other pages in the same
> VMA should still be migrateable between CPU nodes via autonuma however.

That's not the way the implementation here works, as I understand it.
See the VM_CDM patch and my responses to it.

> Its expected a lot of these allocations are going to end up in THPs. 
> I'm not sure we need to explicitly disallow hugetlbfs support but the
> identified use case is definitely via THPs not tlbfs.

I think THP and hugetlbfs are implementations, not use cases. :)

Is it too hard to support hugetlbfs that we should complicate its code
to exclude it from this type of memory?  Why?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
