Date: Tue, 29 Apr 2008 16:20:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-Id: <20080429162016.961aa59d.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20080423004804.GA14134@wotan.suse.de>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
	<20080422045205.GH21993@wotan.suse.de>
	<20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com>
	<20080422094352.GB23770@wotan.suse.de>
	<Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com>
	<20080423004804.GA14134@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Christoph Lameter <clameter@sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

I myself want to this patch to be included (to next -mm) and put this under
test. How do you think ? Nick ? Christoph ?

Thanks,
-Kame


On Wed, 23 Apr 2008 02:48:04 +0200
Nick Piggin <npiggin@suse.de> wrote:
> What was happening is that migrate_page_copy wants to transfer the PG_dirty
> bit from old page to new page, so what it would do is set_page_dirty(newpage).
> However set_page_dirty() is used to set the entire page dirty, wheras in
> this case, only part of the page was dirty, and it also was not uptodate.
> 
> Marking the whole page dirty with set_page_dirty would lead to corruption or
> unresolvable conditions -- a dirty && !uptodate page and dirty && !uptodate
> buffers.
> 
> Possibly we could just ClearPageDirty(oldpage); SetPageDirty(newpage);
> however in the interests of keeping the change minimal...
> 
> Signed-off-by: Nick Piggin <npiggin@suse.de>
> ---
> Index: linux-2.6/mm/migrate.c
> ===================================================================
> --- linux-2.6.orig/mm/migrate.c
> +++ linux-2.6/mm/migrate.c
> @@ -383,7 +383,14 @@ static void migrate_page_copy(struct pag
>  
>  	if (PageDirty(page)) {
>  		clear_page_dirty_for_io(page);
> -		set_page_dirty(newpage);
> +		/*
> +		 * Want to mark the page and the radix tree as dirty, and
> +		 * redo the accounting that clear_page_dirty_for_io undid,
> +		 * but we can't use set_page_dirty because that function
> +		 * is actually a signal that all of the page has become dirty.
> +		 * Wheras only part of our page may be dirty.
> +		 */
> +		__set_page_dirty_nobuffers(newpage);
>   	}
>  
>  #ifdef CONFIG_SWAP

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
