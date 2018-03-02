Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C8D106B0003
	for <linux-mm@kvack.org>; Fri,  2 Mar 2018 08:01:25 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id o19so4100491pgn.12
        for <linux-mm@kvack.org>; Fri, 02 Mar 2018 05:01:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d9si2013729pga.789.2018.03.02.05.01.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 02 Mar 2018 05:01:24 -0800 (PST)
Date: Fri, 2 Mar 2018 14:01:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: fix memmap_init_zone pageblock alignment
Message-ID: <20180302130052.GN15057@dhcp22.suse.cz>
References: <1519908465-12328-1-git-send-email-neelx@redhat.com>
 <20180301131033.GH15057@dhcp22.suse.cz>
 <CACjP9X-S=OgmUw-WyyH971_GREn1WzrG3aeGkKLyR1bO4_pWPA@mail.gmail.com>
 <20180301152729.GM15057@dhcp22.suse.cz>
 <CACjP9X8hFDhkKUHRu2K5WgEp9YFHh2=vMSyM6KkZ5UZtxs7k-w@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACjP9X8hFDhkKUHRu2K5WgEp9YFHh2=vMSyM6KkZ5UZtxs7k-w@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Pavel Tatashin <pasha.tatashin@oracle.com>, Paul Burton <paul.burton@imgtec.com>, stable@vger.kernel.org

On Thu 01-03-18 17:20:04, Daniel Vacek wrote:
> On Thu, Mar 1, 2018 at 4:27 PM, Michal Hocko <mhocko@kernel.org> wrote:
> > On Thu 01-03-18 16:09:35, Daniel Vacek wrote:
> > [...]
> >> $ grep 7b7ff000 /proc/iomem
> >> 7b7ff000-7b7fffff : System RAM
> > [...]
> >> After commit b92df1de5d28 machine eventually crashes with:
> >>
> >> BUG at mm/page_alloc.c:1913
> >>
> >> >         VM_BUG_ON(page_zone(start_page) != page_zone(end_page));
> >
> > This is an important information that should be in the changelog.
> 
> And that's exactly what my seven very first words tried to express in
> human readable form instead of mechanically pasting the source code. I
> guess that's a matter of preference. Though I see grepping later can
> be an issue here.

Do not get me wrong I do not want to nag just for fun of it. The
changelog should be really clear about the problem. What might be clear
to you based on the debugging might not be so clear to others. And the
struct page initialization code is far from trivial especially when we
have different alignment requirements by the memory model and the page
allocator.

Therefore being as clear as possible is really valuable. So I would
really love to see the changelog to contain.
- What is going on - VM_BUG_ON in move_freepages along with the crash
  report
- memory ranges exported by BIOS/FW
- explain why is the pageblock alignment the proper one. How does the
  range look from the memory section POV (with SPARSEMEM).
- What about those unaligned pages which are not backed by any memory?
  Are they reserved so that they will never get used?

And just to be clear. I am not saying your patch is wrong. It just
raises more questions than answers and I suspect it just papers over
some more fundamental problem. I might be clearly wrong and I cannot
deserve this more time for the next week because I will be offline
but I would _really_ appreciate if this all got explained.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
