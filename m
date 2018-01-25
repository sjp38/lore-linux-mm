Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f197.google.com (mail-ot0-f197.google.com [74.125.82.197])
	by kanga.kvack.org (Postfix) with ESMTP id 06DB0800D8
	for <linux-mm@kvack.org>; Thu, 25 Jan 2018 02:02:19 -0500 (EST)
Received: by mail-ot0-f197.google.com with SMTP id x4so4076652otx.23
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 23:02:19 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x7sor1798221otd.87.2018.01.24.23.02.17
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 24 Jan 2018 23:02:17 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1516852902.3724.4.camel@wdc.com>
References: <CAPcyv4gQNM9RbTbRWKnG6Vby_CW9CJ9EZTARsVNi=9cas7ZR2A@mail.gmail.com>
 <1516852902.3724.4.camel@wdc.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Wed, 24 Jan 2018 23:02:16 -0800
Message-ID: <CAPcyv4iERedTChineSd-9fYR-xOc6E4L-okj7OnCMmoUkMf0tA@mail.gmail.com>
Subject: Re: [LSF/MM TOPIC] Filesystem-DAX, page-pinning, and RDMA
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bart Van Assche <Bart.VanAssche@wdc.com>
Cc: "lsf-pc@lists.linux-foundation.org" <lsf-pc@lists.linux-foundation.org>, "jgg@mellanox.com" <jgg@mellanox.com>, "hch@infradead.org" <hch@infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "mhocko@kernel.org" <mhocko@kernel.org>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>

On Wed, Jan 24, 2018 at 8:01 PM, Bart Van Assche <Bart.VanAssche@wdc.com> wrote:
> On Wed, 2018-01-24 at 19:56 -0800, Dan Williams wrote:
>> The get_user_pages_longterm() api was recently added as a stop-gap
>> measure to prevent applications from growing dependencies on the
>> ability to to pin DAX-mapped filesystem blocks for RDMA indefinitely
>> with no ongoing coordination with the filesystem. This 'longterm'
>> pinning is also problematic for the non-DAX VMA case where the core-mm
>> needs a time bounded way to revoke a pin and manipulate the physical
>> pages. While existing RDMA applications have already grown the
>> assumption that they can pin page-cache pages indefinitely, the fact
>> that we are breaking this assumption for filesystem-dax presents an
>> opportunity to deprecate the 'indefinite pin' mechanisms and move to a
>> general interface that supports pin revocation.
>>
>> While RDMA may grow an explicit Infiniband-verb for this 'memory
>> registration with lease' semantic, it seems that this problem is
>> bigger than just RDMA. At LSF/MM it would be useful to have a
>> discussion between fs, mm, dax, and RDMA folks about addressing this
>> problem at the core level.
>>
>> Particular people that would be useful to have in attendance are
>> Michal Hocko, Christoph Hellwig, and Jason Gunthorpe (cc'd).
>
> Is on demand paging sufficient as a solution for your use case...

No, in 3 dimensions since there is a need to support non-ODP RDMA
hardware, hypervisors want to coordinate DMA for guests, and non-RDMA
hardware also pins memory indefinitely like V4L2. So it's bigger than
RDMA, but that will likely be the first consumer of this 'longterm
pin' mechanism.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
