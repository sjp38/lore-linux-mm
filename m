Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id SAA09702
	for <linux-mm@kvack.org>; Wed, 6 Nov 2002 18:51:11 -0800 (PST)
Message-ID: <3DC9D51B.4CF2B06D@digeo.com>
Date: Wed, 06 Nov 2002 18:51:07 -0800
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: PageLRU BUG() when preemption is turned on (2.4 kernel)
References: <20021106183317.E15363@mvista.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jun Sun <jsun@mvista.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Jun Sun wrote:
> 
> I am chasing a nasty bug that shows up in 2.4 kernel when preemption
> is turned on.  I would appreciate any help.  Please cc your reply
> to me email account.
> 
> I caught the BUG() live with kgdb (on a MIPS board).  See the backtrace
> attached at the end.
> 
> In a nutshell, access_process_vm() calls put_page(), which
> calls __free_pages(), where it finds page->count is 0 but does not
> like the fact that page->flags still has LRU bit set.
> 

That's a bug in older 2.4 kernels.  You'll need to use a more recent
kernel, or change that put_page() to be a page_cache_release(),
or forward-port this chunk:


        /*
         * Yes, think what happens when other parts of the kernel take 
         * a reference to a page in order to pin it for io. -ben
         */
        if (PageLRU(page)) {
                if (unlikely(in_interrupt()))
                        BUG();
                lru_cache_del(page);
        }

to your __free_pages_ok().

The problem is that `put_page()' doesn't know how to deal with the
final release of a page which is on the LRU.  Someone else released
their reference, leaving access_process_vm() unexpectedly holding
the last reference to the page.  But it does put_page(), which then
says "why didn't you remove this page from the LRU?  BUG."
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
