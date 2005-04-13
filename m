Date: Wed, 13 Apr 2005 13:43:21 +0900 (JST)
Message-Id: <20050413.134321.53061369.taka@valinux.co.jp>
Subject: Re: question on page-migration code
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <425B600E.6020701@engr.sgi.com>
References: <425AC268.4090704@engr.sgi.com>
	<20050412.084143.41655902.taka@valinux.co.jp>
	<425B600E.6020701@engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: raybry@engr.sgi.com
Cc: marcelo.tosatti@cyclades.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Ray,

> Hi Hirokazu,
> 
> What appears to be happening is the following:
> 
> dirty pte bits are being swept into the page dirty bit as a side effect
> of migration.  That is, if a page had pte_dirty(pte) set, then after
> migration, it will have PageDirty(page) = true.
> 
> Only pages with PageDirty() set will be written to swap as part of the
> process of trying to clear PG_private.  So, when I do the first migration,
> the PG_dirty bit is not set on the page, but the dirty bit is set in the
> pte.  Because PG_dirty is not set, the page does not get written to swap,
> and the migration is fast.  However, at the end of the migration process,
> the pages all have PG_dirty set and the pte dirty bits are cleared.
>
> The second time I do the migration, the PG_dirty bits are still set
> (left over from the first migration), so they have to be written to swap
> and the migration is slow.  As part of the pageout(), try_to_release_page()
> process, the PG_dirty is cleared, along with the pte dirty bits, as before.
> 
> When the program is resumed, it will cause the pte dirty bits to be set,
> and then we will be back in the situation we started with before the first
> migration.

In both cases, the PG_dirty flag are always set before
writeback_and_free_buffers() is called, as try_to_unmap() moves
the pte dirty bits to the PG_dirty on the page prior to starting
the migration.

In my guess, the difference may be the PG_private flag.
In the first migration, the pages may not have the PG_private flag
while it may have the flag in the second time.
If the PG_dirty flag is set, Linux VM tends to make the pages
have their own private data, preparing the write-back I/Os.

The scenario might be like this:
At the first time, the pages can be migrated without any I/Os
as the PG_private isn't set even though the PG_dirty is set.
Linux VM may set the PG_private on the pages since they have the
PG_dirty.
At the second time, the write-back is required as both the
PG_private and the PG_dirty are set, clearing both of the flags.
At the third time, the pages don't have the PG_private and can
be migrated easily.

But, this is not what we expected;(

> Hence the third migration will be fast, and the 4th migration will be slow,
> etc.  This is a stable, repeatable process.
> 
> I guess it seems to me that if a page has pte dirty set, but doesn't have
> PG_dirty set, then that state should be carried over to the newpage after
> a migration, rather than sweeping the pte dirty bit into the PG_dirty bit.
> 
> Another way to do this would be to implement the migrate dirty buffers
> without swap I/O trick of ext2/3 in XFS, but that is somewhat far afield
> for me to try.  :-)  I'll discuss this with Nathan Scott et al and see
> if that is something that would be straightforward to do.
> 
> But I have a nagging suspicion that this covers up, rather than fixes
> the state transition from oldpage to newpage that really shouldn't be
> happening, as near as I can tell.
> 
> BTW, the program that I am testing creates a relatively large mapped file,
> and, as you guessed, this file is backed by XFS.  Programs that just use
> large amounts of anonymous storage are not effected by this problem, I
> would imagine.
> -- 
> Best Regards,
> Ray
> -----------------------------------------------
>                    Ray Bryant
> 512-453-9679 (work)         512-507-7807 (cell)
> raybry@sgi.com             raybry@austin.rr.com
> The box said: "Requires Windows 98 or better",
>             so I installed Linux.
> -----------------------------------------------
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
> 
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
