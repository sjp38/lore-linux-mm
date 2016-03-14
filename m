Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f179.google.com (mail-io0-f179.google.com [209.85.223.179])
	by kanga.kvack.org (Postfix) with ESMTP id DE4046B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 17:57:16 -0400 (EDT)
Received: by mail-io0-f179.google.com with SMTP id m184so1868805iof.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 14:57:16 -0700 (PDT)
Received: from quartz.orcorp.ca (quartz.orcorp.ca. [184.70.90.242])
        by mx.google.com with ESMTPS id d191si11295158ioe.15.2016.03.14.14.57.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 14:57:15 -0700 (PDT)
Date: Mon, 14 Mar 2016 15:57:08 -0600
From: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>
Subject: Re: [PATCH RFC 1/1] Add support for ZONE_DEVICE IO memory with
 struct pages.
Message-ID: <20160314215708.GA7282@obsidianresearch.com>
References: <1457979277-26791-1-git-send-email-stephen.bates@pmcs.com>
 <20160314212344.GC23727@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160314212344.GC23727@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Stephen Bates <stephen.bates@pmcs.com>, linux-mm@kvack.org, linux-rdma@vger.kernel.org, linux-nvdimm@ml01.01.org, haggaie@mellanox.com, javier@cnexlabs.com, sagig@mellanox.com, leonro@mellanox.com, artemyko@mellanox.com, hch@infradead.org

On Mon, Mar 14, 2016 at 05:23:44PM -0400, Matthew Wilcox wrote:
> On Mon, Mar 14, 2016 at 12:14:37PM -0600, Stephen Bates wrote:
> > 3. Coherency Issues. When IOMEM is written from both the CPU and a PCIe
> > peer there is potential for coherency issues and for writes to occur out
> > of order. This is something that users of this feature need to be
> > cognizant of and may necessitate the use of CONFIG_EXPERT. Though really,
> > this isn't much different than the existing situation with RDMA: if
> > userspace sets up an MR for remote use, they need to be careful about
> > using that memory region themselves.
> 
> There's more to the coherency problem than this.  As I understand it, on
> x86, memory in a PCI BAR does not participate in the coherency protocol.
> So you can get a situation where CPU A stores 4 bytes to offset 8 in a
> cacheline, then CPU B stores 4 bytes to offset 16 in the same cacheline,
> and CPU A's write mysteriously goes missing.

No, this cannot happen with writing combining. You need full caching turned
on to get that kind of problem.

write combining can only combine writes, it cannot make up writes that
never existed.

That said, I question I don't know the answer to, is how does write
locking/memory barries interact with the write combining CPU buffers,
and are all the fencing semantics guarenteed.. There is some
interaction there (some drivers use write combining a lot).. but that
sure is a rarely used corner area...

The other issue is that the fencing mechanism RDMA uses to create
ordering with system memory is not good enough to fence peer-peer
transactions in the general case. It is only possibly good enough if
all the transactions run through the root complex.

> I may have misunderstood the exact details when this was explained to me a
> few years ago, but the details were horrible enough to run away screaming.
> Pretending PCI BARs are real memory?  Just Say No.

Someone should probably explain in more detail what this is even good
for, DAX on PCI-E bar memory seems goofy in the general case. I was
under the impression the main use case involved the CPU never touching
these memories and just using them to route-through to another IO
device (eg network). So all these discussions about CPU coherency seem
a bit strange.

Jason

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
