Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 738D96B0005
	for <linux-mm@kvack.org>; Sun, 22 Apr 2018 10:02:58 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f19so8170596pfn.6
        for <linux-mm@kvack.org>; Sun, 22 Apr 2018 07:02:58 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 30-v6si7394000plf.104.2018.04.22.07.02.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 22 Apr 2018 07:02:55 -0700 (PDT)
Date: Sun, 22 Apr 2018 07:02:46 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC 2/8] mm: introduce PG_offline
Message-ID: <20180422140246.GA30714@bombadil.infradead.org>
References: <20180413131632.1413-1-david@redhat.com>
 <20180413131632.1413-3-david@redhat.com>
 <20180413171120.GA1245@bombadil.infradead.org>
 <89329958-2ff8-9447-408e-fd478b914ec4@suse.cz>
 <20180422030130.GG14610@bombadil.infradead.org>
 <7db70df4-c714-574c-5b14-898c1cf49af6@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <7db70df4-c714-574c-5b14-898c1cf49af6@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Miles Chen <miles.chen@mediatek.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, James Hogan <jhogan@kernel.org>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, open list <linux-kernel@vger.kernel.org>

On Sun, Apr 22, 2018 at 10:17:31AM +0200, David Hildenbrand wrote:
> On 22.04.2018 05:01, Matthew Wilcox wrote:
> > On Sat, Apr 21, 2018 at 06:52:18PM +0200, Vlastimil Babka wrote:
> >> Sounds like your newly introduced "page types" could be useful here? I
> >> don't suppose those offline pages would be using mapcount which is
> >> aliased there?
> > 
> > Oh, that's a good point!  Yes, this is a perfect use for page_type.
> > We have something like twenty bits available there.
> > 
> > Now you've got me thinking that we can move PG_hwpoison and PG_reserved
> > to be page_type flags too.  That'll take us from 23 to 21 bits (on 32-bit,
> > with PG_UNCACHED)
> 
> Some things to clarify here. I modified the current RFC to also allow
> PG_offline on allocated (ballooned) pages (e.g. virtio-balloon).
> 
> kdump based dump tools can then easily identify which pages are not to
> be dumped (either because the content is invalid or not accessible).
> 
> I previously stated that ballooned pages would be marked as PG_reserved,
> which is not true (at least not for virtio-balloon). However this allows
> me to detect if all pages in a section are offline by looking at
> (PG_reserved && PG_offline). So I can actually tell if a page is marked
> as offline and allocated or really offline.
> 
> 
> 1. The location (not the number!) of PG_hwpoison is basically ABI and
> cannot be changed. Moving it around will most probably break dump tools.
> (see kernel/crash_core.c)

It's not ABI.  It already changed after 4.9 when PG_waiters was introduced
by commit 62906027091f.

> 2. Exposing PG_offline via kdump will make it ABI as well. And we don't
> want any complicated validity checks ("is the bit valid or not?"),
> because that would imply having to make these bits ABI as well. So
> having PG_offline just like PG_hwpoison part of page_flags is the right
> thing to do. (see patch nr 4)
> 
> 3. For determining if all pages of a section are offline (see patch nr
> 5), I will have to be able to check 1. PG_offline and 2. PG_reserved on
> any page. Will this be possible by moving e.g. PG_reserved to page
> types? (especially if some field is suddenly aliased?)

It's possible to tell whether the field is in use as mapcount or
page_types; mapcount should always be non-negative, and page_types
reserves a few bits to detect under/overflow of mapcount.  The slab/slob
users of the field will also be positive uses.
