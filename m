Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0DBA06B00DB
	for <linux-mm@kvack.org>; Wed,  3 Jun 2009 11:48:34 -0400 (EDT)
Date: Wed, 3 Jun 2009 12:21:51 +0200
From: Jens Axboe <jens.axboe@oracle.com>
Subject: Re: [PATCH] [13/16] HWPOISON: The high level memory error handler
	in the VM v3
Message-ID: <20090603102151.GM11363@kernel.dk>
References: <20090528082616.GG6920@wotan.suse.de> <20090528095934.GA10678@localhost> <20090528122357.GM6920@wotan.suse.de> <20090528135428.GB16528@localhost> <20090601115046.GE5018@wotan.suse.de> <20090601140553.GA1979@localhost> <20090601144050.GA12099@wotan.suse.de> <20090602111407.GA17234@localhost> <20090602121940.GD1392@wotan.suse.de> <20090602125134.GA20462@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090602125134.GA20462@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Nick Piggin <npiggin@suse.de>, Andi Kleen <andi@firstfloor.org>, "hugh@veritas.com" <hugh@veritas.com>, "riel@redhat.com" <riel@redhat.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "chris.mason@oracle.com" <chris.mason@oracle.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 02 2009, Wu Fengguang wrote:
> > And then this is possible because you aren't violating mm
> > assumptions due to 1b. This proceeds just as the existing
> > pagecache mce error handler case which exists now.
> 
> Yeah that's a good scheme - we are talking about two interception
> scheme. Mine is passive one and yours is active one.
> 
> passive: check hwpoison pages at __generic_make_request()/elv_next_request() 
>          (the code will be enabled by an mce_bad_io_pages counter)

That's not a feasible approach at all, it'll add O(N) scan of a bio at
queue time. Ditto for the elv_next_request() approach.

What would be cheaper is to check the pages at dma map time, since you
have to scan the request anyway. That means putting it in
blk_rq_map_sg() or similar.

-- 
Jens Axboe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
