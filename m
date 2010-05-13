Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id C6A036B01E3
	for <linux-mm@kvack.org>; Wed, 12 May 2010 20:23:55 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4D0Nr9e000860
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 13 May 2010 09:23:53 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id F180D45DE51
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:23:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id D13AA45DE4E
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:23:52 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id BA37F1DB803A
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:23:52 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B9391DB8038
	for <linux-mm@kvack.org>; Thu, 13 May 2010 09:23:52 +0900 (JST)
Date: Thu, 13 May 2010 09:19:30 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm,migration: Avoid race between shift_arg_pages() and
 rmap_walk() during migration by not migrating temporary stacks
Message-Id: <20100513091930.9b42e3b8.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <alpine.DEB.2.00.1005121627020.1273@router.home>
References: <20100511085752.GM26611@csn.ul.ie>
	<20100512092239.2120.A69D9226@jp.fujitsu.com>
	<20100512125427.d1b170ba.akpm@linux-foundation.org>
	<alpine.DEB.2.00.1005121627020.1273@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

On Wed, 12 May 2010 16:33:12 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> 
> Still think this special casing is not that good.
> 
> One can also disable migration by providing a migration function that
> always fails. One such function exists in mm/migrate.c:
> 
> /* Always fail migration. Used for mappings that are not movable */
> int fail_migrate_page(struct address_space *mapping,
>                         struct page *newpage, struct page *page)
> {
>         return -EIO;
> }
> EXPORT_SYMBOL(fail_migrate_page);
> 
> 
> The migration function is specified in
> 
> vma->vm_ops->migrate
> 
> If that is set to fail_migrate_page() then the pages in the vma will never
> be migrated. XFS uses it f.e. to avoid page migration:
> 
> STATIC int
> xfs_mapping_buftarg(
>         xfs_buftarg_t           *btp,
>         struct block_device     *bdev)
> {
>         struct backing_dev_info *bdi;
>         struct inode            *inode;
>         struct address_space    *mapping;
>         static const struct address_space_operations mapping_aops = {
>                 .sync_page = block_sync_page,
>                 .migratepage = fail_migrate_page,
>         };
> 
> 
> 
> Would it not be possible to do something similar for the temporary stack?
> 

Problem here is unmap->remap. ->migratepage() function is used as

	unmap 
	   -> migratepage() 
	      -> failed 
		-> remap

Then, migratepage() itself is no help. We need some check-callback before unmap
or lock to wait for an event we can make remapping progress.

Thanks,
-Kame


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
