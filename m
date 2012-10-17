Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 197306B002B
	for <linux-mm@kvack.org>; Tue, 16 Oct 2012 22:34:23 -0400 (EDT)
Date: Wed, 17 Oct 2012 10:34:19 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: Re: Re: [PATCH 2/5] mm/readahead: Change the condition for
 SetPageReadahead
Message-ID: <20121017023419.GC13769@localhost>
References: <cover.1348309711.git.rprabhu@wnohang.net>
 <82b88a97e1b86b718fe8e4616820d224f6abbc52.1348309711.git.rprabhu@wnohang.net>
 <20120922124920.GB17562@localhost>
 <20120926012900.GA36532@Archie>
 <20120928115623.GB1525@localhost>
 <20121016174252.GB2826@Archie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121016174252.GB2826@Archie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Cc: linux-mm@kvack.org, viro@zeniv.linux.org.uk, akpm@linux-foundation.org

Hi Raghavendra,

> An implication of 51daa88ebd8e0d437289f589af29d4b39379ea76 is that,
> a redundant check for PageReadahead(page) is avoided since  async is
> piggy-backed into the synchronous readahead itself.

That's right.

> So, in case of
> 
>     page = find_get_page()
>     if(!page)
>         page_cache_sync_readahead()
>     else if (PageReadahead(page))
>         page_cache_async_readahead();
> 
> isnt' there a possibility that PG_readahead won't be set at all if
> page is not in cache (causing page_cache_sync_readahead) but page at
> index  (nr_to_read - lookahead_size) is already in the cache? (due
> to if (page) continue; in the code)?

Yes, and I'm fully aware of that. It's left alone because it's assumed
to be a rare case. The nature of readahead is, there are all kinds of
less common cases that we deliberately ignore in order to keep the
code simple and maintainable.

> Hence, I changed the condition from equality to >= for setting
> SetPageReadahead(page) (and added a variable so that it is done only
> once).

It's excellent that you noticed that case. And sorry that I come to
realize that your change

-               if (page_idx == nr_to_read - lookahead_size)
+               if (page_idx >= nr_to_read - lookahead_size) {
                        SetPageReadahead(page);
+                       lookahead_size = 0;
+               }

won't negatively impact cache hot reads. So I have no strong feelings
about the patch now.

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
