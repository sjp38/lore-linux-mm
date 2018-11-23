Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 338A96B329B
	for <linux-mm@kvack.org>; Fri, 23 Nov 2018 15:11:14 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id g188so4623075pgc.22
        for <linux-mm@kvack.org>; Fri, 23 Nov 2018 12:11:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y5sor166017plk.43.2018.11.23.12.11.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 23 Nov 2018 12:11:12 -0800 (PST)
Date: Fri, 23 Nov 2018 12:11:02 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH v3] mm: use swp_offset as key in shmem_replace_page()
In-Reply-To: <20181121210159.3a5fb6946e460c561fdec391@linux-foundation.org>
Message-ID: <alpine.LSU.2.11.1811231140190.1964@eggly.anvils>
References: <20181119010924.177177-1-yuzhao@google.com> <20181121215442.138545-1-yuzhao@google.com> <20181121210159.3a5fb6946e460c561fdec391@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yu Zhao <yuzhao@google.com>, Hugh Dickins <hughd@google.com>, Matthew Wilcox <willy@infradead.org>, stable@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 21 Nov 2018, Andrew Morton wrote:
> On Wed, 21 Nov 2018 14:54:42 -0700 Yu Zhao <yuzhao@google.com> wrote:
> 
> > We changed key of swap cache tree from swp_entry_t.val to
> > swp_offset. Need to do so in shmem_replace_page() as well.
> 
> What are the user-visible effects of this change?

Sorry, I don't know; and I don't know whether it's something Yu noticed
by source inspection, or in trying to use it, perhaps in some new way:
I assume the former, but he can add more info if the latter.

shmem_replace_page() was added in 3.5, to allow Intel's GMA500 graphics
driver to use the shmem support for GEM objects, despite its hardware
addressing limitations.  (I did once try to extend it to NUMA placement,
but that turned out to be a waste, doing more harm than good.)

My guess at user-visible effects would be that the screen goes blank
or weird on GMA500 after a bout of swapping (because shmem_getpage_gfp()
failed to bring back a part of the object).  The code in shmem.c looks
robust (amusing to see my "Is this possible? I think not" comment!),
but I don't know how it plays out at the graphics driver end.

> 
> > Fixes: f6ab1f7f6b2d ("mm, swap: use offset of swap entry as key of swap cache")
> > Cc: stable@vger.kernel.org # v4.9+
> 
> Please always provide the user-impact information when fixing bugs.  This
> becomes especially important when proposing -stable backporting.

So far as I know, nothing but GMA500 gets to use it, but perhaps other
uses have been added since.  We could ask around, but, frankly I'd prefer
just to remove the Fixes and Cc stable tags if they're causing trouble.
It's just a good simple bugfix, we thought stable would be glad of it.

> 
> Hugh said
> 
> : shmem_replace_page() has been wrong since the day I wrote it: good
> : enough to work on swap "type" 0, which is all most people ever use
> : (especially those few who need shmem_replace_page() at all), but broken
> : once there are any non-0 swp_type bits set in the higher order bits.

Yu then kindly restored my honour on that: I was misreading,
it was not broken from the start, but got broken by the commit in 4.9.

> 
> but we still don't have a description of "broken".
> 
> Thanks.

Hugh
