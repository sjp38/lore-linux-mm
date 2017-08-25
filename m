Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8A1126810C8
	for <linux-mm@kvack.org>; Fri, 25 Aug 2017 15:44:32 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id n83so496100oig.0
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 12:44:32 -0700 (PDT)
Received: from mail-oi0-x236.google.com (mail-oi0-x236.google.com. [2607:f8b0:4003:c06::236])
        by mx.google.com with ESMTPS id r64si5946182oih.550.2017.08.25.12.44.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Aug 2017 12:44:30 -0700 (PDT)
Received: by mail-oi0-x236.google.com with SMTP id r203so3341360oih.0
        for <linux-mm@kvack.org>; Fri, 25 Aug 2017 12:44:30 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAPcyv4gWD7sTLdmwoX7Ce+McMvtLKhOf60e-1ax12qQs7=Qzdg@mail.gmail.com>
References: <150353211413.5039.5228914877418362329.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150353212577.5039.14069456126848863439.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170824161347.GC27591@lst.de> <CAPcyv4gWD7sTLdmwoX7Ce+McMvtLKhOf60e-1ax12qQs7=Qzdg@mail.gmail.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 25 Aug 2017 12:44:29 -0700
Message-ID: <CAPcyv4iT+7M6NwzE0WDZLZVjDYRr1Tj0_ug-Bcu9YWDtq13rXg@mail.gmail.com>
Subject: Re: [PATCH v6 2/5] fs, xfs: introduce S_IOMAP_SEALED
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "Darrick J. Wong" <darrick.wong@oracle.com>, Linux API <linux-api@vger.kernel.org>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Dave Chinner <david@fromorbit.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andy Lutomirski <luto@kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>

On Thu, Aug 24, 2017 at 11:00 PM, Dan Williams <dan.j.williams@intel.com> wrote:
> On Thu, Aug 24, 2017 at 9:13 AM, Christoph Hellwig <hch@lst.de> wrote:
>> I'm still very unhappy about the get/set flag state.  What is the
>> reason you can't use/extend leases? (take a look at the fcntl
>> man page and look for Leases).  A variant of the concept is what
>> the pNFS block server uses.
>
> So I think leases could potentially be extended to replace the inode
> flag. A MAP_DIRECT operation would take out a lease that is broken by
> break_layouts(). However, like the pNFS case the lease break would
> need to held off while any DMA might be in-flight. We can use an
> elevated page count as that indication as ZONE_DEVICE pages only ever
> have an elevated page count in response to get_user_pages().
>
> However, I think the only practical difference is turning an immediate
> ETXTBSY response that S_IOMAP_SEALED provides into an indefinite
> blocking wait for break_layouts() to complete. Can pNFS run
> break_layouts() in bounded time?
>
> As far I can see a lease and S_IOMAP_SEALED have the same DMA
> cancelling problem, so a lease is not better in that regard. Absent an
> overlaying protocol like pNFS, I think S_IOMAP_SEALED is cleaner
> because it fails incompatible operations outright rather than stalls
> them in break_layouts(). Were their other benefits to a lease over an
> inode flag that you had in mind for this case where the protocol is
> userspace defined? Maybe I'm thinking too small on the ways a lease
> might be extended.

At a minimum I can at least use a new lease type as an indication of
when to bail out an block-map operation with ETXTBSY, and reuse the
lease security model. That way we at least start to converge the
in-kernel lease machinery for pinning blocks with this userspace
mechanism.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
