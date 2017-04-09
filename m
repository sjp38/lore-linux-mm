Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 523136B0038
	for <linux-mm@kvack.org>; Sat,  8 Apr 2017 20:32:20 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id b10so103300487pgn.8
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 17:32:20 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id s65si9416019pgb.37.2017.04.08.17.32.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Apr 2017 17:32:19 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id g2so21278914pge.2
        for <linux-mm@kvack.org>; Sat, 08 Apr 2017 17:32:18 -0700 (PDT)
Message-ID: <1491697908.7894.3.camel@gmail.com>
Subject: Re: [RFC HMM CDM 0/3] Coherent Device Memory (CDM) on top of HMM
From: Balbir Singh <bsingharora@gmail.com>
Date: Sun, 09 Apr 2017 10:31:48 +1000
In-Reply-To: <1491596933-21669-1-git-send-email-jglisse@redhat.com>
References: <1491596933-21669-1-git-send-email-jglisse@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?ISO-8859-1?Q?J=E9r=F4me?= Glisse <jglisse@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: John Hubbard <jhubbard@nvidia.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Aneesh Kumar <aneesh.kumar@linux.vnet.ibm.com>, "Paul E . McKenney" <paulmck@linux.vnet.ibm.com>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Haren Myneni <haren@linux.vnet.ibm.com>, Dan Williams <dan.j.williams@intel.com>

On Fri, 2017-04-07 at 16:28 -0400, JA(C)rA'me Glisse wrote:
> This patch serie implement coherent device memory using ZONE_DEVICE
> and adds new helper to the HMM framework to support this new kind
> of ZONE_DEVICE memory. This is on top of HMM v19 and you can find a
> branch here:
>A 
> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-cdm
>A 
> It needs more special casing as it behaves differently from regular
> ZONE_DEVICE (persistent memory). Unlike the unaddressable memory
> type added with HMM patchset, the CDM type can be access by CPU.
> Because of this any page can be migrated to CDM memory, private
> anonymous or share memory (file back or not).
>A 
> It is missing some features like allowing to direct device fault to
> directly allocates device memory (intention is to add new fields to
> vm_fault struct for this).
>A 
>A 
> This is mostly un-tested but i am posting now because i believe we
> want to start discussion on design consideration. So this differ from
> the NUMA approach by adding yet a new type to ZONE_DEVICE with more
> special casing. While it is a rather small patchset, i might have
> miss some code-path that might require more special casing (i and
> other need to audit mm to make sure that everytime mm is confronted
> so such page it behaves as we want).
>A 
> So i believe question is do we want to keep on adding new type to
> ZONE_DEVICE and more special casing each of them or is a NUMA like
> approach better ?
>A 
>A 
> My personal belief is that the hierarchy of memory is getting deeper
> (DDR, HBM stack memory, persistent memory, device memory, ...) and
> it may make sense to try to mirror this complexity within mm concept.
> Generalizing the NUMA abstraction is probably the best starting point
> for this. I know there are strong feelings against changing NUMA so
> i believe now is the time to pick a direction.

Thanks for all your hard-work and effort on this.

I agree that NUMA is the best representation and in the we want
the mm to manage coherent memory. The device memory is very similar
to NUMA, it is cache coherent, can be simultaneously accessed from
both sides. Like you say, this will evolve, my current design proposal
is at

https://github.com/bsingharora/linux/commits/balbir/cdmv1

with HMM patches (v17) on top. The relevant commits are
c0750c30070e8537ca2ee3ddfce3c0bac7eaab26
dcb3ff6d7900ff644d08a3d1892b6c0ab6982021
9041c3fee859b40c1f9d3e60fd48e0f64ee69abb
b26b6e9f3b078a606a0eaada08bc187b96d966a5

I intend to rebase and repost them. The core motivation of this approach
compared to Anshuman's approach https://lwn.net/Articles/704403/ is
avoiding allocator changes, there are however mempolicy changes. Creating
N_COHERENT_MEMORY exclusive to N_MEMORY allows us to avoid changes in
the allocator paths, with the changes being controlled by mempolicy, where
an explicit node allocation works via changes to policy_zonelist() and policy_
nodemask(). This also isolates coherent memory from kswapd and other back-
ground processes, but direct reclaim and direct compaction, etc are expected
to work. The reason for isolation is performance to prevent wrong allocations
ending up on device memory, but there is no strict requirements, one could
easily use migrations to migrate misplaced memory.

>From a HMM perspective, we still find HMM useful for migration, specifically
your migrate_vma() API and the new propose migrate_dma() API that is a
part of this patchset. I think for isolation we prefer the NUMA approach.

We do find HMM useful for hardware that does not have
coherency, but for coherent devices we prefer the NUMA approach.

With HMM we'll start seeing ZONE_DEVICE pages mapped into user space and
that would mean a thorough audit of all code paths to make sure we are
ready for such a use case and enabling those use cases, like you've done
with patch 1. I've done a quick evaluation to check for features like
migration (page cache migration), fault handling to the right location
(direct page cache allocation in the coherent memory), mlock handling,
RSS accounting, memcg enforcement for pages not on LRU, etc.

>A 
> Note that i don't think choosing one would mean we will be stuck with
> it, as long as we don't expose anything new (syscall) to userspace
> and hide thing through driver API then we keep our options open to
> change direction latter on.
>

I agree, but I think user space will need to adopt, for example using
malloc on a coherent device will not work, the user space will need to
have a driver supported way of accessing coherent memory.
A 
> Nonetheless we need to make progress on this as they are hardware
> right around the corner and it would be a shame if we could not
> leverage such hardware with linux.
>A 
>

I agree 100%A 

Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
