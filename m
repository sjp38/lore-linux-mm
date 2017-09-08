Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 06BBF6B0340
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 13:24:27 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id e9so3306273iod.4
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 10:24:27 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id i141sor998478ioe.262.2017.09.08.10.24.25
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 08 Sep 2017 10:24:25 -0700 (PDT)
Date: Fri, 8 Sep 2017 11:24:22 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v6 05/11] arm64/mm: Add support for XPFO
Message-ID: <20170908172422.rxmhwd2vl6eye2or@docker>
References: <20170907173609.22696-1-tycho@docker.com>
 <20170907173609.22696-6-tycho@docker.com>
 <20170908075347.GC4957@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20170908075347.GC4957@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, linux-arm-kernel@lists.infradead.org, xen-devel@lists.xenproject.org

On Fri, Sep 08, 2017 at 12:53:47AM -0700, Christoph Hellwig wrote:
> > +/*
> > + * Lookup the page table entry for a virtual address and return a pointer to
> > + * the entry. Based on x86 tree.
> > + */
> > +static pte_t *lookup_address(unsigned long addr)
> 
> Seems like this should be moved to common arm64 mm code and used by
> kernel_page_present.

Sounds good, I'll include something like the patch below in the next
series.

Unfortunately, adding an implementation of lookup_address seems to be
slightly more complicated than necessary, because of the xen piece. We
have to define lookup_address() with the level parameter, but it's not
obvious to me to name the page levels. So for now I've just left it as
a WARN() if someone supplies it.

It seems like xen still does need this to be defined, because if I
define it without level:

drivers/xen/xenbus/xenbus_client.c: In function a??xenbus_unmap_ring_vfree_pva??:
drivers/xen/xenbus/xenbus_client.c:760:4: error: too many arguments to function a??lookup_addressa??
    lookup_address(addr, &level)).maddr;
    ^~~~~~~~~~~~~~
In file included from ./arch/arm64/include/asm/page.h:37:0,
                 from ./include/linux/mmzone.h:20,
                 from ./include/linux/gfp.h:5,
                 from ./include/linux/mm.h:9,
                 from drivers/xen/xenbus/xenbus_client.c:33:
./arch/arm64/include/asm/pgtable-types.h:67:15: note: declared here
 extern pte_t *lookup_address(unsigned long addr);
               ^~~~~~~~~~~~~~

I've cc-d the xen folks, maybe they can suggest a way to untangle it?
Alternatively, if someone can suggest a good naming scheme for the
page levels, I can just do that.

Cheers,

Tycho
