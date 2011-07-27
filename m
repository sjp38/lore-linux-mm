Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id A96C96B016B
	for <linux-mm@kvack.org>; Wed, 27 Jul 2011 19:45:27 -0400 (EDT)
Date: Wed, 27 Jul 2011 16:45:23 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH]vmscan: add block plug for page reclaim
Message-Id: <20110727164523.c2b1d569.akpm@linux-foundation.org>
In-Reply-To: <4E2B17A6.6080602@fusionio.com>
References: <1311130413.15392.326.camel@sli10-conroe>
	<CAEwNFnDj30Bipuxrfe9upD-OyuL4v21tLs0ayUKYUfye5TcGyA@mail.gmail.com>
	<1311142253.15392.361.camel@sli10-conroe>
	<CAEwNFnD3iCMBpZK95Ks+Z7DYbrzbZbSTLf3t6WXDQdeHrE6bLQ@mail.gmail.com>
	<1311144559.15392.366.camel@sli10-conroe>
	<4E287EC0.4030208@fusionio.com>
	<1311311695.15392.369.camel@sli10-conroe>
	<4E2B17A6.6080602@fusionio.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jens Axboe <jaxboe@fusionio.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Minchan Kim <minchan.kim@gmail.com>, "mgorman@suse.de" <mgorman@suse.de>, linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>

On Sat, 23 Jul 2011 20:49:10 +0200
Jens Axboe <jaxboe@fusionio.com> wrote:

> > I can observe the average request size changes. Before the patch, the
> > average request size is about 90k from iostat (but the variation is
> > big). With the patch, the request size is about 100k and variation is
> > small.
> 
> That's a good win right there, imho.

yup.  Reduced CPU consumption on that path isn't terribly exciting IMO,
but improved request size is significant.

Using an additional 44 bytes of stack on that path is also
significant(ly bad).  But we need to fix that problem anyway.  One way
we could improve things in mm/vmscan.c is to move the blk_plug into
scan_control then get the scan_control off the stack in some manner. 
That's easy for kswapd: allocate one scan_control per kswapd at
startup.  Doing it for direct-reclaim would be a bit trickier...



And I have the usual maintainability whine.  If someone comes up to
vmscan.c and sees it calling blk_start_plug(), how are they supposed to
work out why that call is there?  They go look at the blk_start_plug()
definition and it is undocumented.  I think we can do better than this?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
