Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f178.google.com (mail-wi0-f178.google.com [209.85.212.178])
	by kanga.kvack.org (Postfix) with ESMTP id 0D6016B0253
	for <linux-mm@kvack.org>; Thu, 27 Aug 2015 03:33:28 -0400 (EDT)
Received: by wijn1 with SMTP id n1so46268519wij.0
        for <linux-mm@kvack.org>; Thu, 27 Aug 2015 00:33:27 -0700 (PDT)
Received: from newverein.lst.de (verein.lst.de. [213.95.11.211])
        by mx.google.com with ESMTPS id 20si2378557wjr.148.2015.08.27.00.33.25
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Aug 2015 00:33:26 -0700 (PDT)
Date: Thu, 27 Aug 2015 09:33:25 +0200
From: "hch@lst.de" <hch@lst.de>
Subject: Re: [PATCH v2 9/9] devm_memremap_pages: protect against pmem
	device unbind
Message-ID: <20150827073325.GB27207@lst.de>
References: <20150826010220.8851.18077.stgit@dwillia2-desk3.amr.corp.intel.com> <20150826012813.8851.35482.stgit@dwillia2-desk3.amr.corp.intel.com> <20150826124649.GA8014@lst.de> <1440625157.31365.21.camel@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1440625157.31365.21.camel@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Williams, Dan J" <dan.j.williams@intel.com>
Cc: "hch@lst.de" <hch@lst.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "mingo@kernel.org" <mingo@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "hpa@zytor.com" <hpa@zytor.com>, "linux-nvdimm@lists.01.org" <linux-nvdimm@lists.01.org>, "ross.zwisler@linux.intel.com" <ross.zwisler@linux.intel.com>, "boaz@plexistor.com" <boaz@plexistor.com>, "david@fromorbit.com" <david@fromorbit.com>

On Wed, Aug 26, 2015 at 09:39:18PM +0000, Williams, Dan J wrote:
> On Wed, 2015-08-26 at 14:46 +0200, Christoph Hellwig wrote:
> > On Tue, Aug 25, 2015 at 09:28:13PM -0400, Dan Williams wrote:
> > > Given that:
> > > 
> > > 1/ device ->remove() can not be failed
> > > 
> > > 2/ a pmem device may be unbound at any time
> > > 
> > > 3/ we do not know what other parts of the kernel are actively using a
> > >    'struct page' from devm_memremap_pages()
> > > 
> > > ...provide a facility for active usages of device memory to block pmem
> > > device unbind.  With a percpu_ref it should be feasible to take a
> > > reference on a per-I/O or other high frequency basis.
> > 
> > Without a caller of get_page_map this is just adding dead code.  I'd
> > suggest to group it in a series with that caller.
> > 
> 
> Agreed, we can drop this until the first user arrives.
> 
> > Also if the page_map gets exposed in a header the name is a bit too generic.
> > memremap_map maybe?
> 
> Done, and in the patch below I hide the internal implementation details
> of page_map in kernel/memremap.c and only expose the percpu_ref in the
> public memremap_map.

Yes, that looks good once we're getting the users for it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
