Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D0F146B1B4A
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 11:27:00 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id e17so12422602edr.7
        for <linux-mm@kvack.org>; Mon, 19 Nov 2018 08:27:00 -0800 (PST)
Received: from mx0a-001b2d01.pphosted.com (mx0b-001b2d01.pphosted.com. [148.163.158.5])
        by mx.google.com with ESMTPS id e8si10786659edd.22.2018.11.19.08.26.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 19 Nov 2018 08:26:59 -0800 (PST)
Received: from pps.filterd (m0098417.ppops.net [127.0.0.1])
	by mx0a-001b2d01.pphosted.com (8.16.0.22/8.16.0.22) with SMTP id wAJGLbj7032516
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 11:26:57 -0500
Received: from e06smtp05.uk.ibm.com (e06smtp05.uk.ibm.com [195.75.94.101])
	by mx0a-001b2d01.pphosted.com with ESMTP id 2nuy5b4y32-1
	(version=TLSv1.2 cipher=AES256-GCM-SHA384 bits=256 verify=NOT)
	for <linux-mm@kvack.org>; Mon, 19 Nov 2018 11:26:56 -0500
Received: from localhost
	by e06smtp05.uk.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rppt@linux.ibm.com>;
	Mon, 19 Nov 2018 16:26:52 -0000
Date: Mon, 19 Nov 2018 08:26:24 -0800
From: Mike Rapoport <rppt@linux.ibm.com>
Subject: Re: [PATCH 1/9] mm: Introduce new vm_insert_range API
References: <20181115154530.GA27872@jordon-HP-15-Notebook-PC>
 <20181116182836.GB17088@rapoport-lnx>
 <CAFqt6zYp0j999WXw9Jus0oZMjADQQkPfso8btv6du6L9CE3PXA@mail.gmail.com>
 <20181117143742.GB7861@bombadil.infradead.org>
 <CAFqt6zbOWX5LUTWwoGDJsGdf+pTR6N1yTPVxyr1W3-6Fte39ww@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAFqt6zbOWX5LUTWwoGDJsGdf+pTR6N1yTPVxyr1W3-6Fte39ww@mail.gmail.com>
Message-Id: <20181119162623.GA13200@rapoport-lnx>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Souptick Joarder <jrdr.linux@gmail.com>
Cc: Matthew Wilcox <willy@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, vbabka@suse.cz, Rik van Riel <riel@surriel.com>, Stephen Rothwell <sfr@canb.auug.org.au>, rppt@linux.vnet.ibm.com, Peter Zijlstra <peterz@infradead.org>, Russell King - ARM Linux <linux@armlinux.org.uk>, robin.murphy@arm.com, iamjoonsoo.kim@lge.com, treding@nvidia.com, Kees Cook <keescook@chromium.org>, Marek Szyprowski <m.szyprowski@samsung.com>, stefanr@s5r6.in-berlin.de, hjc@rock-chips.com, Heiko Stuebner <heiko@sntech.de>, airlied@linux.ie, oleksandr_andrushchenko@epam.com, joro@8bytes.org, pawel@osciak.com, Kyungmin Park <kyungmin.park@samsung.com>, mchehab@kernel.org, Boris Ostrovsky <boris.ostrovsky@oracle.com>, Juergen Gross <jgross@suse.com>, linux-kernel@vger.kernel.org, Linux-MM <linux-mm@kvack.org>, linux-arm-kernel@lists.infradead.org, linux1394-devel@lists.sourceforge.net, dri-devel@lists.freedesktop.org, linux-rockchip@lists.infradead.org, xen-devel@lists.xen.org, iommu@lists.linux-foundation.org, linux-media@vger.kernel.org

On Mon, Nov 19, 2018 at 08:43:09PM +0530, Souptick Joarder wrote:
> Hi Mike,
> 
> On Sat, Nov 17, 2018 at 8:07 PM Matthew Wilcox <willy@infradead.org> wrote:
> >
> > On Sat, Nov 17, 2018 at 12:26:38PM +0530, Souptick Joarder wrote:
> > > On Fri, Nov 16, 2018 at 11:59 PM Mike Rapoport <rppt@linux.ibm.com> wrote:
> > > > > + * vm_insert_range - insert range of kernel pages into user vma
> > > > > + * @vma: user vma to map to
> > > > > + * @addr: target user address of this page
> > > > > + * @pages: pointer to array of source kernel pages
> > > > > + * @page_count: no. of pages need to insert into user vma
> > > > > + *
> > > > > + * This allows drivers to insert range of kernel pages they've allocated
> > > > > + * into a user vma. This is a generic function which drivers can use
> > > > > + * rather than using their own way of mapping range of kernel pages into
> > > > > + * user vma.
> > > >
> > > > Please add the return value and context descriptions.
> > > >
> > >
> > > Sure I will wait for some time to get additional review comments and
> > > add all of those requested changes in v2.
> >
> > You could send your proposed wording now which might remove the need
> > for a v3 if we end up arguing about the wording.
> 
> Does this description looks good ?
> 
> /**
>  * vm_insert_range - insert range of kernel pages into user vma
>  * @vma: user vma to map to
>  * @addr: target user address of this page
>  * @pages: pointer to array of source kernel pages
>  * @page_count: number of pages need to insert into user vma
>  *
>  * This allows drivers to insert range of kernel pages they've allocated
>  * into a user vma. This is a generic function which drivers can use
>  * rather than using their own way of mapping range of kernel pages into
>  * user vma.
>  *
>  * Context - Process context. Called by mmap handlers.

Context:

>  * Return - int error value

Return:

>  * 0                    - OK
>  * -EINVAL              - Invalid argument
>  * -ENOMEM              - No memory
>  * -EFAULT              - Bad address
>  * -EBUSY               - Device or resource busy

I don't think that elaborate description of error values is needed, just "0
on success and error code otherwise" would be sufficient.

>  */
> 

-- 
Sincerely yours,
Mike.
