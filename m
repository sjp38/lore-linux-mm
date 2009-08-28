Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E81D76B00AC
	for <linux-mm@kvack.org>; Fri, 28 Aug 2009 08:16:30 -0400 (EDT)
Received: by fxm18 with SMTP id 18so1557369fxm.38
        for <linux-mm@kvack.org>; Fri, 28 Aug 2009 05:16:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1251449067-3109-3-git-send-email-mel@csn.ul.ie>
References: <1251449067-3109-1-git-send-email-mel@csn.ul.ie>
	 <1251449067-3109-3-git-send-email-mel@csn.ul.ie>
Date: Fri, 28 Aug 2009 15:16:34 +0300
Message-ID: <84144f020908280516y6473a531n3f11f3e86251eba4@mail.gmail.com>
Subject: Re: [PATCH 2/2] page-allocator: Maintain rolling count of pages to
	free from the PCP
From: Pekka Enberg <penberg@cs.helsinki.fi>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Hi Mel,

On Fri, Aug 28, 2009 at 11:44 AM, Mel Gorman<mel@csn.ul.ie> wrote:
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D list_entry(list->prev, struct page=
, lru);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* have to delete it as __free_one_page lis=
t manipulates */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&page->lru);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_page_pcpu_drain(page, 0, migratety=
pe);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_one_page(page, zone, 0, migratetype)=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 page =3D list_entry(list->p=
rev, struct page, lru);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* must delete as __free_on=
e_page list manipulates */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 list_del(&page->lru);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __free_one_page(page, zone,=
 0, migratetype);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 trace_mm_page_pcpu_drain(pa=
ge, 0, migratetype);

This calls trace_mm_page_pcpu_drain() *after* __free_one_page(). It's
probably not a good idea as __free_one_page() can alter the struct
page in various ways.

> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } while (--count && --batch_free && !list_e=
mpty(list));
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0spin_unlock(&zone->lock);
> =A0}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
