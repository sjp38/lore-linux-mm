Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 23DC16B0038
	for <linux-mm@kvack.org>; Sat, 21 Oct 2017 00:16:24 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 14so13070517oii.2
        for <linux-mm@kvack.org>; Fri, 20 Oct 2017 21:16:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k13sor996648oih.294.2017.10.20.21.16.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Oct 2017 21:16:23 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20171021032008.GA27694@bombadil.infradead.org>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com>
 <150846714747.24336.14704246566580871364.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20171020075735.GA14378@lst.de> <CAPcyv4hA1nrhDf=DA6_j7s7ezGOBhvEVZ8cu81DNui_p3bhhaA@mail.gmail.com>
 <20171020162933.GA26320@lst.de> <CAPcyv4jP0ws7dcBrXafS7ON+0_J1BTp_LCB6XB3od4d6db071A@mail.gmail.com>
 <20171021032008.GA27694@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 20 Oct 2017 21:16:21 -0700
Message-ID: <CAPcyv4hYFAFsyF8RVc2kQwf-q2SWVPA4BFaerNbQXQBvhDONmg@mail.gmail.com>
Subject: Re: [PATCH v3 02/13] dax: require 'struct page' for filesystem dax
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Fri, Oct 20, 2017 at 8:20 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Fri, Oct 20, 2017 at 03:29:57PM -0700, Dan Williams wrote:
>> Ok, I'd also like to kill DAX support in the brd driver. It's a source
>> of complexity and maintenance burden for zero benefit. It's the only
>> ->direct_access() implementation that sleeps and it's the only
>> implementation where there is a non-linear relationship between
>> sectors and pfns. Having a 1:1 sector to pfn relationship will help
>> with the dma-extent-busy management since we don't need to keep
>> calling into the driver to map pfns back to sectors once we know the
>> pfn[0] sector[0] relationship.
>
> But these are important things that other block devices may / will want.
>
> For example, I think it's entirely sensible to support ->direct_access
> for RAID-0.  Dell are looking at various different options for having
> one pmemX device per DIMM and using RAID to lash them together.
> ->direct_access makes no sense for RAID-5 or RAID-1, but RAID-0 makes
> sense to me.
>
> Last time we tried to take sleeping out, there were grumblings from people
> with network block devices who thought they'd want to bring pages in
> across the network.  I'm a bit less sympathetic to this because I don't
> know anyone actively working on it, but the RAID-0 case is something I
> think we should care about.

True, good point. In fact we already support device-mapper striping
with ->direct_access(). I'd still like to go ahead with the sleeping
removal. When those folks come back and add network direct_access they
can do the hard work of figuring out cases where we need to call
direct_access in atomic contexts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
