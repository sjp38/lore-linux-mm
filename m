Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f198.google.com (mail-qt1-f198.google.com [209.85.160.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8FF878E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:23:19 -0500 (EST)
Received: by mail-qt1-f198.google.com with SMTP id w15so4332269qtk.19
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 18:23:19 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id g11si6918592qth.320.2019.01.15.18.23.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Jan 2019 18:23:18 -0800 (PST)
Date: Tue, 15 Jan 2019 21:23:12 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190116022312.GJ3696@redhat.com>
References: <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz>
 <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz>
 <20190115171557.GB3696@redhat.com>
 <752839e6-6cb3-a6aa-94cb-63d3d4265934@nvidia.com>
 <20190115221205.GD3696@redhat.com>
 <99110c19-3168-f6a9-fbde-0a0e57f67279@nvidia.com>
 <20190116015610.GH3696@redhat.com>
 <CAPcyv4h2hX_CJ=Ffzip4YzryOX0NPo9yy+yDsSPnyp20xat94Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAPcyv4h2hX_CJ=Ffzip4YzryOX0NPo9yy+yDsSPnyp20xat94Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Jan 15, 2019 at 06:01:09PM -0800, Dan Williams wrote:
> On Tue, Jan 15, 2019 at 5:56 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > On Tue, Jan 15, 2019 at 04:44:41PM -0800, John Hubbard wrote:
> [..]
> > To make it clear.
> >
> > Lock code:
> >     GUP()
> >         ...
> >         lock_page(page);
> >         if (PageWriteback(page)) {
> >             unlock_page(page);
> >             wait_stable_page(page);
> >             goto retry;
> >         }
> >         atomic_add(page->refcount, PAGE_PIN_BIAS);
> >         unlock_page(page);
> >
> >     test_set_page_writeback()
> >         bool pinned = false;
> >         ...
> >         pinned = page_is_pin(page); // could be after TestSetPageWriteback
> >         TestSetPageWriteback(page);
> >         ...
> >         return pinned;
> >
> > Memory barrier:
> >     GUP()
> >         ...
> >         atomic_add(page->refcount, PAGE_PIN_BIAS);
> >         smp_mb();
> >         if (PageWriteback(page)) {
> >             atomic_add(page->refcount, -PAGE_PIN_BIAS);
> >             wait_stable_page(page);
> >             goto retry;
> >         }
> >
> >     test_set_page_writeback()
> >         bool pinned = false;
> >         ...
> >         TestSetPageWriteback(page);
> >         smp_wmb();
> >         pinned = page_is_pin(page);
> >         ...
> >         return pinned;
> >
> >
> > One is not more complex than the other. One can contend, the other
> > will _never_ contend.
> 
> The complexity is in the validation of lockless algorithms. It's
> easier to reason about locks than barriers for the long term
> maintainability of this code. I'm with Jan and John on wanting to
> explore lock_page() before a barrier-based scheme.

How is the above hard to validate ? Either GUP see racing
test_set_page_writeback because it test write back after
incrementing the refcount, or test_set_page_writeback sees
GUP because it checks for pin after setting the write back
bits.

So if GUP see !PageWriteback() then test_set_page_writeback
see page_pin(page) as true. If test_set_page_writeback sees
page_pin(page) as false then GUP did see PageWriteback() as
true.

You _never_ have !PageWriteback() in GUP and !page_pin() in
test_set_page_writeback() if they are both racing. This is
an impossible scenario because of memory barrier.

Cheers,
Jérôme
