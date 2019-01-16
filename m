Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt1-f200.google.com (mail-qt1-f200.google.com [209.85.160.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1AE098E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:50:25 -0500 (EST)
Received: by mail-qt1-f200.google.com with SMTP id b16so5716795qtc.22
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 06:50:25 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a128si6239360qkc.19.2019.01.16.06.50.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 06:50:23 -0800 (PST)
Date: Wed, 16 Jan 2019 09:50:16 -0500
From: Jerome Glisse <jglisse@redhat.com>
Subject: Re: [PATCH 1/2] mm: introduce put_user_page*(), placeholder versions
Message-ID: <20190116145016.GB3617@redhat.com>
References: <20190114172124.GA3702@redhat.com>
 <20190115080759.GC29524@quack2.suse.cz>
 <20190115171557.GB3696@redhat.com>
 <752839e6-6cb3-a6aa-94cb-63d3d4265934@nvidia.com>
 <20190115221205.GD3696@redhat.com>
 <99110c19-3168-f6a9-fbde-0a0e57f67279@nvidia.com>
 <20190116015610.GH3696@redhat.com>
 <CAPcyv4h2hX_CJ=Ffzip4YzryOX0NPo9yy+yDsSPnyp20xat94Q@mail.gmail.com>
 <20190116022312.GJ3696@redhat.com>
 <20190116043455.GP4205@dastard>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="7AUc2qLy4jB3hD7Z"
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20190116043455.GP4205@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Dan Williams <dan.j.williams@intel.com>, John Hubbard <jhubbard@nvidia.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <willy@infradead.org>, John Hubbard <john.hubbard@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, tom@talpey.com, Al Viro <viro@zeniv.linux.org.uk>, benve@cisco.com, Christoph Hellwig <hch@infradead.org>, Christopher Lameter <cl@linux.com>, "Dalessandro, Dennis" <dennis.dalessandro@intel.com>, Doug Ledford <dledford@redhat.com>, Jason Gunthorpe <jgg@ziepe.ca>, Michal Hocko <mhocko@kernel.org>, Mike Marciniszyn <mike.marciniszyn@intel.com>, rcampbell@nvidia.com, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>


--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit

On Wed, Jan 16, 2019 at 03:34:55PM +1100, Dave Chinner wrote:
> On Tue, Jan 15, 2019 at 09:23:12PM -0500, Jerome Glisse wrote:
> > On Tue, Jan 15, 2019 at 06:01:09PM -0800, Dan Williams wrote:
> > > On Tue, Jan 15, 2019 at 5:56 PM Jerome Glisse <jglisse@redhat.com> wrote:
> > > > On Tue, Jan 15, 2019 at 04:44:41PM -0800, John Hubbard wrote:
> > > [..]
> > > > To make it clear.
> > > >
> > > > Lock code:
> > > >     GUP()
> > > >         ...
> > > >         lock_page(page);
> > > >         if (PageWriteback(page)) {
> > > >             unlock_page(page);
> > > >             wait_stable_page(page);
> > > >             goto retry;
> > > >         }
> > > >         atomic_add(page->refcount, PAGE_PIN_BIAS);
> > > >         unlock_page(page);
> > > >
> > > >     test_set_page_writeback()
> > > >         bool pinned = false;
> > > >         ...
> > > >         pinned = page_is_pin(page); // could be after TestSetPageWriteback
> > > >         TestSetPageWriteback(page);
> > > >         ...
> > > >         return pinned;
> > > >
> > > > Memory barrier:
> > > >     GUP()
> > > >         ...
> > > >         atomic_add(page->refcount, PAGE_PIN_BIAS);
> > > >         smp_mb();
> > > >         if (PageWriteback(page)) {
> > > >             atomic_add(page->refcount, -PAGE_PIN_BIAS);
> > > >             wait_stable_page(page);
> > > >             goto retry;
> > > >         }
> > > >
> > > >     test_set_page_writeback()
> > > >         bool pinned = false;
> > > >         ...
> > > >         TestSetPageWriteback(page);
> > > >         smp_wmb();
> > > >         pinned = page_is_pin(page);
> > > >         ...
> > > >         return pinned;
> > > >
> > > >
> > > > One is not more complex than the other. One can contend, the other
> > > > will _never_ contend.
> > > 
> > > The complexity is in the validation of lockless algorithms. It's
> > > easier to reason about locks than barriers for the long term
> > > maintainability of this code. I'm with Jan and John on wanting to
> > > explore lock_page() before a barrier-based scheme.
> > 
> > How is the above hard to validate ?
> 
> Well, if you think it's so easy, then please write the test cases so
> we can add them to fstests and make sure that we don't break it in
> future.
> 
> If you can't write filesystem test cases that exercise these race
> conditions reliably, then the answer to your question is "it is
> extremely hard to validate" and the correct thing to do is to start
> with the simple lock_page() based algorithm.
> 
> Premature optimisation in code this complex is something we really,
> really need to avoid.

Litmus test shows that this never happens, i am attaching 2 litmus
test one with barrier and one without. Without barrier we can see
the double negative !PageWriteback in GUP and !page_pinned() in
test_set_page_writeback() (0:EAX = 0; 1:EAX = 0; below)


    ~/local/bin/litmus7 -r 100 gup.litmus

    ...

    Histogram (3 states)
    2     *>0:EAX=0; 1:EAX=0; x=1; y=1;
    4999999:>0:EAX=1; 1:EAX=0; x=1; y=1;
    4999999:>0:EAX=0; 1:EAX=1; x=1; y=1;
    Ok

    Witnesses
    Positive: 2, Negative: 9999998
    Condition exists (0:EAX=0 /\ 1:EAX=0) is validated
    Hash=2d53e83cd627ba17ab11c875525e078b
    Observation SB Sometimes 2 9999998
    Time SB 3.24



With the barrier this never happens:
    ~/local/bin/litmus7 -r 10000 gup-mb.litmus

    ...

    Histogram (3 states)
    499579828:>0:EAX=1; 1:EAX=0; x=1; y=1;
    499540152:>0:EAX=0; 1:EAX=1; x=1; y=1;
    880020:>0:EAX=1; 1:EAX=1; x=1; y=1;
    No

    Witnesses
    Positive: 0, Negative: 1000000000
    Condition exists (0:EAX=0 /\ 1:EAX=0) is NOT validated
    Hash=0dd48258687c8f737921f907c093c316
    Observation SB Never 0 1000000000


I do not know any better test than litmus for this kind of thing.

Cheers,
Jérôme

--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="gup.litmus"

X86 SB
"GUP"
{ x=0; y=0; }
 P0          | P1          ;
 MOV [x],$1  | MOV [y],$1  ;
 MOV EAX,[y] | MOV EAX,[x] ;
locations [x;y;]
exists (0:EAX=0 /\ 1:EAX=0)

--7AUc2qLy4jB3hD7Z
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="gup-mb.litmus"

X86 SB
"GUP with barrier"
{ x=0; y=0; }
 P0          | P1          ;
 MOV [x],$1  | MOV [y],$1  ;
 MFENCE      | MFENCE      ;
 MOV EAX,[y] | MOV EAX,[x] ;
locations [x;y;]
exists (0:EAX=0 /\ 1:EAX=0)

--7AUc2qLy4jB3hD7Z--
