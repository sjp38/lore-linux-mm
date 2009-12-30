Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 4E9F660021B
	for <linux-mm@kvack.org>; Wed, 30 Dec 2009 12:03:42 -0500 (EST)
Date: Wed, 30 Dec 2009 17:03:31 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: Re: [PATCH -mmotm-2009-12-10-17-19] Prevent churning of zero page
 in LRU list.
In-Reply-To: <20091228130926.6874d7b2.minchan.kim@barrios-desktop>
Message-ID: <alpine.LSU.2.00.0912301653200.4532@sister.anvils>
References: <20091228115315.76b1ecd0.minchan.kim@barrios-desktop> <4B38246C.3020209@redhat.com> <20091228130926.6874d7b2.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Dec 2009, Minchan Kim wrote:
> On Sun, 27 Dec 2009 22:22:20 -0500
> Rik van Riel <riel@redhat.com> wrote:
> > On 12/27/2009 09:53 PM, Minchan Kim wrote:
> > >
> > > VM doesn't add zero page to LRU list.
> > > It means zero page's churning in LRU list is pointless.
> > >
> > > As a matter of fact, zero page can't be promoted by mark_page_accessed
> > > since it doesn't have PG_lru.
> > >
> > > This patch prevent unecessary mark_page_accessed call of zero page
> > > alghouth caller want FOLL_TOUCH.
> > >
> > > Signed-off-by: Minchan Kim<minchan.kim@gmail.com>
> > 
> > The code looks correct, but I wonder how frequently we run into
> > the zero page in this code, vs. how much the added cost is of
> > having this extra code in follow_page.
> > 
> > What kind of problem were you running into that motivated you
> > to write this patch?
> 
> I didn't have experienced any problem in this case. 
> In fact, I found that while trying to make patch smap_pte_change. 
> 
> Long time ago when we have a zero page, we regards it to file_rss. 
> So while we see the smaps, vm_normal_page returns zero page and we can
> calculate it properly with PSS. 
> 
> But now we don't acccout zero page to file_rss. 
> I am not sure we have to account it with file_rss. 
> So I think now smaps_pte_range's resident count routine also is changed. 
> 
> Anyway, I think my patch doesn't have much cost since many customers of 
> follow_page are already not a fast path.
> 
> I tend to agree with your opinion "How frequently we runt into the zero page?"
> But my thought GUP is export function which can be used for anything by anyone.
> 
> Thanks for the review, Rik. 

I'm guessing that you've now dropped the idea of this patch,
since it wasn't included along with your 1/3, 2/3, 3/3.

You thought the ZERO_PAGE was moving around the LRUs, but now
realize that it isn't, so accept there's no need for this patch?

There's lots of places where we could shave a little time off dealing
with the ZERO_PAGE by adding tests for it; but at the expense of
adding code to normal paths of the system, slowing them down.

If there's a proven reason for doing so somewhere, yes, we should
add such tests to avoid significant cacheline bouncing; but without
good reason, we just let ZERO_PAGEs fall through the code as they do.

I believe that get_user_pages() on ZERO_PAGEs is exceptional, beyond
the cases of coredumping and mlock and make_pages_present; but if
you've evidence for adding a test somewhere, please provide it.

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
