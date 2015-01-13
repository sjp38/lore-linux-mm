Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 450126B0032
	for <linux-mm@kvack.org>; Tue, 13 Jan 2015 02:56:08 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kq14so2136458pab.12
        for <linux-mm@kvack.org>; Mon, 12 Jan 2015 23:56:07 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id hw10si26278912pab.71.2015.01.12.23.56.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Jan 2015 23:56:06 -0800 (PST)
Date: Tue, 13 Jan 2015 10:55:57 +0300
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: Re: [PATCH -mm 2/2] mm: vmscan: init reclaim_state in
 do_try_to_free_pages
Message-ID: <20150113075557.GH2110@esperanza>
References: <880700a513472a8b86fd3100aef674322c66c68e.1421054931.git.vdavydov@parallels.com>
 <20a8ae66cc2b9412b1bf81c0a46f4e8c737aa537.1421054931.git.vdavydov@parallels.com>
 <20150112222634.GC25609@phnom.home.cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20150112222634.GC25609@phnom.home.cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Jan 12, 2015 at 05:26:34PM -0500, Johannes Weiner wrote:
> On Mon, Jan 12, 2015 at 12:30:38PM +0300, Vladimir Davydov wrote:
> > All users of do_try_to_free_pages() want to have current->reclaim_state
> > set in order to account reclaimed slab pages. So instead of duplicating
> > the reclaim_state initialization code in each call site, let's do it
> > directly in do_try_to_free_pages().
> 
> Couldn't this be contained in shrink_slab() directly?

I had considered this possibility, but finally rejected it, because

 - some slab pages can be reclaimed from shrink_lruvec (e.g.
   buffer_head's); there shouldn't be too many of them though

 - struct reclaim_state looks to me as a generic placeholder for lots of
   reclaim-related stuff, though currently it is only used for counting
   reclaimed slab pages, so IMO it should be initialized before starting
   reclaim

Both arguments are not rock-solid as you can see, so if you think we can
neglect them, I'll do.

Thanks,
Vladimir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
