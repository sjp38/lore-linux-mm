Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id BE53B6B0022
	for <linux-mm@kvack.org>; Fri, 13 May 2011 12:12:40 -0400 (EDT)
Subject: Possible sandybridge livelock issue
From: James Bottomley <James.Bottomley@HansenPartnership.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 13 May 2011 11:12:36 -0500
Message-ID: <1305303156.2611.51.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

We've just come off a large round of debugging a kswapd problem over on
linux-mm:

http://marc.info/?t=130392066000001

The upshot was that kswapd wasn't being allowed to sleep (which we're
now fixing).  However, in spite of intensive efforts, the actual hang
was only reproducible on sandybridge laptops.

When the hang occurred, kswapd basically pegged one core in 100% system
time.  This looks like there's something specific to sandybridge that
causes this type of bad interaction.  I was wondering if it could be
something to to with a scheduling problem in turbo mode?  Once kswapd
goes flat out, the core its on will kick into turbo mode, which causes
it to get preferentially scheduled there, leading to the live lock.

The only evidence I have to support this theory is that when I reproduce
the problem with PREEMPT, the core pegs at 100% system time and stays
there even if I turn off the load.  However, if I can execute work that
causes kswapd to be kicked off the core it's running on, it will calm
back down and go to sleep.

James


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
