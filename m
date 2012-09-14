Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx106.postini.com [74.125.245.106])
	by kanga.kvack.org (Postfix) with SMTP id 7FC8E6B018C
	for <linux-mm@kvack.org>; Thu, 13 Sep 2012 20:08:21 -0400 (EDT)
Date: Fri, 14 Sep 2012 09:10:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH] mm: cma: Discard clean pages during contiguous
 allocation instead of migration
Message-ID: <20120914001032.GD5085@bbox>
References: <1347324112-14134-1-git-send-email-minchan@kernel.org>
 <CAMuHMdXWZ=Jeggd7cT_LXK0MTnmFAf+cWEhC75B1gCcSd3eWeg@mail.gmail.com>
 <20120913151922.b8893088.akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120913151922.b8893088.akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Kyungmin Park <kmpark@infradead.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Linux-Next <linux-next@vger.kernel.org>

On Thu, Sep 13, 2012 at 03:19:22PM -0700, Andrew Morton wrote:
> On Thu, 13 Sep 2012 21:17:19 +0200
> Geert Uytterhoeven <geert@linux-m68k.org> wrote:
> 
> > On Tue, Sep 11, 2012 at 2:41 AM, Minchan Kim <minchan@kernel.org> wrote:
> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -674,8 +674,10 @@ static enum page_references page_check_references(struct page *page,
> > >  static unsigned long shrink_page_list(struct list_head *page_list,
> > >                                       struct zone *zone,
> > >                                       struct scan_control *sc,
> > > +                                     enum ttu_flags ttu_flags,
> > 
> > "enum ttu_flags" is defined on CONFIG_MMU=y only, causing on nommu:
> > 
> > mm/vmscan.c:677:26: error: parameter 4 ('ttu_flags') has incomplete type
> > mm/vmscan.c:987:5: error: 'TTU_UNMAP' undeclared (first use in this function)
> > mm/vmscan.c:987:15: error: 'TTU_IGNORE_ACCESS' undeclared (first use
> > in this function)
> > mm/vmscan.c:1312:56: error: 'TTU_UNMAP' undeclared (first use in this function)
> > 
> > E.g.
> > http://kisskb.ellerman.id.au/kisskb/buildresult/7191694/ (h8300-defconfig)
> > http://kisskb.ellerman.id.au/kisskb/buildresult/7191858/ (sh-allnoconfig)
> 
> hm, OK, the means by which current mainline avoids build errors is
> either clever or lucky.
> 
> 			switch (try_to_unmap(page, TTU_UNMAP)) {
> 
> gets preprocessed into
> 
> 			switch (2) {
> 
> so the cmopiler never gets to see the TTU_ symbol at all.  Because it
> happens to be inside the try_to_unmap() call.
> 
> 
> I guess we can just make ttu_flags visible to NOMMU:

I agree.

Geert, Andrew
Thanks for the reporting and quick fix!

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
