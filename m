Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id F003A6B007E
	for <linux-mm@kvack.org>; Mon, 21 Mar 2016 19:54:50 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id x3so283675192pfb.1
        for <linux-mm@kvack.org>; Mon, 21 Mar 2016 16:54:50 -0700 (PDT)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id r74si5234947pfa.134.2016.03.21.16.54.49
        for <linux-mm@kvack.org>;
        Mon, 21 Mar 2016 16:54:49 -0700 (PDT)
Date: Tue, 22 Mar 2016 08:56:04 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v2 01/18] mm: use put_page to free page instead of
 putback_lru_page
Message-ID: <20160321235604.GB27197@bbox>
References: <1458541867-27380-1-git-send-email-minchan@kernel.org>
 <1458541867-27380-2-git-send-email-minchan@kernel.org>
 <56EF9F27.9060400@samsung.com>
MIME-Version: 1.0
In-Reply-To: <56EF9F27.9060400@samsung.com>
Content-Type: text/plain; charset="utf-8"
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chulmin Kim <cmlaika.kim@samsung.com>
Cc: linux-mm@kvack.org

On Mon, Mar 21, 2016 at 04:13:43PM +0900, Chulmin Kim wrote:
> On 2016=EB=85=84 03=EC=9B=94 21=EC=9D=BC 15:30, Minchan Kim wrote:
> >Procedure of page migration is as follows:
> >
> >First of all, it should isolate a page from LRU and try to
> >migrate the page. If it is successful, it releases the page
> >for freeing. Otherwise, it should put the page back to LRU
> >list.
> >
> >For LRU pages, we have used putback=5Flru=5Fpage for both freeing
> >and putback to LRU list. It's okay because put=5Fpage is aware of
> >LRU list so if it releases last refcount of the page, it removes
> >the page from LRU list. However, It makes unnecessary operations
> >(e.g., lru=5Fcache=5Fadd, pagevec and flags operations. It would be
> >not significant but no worth to do) and harder to support new
> >non-lru page migration because put=5Fpage isn't aware of non-lru
> >page's data structure.
> >
> >To solve the problem, we can add new hook in put=5Fpage with
> >PageMovable flags check but it can increase overhead in
> >hot path and needs new locking scheme to stabilize the flag check
> >with put=5Fpage.
> >
> >So, this patch cleans it up to divide two semantic(ie, put and putback).
> >If migration is successful, use put=5Fpage instead of putback=5Flru=5Fpa=
ge and
> >use putback=5Flru=5Fpage only on failure. That makes code more readable
> >and doesn't add overhead in put=5Fpage.
> >
> >Comment from Vlastimil
> >"Yeah, and compaction (perhaps also other migration users) has to drain
> >the lru pvec... Getting rid of this stuff is worth even by itself."
> >
> >Cc: Mel Gorman <mgorman@suse.de>
> >Cc: Hugh Dickins <hughd@google.com>
> >Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> >Acked-by: Vlastimil Babka <vbabka@suse.cz>
> >Signed-off-by: Minchan Kim <minchan@kernel.org>
> >---
> >  mm/migrate.c | 50 +++++++++++++++++++++++++++++++-------------------
> >  1 file changed, 31 insertions(+), 19 deletions(-)
> >
> >diff --git a/mm/migrate.c b/mm/migrate.c
> >index 6c822a7b27e0..b65c84267ce0 100644
> >--- a/mm/migrate.c
> >+++ b/mm/migrate.c
> >@@ -913,6 +913,14 @@ static int =5F=5Funmap=5Fand=5Fmove(struct page *pa=
ge, struct page *newpage,
> >  		put=5Fanon=5Fvma(anon=5Fvma);
> >  	unlock=5Fpage(page);
> >  out:
> >+	/* If migration is scucessful, move newpage to right list */
>=20
> A minor comment fix :)
>  +	/* If migration is successful, move newpage to right list */

Hello Chulmin,

Fixed the typo.

Thanks for the review!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
