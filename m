Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 40FA86B004F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 13:17:52 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n65CLLP5030964
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Sun, 5 Jul 2009 21:21:22 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0BCD45DE4F
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 21:21:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F48645DE4E
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 21:21:21 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 82D14E08005
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 21:21:21 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3D373E08003
	for <linux-mm@kvack.org>; Sun,  5 Jul 2009 21:21:21 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 5/5] add NR_ANON_PAGES to OOM log
In-Reply-To: <20090705121308.GC5252@localhost>
References: <20090705182533.0902.A69D9226@jp.fujitsu.com> <20090705121308.GC5252@localhost>
Message-Id: <20090705211739.091D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Sun,  5 Jul 2009 21:21:20 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: kosaki.motohiro@jp.fujitsu.com, LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Christoph Lameter <cl@linux-foundation.org>, David Rientjes <rientjes@google.com>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

> On Sun, Jul 05, 2009 at 05:26:18PM +0800, KOSAKI Motohiro wrote:
> > Subject: [PATCH] add NR_ANON_PAGES to OOM log
> > 
> > show_free_areas can display NR_FILE_PAGES, but it can't display
> > NR_ANON_PAGES.
> > 
> > this patch fix its inconsistency.
> > 
> > 
> > Reported-by: Wu Fengguang <fengguang.wu@gmail.com>
> > Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> > ---
> >  mm/page_alloc.c |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > Index: b/mm/page_alloc.c
> > ===================================================================
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2216,6 +2216,7 @@ void show_free_areas(void)
> >  		printk("= %lukB\n", K(total));
> >  	}
> >  
> > +	printk("%ld total anon pages\n", global_page_state(NR_ANON_PAGES));
> >  	printk("%ld total pagecache pages\n", global_page_state(NR_FILE_PAGES));
> 
> Can we put related items together, ie. this looks more friendly:
> 
>         Anon:XXX active_anon:XXX inactive_anon:XXX
>         File:XXX active_file:XXX inactive_file:XXX

hmmm. Actually NR_ACTIVE_ANON + NR_INACTIVE_ANON != NR_ANON_PAGES.
tmpfs pages are accounted as FILE, but it is stay in anon lru.

I think your proposed format easily makes confusion. this format cause to
imazine Anon = active_anon + inactive_anon.

At least, we need to use another name, I think.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
