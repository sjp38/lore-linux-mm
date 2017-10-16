Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2B0496B0253
	for <linux-mm@kvack.org>; Mon, 16 Oct 2017 14:18:02 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id y39so2850472wrd.17
        for <linux-mm@kvack.org>; Mon, 16 Oct 2017 11:18:02 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u11si6328911wrg.462.2017.10.16.11.18.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 16 Oct 2017 11:18:00 -0700 (PDT)
Date: Mon, 16 Oct 2017 20:17:56 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH 3/3] mm/map_contig: Add mmap(MAP_CONTIG) support
Message-ID: <20171016181756.3tpp27x6gb53sejg@dhcp22.suse.cz>
References: <20171013154747.2jv7rtfqyyagiodn@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710131053450.4400@nuc-kabylake>
 <20171013161736.htumyr4cskfrjq64@dhcp22.suse.cz>
 <752b49eb-55c6-5a34-ab41-6e91dd93ea70@mellanox.com>
 <20171016082456.no6ux63uy2rmj4fe@dhcp22.suse.cz>
 <0e238c56-c59d-f648-95fc-c8cb56c3652e@mellanox.com>
 <20171016123248.csntl6luxgafst6q@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710161058470.12436@nuc-kabylake>
 <20171016174229.pz3o4uhzz3qbrp6n@dhcp22.suse.cz>
 <alpine.DEB.2.20.1710161253520.13473@nuc-kabylake>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.20.1710161253520.13473@nuc-kabylake>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Lameter <cl@linux.com>
Cc: Guy Shattah <sguy@mellanox.com>, Mike Kravetz <mike.kravetz@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Laura Abbott <labbott@redhat.com>, Vlastimil Babka <vbabka@suse.cz>

On Mon 16-10-17 12:56:43, Cristopher Lameter wrote:
> On Mon, 16 Oct 2017, Michal Hocko wrote:
> 
> > > We already have that issue and have ways to control that by tracking
> > > pinned and mlocked pages as well as limits on their allocations.
> >
> > Ohh, it is very different because mlock limit is really small (64kB)
> > which is not even close to what this is supposed to be about. Moreover
> > mlock doesn't prevent from migration and so it doesn't prevent
> > compaction to form higher order allocations.
> 
> The mlock limit is configurable. There is a tracking of pinned pages as
> well.

I am not aware of any such generic tracking API. The attempt by Peter
has never been merged. So what we have right now is just an adhoc
tracking...
 
> > Really, this is just too dangerous without a deep consideration of all
> > the potential consequences. The more I am thinking about this the more I
> > am convinced that this all should be driver specific mmap based thing.
> > If it turns out to be too restrictive over time and there are more
> > experiences about the usage we can consider thinking about a more
> > generic API. But starting from the generic MAP_ flag is just asking for
> > problems.
> 
> This issue is already present with the pinning of lots of memory via the
> RDMA API when in use for large gigabyte ranges.

... like in those

> There is nothing new aside
> from memory being contiguous with this approach.

which makes a hell of a difference. Once you allow to pin larger blocks
of memory you make the whole compaction hopelessly ineffective.

> > > There is not much new here in terms of problems. The hardware that
> > > needs this seems to become more and more plentiful. That is why we need a
> > > generic implementation.
> >
> > It would really help to name that HW and other potential usecases
> > independent on the HW because I am rather skeptical about the
> > _plentiful_ part. And so I really do not see any foundation to claim
> > the generic part. Because, fundamentally, it is the HW which requires
> > the specific memory placement/physically contiguous range etc. So the
> > generic implementation doesn't really make sense in such a context.
> 
> RDMA hardware? Storage interfaces? Look at what the RDMA subsystem
> and storage (NVME?) support.
> 
> This is not a hardware specific thing but a reflection of the general
> limitations of the exiting 4k page struct scheme that limits performance
> and causes severe pressure on I/O devices.

This is something more for storage people to comment. I expect (NVME)
storage to use DAX and it support for large and direct access. Nothing
really prevents RDMA HW to provide mmap implementation to use contiguous
pages, we already provide an API to allocate large memory.
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
