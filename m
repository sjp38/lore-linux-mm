Date: Wed, 10 May 2000 11:10:36 +0100
From: Steve Dodd <steved@loth.demon.co.uk>
Subject: Re: [PATCH] remove_inode_page rewrite.
Message-ID: <20000510111035.A685@loth.demon.co.uk>
References: <Pine.LNX.4.21.0005092051120.911-100000@neo.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <Pine.LNX.4.21.0005092051120.911-100000@neo.local>; from Dave Jones on Tue, May 09, 2000 at 09:14:08PM +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Jones <dave@denial.force9.co.uk>
Cc: Linux Kernel Mailing List <linux-kernel@vger.rutgers.edu>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, May 09, 2000 at 09:14:08PM +0100, Dave Jones wrote:

> I believe that while after CPU0 drops the pagecache_lock, and starts
> removing one page, CPU1 fails to lock the same page (as CPU0 grabbed it 
> with the trylock) and moves to the next page in the list, succeeds,
> removes it, and then rescans from the top.
> 
> With the current locking I believe it's then possible for CPU1 to
> lock that page

Which page? CPU1 should never find the page CPU0 is freeing because it will
either be locked, or not on the list at all. By the time CPU0 unlocks the
page, it's removed it from the list (and it grabs the spinlock while messing
with the list structure).

> (again in the TryLockPage(page) call) just before CPU0
> calls page_cache_release(page)
> 
> This patch probably kills us latency-wise, but looks a lot more
> sane in my eyes.

Now that invalidate_inode_page isn't calling sync_page, there seems to be
no reason to drop and retake the spinlock, I agree.

[..]
> - repeat:
> -	head = &inode->i_mapping->pages;
>  	spin_lock(&pagecache_lock);
> +
> +	head = &inode->i_mapping->pages;

That shouldn't be necessary - nobody is likely to change the address of
inode->i_mapping->pages under us :)
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
