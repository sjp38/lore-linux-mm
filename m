Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 60CDD6B026A
	for <linux-mm@kvack.org>; Mon, 24 Oct 2016 14:32:12 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id s7so3488695pal.1
        for <linux-mm@kvack.org>; Mon, 24 Oct 2016 11:32:12 -0700 (PDT)
Received: from hqemgate16.nvidia.com (hqemgate16.nvidia.com. [216.228.121.65])
        by mx.google.com with ESMTPS id d76si14120588pfl.192.2016.10.24.11.32.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Oct 2016 11:32:11 -0700 (PDT)
Subject: Re: [RFC 0/8] Define coherent device memory node
References: <1477283517-2504-1-git-send-email-khandual@linux.vnet.ibm.com>
 <580E4D2D.2070408@intel.com>
From: David Nellans <dnellans@nvidia.com>
Message-ID: <6f96676c-c1cb-c08b-1dea-8d6e6c6c3c68@nvidia.com>
Date: Mon, 24 Oct 2016 13:32:09 -0500
MIME-Version: 1.0
In-Reply-To: <580E4D2D.2070408@intel.com>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: mhocko@suse.com, js1304@gmail.com, vbabka@suse.cz, mgorman@suse.de, minchan@kernel.org, akpm@linux-foundation.org, aneesh.kumar@linux.vnet.ibm.com, bsingharora@gmail.com

On 10/24/2016 01:04 PM, Dave Hansen wrote:

> On 10/23/2016 09:31 PM, Anshuman Khandual wrote:
>> 	To achieve seamless integration  between system RAM and coherent
>> device memory it must be able to utilize core memory kernel features like
>> anon mapping, file mapping, page cache, driver managed pages, HW poisoning,
>> migrations, reclaim, compaction, etc.
> So, you need to support all these things, but not autonuma or hugetlbfs?
>   What's the reasoning behind that?
>
> If you *really* don't want a "cdm" page to be migrated, then why isn't
> that policy set on the VMA in the first place?  That would keep "cdm"
> pages from being made non-cdm.  And, why would autonuma ever make a
> non-cdm page and migrate it in to cdm?  There will be no NUMA access
> faults caused by the devices that are fed to autonuma.
>
Pages are desired to be migrateable, both into (starting cpu zone 
movable->cdm) and out of (starting cdm->cpu zone movable) but only 
through explicit migration, not via autonuma.  other pages in the same 
VMA should still be migrateable between CPU nodes via autonuma however.

Its expected a lot of these allocations are going to end up in THPs.  
I'm not sure we need to explicitly disallow hugetlbfs support but the 
identified use case is definitely via THPs not tlbfs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
