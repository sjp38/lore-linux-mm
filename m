Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx192.postini.com [74.125.245.192])
	by kanga.kvack.org (Postfix) with SMTP id EC43B6B005D
	for <linux-mm@kvack.org>; Wed, 15 Aug 2012 20:13:14 -0400 (EDT)
Date: Thu, 16 Aug 2012 09:15:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC 2/2] cma: support MIGRATE_DISCARD
Message-ID: <20120816001517.GC15225@bbox>
References: <1344934627-8473-1-git-send-email-minchan@kernel.org>
 <1344934627-8473-3-git-send-email-minchan@kernel.org>
 <502BF139.3040403@redhat.com>
 <20120815233323.GB15225@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120815233323.GB15225@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mgorman@suse.de>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, Aug 16, 2012 at 08:33:23AM +0900, Minchan Kim wrote:
> Hi Rik,
> 
> On Wed, Aug 15, 2012 at 02:58:01PM -0400, Rik van Riel wrote:
> > On 08/14/2012 04:57 AM, Minchan Kim wrote:
> > >This patch introudes MIGRATE_DISCARD mode in migration.
> > >It drop clean cache pages instead of migration so that
> > >migration latency could be reduced. Of course, it could
> > >evict code pages but latency of big contiguous memory
> > >is more important than some background application's slow down
> > >in mobile embedded enviroment.
> > 
> > Would it be an idea to only drop clean UNMAPPED
> > page cache pages?
> 
> Firstly I thougt about that but I chose more agressive thing.
> Namely, even drop mapped page cache.
> Because it can reduce latency more(ex, memcpy + remapping cost
> during migration) and it could not trivial if migration range is big.
> 
> > 
> > >Signed-off-by: Minchan Kim <minchan@kernel.org>
> > 
> > >@@ -799,12 +802,39 @@ static int __unmap_and_move(struct page *page, struct page *newpage,
> > >  		goto skip_unmap;
> > >  	}
> > >
> > >+	file = page_is_file_cache(page);
> > >+	ttu_flags = TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS;
> > >+
> > >+	if (!(mode & MIGRATE_DISCARD) || !file || PageDirty(page))
> > >+		ttu_flags |= TTU_MIGRATION;
> > >+	else
> > >+		discard_mode = true;
> > >+
> > >  	/* Establish migration ptes or remove ptes */
> > >-	try_to_unmap(page, TTU_MIGRATION|TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS);
> > >+	try_to_unmap(page, ttu_flags);
> > 
> > This bit looks wrong, because you end up ignoring
> > mlock and then discarding the page.
> 
> Argh, Thanks!
> I will fix it in next spin.
> 
> > 
> > Only dropping clean page cache pages that are not
> > mapped would avoid that problem, without introducing
> > much complexity in the code.
> 
> Hmm, I don't think it makes code much complex.
> How about this?
> 
> diff --git a/mm/rmap.c b/mm/rmap.c
> index 0f3b7cd..0909d79 100644
> --- a/mm/rmap.c
> +++ b/mm/rmap.c
> @@ -1223,7 +1223,8 @@ out:
>   * repeatedly from try_to_unmap_ksm, try_to_unmap_anon or try_to_unmap_file.
>   */
>  int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
> -                    unsigned long address, enum ttu_flags flags)
> +                    unsigned long address, enum ttu_flags flags,
> +                    unsigned long *vm_flags)
>  {
>         struct mm_struct *mm = vma->vm_mm;
>         pte_t *pte;
> @@ -1235,6 +1236,7 @@ int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
>         if (!pte)
>                 goto out;
>  
> +       vm_flags |= vma->vm_flags;
>         /*
>          * If the page is mlock()d, we cannot swap it out.
>          * If it's recently referenced (perhaps page_referenced
> @@ -1652,7 +1654,7 @@ out:
>   * SWAP_FAIL   - the page is unswappable
>   * SWAP_MLOCK  - page is mlocked.
>   */
> -int try_to_unmap(struct page *page, enum ttu_flags flags)
> +int try_to_unmap(struct page *page, enum ttu_flags flags, unsigned long *vm_flags)
>  {
>         int ret;
> 
> <snip> 
> 
> +       file = page_is_file_cache(page);
> +       ttu_flags = TTU_IGNORE_MLOCK|TTU_IGNORE_ACCESS;
> +
> +       if (!(mode & MIGRATE_DISCARD) || !file || PageDirty(page) ||
> +               vm_flags & VM_LOCKED)

We do try_to_unmap after this piece so we can't get the information in advance. :(
I don't have better idea which doesn't have a drawback so I will accept your idea.
Thanks, Rik.

> +               ttu_flags |= TTU_MIGRATION;
> +       else
> +               discard_mode = true;
> +
> 
> 
-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
