Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 9FBFE8D0039
	for <linux-mm@kvack.org>; Wed,  9 Feb 2011 15:07:36 -0500 (EST)
Date: Wed, 9 Feb 2011 21:07:28 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [mmotm] BUG: Bad page state in process khugepaged ?
Message-ID: <20110209200728.GQ3347@random.random>
References: <20110209151036.f24a36a6.kamezawa.hiroyu@jp.fujitsu.com>
 <20110209155001.0e369475.nishimura@mxp.nes.nec.co.jp>
 <20110209155246.69a7f3a1.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110209155246.69a7f3a1.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>

On Wed, Feb 09, 2011 at 03:52:46PM +0900, KAMEZAWA Hiroyuki wrote:
> On Wed, 9 Feb 2011 15:50:01 +0900
> Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp> wrote:
> 
> > > 
> > > In hex, pc->flags was 7A00000000004 and this means PCG_USED bit is set.
> > > This implies page_remove_rmap() may not be called but ->mapping is NULL. Hmm?
> > > (7A is encoding of section number.)
> > > 
> > Sigh.. it seems another freed-but-not-uncharged problem..
> > 
> 
> Ah, ok, this is maybe caused by this. I'm sorry that I missed this.
> ==
> static inline int free_pages_check(struct page *page)
> {
>         if (unlikely(page_mapcount(page) |
>                 (page->mapping != NULL)  |
>                 (atomic_read(&page->_count) != 0) |
>                 (page->flags & PAGE_FLAGS_CHECK_AT_FREE) |
>                 (mem_cgroup_bad_page_check(page)))) {    <==========(*)
>                 bad_page(page);
>                 return 1;
> ==
> 
> Then, ok, this is a memcgroup and hugepage issue.
> 
> I'll look into.

Yes, the rest of the info on the page looked ok and shouldn't have
triggered a bad_page call. Thanks so much for looking into it.

Andrea

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
