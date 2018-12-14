Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f199.google.com (mail-oi1-f199.google.com [209.85.167.199])
	by kanga.kvack.org (Postfix) with ESMTP id EBE1B8E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:17:22 -0500 (EST)
Received: by mail-oi1-f199.google.com with SMTP id r131so3150211oia.7
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 12:17:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i3sor2960039oii.154.2018.12.14.12.17.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 14 Dec 2018 12:17:21 -0800 (PST)
MIME-Version: 1.0
References: <20181212150319.GA3432@redhat.com> <20181212214641.GB29416@dastard>
 <20181212215931.GG5037@redhat.com> <20181213005119.GD29416@dastard>
 <05a68829-6e6d-b766-11b4-99e1ba4bc87b@nvidia.com> <CAPcyv4jyG3YTtghyr04wws_hcSBAmPBpnCm0tFcKgz9VwrV=ow@mail.gmail.com>
 <01cf4e0c-b2d6-225a-3ee9-ef0f7e53684d@nvidia.com> <CAPcyv4hrbA9H20bi+QMpKNi7r=egstt61MdQSD5Fb293W1btaw@mail.gmail.com>
 <20181214194843.GG10600@bombadil.infradead.org> <ed49a260-ffd5-613d-e48b-dfb4b550e8bb@intel.com>
 <20181214200311.GH10600@bombadil.infradead.org>
In-Reply-To: <20181214200311.GH10600@bombadil.infradead.org>
From: Dan Williams <dan.j.williams@intel.com>
Date: Fri, 14 Dec 2018 12:17:08 -0800
Message-ID: <CAPcyv4j1CJO=TAXiNzp032GnkJ0JcYSEXkn1ZqVP2o3b=P453g@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Dave Hansen <dave.hansen@intel.com>, John Hubbard <jhubbard@nvidia.com>, david <david@fromorbit.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Dec 14, 2018 at 12:03 PM Matthew Wilcox <willy@infradead.org> wrote:
>
> On Fri, Dec 14, 2018 at 11:53:31AM -0800, Dave Hansen wrote:
> > On 12/14/18 11:48 AM, Matthew Wilcox wrote:
> > > I think we can do better than a proxy object with bit 0 set.  I'd go
> > > for allocating something like this:
> > >
> > > struct dynamic_page {
> > >     struct page;
> > >     unsigned long vaddr;
> > >     unsigned long pfn;
> > >     ...
> > > };
> > >
> > > and use a bit in struct page to indicate that this is a dynamic page.
> >
> > That might be fun.  We'd just need a fast/static and slow/dynamic path
> > in page_to_pfn()/pfn_to_page().  We'd also need some kind of auxiliary
> > pfn-to-page structure since we could not fit that^ structure in vmemmap[].
>
> Yes; working on the pfn-to-page structure right now as it happens ...
> in the meantime, an XArray for it probably wouldn't be _too_ bad.

It might... see the recent patch from Ketih responding to complaints
about get_dev_pagemap() lookup overhead:

    df06b37ffe5a mm/gup: cache dev_pagemap while pinning pages
