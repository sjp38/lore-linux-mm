Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 220946B0005
	for <linux-mm@kvack.org>; Mon, 13 Aug 2018 06:52:32 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id f13-v6so7086443pgs.15
        for <linux-mm@kvack.org>; Mon, 13 Aug 2018 03:52:32 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r9-v6sor4758702pls.43.2018.08.13.03.52.30
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 13 Aug 2018 03:52:30 -0700 (PDT)
Date: Mon, 13 Aug 2018 19:55:36 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [PATCH] zsmalloc: fix linking bug in init_zspage
Message-ID: <20180813105536.GA435@jagdpanzerIV>
References: <20180810002817.2667-1-zhouxianrong@tom.com>
 <20180813060549.GB64836@rodete-desktop-imager.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180813060549.GB64836@rodete-desktop-imager.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: zhouxianrong <zhouxianrong@tom.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, ngupta@vflare.org, sergey.senozhatsky.work@gmail.com, zhouxianrong <zhouxianrong@huawei.com>

On (08/13/18 15:05), Minchan Kim wrote:
> > From: zhouxianrong <zhouxianrong@huawei.com>
> > 
> > The last partial object in last subpage of zspage should not be linked
> > in allocation list. Otherwise it could trigger BUG_ON explicitly at
> > function zs_map_object. But it happened rarely.
> 
> Could you be more specific? What case did you see the problem?
> Is it a real problem or one founded by review?
[..]
> > Signed-off-by: zhouxianrong <zhouxianrong@huawei.com>
> > ---
> >  mm/zsmalloc.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
> > index 8d87e973a4f5..24dd8da0aa59 100644
> > --- a/mm/zsmalloc.c
> > +++ b/mm/zsmalloc.c
> > @@ -1040,6 +1040,8 @@ static void init_zspage(struct size_class *class, struct zspage *zspage)
> >  			 * Reset OBJ_TAG_BITS bit to last link to tell
> >  			 * whether it's allocated object or not.
> >  			 */
> > +			if (off > PAGE_SIZE)
> > +				link -= class->size / sizeof(*link);
> >  			link->next = -1UL << OBJ_TAG_BITS;
> >  		}
> >  		kunmap_atomic(vaddr);

Hmm. This can be a real issue. Unless I'm missing something.

So... I might be wrong, but the way I see the bug report is:

When we link objects during zspage init, we do the following:

	while ((off += class->size) < PAGE_SIZE) {
		link->next = freeobj++ << OBJ_TAG_BITS;
		link += class->size / sizeof(*link);
	}

Note that we increment the link first, link += class->size / sizeof(*link),
and check for the offset only afterwards. So by the time we break out of
the while-loop the link *might* point to the partial object which starts at
the last page of zspage, but *never* ends, because we don't have next_page
in current zspage. So that's why that object should not be linked in,
because it's not a valid allocates object - we simply don't have space
for it anymore.

zspage [      page 1     ][      page 2      ]
        ...............................link
	                                   [..###]

therefore the last object must be "link - 1" for such cases.

I think, the following change can also do the trick:

	while ((off + class->size) < PAGE_SIZE) {
		link->next = freeobj++ << OBJ_TAG_BITS;
		link += class->size / sizeof(*link);
		off += class->size;
	}

Once again, I might be wrong on this.
Any thoughts?

	-ss
