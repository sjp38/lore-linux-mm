Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 19E486B0032
	for <linux-mm@kvack.org>; Mon,  9 Feb 2015 01:50:57 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id kx10so16647515pab.13
        for <linux-mm@kvack.org>; Sun, 08 Feb 2015 22:50:56 -0800 (PST)
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com. [209.85.192.173])
        by mx.google.com with ESMTPS id zt10si20895927pbc.18.2015.02.08.22.50.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 08 Feb 2015 22:50:56 -0800 (PST)
Received: by pdjz10 with SMTP id z10so11693138pdj.9
        for <linux-mm@kvack.org>; Sun, 08 Feb 2015 22:50:56 -0800 (PST)
Date: Mon, 9 Feb 2015 15:50:45 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: MADV_DONTNEED semantics? Was: [RFC PATCH] mm: madvise: Ignore
 repeated MADV_DONTNEED hints
Message-ID: <20150209065045.GB32300@blaptop>
References: <54D08483.40209@suse.cz>
 <20150203105301.GC14259@node.dhcp.inet.fi>
 <54D0B43D.8000209@suse.cz>
 <54D0F56A.9050003@gmail.com>
 <54D22298.3040504@suse.cz>
 <CAKgNAkgOOCuzJz9whoVfFjqhxM0zYsz94B1+oH58SthC5Ut9sg@mail.gmail.com>
 <54D2508A.9030804@suse.cz>
 <CAKgNAkhNbHQX7RukSsSe3bMqY11f493rYbDpTOA2jH7vsziNww@mail.gmail.com>
 <20150205154102.GA20607@dhcp22.suse.cz>
 <54D4E47E.4020509@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <54D4E47E.4020509@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Michael Kerrisk (man-pages)" <mtk.manpages@gmail.com>
Cc: Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Dave Hansen <dave.hansen@intel.com>, Mel Gorman <mgorman@suse.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, Linux API <linux-api@vger.kernel.org>, linux-man <linux-man@vger.kernel.org>, Hugh Dickins <hughd@google.com>

On Fri, Feb 06, 2015 at 04:57:50PM +0100, Michael Kerrisk (man-pages) wrote:
> Hi Michael
> 
> On 02/05/2015 04:41 PM, Michal Hocko wrote:
> > On Wed 04-02-15 20:24:27, Michael Kerrisk wrote:
> > [...]
> >> So, how about this text:
> >>
> >>               After a successful MADV_DONTNEED operation, the semana??
> >>               tics  of  memory  access  in  the specified region are
> >>               changed: subsequent accesses of  pages  in  the  range
> >>               will  succeed,  but will result in either reloading of
> >>               the memory contents from the  underlying  mapped  file
> > 
> > "
> > result in either providing the up-to-date contents of the underlying
> > mapped file
> > "
> 
> Thanks! I did something like that. See below.
> 
> > Would be more precise IMO because reload might be interpreted as a major
> > fault which is not necessarily the case (see below).
> > 
> >>               (for  shared file mappings, shared anonymous mappings,
> >>               and shmem-based techniques such  as  System  V  shared
> >>               memory  segments)  or  zero-fill-on-demand  pages  for
> >>               anonymous private mappings.
> > 
> > Yes, this wording is better because many users are not aware of
> > MAP_ANON|MAP_SHARED being file backed in fact and mmap man page doesn't
> > mention that.
> 
> (Michal, would you have a text to propose to add to the mmap(2) page?
> Maybe it would be useful to add something there.)
> 
> > 
> > I am just wondering whether it makes sense to mention that MADV_DONTNEED
> > for shared mappings might be surprising and not freeing the backing
> > pages thus not really freeing memory until there is a memory
> > pressure. But maybe this is too implementation specific for a man
> > page. What about the following wording on top of yours?
> > "
> > Please note that the MADV_DONTNEED hint on shared mappings might not
> > lead to immediate freeing of pages in the range. The kernel is free to
> > delay this until an appropriate moment. RSS of the calling process will
> > be reduced however.
> > "
> 
> Thanks! I added this, but dropped in the word "immediately" in the last 
> sentence, since I assume that was implied. So now we have:
> 
>               After  a  successful MADV_DONTNEED operation, the semana??
>               tics of  memory  access  in  the  specified  region  are
>               changed:  subsequent accesses of pages in the range will
>               succeed, but will result in either repopulating the mema??
>               ory  contents from the up-to-date contents of the undera??
>               lying mapped file  (for  shared  file  mappings,  shared
>               anonymous  mappings,  and shmem-based techniques such as
>               System V shared memory segments) or  zero-fill-on-demand
>               pages for anonymous private mappings.
> 
>               Note  that,  when applied to shared mappings, MADV_DONTa??
>               NEED might not lead to immediate freeing of the pages in
>               the  range.   The  kernel  is  free to delay freeing the
>               pages until an appropriate  moment.   The  resident  set
>               size  (RSS)  of  the calling process will be immediately
>               reduced however.

Looks good. So, I can parse it that anonymous private mappings will lead
to immediate freeing of the pages in the range so it's clearly different
with MADV_FREE.

> 
> The current draft of the page can be found in a branch,
> http://git.kernel.org/cgit/docs/man-pages/man-pages.git/log/?h=draft_madvise
> 
> Thanks,
> 
> Michael
> 
> 
> 
> -- 
> Michael Kerrisk
> Linux man-pages maintainer; http://www.kernel.org/doc/man-pages/
> Linux/UNIX System Programming Training: http://man7.org/training/

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
