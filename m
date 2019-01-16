Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f70.google.com (mail-ot1-f70.google.com [209.85.210.70])
	by kanga.kvack.org (Postfix) with ESMTP id 4717E8E0002
	for <linux-mm@kvack.org>; Tue, 15 Jan 2019 21:01:22 -0500 (EST)
Received: by mail-ot1-f70.google.com with SMTP id g4so2012877otl.14
        for <linux-mm@kvack.org>; Tue, 15 Jan 2019 18:01:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m11sor2778459otk.110.2019.01.15.18.01.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 15 Jan 2019 18:01:21 -0800 (PST)
MIME-Version: 1.0
References: <294bdcfa-5bf9-9c09-9d43-875e8375e264@nvidia.com>
 <20190112024625.GB5059@redhat.com> <b6f4ed36-fc8d-1f9b-8c74-b12f61d496ae@nvidia.com>
 <20190114145447.GJ13316@quack2.suse.cz> <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz> <20190115171557.GB3696@redhat.com>
 <752839e6-6cb3-a6aa-94cb-63d3d4265934@nvidia.com> <20190115221205.GD3696@redhat.com>
 <99110c19-3168-f6a9-fbde-0a0e57f67279@nvidia.com> <20190116015610.GH3696@redhat.com>
In-Reply-To: <20190116015610.GH3696@redhat.com>
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 15 Jan 2019 18:01:09 -0800
Message-ID: <CAPcyv4h2hX_CJ=Ffzip4YzryOX0NPo9yy+yDsSPnyp20xat94Q@mail.gmail.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, Dave Chinner <david@fromorbit.com>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Tue, Jan 15, 2019 at 5:56 PM Jerome Glisse <jglisse@redhat.com> wrote:
> On Tue, Jan 15, 2019 at 04:44:41PM -0800, John Hubbard wrote:
[..]
> To make it clear.
>
> Lock code:
>     GUP()
>         ...
>         lock_page(page);
>         if (PageWriteback(page)) {
>             unlock_page(page);
>             wait_stable_page(page);
>             goto retry;
>         }
>         atomic_add(page->refcount, PAGE_PIN_BIAS);
>         unlock_page(page);
>
>     test_set_page_writeback()
>         bool pinned = false;
>         ...
>         pinned = page_is_pin(page); // could be after TestSetPageWriteback
>         TestSetPageWriteback(page);
>         ...
>         return pinned;
>
> Memory barrier:
>     GUP()
>         ...
>         atomic_add(page->refcount, PAGE_PIN_BIAS);
>         smp_mb();
>         if (PageWriteback(page)) {
>             atomic_add(page->refcount, -PAGE_PIN_BIAS);
>             wait_stable_page(page);
>             goto retry;
>         }
>
>     test_set_page_writeback()
>         bool pinned = false;
>         ...
>         TestSetPageWriteback(page);
>         smp_wmb();
>         pinned = page_is_pin(page);
>         ...
>         return pinned;
>
>
> One is not more complex than the other. One can contend, the other
> will _never_ contend.

The complexity is in the validation of lockless algorithms. It's
easier to reason about locks than barriers for the long term
maintainability of this code. I'm with Jan and John on wanting to
explore lock_page() before a barrier-based scheme.
