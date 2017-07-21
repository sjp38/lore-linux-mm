Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFEEC6B025F
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 11:21:12 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id u12so24024076qkl.13
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 08:21:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id p66si3891251qka.162.2017.07.21.08.21.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 08:21:12 -0700 (PDT)
Date: Fri, 21 Jul 2017 11:21:07 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Message-ID: <20170721152107.GA3202@redhat.com>
References: <2d534afc-28c5-4c81-c452-7e4c013ab4d0@huawei.com>
 <20170718153816.GA3135@redhat.com>
 <b6f9d812-a1f5-d647-0a6a-39a08023c3b4@huawei.com>
 <20170719022537.GA6911@redhat.com>
 <f571a0a5-69ff-10b7-d612-353e53ba16fd@huawei.com>
 <20170720150305.GA2767@redhat.com>
 <ab3e67d5-5ed5-816f-6f8e-3228866be1fe@huawei.com>
 <20170721014106.GB25991@redhat.com>
 <052b3b89-6382-a1b8-270f-3a4e44158964@huawei.com>
 <CAA_GA1du0qd8b8Eq2yVeULo6TxXw2YckABWiwY8RO5N7FB+Z=A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAA_GA1du0qd8b8Eq2yVeULo6TxXw2YckABWiwY8RO5N7FB+Z=A@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: Bob Liu <liubo95@huawei.com>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Fri, Jul 21, 2017 at 08:01:07PM +0800, Bob Liu wrote:
> On Fri, Jul 21, 2017 at 10:10 AM, Bob Liu <liubo95@huawei.com> wrote:
> > On 2017/7/21 9:41, Jerome Glisse wrote:
> >> On Fri, Jul 21, 2017 at 09:15:29AM +0800, Bob Liu wrote:
> >>> On 2017/7/20 23:03, Jerome Glisse wrote:
> >>>> On Wed, Jul 19, 2017 at 05:09:04PM +0800, Bob Liu wrote:
> >>>>> On 2017/7/19 10:25, Jerome Glisse wrote:
> >>>>>> On Wed, Jul 19, 2017 at 09:46:10AM +0800, Bob Liu wrote:
> >>>>>>> On 2017/7/18 23:38, Jerome Glisse wrote:
> >>>>>>>> On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
> >>>>>>>>> On 2017/7/14 5:15, Jerome Glisse wrote:
> >>
> >> [...]
> >>
> >>>>> Then it's more like replace the numa node solution(CDM) with ZONE_DEVICE
> >>>>> (type MEMORY_DEVICE_PUBLIC). But the problem is the same, e.g how to make
> >>>>> sure the device memory say HBM won't be occupied by normal CPU allocation.
> >>>>> Things will be more complex if there are multi GPU connected by nvlink
> >>>>> (also cache coherent) in a system, each GPU has their own HBM.
> >>>>>
> >>>>> How to decide allocate physical memory from local HBM/DDR or remote HBM/
> >>>>> DDR?
> >>>>>
> >>>>> If using numa(CDM) approach there are NUMA mempolicy and autonuma mechanism
> >>>>> at least.
> >>>>
> >>>> NUMA is not as easy as you think. First like i said we want the device
> >>>> memory to be isolated from most existing mm mechanism. Because memory
> >>>> is unreliable and also because device might need to be able to evict
> >>>> memory to make contiguous physical memory allocation for graphics.
> >>>>
> >>>
> >>> Right, but we need isolation any way.
> >>> For hmm-cdm, the isolation is not adding device memory to lru list, and many
> >>> if (is_device_public_page(page)) ...
> >>>
> >>> But how to evict device memory?
> >>
> >> What you mean by evict ? Device driver can evict whenever they see the need
> >> to do so. CPU page fault will evict too. Process exit or munmap() will free
> >> the device memory.
> >>
> >> Are you refering to evict in the sense of memory reclaim under pressure ?
> >>
> >> So the way it flows for memory pressure is that if device driver want to
> >> make room it can evict stuff to system memory and if there is not enough
> >
> > Yes, I mean this.
> > So every driver have to maintain their own LRU-similar list instead of
> > reuse what already in linux kernel.

Regarding LRU it is again not as easy. First we do necessarily have access
information like CPU page table for device page table. Second the mmu_notifier
callback on per page basis is costly. Finaly device are use differently than
CPU, usualy you schedule a job and once that job is done you can safely evict
memory it was using. Existing device driver already have quite large memory
management code of their own because of that different usage model.

LRU might make sense at one point but so far i doubt it is the right solution
for device memory.

> 
> And how HMM-CDM can handle multiple devices or device with multiple
> device memories(may with different properties also)?
> This kind of hardware platform would be very common when CCIX is out soon.

A) Multiple device is under control of device driver. Multiple devices link
to each other through dedicated link can have themself a complex topology and
remote access between device is highly tie to the device (how to program the
device mmu and device registers) and thus to the device driver.

If we identify common design pattern between different hardware then we might
start thinking about factoring out some common code to help those cases.


B) Multiple different device is an harder problem. Each device provide their
own userspace API and that is through that API that you will get memory
placement advise. If several device fight for placement of same chunk of
memory one can argue that the application is broken or device is broken.
But for now we assume that device and application will behave.

Rate limiting migration is hard, you need to keep migration statistics and
that need memory. So unless we really need to do that i would rather avoid
doing that. Again this is a thing for which we will have to wait and see
how thing panout.


Maybe i should stress that HMM is a set of helpers for device memory and it
is not intended to be a policy maker or to manage device memory. Intention
is that device driver will keep managing device memory as they already do
today.

A deeper integration with process memory management is probably bound to
happen but for now it is just about having toolbox for device driver.

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
