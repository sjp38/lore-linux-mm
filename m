Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C6DDF6B0253
	for <linux-mm@kvack.org>; Sat, 21 Oct 2017 04:15:57 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m72so5596974wmc.0
        for <linux-mm@kvack.org>; Sat, 21 Oct 2017 01:15:57 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id m8si406672wmc.210.2017.10.21.01.15.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 21 Oct 2017 01:15:56 -0700 (PDT)
Date: Sat, 21 Oct 2017 10:15:56 +0200
From: Christoph Hellwig <hch@lst.de>
Subject: Re: [PATCH v3 02/13] dax: require 'struct page' for filesystem dax
Message-ID: <20171021081556.GC21101@lst.de>
References: <150846713528.24336.4459262264611579791.stgit@dwillia2-desk3.amr.corp.intel.com> <150846714747.24336.14704246566580871364.stgit@dwillia2-desk3.amr.corp.intel.com> <20171020075735.GA14378@lst.de> <CAPcyv4hA1nrhDf=DA6_j7s7ezGOBhvEVZ8cu81DNui_p3bhhaA@mail.gmail.com> <20171020162933.GA26320@lst.de> <CAPcyv4jP0ws7dcBrXafS7ON+0_J1BTp_LCB6XB3od4d6db071A@mail.gmail.com> <20171021032008.GA27694@bombadil.infradead.org> <CAPcyv4hYFAFsyF8RVc2kQwf-q2SWVPA4BFaerNbQXQBvhDONmg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAPcyv4hYFAFsyF8RVc2kQwf-q2SWVPA4BFaerNbQXQBvhDONmg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <willy@infradead.org>, Christoph Hellwig <hch@lst.de>, Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-xfs@vger.kernel.org, Linux MM <linux-mm@kvack.org>, Jeff Moyer <jmoyer@redhat.com>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>

On Fri, Oct 20, 2017 at 09:16:21PM -0700, Dan Williams wrote:
> > For example, I think it's entirely sensible to support ->direct_access
> > for RAID-0.  Dell are looking at various different options for having
> > one pmemX device per DIMM and using RAID to lash them together.
> > ->direct_access makes no sense for RAID-5 or RAID-1, but RAID-0 makes
> > sense to me.
> >
> > Last time we tried to take sleeping out, there were grumblings from people
> > with network block devices who thought they'd want to bring pages in
> > across the network.  I'm a bit less sympathetic to this because I don't
> > know anyone actively working on it, but the RAID-0 case is something I
> > think we should care about.
> 
> True, good point. In fact we already support device-mapper striping
> with ->direct_access(). I'd still like to go ahead with the sleeping
> removal. When those folks come back and add network direct_access they
> can do the hard work of figuring out cases where we need to call
> direct_access in atomic contexts.

It would be great to move DAX striping out of DM so that we don't need
to keep fake block devices around just for that.  In fact if Dell is so
interested in it it would be great if they get a strip/concact table
into ACPI so that the bios and OS can agree on it in a standardized way,
and we can just implement it in the nvdimm layer.

I agree that there is no reason at all to support sleeping in
->direct_access - it makes life painful for no gain at all.  If you
network access remote memory you will need local memory to support
mmap, so we might as well use the page cache instead of reinventing
it. (saying that with my remote pmem over NFS hat on).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
