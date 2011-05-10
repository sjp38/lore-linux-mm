Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 2A8316B0011
	for <linux-mm@kvack.org>; Tue, 10 May 2011 01:37:51 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: Colin Ian King <colin.king@ubuntu.com>
In-Reply-To: <20110506154444.GG6591@suse.de>
References: <20110428171826.GZ4658@suse.de>
	 <1304015436.2598.19.camel@mulgrave.site> <20110428192104.GA4658@suse.de>
	 <1304020767.2598.21.camel@mulgrave.site>
	 <1304025145.2598.24.camel@mulgrave.site>
	 <1304030629.2598.42.camel@mulgrave.site> <20110503091320.GA4542@novell.com>
	 <1304431982.2576.5.camel@mulgrave.site>
	 <1304432553.2576.10.camel@mulgrave.site> <20110506074224.GB6591@suse.de>
	 <20110506154444.GG6591@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 10 May 2011 07:37:42 +0200
Message-ID: <1305005862.1937.2.camel@hpmini>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: James Bottomley <James.Bottomley@suse.de>, Mel Gorman <mgorman@novell.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, 2011-05-06 at 16:44 +0100, Mel Gorman wrote:
> On Fri, May 06, 2011 at 08:42:24AM +0100, Mel Gorman wrote:
> > 
> > 1. High-order allocations? You machine is using i915 and RPC, something
> >    neither of my test machine uses. i915 is potentially a source for
> >    high-order allocations. I'm attaching a perl script. Please run it as
> >    ./watch-highorder.pl --output /tmp/highorders.txt
> >    while you are running tar. When kswapd is running for about 30
> >    seconds, interrupt it with ctrl+c twice in quick succession and
> >    post /tmp/highorders.txt
> > 
> 
> Colin send me this information for his test case at least and I see
> 
> 11932 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC
>  => alloc_pages_current+0xa5/0x110 <ffffffff81149ef5>
>  => new_slab+0x1f5/0x290 <ffffffff81153645>
>  => __slab_alloc+0x262/0x390 <ffffffff81155192>
>  => kmem_cache_alloc+0x115/0x120 <ffffffff81155ab5>
>  => mempool_alloc_slab+0x15/0x20 <ffffffff8110e705>
>  => mempool_alloc+0x59/0x140 <ffffffff8110ea49>
>  => bio_alloc_bioset+0x3e/0xf0 <ffffffff811976ae>
>  => bio_alloc+0x15/0x30 <ffffffff81197805>
> 
> Colin and James: Did you happen to switch from SLAB to SLUB between
> 2.6.37 and 2.6.38? My own tests were against SLAB which might be why I
> didn't see the problem. Am restarting the tests with SLUB.

So I tested with SLAB instead of SLUB and I reliably ran my copy test
for 4+ hours with several hundred iterations of the test.  (Apologies
for taking time to respond, but I was travelling).
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
