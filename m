Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id EF6786B0033
	for <linux-mm@kvack.org>; Mon,  1 Jul 2013 11:25:18 -0400 (EDT)
Date: Mon, 01 Jul 2013 11:25:03 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Message-ID: <1372692303-56f0gltk-mutt-n-horiguchi@ah.jp.nec.com>
In-Reply-To: <20130701091355.GA14444@gchen.bj.intel.com>
References: <1368807482-11153-1-git-send-email-n-horiguchi@ah.jp.nec.com>
 <20130701091355.GA14444@gchen.bj.intel.com>
Subject: Re: [PATCH] mm/memory-failure.c: fix memory leak in successful soft
 offlining
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gong.chen@linux.intel.com
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org

On Mon, Jul 01, 2013 at 05:13:55AM -0400, Chen Gong wrote:
> On Fri, May 17, 2013 at 12:18:02PM -0400, Naoya Horiguchi wrote:
> > Date: Fri, 17 May 2013 12:18:02 -0400
> > From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > To: linux-mm@kvack.org
> > Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen
> >  <andi@firstfloor.org>, linux-kernel@vger.kernel.org, Naoya Horiguchi
> >  <n-horiguchi@ah.jp.nec.com>
> > Subject: [PATCH] mm/memory-failure.c: fix memory leak in successful soft
> >  offlining
> > 
> > After a successful page migration by soft offlining, the source page is
> > not properly freed and it's never reusable even if we unpoison it afterward.
> > 
> > This is caused by the race between freeing page and setting PG_hwpoison.
> > In successful soft offlining, the source page is put (and the refcount
> > becomes 0) by putback_lru_page() in unmap_and_move(), where it's linked to
> > pagevec and actual freeing back to buddy is delayed. So if PG_hwpoison is
> > set for the page before freeing, the freeing does not functions as expected
> > (in such case freeing aborts in free_pages_prepare() check.)
> > 
> > This patch tries to make sure to free the source page before setting
> > PG_hwpoison on it. To avoid reallocating, the page keeps MIGRATE_ISOLATE
> > until after setting PG_hwpoison.
> > 
> > This patch also removes obsolete comments about "keeping elevated refcount"
> > because what they say is not true. Unlike memory_failure(), soft_offline_page()
> > uses no special page isolation code, and the soft-offlined pages have no
> > difference from buddy pages except PG_hwpoison. So no need to keep refcount
> > elevated.
> > 
> > Signed-off-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> > ---
...
> Hi, Naoya
> 
> What happens about this patch? It looks find to me but not merged yet.
> If something I missed, would you please tell me again?

Hello Gong,

It's already on mmotm, so I hope Andrew will push it in this merge window
(just opened yesterday.)

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
