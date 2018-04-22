Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 781576B0005
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 23:01:47 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t2so4407537pgb.19
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 20:01:47 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 33-v6si9487013plb.19.2018.04.21.20.01.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 21 Apr 2018 20:01:43 -0700 (PDT)
Date: Sat, 21 Apr 2018 20:01:30 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH RFC 2/8] mm: introduce PG_offline
Message-ID: <20180422030130.GG14610@bombadil.infradead.org>
References: <20180413131632.1413-1-david@redhat.com>
 <20180413131632.1413-3-david@redhat.com>
 <20180413171120.GA1245@bombadil.infradead.org>
 <89329958-2ff8-9447-408e-fd478b914ec4@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <89329958-2ff8-9447-408e-fd478b914ec4@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: David Hildenbrand <david@redhat.com>, linux-mm@kvack.org, Steven Rostedt <rostedt@goodmis.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Huang Ying <ying.huang@intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Pavel Tatashin <pasha.tatashin@oracle.com>, Miles Chen <miles.chen@mediatek.com>, Mel Gorman <mgorman@techsingularity.net>, Rik van Riel <riel@redhat.com>, James Hogan <jhogan@kernel.org>, "Levin, Alexander (Sasha Levin)" <alexander.levin@verizon.com>, open list <linux-kernel@vger.kernel.org>

On Sat, Apr 21, 2018 at 06:52:18PM +0200, Vlastimil Babka wrote:
> On 04/13/2018 07:11 PM, Matthew Wilcox wrote:
> > On Fri, Apr 13, 2018 at 03:16:26PM +0200, David Hildenbrand wrote:
> >> online_pages()/offline_pages() theoretically allows us to work on
> >> sub-section sizes. This is especially relevant in the context of
> >> virtualization. It e.g. allows us to add/remove memory to Linux in a VM in
> >> 4MB chunks.
> >>
> >> While the whole section is marked as online/offline, we have to know
> >> the state of each page. E.g. to not read memory that is not online
> >> during kexec() or to properly mark a section as offline as soon as all
> >> contained pages are offline.
> > 
> > Can you not use PG_reserved for this purpose?
> 
> Sounds like your newly introduced "page types" could be useful here? I
> don't suppose those offline pages would be using mapcount which is
> aliased there?

Oh, that's a good point!  Yes, this is a perfect use for page_type.
We have something like twenty bits available there.

Now you've got me thinking that we can move PG_hwpoison and PG_reserved
to be page_type flags too.  That'll take us from 23 to 21 bits (on 32-bit,
with PG_UNCACHED)
