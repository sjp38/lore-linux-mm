Date: Wed, 20 Apr 2005 15:16:18 -0300
From: Marcelo Tosatti <marcelo.tosatti@cyclades.com>
Subject: Re: question on page-migration code
Message-ID: <20050420181618.GB8871@logos.cnet>
References: <425AC268.4090704@engr.sgi.com> <20050412.084143.41655902.taka@valinux.co.jp> <1113324392.8343.53.camel@localhost> <20050413.194800.74725991.taka@valinux.co.jp> <426470EB.4090600@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <426470EB.4090600@sgi.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Bryant <raybry@sgi.com>
Cc: Hirokazu Takahashi <taka@valinux.co.jp>, haveblue@us.ibm.com, raybry@engr.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Ray,

On Mon, Apr 18, 2005 at 09:46:03PM -0500, Ray Bryant wrote:
> Hirokazu et al,
> 
> I'm sorry, I've been kind of out of the loop here since last Wenesday
> (that's the day I left Austin to fly to Melbourne, Australia which is
> where I am now, visiting the SGI lab in Melbourne).
> 
> Nathan Scott (who works at SGI Melbourne) looked at the ext2/ext3
> migrate_page code and realized that basically the same implementation
> would work for xfs.  So I now have a kernel that implements that
> function for xfs and, as you predicted, the "slow down" in the 2nd
> migration that I was seeing before has gone away.  I'll add Nathan's
> patch to my manual page migration stuff in the next version (later
> this week, I hope).
> 
> So I guess it doesn't matter to me at the moment whether or not
> the PG_dirty bit is set on the pages, except that I philosphically
> dislike the fact that migration changes the state of the page.
> I'm not sure it matters, but I would prefer it if this didn't
> happen.  However, I'm not adamant about this, since what I really
> want to happen is to have a functioning manual page migration
> system call.  It does seem to be a bother to have to add that
> migrate_page method to each file system, since in most cases
> the addition is going to look somewhat like it does for ext2/3. 

One could create "block_migrate_page()" in fs/buffer.c so to void 
migrate_page definition on each filesystem which uses buffer_head's.

But all address_space_operations need to be updated anyway.

> For xfs, Nathan did add an additional bit to make sure that
> xfs metadata pages were not considered migratable.
> 
> WRT, Marcelo's question as to who is causing the page out I/O
> to occur during migration, let me go back and verify this is
> actually what is happening.
> 
> Otherwise, is there a consensus about what to do about the
> PG_dirty bits being set on the migrated pages?  As I read
> things Marcelo says it is not worth it, but others think
> that it should be fixed?

Dirty mmaped file pages will have their dirty tag migrated from  
ptes to pages via unmapping (try_to_unmap), which causes
pdflush to sync these pages when their inodes get aged, as 
Toshihiro notices.

I dislike the idea of "saving the dirty state to reinstantiate 
it later", but, it seems its the only way of avoiding the dirty 
mmaped file writeouts.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
