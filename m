Message-ID: <425B600E.6020701@engr.sgi.com>
Date: Tue, 12 Apr 2005 00:43:42 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: question on page-migration code
References: <4255B13E.8080809@engr.sgi.com>	<20050407180858.GB19449@logos.cnet>	<425AC268.4090704@engr.sgi.com> <20050412.084143.41655902.taka@valinux.co.jp>
In-Reply-To: <20050412.084143.41655902.taka@valinux.co.jp>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: marcelo.tosatti@cyclades.com, haveblue@us.ibm.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Hirokazu,

What appears to be happening is the following:

dirty pte bits are being swept into the page dirty bit as a side effect
of migration.  That is, if a page had pte_dirty(pte) set, then after
migration, it will have PageDirty(page) = true.

Only pages with PageDirty() set will be written to swap as part of the
process of trying to clear PG_private.  So, when I do the first migration,
the PG_dirty bit is not set on the page, but the dirty bit is set in the
pte.  Because PG_dirty is not set, the page does not get written to swap,
and the migration is fast.  However, at the end of the migration process,
the pages all have PG_dirty set and the pte dirty bits are cleared.

The second time I do the migration, the PG_dirty bits are still set
(left over from the first migration), so they have to be written to swap
and the migration is slow.  As part of the pageout(), try_to_release_page()
process, the PG_dirty is cleared, along with the pte dirty bits, as before.

When the program is resumed, it will cause the pte dirty bits to be set,
and then we will be back in the situation we started with before the first
migration.

Hence the third migration will be fast, and the 4th migration will be slow,
etc.  This is a stable, repeatable process.

I guess it seems to me that if a page has pte dirty set, but doesn't have
PG_dirty set, then that state should be carried over to the newpage after
a migration, rather than sweeping the pte dirty bit into the PG_dirty bit.

Another way to do this would be to implement the migrate dirty buffers
without swap I/O trick of ext2/3 in XFS, but that is somewhat far afield
for me to try.  :-)  I'll discuss this with Nathan Scott et al and see
if that is something that would be straightforward to do.

But I have a nagging suspicion that this covers up, rather than fixes
the state transition from oldpage to newpage that really shouldn't be
happening, as near as I can tell.

BTW, the program that I am testing creates a relatively large mapped file,
and, as you guessed, this file is backed by XFS.  Programs that just use
large amounts of anonymous storage are not effected by this problem, I
would imagine.
-- 
Best Regards,
Ray
-----------------------------------------------
                   Ray Bryant
512-453-9679 (work)         512-507-7807 (cell)
raybry@sgi.com             raybry@austin.rr.com
The box said: "Requires Windows 98 or better",
            so I installed Linux.
-----------------------------------------------
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
