Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C0E3F6B0033
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 08:07:32 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id u138so9199732wmu.19
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 05:07:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b47sor2079369wrd.35.2017.10.16.05.07.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 16 Oct 2017 05:07:31 -0700 (PDT)
Subject: Re: [PATCH v9 0/6] MAP_DIRECT for DAX userspace flush
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171012142319.GA11254@lst.de>
 <CAPcyv4gTON__Ohop0B5R2gsKXC71bycTBozqGmF3WmwG9C6LVA@mail.gmail.com>
 <20171013065716.GB26461@lst.de>
 <CAPcyv4gaLBBefOU+8f7_ypYnCTjSMk+9nq8NfCqBHAE+NbUusw@mail.gmail.com>
 <20171013163822.GA17411@obsidianresearch.com>
 <CAPcyv4jDHp8z2VgVfyRK1WwMzixYVQnh54LZoPD57HB3yqSPPQ@mail.gmail.com>
 <20171013173145.GA18702@obsidianresearch.com> <20171016072644.GB28270@lst.de>
From: Sagi Grimberg <sagi@grimberg.me>
Message-ID: <27694a5e-ec3a-0a68-b053-c138e0c91446@grimberg.me>
Date: Mon, 16 Oct 2017 15:07:28 +0300
MIME-Version: 1.0
In-Reply-To: <20171016072644.GB28270@lst.de>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>, Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Jan Kara <jack@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Arnd Bergmann <arnd@arndb.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Linux API <linux-api@vger.kernel.org>, "Darrick J. Wong" <darrick.wong@oracle.com>, Dave Chinner <david@fromorbit.com>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Layton <jlayton@poochiereds.net>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>


>> I don't think that really represents how lots of apps actually use
>> RDMA.
>>
>> RDMA is often buried down in the software stack (eg in a MPI), and by
>> the time a mapping gets used for RDMA transfer the link between the
>> FD, mmap and the MR is totally opaque.
>>
>> Having a MR specific notification means the low level RDMA libraries
>> have a chance to deal with everything for the app.
>>
>> Eg consider a HPC app using MPI that uses some DAX aware library to
>> get DAX backed mmap's. It then passes memory in those mmaps to the
>> MPI library to do transfers. The MPI creates the MR on demand.
>>
> 
> I suspect one of the more interesting use cases might be a file server,
> for which that's not the case.  But otherwise I agree with the above,
> and also thing that notifying the MR handle is the only way to go for
> another very important reason:  fencing.  What if the application/library
> does not react on the notification?  With a per-MR notification we
> can unregister the MR in kernel space and have a rock solid fencing
> mechanism.  And that is the most important bit here.

I agree we must deregister the MR in kernel space. As said, I think
its perfectly reasonable to let user-space see error completions and
provide query mechanism for MR granularity (unfortunately this will
probably need drivers assistance as they know how their device reports
in MR granularity access violations).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
