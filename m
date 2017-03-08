Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5184E6B039C
	for <linux-mm@kvack.org>; Wed,  8 Mar 2017 01:42:46 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b2so42609981pgc.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 22:42:46 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id d81si2334696pfd.82.2017.03.07.22.42.44
        for <linux-mm@kvack.org>;
        Tue, 07 Mar 2017 22:42:45 -0800 (PST)
Date: Wed, 8 Mar 2017 15:42:42 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 06/11] mm: remove SWAP_MLOCK in ttu
Message-ID: <20170308064242.GH11206@bbox>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-7-git-send-email-minchan@kernel.org>
 <54799ea5-005d-939c-de32-bc21af881ab4@linux.vnet.ibm.com>
 <20170306021508.GD8779@bbox>
 <20170307152437.GB2940@node.shutemov.name>
MIME-Version: 1.0
In-Reply-To: <20170307152437.GB2940@node.shutemov.name>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: g@node.shutemov.name, Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On Tue, Mar 07, 2017 at 06:24:37PM +0300, Kirill A. Shutemov wrote:
> On Mon, Mar 06, 2017 at 11:15:08AM +0900, Minchan Kim wrote:
> > Hi Anshuman,
> > 
> > On Fri, Mar 03, 2017 at 06:06:38PM +0530, Anshuman Khandual wrote:
> > > On 03/02/2017 12:09 PM, Minchan Kim wrote:
> > > > ttu don't need to return SWAP_MLOCK. Instead, just return SWAP_FAIL
> > > > because it means the page is not-swappable so it should move to
> > > > another LRU list(active or unevictable). putback friends will
> > > > move it to right list depending on the page's LRU flag.
> > > 
> > > Right, if it cannot be swapped out there is not much difference with
> > > SWAP_FAIL once we change the callers who expected to see a SWAP_MLOCK
> > > return instead.
> > > 
> > > > 
> > > > A side effect is shrink_page_list accounts unevictable list movement
> > > > by PGACTIVATE but I don't think it corrupts something severe.
> > > 
> > > Not sure I got that, could you please elaborate on this. We will still
> > > activate the page and put it in an appropriate LRU list if it is marked
> > > mlocked ?
> > 
> > Right. putback_iactive_pages/putback_lru_page has a logic to filter
> > out unevictable pages and move them to unevictable LRU list so it
> > doesn't break LRU change behavior but the concern is until now,
> > we have accounted PGACTIVATE for only evictable LRU list page but
> > by this change, it accounts it to unevictable LRU list as well.
> > However, although I don't think it's big problem in real practice,
> > we can fix it simply with checking PG_mlocked if someone reports.
> 
> I think it's better to do this pro-actively. Let's hide both pgactivate++
> and SetPageActive() under "if (!PageMlocked())".
> SetPageActive() is not free.

I will consider it in next spin.

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
