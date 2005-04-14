Date: Thu, 14 Apr 2005 12:57:34 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: question on page-migration code
Message-ID: <20050414155734.GE14975@logos.cnet>
References: <425AC268.4090704@engr.sgi.com> <20050412.084143.41655902.taka@valinux.co.jp> <1113324392.8343.53.camel@localhost> <20050413.194800.74725991.taka@valinux.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050413.194800.74725991.taka@valinux.co.jp>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: haveblue@us.ibm.com, raybry@engr.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Apr 13, 2005 at 07:48:00PM +0900, Hirokazu Takahashi wrote:
> Hi,
> 
> > > If the method isn't implemented for the page, the migration code
> > > calls pageout() and try_to_release_page() to release page->private
> > > instead. 
> > > 
> > > Which filesystem are you using? I guess it might be XFS which
> > > doesn't have the method yet.
> > 
> > Can we more easily detect and work around this in the code, so that this
> > won't happen for more filesystems?
> 
> As Ray said, the following seems to be a straight approach.
> I haven't had any other ideas to work around it. 

>From my understanding there are two problems:

1) PG_private set on file pages whose filesystems do not implement 
->migrate_page() method.

Not much can be done about it, except implementing migrate_page() for all 
filesystems using page->private for uses other than buffer_head's.

BTW: only ext2/3 are implementing migrate_page(), all buffer_head 
based filesystems should do the same on a final version. 
Have you guys tried fs'es other than ext2/3? 

Dave, I dont understand what you mean with "workaround". The page is 
not migratable, thus the memory area which contains it can't 
be migrated either.

2) PG_dirty bit set on anonymous pages which have been migrated.

> ray> I guess it seems to me that if a page has pte dirty set, but doesn't have
> ray> PG_dirty set, then that state should be carried over to the newpage after
> ray> a migration, rather than sweeping the pte dirty bit into the PG_dirty bit.

The dirty bit is set by swap allocation and freeing code. 

> The implementation might be as follows:
>    - to make try_to_unmap_one() record dirty bit in anywhere
>      instead of calling set_page_dirty().
>    - to make touch_unmapped_address() call get_user_pages() with
>      the record of the dirty bit.

Quoting Ray:
"Checking /proc/vmstat/pgpgout appears to indicate that the pages I am
migrating are being swapped out when I see the migration slow down,
although something is fishy with pgpgout."

Anonymous pages seem to the problem Ray is seeing, except (1) which 
vanishes with ext2/ext3 as he reports.

Anon pages _should_ be removed from the swapcache at the end of 
generic_migrate_page (__remove_exclusive_swap_page()).

So, it does not matter if they have PG_dirty bit set, as long as
they are not swap-allocated (PageSwapCache).

Ray, please confirm that anon pages are removed from the swapcache after
being migrated (watching /proc/meminfo should do it).

One point is that if free memory is below the safe watermarks, the
system will vmscan, allocating swap & writing out, which is expected.

How much memory is free during said tests? 

> However, we have to remember that there must exit some race conditions.
> For example, it may fail to restore the dirty bit since the process
> address spaces might be deleted during the memory migration.
> This may occur as the process isn't suspended during the migration.

The PG_dirty bit is set, by the migration code, for anonymous pages only.

That said, I see no need to reset PG_dirty in case it was not set before
migration, as you propose.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
