Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 34F598E01DC
	for <linux-mm@kvack.org>; Fri, 14 Dec 2018 15:03:19 -0500 (EST)
Received: by mail-pf1-f200.google.com with SMTP id 82so5235039pfs.20
        for <linux-mm@kvack.org>; Fri, 14 Dec 2018 12:03:19 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id g15si4748760pgl.141.2018.12.14.12.03.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 14 Dec 2018 12:03:18 -0800 (PST)
Date: Fri, 14 Dec 2018 12:03:11 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20181214200311.GH10600@bombadil.infradead.org>
References: <20181212150319.GA3432@redhat.com>
 <20181212214641.GB29416@dastard>
 <20181212215931.GG5037@redhat.com>
 <20181213005119.GD29416@dastard>
 <05a68829-6e6d-b766-11b4-99e1ba4bc87b@nvidia.com>
 <CAPcyv4jyG3YTtghyr04wws_hcSBAmPBpnCm0tFcKgz9VwrV=ow@mail.gmail.com>
 <01cf4e0c-b2d6-225a-3ee9-ef0f7e53684d@nvidia.com>
 <CAPcyv4hrbA9H20bi+QMpKNi7r=egstt61MdQSD5Fb293W1btaw@mail.gmail.com>
 <20181214194843.GG10600@bombadil.infradead.org>
 <ed49a260-ffd5-613d-e48b-dfb4b550e8bb@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <ed49a260-ffd5-613d-e48b-dfb4b550e8bb@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, david <david@fromorbit.com>, =?iso-8859-1?B?Suly9G1l?= Glisse <jglisse@redhat.com>, Jan Kara <jack@suse.cz>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Fri, Dec 14, 2018 at 11:53:31AM -0800, Dave Hansen wrote:
> On 12/14/18 11:48 AM, Matthew Wilcox wrote:
> > I think we can do better than a proxy object with bit 0 set.  I'd go
> > for allocating something like this:
> > 
> > struct dynamic_page {
> > 	struct page;
> > 	unsigned long vaddr;
> > 	unsigned long pfn;
> > 	...
> > };
> > 
> > and use a bit in struct page to indicate that this is a dynamic page.
> 
> That might be fun.  We'd just need a fast/static and slow/dynamic path
> in page_to_pfn()/pfn_to_page().  We'd also need some kind of auxiliary
> pfn-to-page structure since we could not fit that^ structure in vmemmap[].

Yes; working on the pfn-to-page structure right now as it happens ...
in the meantime, an XArray for it probably wouldn't be _too_ bad.
