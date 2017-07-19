Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id B62946B02C3
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 22:25:43 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id n43so16796736qtc.13
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 19:25:43 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s69si3722726qka.6.2017.07.18.19.25.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 19:25:42 -0700 (PDT)
Date: Tue, 18 Jul 2017 22:25:38 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Message-ID: <20170719022537.GA6911@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com>
 <2d534afc-28c5-4c81-c452-7e4c013ab4d0@huawei.com>
 <20170718153816.GA3135@redhat.com>
 <b6f9d812-a1f5-d647-0a6a-39a08023c3b4@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <b6f9d812-a1f5-d647-0a6a-39a08023c3b4@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Wed, Jul 19, 2017 at 09:46:10AM +0800, Bob Liu wrote:
> On 2017/7/18 23:38, Jerome Glisse wrote:
> > On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
> >> On 2017/7/14 5:15, Jerome Glisse wrote:
> >>> Sorry i made horrible mistake on names in v4, i completly miss-
> >>> understood the suggestion. So here i repost with proper naming.
> >>> This is the only change since v3. Again sorry about the noise
> >>> with v4.
> >>>
> >>> Changes since v4:
> >>>   - s/DEVICE_HOST/DEVICE_PUBLIC
> >>>
> >>> Git tree:
> >>> https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-cdm-v5
> >>>
> >>>
> >>> Cache coherent device memory apply to architecture with system bus
> >>> like CAPI or CCIX. Device connected to such system bus can expose
> >>> their memory to the system and allow cache coherent access to it
> >>> from the CPU.
> >>>
> >>> Even if for all intent and purposes device memory behave like regular
> >>> memory, we still want to manage it in isolation from regular memory.
> >>> Several reasons for that, first and foremost this memory is less
> >>> reliable than regular memory if the device hangs because of invalid
> >>> commands we can loose access to device memory. Second CPU access to
> >>> this memory is expected to be slower than to regular memory. Third
> >>> having random memory into device means that some of the bus bandwith
> >>> wouldn't be available to the device but would be use by CPU access.
> >>>
> >>> This is why we want to manage such memory in isolation from regular
> >>> memory. Kernel should not try to use this memory even as last resort
> >>> when running out of memory, at least for now.
> >>>
> >>
> >> I think set a very large node distance for "Cache Coherent Device Memory"
> >> may be a easier way to address these concerns.
> > 
> > Such approach was discuss at length in the past see links below. Outcome
> > of discussion:
> >   - CPU less node are bad
> >   - device memory can be unreliable (device hang) no way for application
> >     to understand that
> 
> Device memory can also be more reliable if using high quality and expensive memory.

Even ECC memory does not compensate for device hang. When your GPU lockups
you might need to re-init GPU from scratch after which the content of the
device memory is unreliable. During init the device memory might not get
proper clock or proper refresh cycle and thus is susceptible to corruption.

> 
> >   - application and driver NUMA madvise/mbind/mempolicy ... can conflict
> >     with each other and no way the kernel can figure out which should
> >     apply
> >   - NUMA as it is now would not work as we need further isolation that
> >     what a large node distance would provide
> > 
> 
> Agree, that's where we need spend time on.
> 
> One drawback of HMM-CDM I'm worry about is one more extra copy.
> In the cache coherent case, CPU can write data to device memory
> directly then start fpga/GPU/other accelerators.

There is not necessarily an extra copy. Device driver can pre-allocate
virtual address range of a process with device memory. Device page fault
can directly allocate device memory. Once allocated CPU access will use
the device memory.

There is plan to allow other allocation (CPU page fault, file cache, ...)
to also use device memory directly. We just don't know what kind of
userspace API will fit best for that so at first it might be hidden behind
device driver specific ioctl. 

Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
