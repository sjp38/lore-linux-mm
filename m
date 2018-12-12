Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 51EF08E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 18:46:17 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id y2so142845plr.8
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 15:46:17 -0800 (PST)
Received: from hqemgate15.nvidia.com (hqemgate15.nvidia.com. [216.228.121.64])
        by mx.google.com with ESMTPS id b61si180565plb.70.2018.12.12.15.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Dec 2018 15:46:16 -0800 (PST)
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
References: <7b4733be-13d3-c790-ff1b-ac51b505e9a6@nvidia.com>
 <20181207191620.GD3293@redhat.com>
 <3c4d46c0-aced-f96f-1bf3-725d02f11b60@nvidia.com>
 <20181208022445.GA7024@redhat.com> <20181210102846.GC29289@quack2.suse.cz>
 <20181212150319.GA3432@redhat.com>
 <CAPcyv4go0Xzhz8rXdfscWuXDu83BO9v8WD4upDUJWb7gKzX5OQ@mail.gmail.com>
 <20181212213005.GE5037@redhat.com>
 <CAPcyv4gJHeFjEgna1S-2uE4KxkSUgkc=e=2E5oqfoirec84C-w@mail.gmail.com>
 <20181212215348.GF5037@redhat.com> <20181212233703.GB2947@ziepe.ca>
From: John Hubbard <jhubbard@nvidia.com>
Message-ID: <63a551ce-c314-db75-f6d3-c92e39655f79@nvidia.com>
Date: Wed, 12 Dec 2018 15:46:14 -0800
MIME-Version: 1.0
In-Reply-To: <20181212233703.GB2947@ziepe.ca>
Content-Type: text/plain; charset="utf-8"
Content-Language: en-US-large
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgg@ziepe.ca>, Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, "Weiny, Ira" <ira.weiny@intel.com>

On 12/12/18 3:37 PM, Jason Gunthorpe wrote:
> On Wed, Dec 12, 2018 at 04:53:49PM -0500, Jerome Glisse wrote:
>>> Almost, we need some safety around assuming that DMA is complete the
>>> page, so the notification would need to go all to way to userspace
>>> with something like a file lease notification. It would also need to
>>> be backstopped by an IOMMU in the case where the hardware does not /
>>> can not stop in-flight DMA.
>>
>> You can always reprogram the hardware right away it will redirect
>> any dma to the crappy page.
> 
> That causes silent data corruption for RDMA users - we can't do that.
> 
> The only way out for current hardware is to forcibly terminate the
> RDMA activity somehow (and I'm not even sure this is possible, at
> least it would be driver specific)
> 
> Even the IOMMU idea probably doesn't work, I doubt all current
> hardware can handle a PCI-E error TLP properly. 

Very true.

> 
> On some hardware it probably just protects DAX by causing data
> corruption for RDMA - I fail to see how that is a win for system
> stability if the user obviously wants to use DAX and RDMA together...
> 
> I think your approach with ODP only is the only one that meets your
> requirements, the only other data-integrity-preserving approach is to
> block/fail ftruncate/etc.
> 
>> From my point of view driver should listen to ftruncate before the
>> mmu notifier kicks in and send event to userspace and maybe wait
>> and block ftruncate (or move it to a worker thread).
> 
> We can do this, but we can't guarantee forward progress in userspace
> and the best way we have to cancel that is portable to all RDMA
> hardware is to kill the process(es)..
> 
> So if that is acceptable then we could use user notifiers and allow
> non-ODP users...
> 

That is exactly the conclusion that some of us in the GPU world reached as
well, when chatting about how this would have to work, even on modern GPU 
hardware that can replay page faults, in many cases. 

I think as long as we specify that the acceptable consequence of doing, say,
umount on a filesystem that has active DMA happening is that the associated
processes get killed, then we're going to be OK.

What would worry me is if there was an expectation that processes could
continue working properly after such a scenario.


thanks,
-- 
John Hubbard
NVIDIA
