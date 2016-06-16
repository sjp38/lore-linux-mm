Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7D2F46B0260
	for <linux-mm@kvack.org>; Thu, 16 Jun 2016 06:09:23 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id g13so83393770ioj.3
        for <linux-mm@kvack.org>; Thu, 16 Jun 2016 03:09:23 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 198si4886872ioz.44.2016.06.16.03.09.22
        for <linux-mm@kvack.org>;
        Thu, 16 Jun 2016 03:09:22 -0700 (PDT)
Date: Thu, 16 Jun 2016 19:09:32 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v7 00/12] Support non-lru page migration
Message-ID: <20160616100932.GS17127@bbox>
References: <1464736881-24886-1-git-send-email-minchan@kernel.org>
 <20160615075909.GA425@swordfish>
 <20160615231248.GI17127@bbox>
 <20160616024827.GA497@swordfish>
 <20160616025800.GO17127@bbox>
 <20160616042343.GA516@swordfish>
 <20160616044710.GP17127@bbox>
 <20160616052209.GB516@swordfish>
 <20160616064753.GR17127@bbox>
 <20160616084211.GA432@swordfish>
MIME-Version: 1.0
In-Reply-To: <20160616084211.GA432@swordfish>
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, dri-devel@lists.freedesktop.org, Hugh Dickins <hughd@google.com>, John Einar Reitan <john.reitan@foss.arm.com>, Jonathan Corbet <corbet@lwn.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Mel Gorman <mgorman@suse.de>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Rafael Aquini <aquini@redhat.com>, Rik van Riel <riel@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, virtualization@lists.linux-foundation.org, Gioh Kim <gi-oh.kim@profitbricks.com>, Chan Gyun Jeong <chan.jeong@lge.com>, Sangseok Lee <sangseok.lee@lge.com>, Kyeongdon Kim <kyeongdon.kim@lge.com>, Chulmin Kim <cmlaika.kim@samsung.com>

On Thu, Jun 16, 2016 at 05:42:11PM +0900, Sergey Senozhatsky wrote:
> On (06/16/16 15:47), Minchan Kim wrote:
> > > [..]
> > > > > this is what I'm getting with the [zsmalloc: keep first object offset in struct page]
> > > > > applied:  "count:0 mapcount:-127". which may be not related to zsmalloc at this point.
> > > > > 
> > > > > kernel: BUG: Bad page state in process khugepaged  pfn:101db8
> > > > > kernel: page:ffffea0004076e00 count:0 mapcount:-127 mapping:          (null) index:0x1
> > > > 
> > > > Hm, it seems double free.
> > > > 
> > > > It doen't happen if you disable zram? IOW, it seems to be related
> > > > zsmalloc migration?
> > > 
> > > need to test more, can't confidently answer now.
> > > 
> > > > How easy can you reprodcue it? Could you bisect it?
> > > 
> > > it takes some (um.. random) time to trigger the bug.
> > > I'll try to come up with more details.
> > 
> > Could you revert [1] and retest?
> > 
> > [1] mm/compaction: split freepages without holding the zone lock
> 
> ok, so this is not related to zsmalloc. finally manged to reproduce
> it. will fork a separate thread.

The reason I mentioned [1] is that it seems to have a bug.

isolate_freepages_block
  __isolate_free_page
    if(!zone_watermark_ok())
      return 0;
  list_add_tail(&page->lru, freelist);

However, the page is not isolated.
Joonsoo?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
