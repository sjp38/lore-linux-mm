Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 8B9636B01EE
	for <linux-mm@kvack.org>; Thu,  1 Apr 2010 20:25:41 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o320PcRF005676
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 2 Apr 2010 09:25:38 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 813AC45DE51
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:25:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 614AF1EF081
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:25:38 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 32310E38002
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:25:38 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AED9E38007
	for <linux-mm@kvack.org>; Fri,  2 Apr 2010 09:25:37 +0900 (JST)
Date: Fri, 2 Apr 2010 09:21:50 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 14/14] mm,migration: Allow the migration of
 PageSwapCache pages
Message-Id: <20100402092150.dc4b54a0.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100401173640.GB621@csn.ul.ie>
References: <1269940489-5776-1-git-send-email-mel@csn.ul.ie>
	<1269940489-5776-15-git-send-email-mel@csn.ul.ie>
	<20100331142623.62ac9175.kamezawa.hiroyu@jp.fujitsu.com>
	<j2s28c262361003311943ke6d39007of3861743cef3733a@mail.gmail.com>
	<20100401120123.f9f9e872.kamezawa.hiroyu@jp.fujitsu.com>
	<n2k28c262361003312144k3a1a725aj1eb22efe6d360118@mail.gmail.com>
	<20100401144234.e3848876.kamezawa.hiroyu@jp.fujitsu.com>
	<w2i28c262361004010351r605c897dzd2bdccac149dcc6b@mail.gmail.com>
	<20100401173640.GB621@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Minchan Kim <minchan.kim@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux-foundation.org>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, David Rientjes <rientjes@google.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 1 Apr 2010 18:36:41 +0100
Mel Gorman <mel@csn.ul.ie> wrote:

> > > ==
> > > A  A  A  A skip_remap = 0;
> > > A  A  A  A if (PageAnon(page)) {
> > > A  A  A  A  A  A  A  A rcu_read_lock();
> > > A  A  A  A  A  A  A  A if (!page_mapped(page)) {
> > > A  A  A  A  A  A  A  A  A  A  A  A if (!PageSwapCache(page))
> > > A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A goto rcu_unlock;
> > > A  A  A  A  A  A  A  A  A  A  A  A /*
> > > A  A  A  A  A  A  A  A  A  A  A  A  * We can't convice this anon_vma is valid or not because
> > > A  A  A  A  A  A  A  A  A  A  A  A  * !page_mapped(page). Then, we do migration(radix-tree replacement)
> > > A  A  A  A  A  A  A  A  A  A  A  A  * but don't remap it which touches anon_vma in page->mapping.
> > > A  A  A  A  A  A  A  A  A  A  A  A  */
> > > A  A  A  A  A  A  A  A  A  A  A  A skip_remap = 1;
> > > A  A  A  A  A  A  A  A  A  A  A  A goto skip_unmap;
> > > A  A  A  A  A  A  A  A } else {
> > > A  A  A  A  A  A  A  A  A  A  A  A anon_vma = page_anon_vma(page);
> > > A  A  A  A  A  A  A  A  A  A  A  A atomic_inc(&anon_vma->external_refcount);
> > > A  A  A  A  A  A  A  A }
> > > A  A  A  A }
> > > A  A  A  A .....copy page, radix-tree replacement,....
> > >
> > 
> > It's not enough.
> > we uses remove_migration_ptes in  move_to_new_page, too.
> > We have to prevent it.
> > We can check PageSwapCache(page) in move_to_new_page and then
> > skip remove_migration_ptes.
> > 
> > ex)
> > static int move_to_new_page(....)
> > {
> >      int swapcache = PageSwapCache(page);
> >      ...
> >      if (!swapcache)
> >          if(!rc)
> >              remove_migration_ptes
> >          else
> >              newpage->mapping = NULL;
> > }
> > 
> 
> This I agree with.
> 
me, too.


> I am not sure this race exists because the page is locked but a key
> observation has been made - A page that is unmapped can be migrated if
> it's PageSwapCache but it may not have a valid anon_vma. Hence, in the
> !page_mapped case, the key is to not use anon_vma. How about the
> following patch?
> 

Seems good to me. But (see below)


> ==== CUT HERE ====
> 
> mm,migration: Allow the migration of PageSwapCache pages
> 
> PageAnon pages that are unmapped may or may not have an anon_vma so are
> not currently migrated. However, a swap cache page can be migrated and
> fits this description. This patch identifies page swap caches and allows
> them to be migrated but ensures that no attempt to made to remap the pages
> would would potentially try to access an already freed anon_vma.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> diff --git a/mm/migrate.c b/mm/migrate.c
> index 35aad2a..5d0218b 100644
> --- a/mm/migrate.c
> +++ b/mm/migrate.c
> @@ -484,7 +484,8 @@ static int fallback_migrate_page(struct address_space *mapping,
>   *   < 0 - error code
>   *  == 0 - success
>   */
> -static int move_to_new_page(struct page *newpage, struct page *page)
> +static int move_to_new_page(struct page *newpage, struct page *page,
> +						int safe_to_remap)
>  {
>  	struct address_space *mapping;
>  	int rc;
> @@ -519,10 +520,12 @@ static int move_to_new_page(struct page *newpage, struct page *page)
>  	else
>  		rc = fallback_migrate_page(mapping, newpage, page);
>  
> -	if (!rc)
> -		remove_migration_ptes(page, newpage);
> -	else
> -		newpage->mapping = NULL;
> +	if (safe_to_remap) {
> +		if (!rc)
> +			remove_migration_ptes(page, newpage);
> +		else
> +			newpage->mapping = NULL;
> +	}
>  
	if (rc)
		newpage->mapping = NULL;
	else if (safe_to_remap)
		remove_migrateion_ptes(page, newpage);

Is better. Old code cleared newpage->mapping if rc!=0.

Thanks,
-Kame




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
