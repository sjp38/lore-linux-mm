Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 054CE6B004D
	for <linux-mm@kvack.org>; Tue, 26 Jan 2010 08:32:35 -0500 (EST)
Date: Tue, 26 Jan 2010 21:32:17 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm/readahead.c: update the LRU positions of in-core
	pages, too
Message-ID: <20100126133217.GB25407@localhost>
References: <20100120215536.GN27212@frostnet.net> <20100121054734.GC24236@localhost> <20100123040348.GC30844@frostnet.net> <20100123102222.GA6943@localhost> <20100125094228.f7ca1430.kamezawa.hiroyu@jp.fujitsu.com> <20100125024544.GA16462@localhost> <20100125223635.GC2822@frostnet.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Disposition: inline
In-Reply-To: <20100125223635.GC2822@frostnet.net>
Sender: owner-linux-mm@kvack.org
To: Chris Frost <frost@cs.ucla.edu>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Steve Dickson <steved@redhat.com>, David Howells <dhowells@redhat.com>, Xu Chenfeng <xcf@ustc.edu.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Steve VanDeBogart <vandebo-lkml@nerdbox.net>
List-ID: <linux-mm.kvack.org>

On Mon, Jan 25, 2010 at 03:36:35PM -0700, Chris Frost wrote:
> I changed Wu's patch to add a PageLRU() guard that I believe is required
> and optimized zone lock acquisition to only unlock and lock at zone changes.
> This optimization seems to provide a 10-20% system time improvement for
> some of my GIMP benchmarks and no improvement for other benchmarks.

> +			del_page_from_lru_list(zone, page, lru);
> +			add_page_to_lru_list(zone, page, lru);
> +		}
> +		put_page(page);

Hmm. put_page() inside lru_lock can deadlock. So you need to further
optimize the code to do pagevec_lookup() and pagevec_release() plus
cond_resched().

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
