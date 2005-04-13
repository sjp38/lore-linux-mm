Date: Wed, 13 Apr 2005 19:48:00 +0900 (JST)
Message-Id: <20050413.194800.74725991.taka@valinux.co.jp>
Subject: Re: question on page-migration code
From: Hirokazu Takahashi <taka@valinux.co.jp>
In-Reply-To: <1113324392.8343.53.camel@localhost>
References: <425AC268.4090704@engr.sgi.com>
	<20050412.084143.41655902.taka@valinux.co.jp>
	<1113324392.8343.53.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: haveblue@us.ibm.com
Cc: raybry@engr.sgi.com, marcelo.tosatti@cyclades.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

> > If the method isn't implemented for the page, the migration code
> > calls pageout() and try_to_release_page() to release page->private
> > instead. 
> > 
> > Which filesystem are you using? I guess it might be XFS which
> > doesn't have the method yet.
> 
> Can we more easily detect and work around this in the code, so that this
> won't happen for more filesystems?

As Ray said, the following seems to be a straight approach.
I haven't had any other ideas to work around it.

ray> I guess it seems to me that if a page has pte dirty set, but doesn't have
ray> PG_dirty set, then that state should be carried over to the newpage after
ray> a migration, rather than sweeping the pte dirty bit into the PG_dirty bit.

The implementation might be as follows:
   - to make try_to_unmap_one() record dirty bit in anywhere
     instead of calling set_page_dirty().
   - to make touch_unmapped_address() call get_user_pages() with
     the record of the dirty bit.

However, we have to remember that there must exit some race conditions.
For example, it may fail to restore the dirty bit since the process
address spaces might be deleted during the memory migration.
This may occur as the process isn't suspended during the migration.


Thanks,
Hirokazu Takahashi.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
