Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id PAA15170
	for <linux-mm@kvack.org>; Mon, 9 Sep 2002 15:07:33 -0700 (PDT)
Message-ID: <3D7D1B94.16F220E3@digeo.com>
Date: Mon, 09 Sep 2002 15:07:16 -0700
From: Andrew Morton <akpm@digeo.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slabasap-mm5_A2
References: <200209071006.18869.tomlins@cam.org> <200209081142.02839.tomlins@cam.org> <3D7BB97A.6B6E4CA5@digeo.com> <200209091733.44112.tomlins@cam.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ed Tomlinson <tomlins@cam.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

Ed Tomlinson wrote:
> 
> Hi Andrew,
> 
> Found three oops when checking this afternoon's log.  Looks like *total_scanned can
> be zero...
> 
> how about;
> 
> ratio = pages > *total_scanned ? pages / (*total_scanned | 1) : 1;
> 

Yup, thanks.  I went the "+ 1" route ;)

Found another dumb bug in there too.  In refill_inactive_zone:

        while (nr_pages && !list_empty(&zone->active_list)) {
		...
                if (page_count(page) == 0) {
                        /* It is currently in pagevec_release() */
                        SetPageLRU(page);
                        list_add(&page->lru, &zone->active_list);
                        continue;
                }
                page_cache_get(page);
                list_add(&page->lru, &l_hold);
                nr_pages--;
        }

does not terminate if the active list consists entirely of zero-count
pages.  I'm not sure how I managed to abuse the system into that
state, but I did, and received a visit from the NMI watchdog for my
sins.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
