Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 817D79000BD
	for <linux-mm@kvack.org>; Tue, 27 Sep 2011 22:25:20 -0400 (EDT)
Received: by pzk4 with SMTP id 4so20606003pzk.6
        for <linux-mm@kvack.org>; Tue, 27 Sep 2011 19:25:17 -0700 (PDT)
Date: Wed, 28 Sep 2011 11:25:10 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] vmscan: add barrier to prevent evictable page in
 unevictable list
Message-ID: <20110928022510.GB12100@barrios-desktop>
References: <1317174330-2677-1-git-send-email-minchan.kim@gmail.com>
 <4E8284C6.1050900@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4E8284C6.1050900@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, jweiner@redhat.com, mel@csn.ul.ie, riel@redhat.com, lee.schermerhorn@hp.com

On Wed, Sep 28, 2011 at 11:21:58AM +0900, KOSAKI Motohiro wrote:
> (2011/09/28 10:45), Minchan Kim wrote:
> > When racing between putback_lru_page and shmem_unlock happens,
> > progrom execution order is as follows, but clear_bit in processor #1
> > could be reordered right before spin_unlock of processor #1.
> > Then, the page would be stranded on the unevictable list.
> > 
> > spin_lock
> > SetPageLRU
> > spin_unlock
> >                                 clear_bit(AS_UNEVICTABLE)
> >                                 spin_lock
> >                                 if PageLRU()
> >                                         if !test_bit(AS_UNEVICTABLE)
> >                                         	move evictable list
> > smp_mb
> > if !test_bit(AS_UNEVICTABLE)
> >         move evictable list
> >                                 spin_unlock
> > 
> > But, pagevec_lookup in scan_mapping_unevictable_pages has rcu_read_[un]lock so
> > it could protect reordering before reaching test_bit(AS_UNEVICTABLE) on processor #1
> > so this problem never happens. But it's a unexpected side effect and we should
> > solve this problem properly.
> 
> Do we still need this after Hannes removes scan_mapping_unevictable_pages?
 
Hi KOSAKI,

What Hannes removes is scan_zone_unevictable_pages not scan_mapping_unevictable_pages.

-- 
Kinds regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
