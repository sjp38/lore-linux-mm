Message-ID: <4282115C.40207@engr.sgi.com>
Date: Wed, 11 May 2005 09:06:20 -0500
From: Ray Bryant <raybry@engr.sgi.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2.6.12-rc3 4/8] mm: manual page migration-rc2 -- add-sys_migrate_pages-rc2.patch
References: <20050511043756.10876.72079.60115@jackhammer.engr.sgi.com>	<20050511043821.10876.47127.71762@jackhammer.engr.sgi.com> <20050511.222314.10910241.taka@valinux.co.jp>
In-Reply-To: <20050511.222314.10910241.taka@valinux.co.jp>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hirokazu Takahashi <taka@valinux.co.jp>
Cc: raybry@sgi.com, marcelo.tosatti@cyclades.com, ak@suse.de, haveblue@us.ibm.com, hch@infradead.org, linux-mm@kvack.org, nathans@sgi.com, raybry@austin.rr.com, lhms-devel@lists.sourceforge.net
List-ID: <linux-mm.kvack.org>

Hi Hirokazu,

Hirokazu Takahashi wrote:

<snip>

> 
> I found there exited a race condition between migrate_vma() and
> the swap code. The following code may cause Oops if the swap code
> takes the page from the LRU list before calling steal_page_from_lru().
> 
> migrate_vma()
> {
>                :
> 	if (PageLRU(page) &&
> 	    steal_page_from_lru(zone, page, &page_list))
> 		count++;
> 	else
> 		BUG();
>                :
> }

Ah, good point.  Perhaps this is cause of the race I am seeing.  Let me check.

I used to take the zone->lru_lock explicitly before __steal_page_from_lru()
but saw the other interface and switched to it (a little too quickly, I
now gather...)  Perhaps I should just go back to that.  That way there is
no chance of a race.

> 
> Ok, I should make steal_page_from_lru() check PageLRU(page) with
> holding zone->lru_lock. Then migrate_vma() can just call
> steal_page_from_lru().
> 
> static inline int
> steal_page_from_lru(struct zone *zone, struct page *page)
> {
>         int ret = 0;
>         spin_lock_irq(&zone->lru_lock);
> 	if (PageLRU(page))
>                 ret = __steal_page_from_lru(zone, page);
>         spin_unlock_irq(&zone->lru_lock);
>         return ret;
> }
> 
> migrate_vma()
> {
>                :
> 	if (steal_page_from_lru(zone, page, &page_list)
> 		count++;
>                :
> }
> 
> 
> BTW, I'm not sure whether it's enough that migrate_vma() can only
> migrate currently mapped pages. This may leave some pages in the
> page-cache if they're not mapped to the process address spaces yet.
> 
> Thanks,
> Hirokazu Takahashi.

If the page isn't mapped, there is no good way to match it up with
a particular process id, is there?   :-)

We've handled that separately in the actual migration application,
by sync'ing the system and  then freeing clean page cache pages
before the migrate_pages() system call is invoked.

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
