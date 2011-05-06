Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D0FE26B0012
	for <linux-mm@kvack.org>; Fri,  6 May 2011 15:37:52 -0400 (EDT)
Date: Fri, 6 May 2011 20:37:48 +0100
From: Mel Gorman <mgorman@novell.com>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback related.
Message-ID: <20110506193748.GJ6657@novell.com>
References: <20110428192104.GA4658@suse.de>
 <1304020767.2598.21.camel@mulgrave.site>
 <1304025145.2598.24.camel@mulgrave.site>
 <1304030629.2598.42.camel@mulgrave.site>
 <20110503091320.GA4542@novell.com>
 <1304431982.2576.5.camel@mulgrave.site>
 <1304432553.2576.10.camel@mulgrave.site>
 <20110506074224.GB6591@suse.de>
 <20110506154444.GG6591@suse.de>
 <1304709277.12427.29.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1304709277.12427.29.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@suse.de>
Cc: Mel Gorman <mgorman@suse.de>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, May 06, 2011 at 02:14:37PM -0500, James Bottomley wrote:
> On Fri, 2011-05-06 at 16:44 +0100, Mel Gorman wrote:
> > Colin and James: Did you happen to switch from SLAB to SLUB between
> > 2.6.37 and 2.6.38? My own tests were against SLAB which might be why I
> > didn't see the problem. Am restarting the tests with SLUB.
> 
> Aargh ... I'm an idiot.  I should have thought of SLUB immediately ...
> it's been causing oopses since debian switched to it.
> 
> So I recompiled the 2.6.38.4 stable kernel with SLAB instead of SLUB and
> the problem goes away ... at least from three untar runs on a loaded
> box ... of course it could manifest a few ms after I send this email ...
> 
> There are material differences, as well: SLAB isn't taking my system
> down to very low memory on the untar ... it's keeping about 0.5Gb listed
> as free.  SLUB took that to under 100kb, so it could just be that SLAB
> isn't wandering as close to the cliff edge?
> 

A comparison of watch-highorder.pl with SLAB and SLUB may be
enlightening as well as testing SLUB altering allocate_slab() to read

alloc_gfp = (flags | __GFP_NOWARN | __GFP_NORETRY | __GFP_NO_KSWAPD) & ~__GFP_NOFAIL;

i.e. try adding the __GFP_NO_KSWAPD. My own tests are still in progress
but I'm still not seeing the problem. I'm installing Fedora on another
test machine at the moment to see if X and other applications have to be
running to pressure high-order allocations properly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
