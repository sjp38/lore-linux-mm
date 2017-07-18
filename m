Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9C32E6B02B4
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 11:38:24 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id q66so10612148qki.1
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 08:38:24 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b24si2533798qkb.222.2017.07.18.08.38.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 08:38:20 -0700 (PDT)
Date: Tue, 18 Jul 2017 11:38:16 -0400
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 0/6] Cache coherent device memory (CDM) with HMM v5
Message-ID: <20170718153816.GA3135@redhat.com>
References: <20170713211532.970-1-jglisse@redhat.com>
 <2d534afc-28c5-4c81-c452-7e4c013ab4d0@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <2d534afc-28c5-4c81-c452-7e4c013ab4d0@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <liubo95@huawei.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, John Hubbard <jhubbard@nvidia.com>, David Nellans <dnellans@nvidia.com>, Dan Williams <dan.j.williams@intel.com>, Balbir Singh <bsingharora@gmail.com>, Michal Hocko <mhocko@kernel.org>

On Tue, Jul 18, 2017 at 11:26:51AM +0800, Bob Liu wrote:
> On 2017/7/14 5:15, Jerome Glisse wrote:
> > Sorry i made horrible mistake on names in v4, i completly miss-
> > understood the suggestion. So here i repost with proper naming.
> > This is the only change since v3. Again sorry about the noise
> > with v4.
> > 
> > Changes since v4:
> >   - s/DEVICE_HOST/DEVICE_PUBLIC
> > 
> > Git tree:
> > https://cgit.freedesktop.org/~glisse/linux/log/?h=hmm-cdm-v5
> > 
> > 
> > Cache coherent device memory apply to architecture with system bus
> > like CAPI or CCIX. Device connected to such system bus can expose
> > their memory to the system and allow cache coherent access to it
> > from the CPU.
> > 
> > Even if for all intent and purposes device memory behave like regular
> > memory, we still want to manage it in isolation from regular memory.
> > Several reasons for that, first and foremost this memory is less
> > reliable than regular memory if the device hangs because of invalid
> > commands we can loose access to device memory. Second CPU access to
> > this memory is expected to be slower than to regular memory. Third
> > having random memory into device means that some of the bus bandwith
> > wouldn't be available to the device but would be use by CPU access.
> > 
> > This is why we want to manage such memory in isolation from regular
> > memory. Kernel should not try to use this memory even as last resort
> > when running out of memory, at least for now.
> >
> 
> I think set a very large node distance for "Cache Coherent Device Memory"
> may be a easier way to address these concerns.

Such approach was discuss at length in the past see links below. Outcome
of discussion:
  - CPU less node are bad
  - device memory can be unreliable (device hang) no way for application
    to understand that
  - application and driver NUMA madvise/mbind/mempolicy ... can conflict
    with each other and no way the kernel can figure out which should
    apply
  - NUMA as it is now would not work as we need further isolation that
    what a large node distance would provide

Probably few others argument i forget.

https://lists.gt.net/linux/kernel/2551369
https://groups.google.com/forum/#!topic/linux.kernel/Za_e8C3XnRs%5B1-25%5D
https://lwn.net/Articles/720380/

Cheers,
Jerome

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
