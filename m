Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id C28986B02E1
	for <linux-mm@kvack.org>; Fri, 28 Apr 2017 02:39:17 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id b20so2610862wma.11
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 23:39:17 -0700 (PDT)
Received: from mail-wr0-x244.google.com (mail-wr0-x244.google.com. [2a00:1450:400c:c0c::244])
        by mx.google.com with ESMTPS id f8si5783602wmh.127.2017.04.27.23.39.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Apr 2017 23:39:16 -0700 (PDT)
Received: by mail-wr0-x244.google.com with SMTP id w50so6012104wrc.0
        for <linux-mm@kvack.org>; Thu, 27 Apr 2017 23:39:16 -0700 (PDT)
Date: Fri, 28 Apr 2017 08:39:13 +0200
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH] mm, zone_device: replace {get, put}_zone_device_page()
 with a single reference
Message-ID: <20170428063913.iz6xjcxblecofjlq@gmail.com>
References: <20170423233125.nehmgtzldgi25niy@node.shutemov.name>
 <149325431313.40660.7404075559824162131.stgit@dwillia2-desk3.amr.corp.intel.com>
 <20170427083317.vzfiw7up63draslc@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170427083317.vzfiw7up63draslc@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dan Williams <dan.j.williams@intel.com>, Ingo Molnar <mingo@redhat.com>, akpm@linux-foundation.org, linux-mm@kvack.org, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Logan Gunthorpe <logang@deltatee.com>, linux-kernel@vger.kernel.org, Kirill Shutemov <kirill.shutemov@linux.intel.com>


* Kirill A. Shutemov <kirill@shutemov.name> wrote:

> On Wed, Apr 26, 2017 at 05:55:31PM -0700, Dan Williams wrote:
> > Kirill points out that the calls to {get,put}_dev_pagemap() can be
> > removed from the mm fast path if we take a single get_dev_pagemap()
> > reference to signify that the page is alive and use the final put of the
> > page to drop that reference.
> > 
> > This does require some care to make sure that any waits for the
> > percpu_ref to drop to zero occur *after* devm_memremap_page_release(),
> > since it now maintains its own elevated reference.
> > 
> > Cc Ingo Molnar <mingo@redhat.com>
> > Cc: Jerome Glisse <jglisse@redhat.com>
> > Cc: Logan Gunthorpe <logang@deltatee.com>
> > Cc: Andrew Morton <akpm@linux-foundation.org>
> > Suggested-by: Kirill Shutemov <kirill.shutemov@linux.intel.com>
> > Signed-off-by: Dan Williams <dan.j.williams@intel.com>
> > ---
> > 
> > This patch might fix the regression that we found with the conversion to
> > generic get_user_pages_fast() in the x86/mm branch pending for 4.12
> > (commit 2947ba054a4d "x86/mm/gup: Switch GUP to the generic
> > get_user_page_fast() implementation"). I'll test tomorrow, but in case
> > someone can give it a try before I wake up, here's an early version.
> 
> + Ingo.
> 
> This works for me with and without GUP revert.
> 
> Tested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> 
> >  drivers/dax/pmem.c    |    2 +-
> >  drivers/nvdimm/pmem.c |   13 +++++++++++--
> 
> There's a trivial conflict in drivers/nvdimm/pmem.c when applied to
> tip/master.

Ok, could someone please send a version either to Linus for v4.11, or a version 
against latest -tip so I can included it in x86/mm, so that x86/mm gets unbroken.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
