Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 43ABE6B00A2
	for <linux-mm@kvack.org>; Thu, 23 Apr 2009 20:07:14 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n3O07IXo002981
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Fri, 24 Apr 2009 09:07:18 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 3618645DD74
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 09:07:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 1517945DD72
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 09:07:18 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id EFB7F1DB8013
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 09:07:17 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 37F60E18005
	for <linux-mm@kvack.org>; Fri, 24 Apr 2009 09:07:14 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH 15/22] Do not disable interrupts in free_page_mlock()
In-Reply-To: <20090423155951.6778bdd3.akpm@linux-foundation.org>
References: <1240408407-21848-16-git-send-email-mel@csn.ul.ie> <20090423155951.6778bdd3.akpm@linux-foundation.org>
Message-Id: <20090424090552.1044.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Fri, 24 Apr 2009 09:07:13 +0900 (JST)
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kosaki.motohiro@jp.fujitsu.com, Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org, cl@linux-foundation.org, npiggin@suse.de, linux-kernel@vger.kernel.org, ming.m.lin@intel.com, yanmin_zhang@linux.intel.com, peterz@infradead.org, penberg@cs.helsinki.fi
List-ID: <linux-mm.kvack.org>

> > @@ -556,6 +555,7 @@ static void __free_pages_ok(struct page *page, unsigned int order)
> >  	unsigned long flags;
> >  	int i;
> >  	int bad = 0;
> > +	int clearMlocked = PageMlocked(page);
> >  
> >  	for (i = 0 ; i < (1 << order) ; ++i)
> >  		bad += free_pages_check(page + i);
> > @@ -571,6 +571,8 @@ static void __free_pages_ok(struct page *page, unsigned int order)
> >  	kernel_map_pages(page, 1 << order, 0);
> >  
> >  	local_irq_save(flags);
> > +	if (unlikely(clearMlocked))
> > +		free_page_mlock(page);
> 
> I wonder what the compiler does in the case
> CONFIG_HAVE_MLOCKED_PAGE_BIT=n.  If it is dumb, this patch would cause
> additional code generation.

if CONFIG_HAVE_MLOCKED_PAGE_BIT=n, PageMlocked() is {return 0;} then
gcc can remove following code, I think.
	if (0) 
		free_page_mlock(page)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
