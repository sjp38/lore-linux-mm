Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 459866B0003
	for <linux-mm@kvack.org>; Fri,  2 Feb 2018 05:47:37 -0500 (EST)
Received: by mail-qt0-f199.google.com with SMTP id a21so19085953qtd.6
        for <linux-mm@kvack.org>; Fri, 02 Feb 2018 02:47:37 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id w19si1869531qtb.132.2018.02.02.02.47.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Feb 2018 02:47:36 -0800 (PST)
Received: from pps.filterd (m0098421.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id w12Ahwrm122291
	for <linux-mm@kvack.org>; Fri, 2 Feb 2018 05:47:35 -0500
Received: from e06smtp14.uk.ibm.com (e06smtp14.uk.ibm.com [195.75.94.110])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2fvm79x814-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Fri, 02 Feb 2018 05:47:35 -0500
Received: from localhost
	by e06smtp14.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <khandual@linux.vnet.ibm.com>;
	Fri, 2 Feb 2018 10:47:33 -0000
Subject: Re: [LSF/MM ATTEND] Requests to attend MM Summit 2018
References: <3cf31aa1-6886-a01c-57ff-143c165a74e3@linux.vnet.ibm.com>
 <20180129131428.GA21853@dhcp22.suse.cz>
From: Anshuman Khandual <khandual@linux.vnet.ibm.com>
Date: Fri, 2 Feb 2018 16:17:26 +0530
MIME-Version: 1.0
In-Reply-To: <20180129131428.GA21853@dhcp22.suse.cz>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Message-Id: <47abe3f0-fdc1-1ad9-b0e5-76b8c6ca9ce8@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Anshuman Khandual <khandual@linux.vnet.ibm.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>, Laura Abbott <labbott@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, John Hubbard <jhubbard@nvidia.com>, Jerome Glisse <jglisse@redhat.com>

On 01/29/2018 06:44 PM, Michal Hocko wrote:
> On Sun 28-01-18 18:22:01, Anshuman Khandual wrote:
> [...]
>> 1. Supporting hotplug memory as a CMA region
>>
>> There are situations where a platform identified specific PFN range
>> can only be used for some low level debug/tracing purpose. The same
>> PFN range must be shared between multiple guests on a need basis,
>> hence its logical to expect the range to be hot add/removable in
>> each guest. But once available and online in the guest, it would
>> require a sort of guarantee of a large order allocation (almost the
>> entire range) into the memory to use it for aforesaid purpose.
>> Plugging the memory as ZONE_MOVABLE with MIGRATE_CMA makes sense in
>> this scenario but its not supported at the moment.
> 
> Isn't Joonsoo's[1] work doing exactly this?
> 
> [1] http://lkml.kernel.org/r/1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com
> 
> Anyway, declaring CMA regions to the hotplugable memory sounds like a
> misconfiguration. Unless I've missed anything CMA memory is not
> migratable and it is far from trivial to change that.

Right, its far from trivial but I think worth considering given
the benefit of being able to allocate large contig range on it.
 
> 
>> This basically extends the idea of relaxing CMA reservation and
>> declaration restrictions as pointed by Mike Kravetz.
>>
>> 2. Adding NUMA
>>
>> Adding NUMA tracking information to individual CMA areas and use it
>> for alloc_cma() interface. In POWER8 KVM implementation, guest HPT
>> (Hash Page Table) is allocated from a predefined CMA region. NUMA
>> aligned allocation for HPT for any given guest VM can help improve
>> performance.
> 
> With CMA using ZONE_MOVABLE this should be rather straightforward. We
> just need a way to distribute CMA regions over nodes and make the core
> CMA allocator to fallback between nodes in a the nodlist order.

Right, something like that.

>  
>> 3. Reducing CMA allocation failures
>>
>> CMA allocation failures are primarily because of not being unable to
>> isolate or migrate the given PFN range (Inside alloc_contig_range).
>> Is there a way to reduce the failure chances ?
>>
>> D. MAP_CONTIG (Mike Kravetz, Laura Abbott, Michal Hocko)
>>
>> I understand that a recent RFC from Mike Kravetz got debated but without
>> any conclusion about the viability to add MAP_CONTIG option for the user
>> space to request large contiguous physical memory.
> 
> The conclusion was pretty clear AFAIR. Our allocator simply cannot
> handle arbitrary sized large allocations so MAP_CONTIG is really hard to
> provide to the userspace. If there are drivers (RDMA I suspect) which
> would benefit from large allocations then they should use a custom mmap
> implementation which preallocates the memory.

Looking at the previous discussions (https://lkml.org/lkml/2017/10/3/992)
seems like though we have some concerns about this kind of feature which
makes future compaction hence kernel ability to alloc higher order pages
difficult, as pointed out by other folks, I would still believe that this
is something worth considering in long term (obviously after addressing
some of the concerns raised).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
