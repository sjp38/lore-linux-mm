Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 9A5846B004D
	for <linux-mm@kvack.org>; Sun, 21 Jun 2009 22:39:22 -0400 (EDT)
Date: Mon, 22 Jun 2009 11:39:53 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: BUG: Bad page state [was: Strange oopses in 2.6.30]
In-Reply-To: <4A3CFFEC.1000805@gmail.com>
References: <1245506908.6327.36.camel@localhost> <4A3CFFEC.1000805@gmail.com>
Message-Id: <20090622113652.21E7.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Jiri Slaby <jirislaby@gmail.com>
Cc: kosaki.motohiro@jp.fujitsu.com, Maxim Levitsky <maximlevitsky@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>
List-ID: <linux-mm.kvack.org>

(cc to Mel and some reviewer)

> Flags are:
> 0000000000400000 -- __PG_MLOCKED
> 800000000050000c -- my page flags
>         3650000c -- Maxim's page flags
> 0000000000693ce1 -- my PAGE_FLAGS_CHECK_AT_FREE

I guess commit da456f14d (page allocator: do not disable interrupts in
free_page_mlock()) is a bit wrong.

current code is:
-------------------------------------------------------------
static void free_hot_cold_page(struct page *page, int cold)
{
(snip)
        int clearMlocked = PageMlocked(page);
(snip)
        if (free_pages_check(page))
                return;
(snip)
        local_irq_save(flags);
        if (unlikely(clearMlocked))
                free_page_mlock(page);
-------------------------------------------------------------

Oh well, we remove PG_Mlocked *after* free_pages_check().
Then, it makes false-positive warning.

Sorry, my review was also wrong. I think reverting this patch is better ;)





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
