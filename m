Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 2880F6B002E
	for <linux-mm@kvack.org>; Tue, 10 May 2011 10:35:16 -0400 (EDT)
Date: Tue, 10 May 2011 15:35:09 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
Message-ID: <20110510143509.GD4146@suse.de>
References: <1304025145.2598.24.camel@mulgrave.site>
 <1304030629.2598.42.camel@mulgrave.site>
 <20110503091320.GA4542@novell.com>
 <1304431982.2576.5.camel@mulgrave.site>
 <1304432553.2576.10.camel@mulgrave.site>
 <20110506074224.GB6591@suse.de>
 <20110506080728.GC6591@suse.de>
 <1304964980.4865.53.camel@mulgrave.site>
 <20110510102141.GA4149@novell.com>
 <1305036064.6737.8.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="vkogqOf2sHV7VnPd"
Content-Disposition: inline
In-Reply-To: <1305036064.6737.8.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Mel Gorman <mgorman@novell.com>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>


--vkogqOf2sHV7VnPd
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline

On Tue, May 10, 2011 at 09:01:04AM -0500, James Bottomley wrote:
> On Tue, 2011-05-10 at 11:21 +0100, Mel Gorman wrote:
> > I really would like to hear if the fix makes a big difference or
> > if we need to consider forcing SLUB high-order allocations bailing
> > at the first sign of trouble (e.g. by masking out __GFP_WAIT in
> > allocate_slab). Even with the fix applied, kswapd might be waking up
> > less but processes will still be getting stalled in direct compaction
> > and direct reclaim so it would still be jittery.
> 
> "the fix" being this
> 
> https://lkml.org/lkml/2011/3/5/121
> 

Drop this for the moment. It was a long shot at best and there is little
evidence the problem is in this area.

I'm attaching two patches. The first is the NO_KSWAPD one to stop
kswapd being woken up by SLUB using speculative high-orders. The second
one is more drastic and prevents slub entering direct reclaim or
compaction. It applies on top of patch 1. These are both untested and
afraid are a bit rushed as well :(

-- 
Mel Gorman
SUSE Labs

--vkogqOf2sHV7VnPd
Content-Type: text/x-patch; charset=iso-8859-15
Content-Disposition: attachment; filename="mm-slub-do-not-wake-kswapd-for-slub-high-orders.patch"


--vkogqOf2sHV7VnPd--
