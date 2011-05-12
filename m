Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id B1D61900001
	for <linux-mm@kvack.org>; Thu, 12 May 2011 13:51:13 -0400 (EDT)
Date: Thu, 12 May 2011 19:51:04 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 3/3] mm: slub: Default slub_max_order to 0
Message-ID: <20110512175104.GM11579@random.random>
References: <alpine.DEB.2.00.1105120942050.24560@router.home>
 <1305213359.2575.46.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121024350.26013@router.home>
 <1305214993.2575.50.camel@mulgrave.site>
 <20110512154649.GB4559@redhat.com>
 <1305216023.2575.54.camel@mulgrave.site>
 <alpine.DEB.2.00.1105121121120.26013@router.home>
 <1305217843.2575.57.camel@mulgrave.site>
 <BANLkTi=MD+voG1i7uDyueV22_daGHPRdqw@mail.gmail.com>
 <BANLkTimDsJDht76Vm7auNqT2gncjpEKZQw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <BANLkTimDsJDht76Vm7auNqT2gncjpEKZQw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: James Bottomley <James.Bottomley@hansenpartnership.com>, Christoph Lameter <cl@linux.com>, Dave Jones <davej@redhat.com>, Mel Gorman <mgorman@suse.de>, Andrew Morton <akpm@linux-foundation.org>, Colin King <colin.king@canonical.com>, Raghavendra D Prabhu <raghu.prabhu13@gmail.com>, Jan Kara <jack@suse.cz>, Chris Mason <chris.mason@oracle.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Thu, May 12, 2011 at 08:11:05PM +0300, Pekka Enberg wrote:
> If it's this:
> 
> http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=blob_plain;f=config-x86_64-generic;hb=HEAD
> 
> I'd love to see what happens if you disable
> 
> CONFIG_TRANSPARENT_HUGEPAGE=y
> 
> because that's going to reduce high order allocations as well, no?

Well THP forces COMPACTION=y so lumpy won't risk to be activated. I
got once a complaint asking not to make THP force COMPACTION=y (there
is no real dependency here, THP will just call alloc_pages with
__GFP_NO_KSWAPD and order 9, or 10 on x86-nopae), but I preferred to
keep it forced exactly to avoid issues like these when THP is on. If
even order 3 is causing troubles (which doesn't immediately make lumpy
activated, it only activates when priority is < DEF_PRIORITY-2, so
after 2 loops failing to reclaim nr_to_reclaim pages), imagine what
was happening at order 9 every time firefox, gcc and mutt allocated
memory ;).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
