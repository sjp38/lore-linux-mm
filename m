Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5F5526B051C
	for <linux-mm@kvack.org>; Thu, 17 May 2018 13:31:39 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id o143-v6so7783961itg.9
        for <linux-mm@kvack.org>; Thu, 17 May 2018 10:31:39 -0700 (PDT)
Received: from aserp2120.oracle.com (aserp2120.oracle.com. [141.146.126.78])
        by mx.google.com with ESMTPS id j185-v6si4990520iof.239.2018.05.17.10.31.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 May 2018 10:31:38 -0700 (PDT)
Content-Type: text/plain;
	charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.4 \(3445.8.2\))
Subject: Re: [RFC] mm, THP: Map read-only text segments using large THP pages
From: William Kucharski <william.kucharski@oracle.com>
In-Reply-To: <20180517152333.GA26718@bombadil.infradead.org>
Date: Thu, 17 May 2018 11:31:14 -0600
Content-Transfer-Encoding: quoted-printable
Message-Id: <714E0B73-BE6C-408B-98A6-2A7C82E7BB11@oracle.com>
References: <5BB682E1-DD52-4AA9-83E9-DEF091E0C709@oracle.com>
 <20180517152333.GA26718@bombadil.infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org



> On May 17, 2018, at 9:23 AM, Matthew Wilcox <willy@infradead.org> =
wrote:
>=20
> I'm certain it is.  The other thing I believe is true that we should =
be
> able to share page tables (my motivation is thousands of processes =
each
> mapping the same ridiculously-sized file).  I was hoping this =
prototype
> would have code that would be stealable for that purpose, but you've
> gone in a different direction.  Which is fine for a prototype; you've
> produced useful numbers.

Definitely, and that's why I mentioned integration with the page cache
would be crucial. This prototype allocates pages for each invocation of
the executable, which would never fly on a real system.

> I think the first step is to get variable sized pages in the page =
cache
> working.  Then the map-around functionality can probably just notice =
if
> they're big enough to map with a PMD and make that happen.  I don't =
immediately
> see anything from this PoC that can be used, but it at least gives us =
a
> good point of comparison for any future work.

Yes, that's the first step to getting actual usable code designed and
working; this prototype was designed just to get something working and
to get a first swag at some performance numbers.

I do think that adding code to map larger pages as a fault_around =
variant
is a good start as the code is already going to potentially map in
fault_around_bytes from the file to satisfy the fault. It makes sense
to extend that paradigm to be able to tune when large pages might be
read in and/or mapped using large pages extant in the page cache.

Filesystem support becomes more important once writing to large pages
is allowed.

> I think that really tells the story.  We almost entirely eliminate
> dTLB load misses (down to almost 0.1%) and iTLB load misses drop to 4%
> of what they were.  Does this test represent any kind of real world =
load,
> or is it designed to show the best possible improvement?

It's admittedly designed to thrash the caches pretty hard and doesn't
represent any type of actual workload I'm aware of. It basically calls
various routines within a huge text area while scribbling to automatic
arrays declared at the top of each routine. It wasn't designed as a =
worst
case scenario, but rather as one that would hopefully show some obvious
degree of difference when large text pages were supported.

Thanks for your comments.

    -- Bill=
