Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 971896B025F
	for <linux-mm@kvack.org>; Thu, 20 Jul 2017 21:41:11 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id q1so16666438qkb.3
        for <linux-mm@kvack.org>; Thu, 20 Jul 2017 18:41:11 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k63si772261qtd.57.2017.07.20.18.41.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 20 Jul 2017 18:41:10 -0700 (PDT)
Date: Thu, 20 Jul 2017 21:41:06 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Message-ID: <20170721014106.GB25991@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com>
 <2d534afc-28c5-4c81-c452-7e4c013ab4d0@huawei.com>
 <20170718153816.GA3135@redhat.com>
 <b6f9d812-a1f5-d647-0a6a-39a08023c3b4@huawei.com>
 <20170719022537.GA6911@redhat.com>
 <f571a0a5-69ff-10b7-d612-353e53ba16fd@huawei.com>
 <20170720150305.GA2767@redhat.com>
 <ab3e67d5-5ed5-816f-6f8e-3228866be1fe@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <ab3e67d5-5ed5-816f-6f8e-3228866be1fe@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Fri, Jul 21, 2017 at 09:15:29AM +0800, Bob Liu wrote:
> On 2017/7/20 23:03, Jerome Glisse wrote:
> > On Wed, Jul 19, 2017 at 05:09:04PM +0800, Bob Liu wrote:
> >> On 2017/7/19 10:25, Jerome Glisse wrote:
> >>> On Wed, Jul 19, 2017 at 09:46:10AM +0800, Bob Liu wrote:
> >>>> On 2017/7/18 23:38, Jerome Glisse wrote:
> >>>>> On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
> >>>>>> On 2017/7/14 5:15, Jerome Glisse wrote:

[...]

> >> Then it's more like replace the numa node solution(CDM) with ZONE_DEVICE
> >> (type MEMORY_DEVICE_PUBLIC). But the problem is the same, e.g how to make
> >> sure the device memory say HBM won't be occupied by normal CPU allocation.
> >> Things will be more complex if there are multi GPU connected by nvlink
> >> (also cache coherent) in a system, each GPU has their own HBM.
> >>
> >> How to decide allocate physical memory from local HBM/DDR or remote HBM/
> >> DDR? 
> >>
> >> If using numa(CDM) approach there are NUMA mempolicy and autonuma mechanism
> >> at least.
> > 
> > NUMA is not as easy as you think. First like i said we want the device
> > memory to be isolated from most existing mm mechanism. Because memory
> > is unreliable and also because device might need to be able to evict
> > memory to make contiguous physical memory allocation for graphics.
> > 
> 
> Right, but we need isolation any way.
> For hmm-cdm, the isolation is not adding device memory to lru list, and many
> if (is_device_public_page(page)) ...
> 
> But how to evict device memory?

What you mean by evict ? Device driver can evict whenever they see the need
to do so. CPU page fault will evict too. Process exit or munmap() will free
the device memory.

Are you refering to evict in the sense of memory reclaim under pressure ?

So the way it flows for memory pressure is that if device driver want to
make room it can evict stuff to system memory and if there is not enough
system memory than thing get reclaim as usual before device driver can
make progress on device memory reclaim.


> > Second device driver are not integrated that closely within mm and the
> > scheduler kernel code to allow to efficiently plug in device access
> > notification to page (ie to update struct page so that numa worker
> > thread can migrate memory base on accurate informations).
> > 
> > Third it can be hard to decide who win between CPU and device access
> > when it comes to updating thing like last CPU id.
> > 
> > Fourth there is no such thing like device id ie equivalent of CPU id.
> > If we were to add something the CPU id field in flags of struct page
> > would not be big enough so this can have repercusion on struct page
> > size. This is not an easy sell.
> > 
> > They are other issues i can't think of right now. I think for now it
> 
> My opinion is most of the issues are the same no matter use CDM or HMM-CDM.
> I just care about a more complete solution no matter CDM,HMM-CDM or other ways.
> HMM or HMM-CDM depends on device driver, but haven't see a public/full driver to 
> demonstrate the whole solution works fine.

I am working with NVidia close source driver team to make sure that it works
well for them. I am also working on nouveau open source driver for same NVidia
hardware thought it will be of less use as what is missing there is a solid
open source userspace to leverage this. Nonetheless open source driver are in
the work.

The way i see it is start with HMM-CDM which isolate most of the changes in
hmm code. Once we get more experience with real workload and not with device
driver test suite then we can start revisiting NUMA and deeper integration
with the linux kernel. I rather grow organicaly toward that than trying to
design something that would make major changes all over the kernel without
knowing for sure that we are going in the right direction. I hope that this
make sense to others too.

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
