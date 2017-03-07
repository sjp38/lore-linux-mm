Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 6BAAC6B038B
	for <linux-mm@kvack.org>; Tue,  7 Mar 2017 10:24:42 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id u9so2329674wme.6
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:24:42 -0800 (PST)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id o67si19297059wmo.87.2017.03.07.07.24.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 07 Mar 2017 07:24:41 -0800 (PST)
Received: by mail-wm0-x244.google.com with SMTP id u132so1556092wmg.1
        for <linux-mm@kvack.org>; Tue, 07 Mar 2017 07:24:40 -0800 (PST)
Date: Tue, 7 Mar 2017 18:24:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC 06/11] mm: remove SWAP_MLOCK in ttu
Message-ID: <20170307152437.GB2940@node.shutemov.name>
References: <1488436765-32350-1-git-send-email-minchan@kernel.org>
 <1488436765-32350-7-git-send-email-minchan@kernel.org>
 <54799ea5-005d-939c-de32-bc21af881ab4@linux.vnet.ibm.com>
 <20170306021508.GD8779@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170306021508.GD8779@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>, g@node.shutemov.name
Cc: Anshuman Khandual <khandual@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kernel-team@lge.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.com>

On Mon, Mar 06, 2017 at 11:15:08AM +0900, Minchan Kim wrote:
> Hi Anshuman,
> 
> On Fri, Mar 03, 2017 at 06:06:38PM +0530, Anshuman Khandual wrote:
> > On 03/02/2017 12:09 PM, Minchan Kim wrote:
> > > ttu don't need to return SWAP_MLOCK. Instead, just return SWAP_FAIL
> > > because it means the page is not-swappable so it should move to
> > > another LRU list(active or unevictable). putback friends will
> > > move it to right list depending on the page's LRU flag.
> > 
> > Right, if it cannot be swapped out there is not much difference with
> > SWAP_FAIL once we change the callers who expected to see a SWAP_MLOCK
> > return instead.
> > 
> > > 
> > > A side effect is shrink_page_list accounts unevictable list movement
> > > by PGACTIVATE but I don't think it corrupts something severe.
> > 
> > Not sure I got that, could you please elaborate on this. We will still
> > activate the page and put it in an appropriate LRU list if it is marked
> > mlocked ?
> 
> Right. putback_iactive_pages/putback_lru_page has a logic to filter
> out unevictable pages and move them to unevictable LRU list so it
> doesn't break LRU change behavior but the concern is until now,
> we have accounted PGACTIVATE for only evictable LRU list page but
> by this change, it accounts it to unevictable LRU list as well.
> However, although I don't think it's big problem in real practice,
> we can fix it simply with checking PG_mlocked if someone reports.

I think it's better to do this pro-actively. Let's hide both pgactivate++
and SetPageActive() under "if (!PageMlocked())".
SetPageActive() is not free.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
