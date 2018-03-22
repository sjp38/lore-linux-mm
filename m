Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 07E746B0010
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 20:32:57 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id u186so4235386qkc.6
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 17:32:57 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id m15si5529152qtb.416.2018.03.21.17.32.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 21 Mar 2018 17:32:56 -0700 (PDT)
Date: Wed, 21 Mar 2018 20:32:54 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: mm/hmm: a simple question regarding devm_request_mem_region()
Message-ID: <20180322003253.GL3214@redhat.com>
References: <20180321222357.GA31089@Asurada-Nvidia>
 <20180321225632.GI3214@redhat.com>
 <20180322002352.GA12673@Asurada-Nvidia>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180322002352.GA12673@Asurada-Nvidia>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicolin Chen <nicoleotsuka@gmail.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Mar 21, 2018 at 05:23:55PM -0700, Nicolin Chen wrote:
> On Wed, Mar 21, 2018 at 06:56:32PM -0400, Jerome Glisse wrote:
> > On Wed, Mar 21, 2018 at 03:23:57PM -0700, Nicolin Chen wrote:
> > > Hello Jerome,
> > > 
> > > I started to looking at the mm/hmm code and having a question at the
> > > devm_request_mem_region() call in the hmm_devmem_add() implementation:
> > > 
> > > >	addr = min((unsigned long)iomem_resource.end,
> > > >		   (1UL << MAX_PHYSMEM_BITS) - 1);
> > > 
> > > The main question is here as I am a bit confused by this addr. The code
> > > is trying to get an addr from the end of memory space. However, I have
> > > tried on an ARM64 platform where ioport_resource.end is -1, so it takes
> > > "(1UL << MAX_PHYSMEM_BITS) - 1" as the addr base, while this addr is way
> > > beyond the actual main memory size that's available on my board. Is HMM
> > > supposed to get an memory region like this? Would it be possible for you
> > > to give some hint to help me understand it?
> > 
> > What are you trying to do ? hmm_devmem_add() is use either for device
> > private memory or device public memory. Device private memory is memory
> > that is not accessible by the CPU, the code you are pointing to is for
> > that case where i try to find a range of physical address not currently
> > use (memory not being accessible means that there is not any valid
> > physical address reserved for it). On x86 MAX_PHYSMEM_BITS is defined
> > to something that make sense, but as it is often the case for those
> > define, it seems that arm define an unreal value. My advice fix the
> > definition for ARM iirc it depends on the SOC dunno if you can know
> > that at build time. You can probably know the biggest one at build time
> > (1 << 47 or something like that).
> > 
> > But this all assume that you have a device with its own memory that is
> > not accessible from the CPU. Which is very uncommon on ARM, only case
> > i know of is regular PCIE GPU on a ARM system with PCIE.
> 
> I am testing with drivers/char/hmm_dmirror.c from your git repository.
> 
> The addr I got (before "- size") is actually 0x7fffffffff, so equally
> (1 << 40).
> 
> So from your reply, it seems to me that HMM is supposed to request a
> region like it.

The dummy driver by default test the private memory, i had patches to
make it test public memory too somewhere in a branch. So yes this is
expected from the dummy driver. HMM here is trying to get a region that
will not collide with any known existing resources. Idealy we would
like a platform/arch function for that but it is hard to justify it
nor is there a safe way to find such thing either from arch/platform
specific code (there isn't for x86 at least).

For real device driver of pcie devices, the advice is to use the pci
bar region of the device. This way we know for sure we do not collide
with anything (ie use hmm_devmem_add_resource() not hmm_devmem_add()
but this need some code change for res->desc).

Cheers,
Jerome
