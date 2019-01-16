Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1439E8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 17:51:32 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a18so4825444pga.16
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 14:51:32 -0800 (PST)
Received: from ipmail03.adl6.internode.on.net (ipmail03.adl6.internode.on.net. [150.101.137.143])
        by mx.google.com with ESMTP id f127si7286399pfc.69.2019.01.16.14.51.29
        for <linux-mm@kvack.org>;
        Wed, 16 Jan 2019 14:51:30 -0800 (PST)
Date: Thu, 17 Jan 2019 09:51:27 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190116225126.GS4205@dastard>
References: <20190115080759.GC29524@quack2.suse.cz>
 <20190115171557.GB3696@redhat.com>
 <752839e6-6cb3-a6aa-94cb-63d3d4265934@nvidia.com>
 <20190115221205.GD3696@redhat.com>
 <99110c19-3168-f6a9-fbde-0a0e57f67279@nvidia.com>
 <20190116015610.GH3696@redhat.com>
 <CAPcyv4h2hX_CJ=Ffzip4YzryOX0NPo9yy+yDsSPnyp20xat94Q@mail.gmail.com>
 <20190116022312.GJ3696@redhat.com>
 <20190116043455.GP4205@dastard>
 <20190116145016.GB3617@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190116145016.GB3617@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <jglisse@redhat.com>
Cc: Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>

On Wed, Jan 16, 2019 at 09:50:16AM -0500, Jerome Glisse wrote:
> On Wed, Jan 16, 2019 at 03:34:55PM +1100, Dave Chinner wrote:
> > On Tue, Jan 15, 2019 at 09:23:12PM -0500, Jerome Glisse wrote:
> > > On Tue, Jan 15, 2019 at 06:01:09PM -0800, Dan Williams wrote:
> > > > On Tue, Jan 15, 2019 at 5:56 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > > On Tue, Jan 15, 2019 at 04:44:41PM -0800, John Hubbard wrote:
> > > > [..]
> > > > > To make it clear.
> > > > >
> > > > > Lock code:
> > > > >     GUP()
> > > > >         ...
> > > > >         lock_page(page);
> > > > >         if (PageWriteback(page)) {
> > > > >             unlock_page(page);
> > > > >             wait_stable_page(page);
> > > > >             goto retry;
> > > > >         }
> > > > >         atomic_add(page->refcount, PAGE_PIN_BIAS);
> > > > >         unlock_page(page);
> > > > >
> > > > >     test_set_page_writeback()
> > > > >         bool pinned = false;
> > > > >         ...
> > > > >         pinned = page_is_pin(page); // could be after TestSetPageWriteback
> > > > >         TestSetPageWriteback(page);
> > > > >         ...
> > > > >         return pinned;
> > > > >
> > > > > Memory barrier:
> > > > >     GUP()
> > > > >         ...
> > > > >         atomic_add(page->refcount, PAGE_PIN_BIAS);
> > > > >         smp_mb();
> > > > >         if (PageWriteback(page)) {
> > > > >             atomic_add(page->refcount, -PAGE_PIN_BIAS);
> > > > >             wait_stable_page(page);
> > > > >             goto retry;
> > > > >         }
> > > > >
> > > > >     test_set_page_writeback()
> > > > >         bool pinned = false;
> > > > >         ...
> > > > >         TestSetPageWriteback(page);
> > > > >         smp_wmb();
> > > > >         pinned = page_is_pin(page);
> > > > >         ...
> > > > >         return pinned;
> > > > >
> > > > >
> > > > > One is not more complex than the other. One can contend, the other
> > > > > will _never_ contend.
> > > > 
> > > > The complexity is in the validation of lockless algorithms. It's
> > > > easier to reason about locks than barriers for the long term
> > > > maintainability of this code. I'm with Jan and John on wanting to
> > > > explore lock_page() before a barrier-based scheme.
> > > 
> > > How is the above hard to validate ?
> > 
> > Well, if you think it's so easy, then please write the test cases so
> > we can add them to fstests and make sure that we don't break it in
> > future.
> > 
> > If you can't write filesystem test cases that exercise these race
> > conditions reliably, then the answer to your question is "it is
> > extremely hard to validate" and the correct thing to do is to start
> > with the simple lock_page() based algorithm.
> > 
> > Premature optimisation in code this complex is something we really,
> > really need to avoid.
> 
> Litmus test shows that this never happens, i am attaching 2 litmus
> test one with barrier and one without. Without barrier we can see
> the double negative !PageWriteback in GUP and !page_pinned() in
> test_set_page_writeback() (0:EAX = 0; 1:EAX = 0; below)

That's not a regression test, nor does it actually test the code
that the kernel runs. It's just an extremely simplified model of
a small part of the algorithm. Sure, that specific interaction is
fine, but that in no way reflects the complexity of the code or the
interactions with other code that interacts with that state. And
it's not something we can use to detect that some future change has
broken gup vs writeback synchronisation.

Memory barriers might be fast, but they are hell for anyone but the
person who wrote the algorithm to understand.  If a simple page lock
is good enough and doesn't cause performance problems, then use the
simple page lock mechanism and stop trying to be clever.

Other people who will have to understand and debug issues in this
code are much less accepting of such clever algorithms. We've
been badly burnt on repeated occasions by broken memory barriers in
code heavily optimised for performance (*cough* rwsems *cough*), so
I'm extremely wary of using memory ordering dependent algorithms in
places where they are not necessary.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
