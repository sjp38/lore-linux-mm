Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 0C0D56B0002
	for <linux-mm@kvack.org>; Mon,  3 Jun 2013 10:53:03 -0400 (EDT)
Message-ID: <51ACADCD.70904@sr71.net>
Date: Mon, 03 Jun 2013 07:53:01 -0700
From: Dave Hansen <dave@sr71.net>
MIME-Version: 1.0
Subject: Re: [v4][PATCH 1/6] mm: swap: defer clearing of page_private() for
 swap cache pages
References: <20130531183855.44DDF928@viggo.jf.intel.com> <20130531183856.1D7D75AD@viggo.jf.intel.com> <20130603054048.GA27858@blaptop>
In-Reply-To: <20130603054048.GA27858@blaptop>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mgorman@suse.de, tim.c.chen@linux.intel.com

On 06/02/2013 10:40 PM, Minchan Kim wrote:
>> > diff -puN mm/vmscan.c~__delete_from_swap_cache-dont-clear-page-private mm/vmscan.c
>> > --- linux.git/mm/vmscan.c~__delete_from_swap_cache-dont-clear-page-private	2013-05-30 16:07:50.632079492 -0700
>> > +++ linux.git-davehans/mm/vmscan.c	2013-05-30 16:07:50.637079712 -0700
>> > @@ -494,6 +494,8 @@ static int __remove_mapping(struct addre
>> >  		__delete_from_swap_cache(page);
>> >  		spin_unlock_irq(&mapping->tree_lock);
>> >  		swapcache_free(swap, page);
>> > +		set_page_private(page, 0);
>> > +		ClearPageSwapCache(page);
> It it worth to support non-atomic version of ClearPageSwapCache?

Just for this, probably not.

It does look like a site where it would be theoretically safe to use
non-atomic flag operations since the page is on a one-way trip to the
allocator at this point and the __clear_page_locked() now happens _just_
after this code.

But, personally, I'm happy to leave it as-is.  The atomic vs. non-atomic
flags look to me like a micro-optimization that we should use when we
_know_ there will be some tangible benefit.  Otherwise, they're just
something extra for developers to trip over and cause very subtle bugs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
