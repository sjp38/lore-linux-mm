Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id 661656B0390
	for <linux-mm@kvack.org>; Thu, 20 Apr 2017 17:27:14 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id x23so21954083uax.20
        for <linux-mm@kvack.org>; Thu, 20 Apr 2017 14:27:14 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id p25si3211666uac.210.2017.04.20.14.27.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 20 Apr 2017 14:27:11 -0700 (PDT)
Message-ID: <1492723609.25766.152.camel@kernel.crashing.org>
Subject: Re: [RFC 0/4] RFC - Coherent Device Memory (Not for inclusion)
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Fri, 21 Apr 2017 07:26:49 +1000
In-Reply-To: <alpine.DEB.2.20.1704201025360.26403@east.gentwo.org>
References: <20170419075242.29929-1-bsingharora@gmail.com>
	 <alpine.DEB.2.20.1704191355280.9478@east.gentwo.org>
	 <1492651508.1015.2.camel@gmail.com>
	 <alpine.DEB.2.20.1704201025360.26403@east.gentwo.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>, Balbir Singh <bsingharora@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, khandual@linux.vnet.ibm.com, aneesh.kumar@linux.vnet.ibm.com, paulmck@linux.vnet.ibm.com, srikar@linux.vnet.ibm.com, haren@linux.vnet.ibm.com, jglisse@redhat.com, mgorman@techsingularity.net, mhocko@kernel.org, arbab@linux.vnet.ibm.com, vbabka@suse.cz

On Thu, 2017-04-20 at 10:29 -0500, Christoph Lameter wrote:
> On Thu, 20 Apr 2017, Balbir Singh wrote:
> > Couple of things are needed
> > 
> > 1. Isolation of allocation
> 
> cgroups, memory policy and cpuset provide that

Can these be configured appropriately by the accelerator or GPU driver
at the point where it hot plugs the memory ?

The problem is we need to ensure there is no window in which the kernel
will start putting things like skb's etc... in there.

My original idea was to cover the whole thing with a CMA, which helps
with the case where the user wants to use the "legacy" APIs of manually
controlling the allocations on the GPU since in that case, the
user/driver might need to do fairly large contiguous allocations.

I was told there are some plumbing issues with having a bunch of CMAs
around though.

Basically the whole debate at the moment revolves around whether to use
HMM/CDM/ZONE_DEVICE vs. making it just a NUMA nodes with a sprinkle of
added foo.

The former approach pretty clearly puts that device into a separate
category and keeps most of the VM stuff at bay. However, it has a
number of disadvantage. ZONE_DEVICE was meant for providing struct
pages & DAX etc... for things like flash storage, "new memory" etc....

What we have here is effectively a bit more like a NUMA node, whose
processing unit is just not a CPU but a GPU or some kind of
accelerator.

The difference boils down to how we want to use is. We want any page,
anonymous memory, mapped file, you name it... to be able to migrate
back and forth depending on which piece of HW is most actively
accessing it. This is helped by a bunch of things such as very fast DMA
engines to facilitate migration, and HW counter to detect when parts of
that memory are accessed "remotely" (and thus request migrations).

So the NUMA model fits reasonably well, with that memory being overall
treated normally. The ZONE_DEVICE model on the other hand creates those
"special" pages which require a pile of special casing in all sort of
places as Balbir has mentioned, with still a bunch of rather standard
stuff not working with them.

However, we do need to address a few quirks, which is what this is
about.

Mostly we want to keep kernel allocations away from it, in part because
the memory is more prone to fail and not terribly fast for direct CPU
access, in part because we want to maximize the availability of it for
dedicated applications.

I find it clumsy to require establishing policies from userspace after
it's been instanciated (and racy). At least for that isolation
mechanism.

Other things are possibly more realistic to do that way, such as taking
KSM and AutoNuma off the picture for it.

Cheers,
Ben.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
