Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f50.google.com (mail-vn0-f50.google.com [209.85.216.50])
	by kanga.kvack.org (Postfix) with ESMTP id 1078F900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 20:36:28 -0400 (EDT)
Received: by vnbg1 with SMTP id g1so34281442vnb.2
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 17:36:27 -0700 (PDT)
Received: from gate.crashing.org (gate.crashing.org. [63.228.1.57])
        by mx.google.com with ESMTPS id j6si3488008vdi.79.2015.04.21.17.36.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 17:36:25 -0700 (PDT)
Message-ID: <1429662969.27410.68.camel@kernel.crashing.org>
Subject: Re: Interacting with coherent memory on external devices
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Date: Wed, 22 Apr 2015 10:36:09 +1000
In-Reply-To: <20150421234606.GA6046@gmail.com>
References: <20150421214445.GA29093@linux.vnet.ibm.com>
	 <20150421234606.GA6046@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jglisse@redhat.com, mgorman@suse.de, aarcange@redhat.com, riel@redhat.com, airlied@redhat.com, aneesh.kumar@linux.vnet.ibm.com, Cameron Buschardt <cabuschardt@nvidia.com>, Mark Hairgrove <mhairgrove@nvidia.com>, Geoffrey Gerfin <ggerfin@nvidia.com>, John McKenna <jmckenna@nvidia.com>, akpm@linux-foundation.org

On Tue, 2015-04-21 at 19:46 -0400, Jerome Glisse wrote:
> On Tue, Apr 21, 2015 at 02:44:45PM -0700, Paul E. McKenney wrote:
> > Hello!
> > 
> > We have some interest in hardware on devices that is cache-coherent
> > with main memory, and in migrating memory between host memory and
> > device memory.  We believe that we might not be the only ones looking
> > ahead to hardware like this, so please see below for a draft of some
> > approaches that we have been thinking of.
> > 
> > Thoughts?
> 
> I have posted several time a patchset just for doing that, i am sure
> Ben did see it. Search for HMM. I am about to repost it in next couple
> weeks.

Actually no :-) This is not at all HMM realm.

HMM deals with non-cachable (MMIO) device memory that isn't represented
by struct page and separate MMUs that allow pages to be selectively
unmapped from CPU vs. device.

This proposal is about a very different type of device where the device
memory is fully cachable from a CPU standpoint, and thus can be
represented by struct page, and the device has an MMU that is completely
shared with the CPU, ie, the device operates within a given context of
the system and if a page is marked read-only or inaccessible, this will
be true on both the CPU and the device.

Note: IBM is also interested in HMM for devices that don't qualify with
the above such as some GPUs or NICs, but this is something *else*.

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
