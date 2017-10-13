Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5AC036B0033
	for <linux-mm@kvack.org>; Fri, 13 Oct 2017 13:01:07 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id j126so6561238oib.2
        for <linux-mm@kvack.org>; Fri, 13 Oct 2017 10:01:07 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id x40sor571598otx.168.2017.10.13.10.01.05
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Oct 2017 10:01:05 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171013163822.GA17411@obsidianresearch.com>
References: <150776922692.9144.16963640112710410217.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171012142319.GA11254@lst.de> <CAPcyv4gTON__Ohop0B5R2gsKXC71bycTBozqGmF3WmwG9C6LVA@mail.gmail.com>
 <20171013065716.GB26461@lst.de> <CAPcyv4gaLBBefOU+8f7_ypYnCTjSMk+9nq8NfCqBHAE+NbUusw@mail.gmail.com>
 <20171013163822.GA17411@obsidianresearch.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 13 Oct 2017 10:01:04 -0700
Message-ID: <CAPcyv4jDHp8z2VgVfyRK1WwMzixYVQnh54LZoPD57HB3yqSPPQ@mail.gmail.com>
Subject: Re: [PATCH v9 0/6] MAP_DIRECT for DAX userspace flush
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Cc: Christoph Hellwig <hch@lst.de>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, linux-xfs@vger.kernel.org, Jan Kara <jack@suse.cz>, Arnd Bergmann <arnd@arndb.de>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, Dave Chinner <david@fromorbit.com>, "J. Bruce Fields" <bfields@fieldses.org>, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Jeff Layton <jlayton@poochiereds.net>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>

On Fri, Oct 13, 2017 at 9:38 AM, Jason Gunthorpe
<jgunthorpe@obsidianresearch.com> wrote:
> On Fri, Oct 13, 2017 at 08:14:55AM -0700, Dan Williams wrote:
>
>> scheme specific to RDMA which seems like a waste to me when we can
>> generically signal an event on the fd for any event that effects any
>> of the vma's on the file. The FL_LAYOUT lease impacts the entire file,
>> so as far as I can see delaying the notification until MR-init is too
>> late, too granular, and too RDMA specific.
>
> But for RDMA a FD is not what we care about - we want the MR handle so
> the app knows which MR needs fixing.

I'd rather put the onus on userspace to remember where it used a
MAP_DIRECT mapping and be aware that all the mappings of that file are
subject to a lease break. Sure, we could build up a pile of kernel
infrastructure to notify on a per-MR basis, but I think that would
only be worth it if leases were range based. As it is, the entire file
is covered by a lease instance and all MRs that might reference that
file get one notification. That said, we can always arrange for a
per-driver callback at lease-break time so that it can do something
above and beyond the default notification.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
