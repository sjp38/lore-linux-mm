Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 86EEE6B2355
	for <linux-mm@kvack.org>; Wed, 21 Nov 2018 07:36:04 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id o23so8214791pll.0
        for <linux-mm@kvack.org>; Wed, 21 Nov 2018 04:36:04 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id v10-v6si11739498pfk.264.2018.11.21.04.36.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Nov 2018 04:36:03 -0800 (PST)
Date: Wed, 21 Nov 2018 04:35:13 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/9] mm: Introduce new vm_insert_range API
Message-ID: <20181121123513.GF3065@bombadil.infradead.org>
References: <20181115154530.GA27872@jordon-HP-15-Notebook-PC>
 <20181116182836.GB17088@rapoport-lnx>
 <CAFqt6zYp0j999WXw9Jus0oZMjADQQkPfso8btv6du6L9CE3PXA@mail.gmail.com>
 <20181117143742.GB7861@bombadil.infradead.org>
 <CAFqt6zbOWX5LUTWwoGDJsGdf+pTR6N1yTPVxyr1W3-6Fte39ww@mail.gmail.com>
 <833B5050-DEF6-44A0-9832-276F86671212@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <833B5050-DEF6-44A0-9832-276F86671212@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: William Kucharski <william.kucharski@oracle.com>
Cc: Souptick Joarder <jrdr.linux@gmail.com>, rppt@linux.ibm.com, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On Wed, Nov 21, 2018 at 04:19:11AM -0700, William Kucharski wrote:
> Could you add a line to the description explicitly stating that a failure
> to insert any page in the range will fail the entire routine, something
> like:
> 
> > * This allows drivers to insert range of kernel pages they've allocated
> > * into a user vma. This is a generic function which drivers can use
> > * rather than using their own way of mapping range of kernel pages into
> > * user vma.
> > *
> > * A failure to insert any page in the range will fail the call as a whole.
> 
> It's obvious when reading the code, but it would be self-documenting to
> state it outright.

It's probably better to be more explicit and answer Randy's question:

 * If we fail to insert any page into the vma, the function will return
 * immediately leaving any previously-inserted pages present.  Callers
 * from the mmap handler may immediately return the error as their
 * caller will destroy the vma, removing any successfully-inserted pages.
 * Other callers should make their own arrangements for calling unmap_region().

Although unmap_region() is static so there clearly isn't any code in the
kernel today other than in mmap handlers (or fault handlers) that needs to
insert pages into a VMA.
