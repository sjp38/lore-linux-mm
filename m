Date: Mon, 5 May 2008 06:27:51 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: Warning on memory offline (and possible in usual migration?)
Message-ID: <20080505042751.GB26920@wotan.suse.de>
References: <20080430001249.c07ff5c8.akpm@linux-foundation.org> <20080430072620.GI27652@wotan.suse.de> <Pine.LNX.4.64.0804301059570.26173@schroedinger.engr.sgi.com> <20080501014418.GB15179@wotan.suse.de> <Pine.LNX.4.64.0805011224150.8738@schroedinger.engr.sgi.com> <20080502004445.GB30768@wotan.suse.de> <Pine.LNX.4.64.0805011805150.13527@schroedinger.engr.sgi.com> <20080502012350.GF30768@wotan.suse.de> <Pine.LNX.4.64.0805011833480.13697@schroedinger.engr.sgi.com> <Pine.LNX.4.64.0805021411260.21677@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0805021411260.21677@schroedinger.engr.sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Fri, May 02, 2008 at 02:16:20PM -0700, Christoph Lameter wrote:
> I guess we need the following patch to handle !uptodate pages. Wish we had 
> a better solution that would allow the skipping of pages with buffers 
> under read I/O.

 
AFAIK, any filesystem which may not lock the page under read IO should
have PG_private set. In which case, if they don't have buffers they
should have a releasepage method. Otherwise, how would we ever reclaim
!uptodate && !buffers pages?

So I don't think we need this patch.

> 
> Subject: Page migration: Do not migrate page that is not uptodate
> 
> If we are migrating pages that are not mapped into a processes address
> space then we may encounter !Uptodate pages. Page migration is now used
> for offlining memory which scans unmapped pages.
> 
> If a page is not uptodate then read I/O may be in progress against it.
> So do not migrate it. On the other hand if the page has buffers then
> read I/O will lock a buffer. In that case we can migrate an !Uptodate
> page but then migration will stall in buffer_migrate_page() until the
> read is complete.
> 
> Signed-off-by: Christoph Lameter <clameter@sgi.com>
> 
> ---
>  mm/migrate.c |   17 +++++++++++++++++
>  1 file changed, 17 insertions(+)
> 
> Index: linux-2.6/mm/migrate.c
> ===================================================================
> --- linux-2.6.orig/mm/migrate.c	2008-05-02 13:47:45.113707645 -0700
> +++ linux-2.6/mm/migrate.c	2008-05-02 14:08:32.203644985 -0700
> @@ -652,6 +652,23 @@ static int unmap_and_move(new_page_t get
>  			goto unlock;
>  		wait_on_page_writeback(page);
>  	}
> +
> +	/*
> +	 * Page may be under read I/O if its not uptodate and has no buffers.
> +	 * In that case the page contents are not stable and should not be
> +	 * migrated. So we just pass on that page and return -EAGAIN.
> +	 *
> +	 * If a page has buffers then the locks taken on the buffers
> +	 * will indicate that read I/O is in progress. Then PageUptodate does
> +	 * not matter because buffer_migrate_page() will stall until I/O is
> +	 * complete. It would be better if we could catch that here and delay
> +	 * migrating the page because we could migrate a the other pages on the
> +	 * migrate list instead of waiting for I/O to complete on this page
> +	 * (like done for writes in progress).
> +	 */
> +	if (!PageUptodate(page) && !page_has_buffers(page))
> +		goto unlock;
> +
>  	/*
>  	 * By try_to_unmap(), page->mapcount goes down to 0 here. In this case,
>  	 * we cannot notice that anon_vma is freed while we migrates a page.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
