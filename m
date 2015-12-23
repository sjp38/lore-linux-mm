Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f171.google.com (mail-ob0-f171.google.com [209.85.214.171])
	by kanga.kvack.org (Postfix) with ESMTP id BCB6C6B0261
	for <linux-mm@kvack.org>; Wed, 23 Dec 2015 11:30:57 -0500 (EST)
Received: by mail-ob0-f171.google.com with SMTP id ba1so76512588obb.3
        for <linux-mm@kvack.org>; Wed, 23 Dec 2015 08:30:57 -0800 (PST)
Received: from emea01-db3-obe.outbound.protection.outlook.com (mail-db3on0064.outbound.protection.outlook.com. [157.55.234.64])
        by mx.google.com with ESMTPS id u206si30585444oif.70.2015.12.23.08.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 23 Dec 2015 08:30:56 -0800 (PST)
From: Shachar Raindel <raindel@mellanox.com>
Subject: RE: [RFC contig pages support 1/2] IB: Supports contiguous memory
 operations
Date: Wed, 23 Dec 2015 16:30:48 +0000
Message-ID: <AM4PR05MB14603CF21CB493086BDEE026DCE60@AM4PR05MB1460.eurprd05.prod.outlook.com>
References: <1449587707-24214-1-git-send-email-yishaih@mellanox.com>
 <1449587707-24214-2-git-send-email-yishaih@mellanox.com>
 <20151208151852.GA6688@infradead.org>
 <20151208171542.GB13549@obsidianresearch.com>
 <AM4PR05MB146005B448BEA876519335CDDCE80@AM4PR05MB1460.eurprd05.prod.outlook.com>
 <20151209183940.GA4522@infradead.org>
 <AM4PR05MB14603FC8169D50AD2A8F5AA3DCEC0@AM4PR05MB1460.eurprd05.prod.outlook.com>
 <56796538.9040906@suse.cz>
In-Reply-To: <56796538.9040906@suse.cz>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>, Christoph Hellwig <hch@infradead.org>
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>, Yishai Hadas <yishaih@mellanox.com>, "dledford@redhat.com" <dledford@redhat.com>, "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>, Or Gerlitz <ogerlitz@mellanox.com>, Tal Alon <talal@mellanox.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>



> -----Original Message-----
> From: Vlastimil Babka [mailto:vbabka@suse.cz]
> Sent: Tuesday, December 22, 2015 4:59 PM
>=20
> On 12/13/2015 01:48 PM, Shachar Raindel wrote:
> >
> >
> >> -----Original Message-----
> >> From: Christoph Hellwig [mailto:hch@infradead.org]
> >> Sent: Wednesday, December 09, 2015 8:40 PM
> >>
> >> On Wed, Dec 09, 2015 at 10:00:02AM +0000, Shachar Raindel wrote:
> >>> As far as gain is concerned, we are seeing gains in two cases here:
> >>> 1. If the system has lots of non-fragmented, free memory, you can
> >> create large contig blocks that are above the CPU huge page size.
> >>> 2. If the system memory is very fragmented, you cannot allocate huge
> >> pages. However, an API that allows you to create small (i.e. 64KB,
> >> 128KB, etc.) contig blocks reduces the load on the HW page tables and
> >> caches.
> >>
> >> None of that is a uniqueue requirement for the mlx4 devices.  Again,
> >> please work with the memory management folks to address your
> >> requirements in a generic way!
> >
> > I completely agree, and this RFC was sent in order to start discussion
> > on this subject.
> >
> > Dear MM people, can you please advise on the subject?
> >
> > Multiple HW vendors, from different fields, ranging between embedded
> SoC
> > devices (TI) and HPC (Mellanox) are looking for a solution to allocate
> > blocks of contiguous memory to user space applications, without using
> huge
> > pages.
> >
> > What should be the API to expose such feature?
> >
> > Should we create a virtual FS that allows the user to create "files"
> > representing memory allocations, and define the contiguous level we
> > attempt to allocate using folders (similar to hugetlbfs)?
> >
> > Should we patch hugetlbfs to allow allocation of contiguous memory
> chunks,
> > without creating larger memory mapping in the CPU page tables?
> >
> > Should we create a special "allocator" virtual device, that will hand
> out
> > memory in contiguous chunks via a call to mmap with an FD connected to
> the
> > device?
>=20
> How much memory do you assume to be used like this?

Depends on the use case. Most likely several MBs/core, used for interfacing
with the HW (packet rings, frame buffers, etc.).

Some applications might want to perform calculations in such memory, to=20
optimize communication time, especially in the HPC market.

> Is this memory
> supposed to be swappable, migratable, etc? I.e. on LRU lists?

Most likely not. In many of the relevant applications (embedded, HPC),
there is no swap and the application threads are pinned to specific cores
and NUMA nodes.
The biggest pain here is that these memory pages will not be eligible for
compaction, making it harder to handle fragmentations and CMA allocation
requests.

> Allocating a lot of memory (e.g. most of userspace memory) that's not
> LRU wouldn't be nice. But LRU operations are not prepared to work witch
> such non-standard-sized allocations, regardless of what API you use.  So
> I think that's the more fundamental questions here.

I agree that there are fundamental questions here.=20

That being said, there is a clear need for an API allowing=20
allocation, to the user space, limited size of memory that
is composed of large contiguous blocks.

What will be the best way to implement such solution?

Thanks,
--Shachar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
