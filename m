Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3627A6B01F1
	for <linux-mm@kvack.org>; Wed, 21 Apr 2010 20:04:31 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o3M04SD6016041
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 22 Apr 2010 09:04:28 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3FAE045DE50
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:04:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 1DEB345DE4F
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:04:28 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 04A701DB8037
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:04:28 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 92A411DB803B
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 09:04:24 +0900 (JST)
Date: Thu, 22 Apr 2010 08:59:43 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 04/14] mm,migration: Allow the migration of
 PageSwapCache pages
Message-Id: <20100422085943.3d908a4b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1004210927550.4959@router.home>
References: <1271797276-31358-1-git-send-email-mel@csn.ul.ie>
	<1271797276-31358-5-git-send-email-mel@csn.ul.ie>
	<alpine.DEB.2.00.1004210927550.4959@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan.kim@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 21 Apr 2010 09:30:20 -0500 (CDT)
Christoph Lameter <cl@linux-foundation.org> wrote:

> On Tue, 20 Apr 2010, Mel Gorman wrote:
> 
> > @@ -520,10 +521,12 @@ static int move_to_new_page(struct page *newpage, struct page *page)
> >  	else
> >  		rc = fallback_migrate_page(mapping, newpage, page);
> >
> > -	if (!rc)
> > -		remove_migration_ptes(page, newpage);
> > -	else
> > +	if (rc) {
> >  		newpage->mapping = NULL;
> > +	} else {
> > +		if (remap_swapcache)
> > +			remove_migration_ptes(page, newpage);
> > +	}
> 
> You are going to keep the migration ptes after the page has been unlocked?
> Or is remap_swapcache true if its not a swapcache page?
> 
> Maybe you meant
> 
> if (!remap_swapcache)
> 

Ah....Can I confirm my understanding ?

remap_swapcache == true only when
  The old page was ANON && it is not mapped. && it is SwapCache.

We do above check under lock_page(). So, this SwapCache is never mapped until
we release lock_page() on the old page. So, we don't use migration_pte in
this case because try_to_unmap() do nothing and don't need to call
remove_migration_pte().

If migration_pte is used somewhere...I think it's bug.

-Kame



> ?
> 
> >  	unlock_page(newpage);
> >
> 
> >
> >  skip_unmap:
> >  	if (!page_mapped(page))
> > -		rc = move_to_new_page(newpage, page);
> > +		rc = move_to_new_page(newpage, page, remap_swapcache);
> >
> > -	if (rc)
> > +	if (rc && remap_swapcache)
> >  		remove_migration_ptes(page, page);
> >  rcu_unlock:
> >
> 
> Looks like you meant !remap_swapcache
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
