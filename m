Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 6A1846B004F
	for <linux-mm@kvack.org>; Thu, 13 Aug 2009 12:33:53 -0400 (EDT)
Date: Thu, 13 Aug 2009 09:33:39 -0700 (PDT)
From: david@lang.hm
Subject: Re: Discard support (was Re: [PATCH] swap: send callback when swap
 slot is freed)
In-Reply-To: <20090813162621.GB1915@phenom2.trippelsdorf.de>
Message-ID: <alpine.DEB.1.10.0908130931400.28013@asgard.lang.hm>
References: <200908122007.43522.ngupta@vflare.org> <Pine.LNX.4.64.0908122312380.25501@sister.anvils> <20090813151312.GA13559@linux.intel.com> <20090813162621.GB1915@phenom2.trippelsdorf.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Sender: owner-linux-mm@kvack.org
To: Markus Trippelsdorf <markus@trippelsdorf.de>
Cc: Matthew Wilcox <willy@linux.intel.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nitin Gupta <ngupta@vflare.org>, Ingo Molnar <mingo@elte.hu>, Peter Zijlstra <peterz@infradead.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-scsi@vger.kernel.org, linux-ide@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 13 Aug 2009, Markus Trippelsdorf wrote:

> On Thu, Aug 13, 2009 at 08:13:12AM -0700, Matthew Wilcox wrote:
>> I am planning a complete overhaul of the discard work.  Users can send
>> down discard requests as frequently as they like.  The block layer will
>> cache them, and invalidate them if writes come through.  Periodically,
>> the block layer will send down a TRIM or an UNMAP (depending on the
>> underlying device) and get rid of the blocks that have remained unwanted
>> in the interim.
>
> That is a very good idea. I've tested your original TRIM implementation on
> my Vertex yesterday and it was awful ;-). The SSD needs hundreds of
> milliseconds to digest a single TRIM command. And since your implementation
> sends a TRIM for each extent of each deleted file, the whole system is
> unusable after a short while.
> An optimal solution would be to consolidate the discard requests, bundle
> them and send them to the drive as infrequent as possible.

or queue them up and send them when the drive is idle (you would need to 
keep track to make sure the space isn't re-used)

as an example, if you would consider spinning down a drive you don't hurt 
performance by sending accumulated trim commands.

David Lang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
