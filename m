Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 72A6F8E0001
	for <linux-mm@kvack.org>; Mon, 28 Jan 2019 10:04:32 -0500 (EST)
Received: by mail-qk1-f198.google.com with SMTP id k203so18546182qke.2
        for <linux-mm@kvack.org>; Mon, 28 Jan 2019 07:04:32 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id n127si699296qkf.230.2019.01.28.07.04.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 28 Jan 2019 07:04:31 -0800 (PST)
Date: Mon, 28 Jan 2019 10:04:20 -0500
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH RFC] mm: migrate: don't rely on PageMovable() of newpage
 after unlocking it
Message-ID: <20190128150420.GB10872@xps>
References: <20190128121609.9528-1-david@redhat.com>
 <20190128130709.GJ18811@dhcp22.suse.cz>
 <b03cae19-d02a-0ba2-69a1-010ee76748e7@redhat.com>
 <20190128132146.GK18811@dhcp22.suse.cz>
 <17e7d7e4-f4ca-a681-93e5-92a0c285be14@redhat.com>
 <20190128133514.GL18811@dhcp22.suse.cz>
 <cb3eccaf-0fbf-f3b8-dbbe-070acb9837be@redhat.com>
 <20190128150156.GA10872@xps>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20190128150156.GA10872@xps>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Hildenbrand <david@redhat.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Jan Kara <jack@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Dominik Brodowski <linux@dominikbrodowski.net>, Matthew Wilcox <willy@infradead.org>, Vratislav Bendel <vbendel@redhat.com>

On Mon, Jan 28, 2019 at 10:01:56AM -0500, Rafael Aquini wrote:
> On Mon, Jan 28, 2019 at 03:38:38PM +0100, David Hildenbrand wrote:
> > On 28.01.19 14:35, Michal Hocko wrote:
> > > On Mon 28-01-19 14:22:52, David Hildenbrand wrote:
> > >> On 28.01.19 14:21, Michal Hocko wrote:
> > >>> On Mon 28-01-19 14:14:28, David Hildenbrand wrote:
> > >>>> On 28.01.19 14:07, Michal Hocko wrote:
> > >>>>> On Mon 28-01-19 13:16:09, David Hildenbrand wrote:
> > >>>>> [...]
> > >>>>>> My theory:
> > >>>>>>
> > >>>>>> In __unmap_and_move(), we lock the old and newpage and perform the
> > >>>>>> migration. In case of vitio-balloon, the new page will become
> > >>>>>> movable, the old page will no longer be movable.
> > >>>>>>
> > >>>>>> However, after unlocking newpage, I think there is nothing stopping
> > >>>>>> the newpage from getting dequeued and freed by virtio-balloon. This
> > >>>>>> will result in the newpage
> > >>>>>> 1. No longer having PageMovable()
> > >>>>>> 2. Getting moved to the local list before finally freeing it (using
> > >>>>>>    page->lru)
> > >>>>>
> > >>>>> Does that mean that the virtio-balloon can change the Movable state
> > >>>>> while there are other users of the page? Can you point to the code that
> > >>>>> does it? How come this can be safe at all? Or is the PageMovable stable
> > >>>>> only under the page lock?
> > >>>>>
> > >>>>
> > >>>> PageMovable is stable under the lock. The relevant instructions are in
> > >>>>
> > >>>> mm/balloon_compaction.c and include/linux/balloon_compaction.h
> > >>>
> > >>> OK, I have just checked __ClearPageMovable and it indeed requires
> > >>> PageLock. Then we also have to move is_lru = __PageMovable(page) after
> > >>> the page lock.
> > >>>
> > >>
> > >> I assume that is fine as is as the page is isolated? (yes, it will be
> > >> modified later when moving but we are interested in the original state)
> > > 
> > > OK, I've missed that the page is indeed isolated. Then the patch makes
> > > sense to me.
> > > 
> > 
> > Thanks Michal. I assume this has broken ever since balloon compaction
> > was introduced. I'll wait a little more and then resend as !RFC with a
> > cc-stable tag.
> >
> 
> Yes, balloon deflation could always race against migration
> This race was a problem, initially, and was dealt with, via:
> 
> commit 117aad1e9e4d97448d1df3f84b08bd65811e6d6a
> Author: Rafael Aquini <aquini@redhat.com>
> Date:   Mon Sep 30 13:45:16 2013 -0700
> 
>     mm: avoid reinserting isolated balloon pages into LRU lists
> 
>  
> 
> I think this upstream patch has re-introduced it, in a more subtle way,
> as we're stumbling on it now, again:
> 
> commit d6d86c0a7f8ddc5b38cf089222cb1d9540762dc2
> Author: Konstantin Khlebnikov <k.khlebnikov@samsung.com>
> Date:   Thu Oct 9 15:29:27 2014 -0700
> 
>     mm/balloon_compaction: redesign ballooned pages management
>     
> 
> 
> On this particular race against migration case, virtio ballon deflation would 
> not see it before
> 
> commit b1123ea6d3b3da25af5c8a9d843bd07ab63213f4
> Author: Minchan Kim <minchan@kernel.org>
> Date:   Tue Jul 26 15:23:09 2016 -0700
> 
>     mm: balloon: use general non-lru movable page feature
> 
> as the recently released balloon page would be post-processed 
> without the page->lru list handling, which for migration stability
> purposes must be done under the protection of page_lock.
> 
> 

missing part here:

I think your patch adresses this new case.


Acked-by: Rafael Aquini <aquini@redhat.com>


> get rid of balloon reference count.

^^ this was a left over (sorry about my fat-fingers)
> 
> 
> -- Rafael
