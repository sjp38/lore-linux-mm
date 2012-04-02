Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx154.postini.com [74.125.245.154])
	by kanga.kvack.org (Postfix) with SMTP id AA1186B0092
	for <linux-mm@kvack.org>; Mon,  2 Apr 2012 10:55:40 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: swap on eMMC and other flash
Date: Mon, 2 Apr 2012 14:55:24 +0000
References: <201203301744.16762.arnd@arndb.de> <201204021145.43222.arnd@arndb.de> <alpine.LSU.2.00.1204020734560.1847@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1204020734560.1847@eggly.anvils>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201204021455.25029.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: linaro-kernel@lists.linaro.org, Rik van Riel <riel@redhat.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, linux-mm@kvack.org, Hyojin Jeong <syr.jeong@samsung.com>, kernel-team@android.com, Yejin Moon <yejin.moon@samsung.com>

On Monday 02 April 2012, Hugh Dickins wrote:
> On Mon, 2 Apr 2012, Arnd Bergmann wrote:
> > 
> > Another option would be batched discard as we do it for file systems:
> > occasionally stop writing to swap space and scanning for areas that
> > have become available since the last discard, then send discard
> > commands for those.
> 
> I'm not sure whether you've missed "swapon --discard", which switches
> on discard_swap_cluster() just before we allocate from a new cluster;
> or whether you're musing that it's no use to you because you want to
> repurpose the swap cluster to match erase block: I'm mentioning it in
> case you missed that it's already there (but few use it, since even
> done at that scale it's often more trouble than it's worth).

I actually argued that discard_swap_cluster is exactly the right thing
to do, especially when clusters match erase blocks on the less capable
devices like SD cards.

Luca was arguing that on some hardware there is no point in ever
submitting a discard just before we start reusing space, because
at that point it the hardware already discards the old data by
overwriting the logical addresses with new blocks, while
issuing a discard on all blocks as soon as they become available
would make a bigger difference. I would be interested in hearing
from Hyojin Jeong and Alex Lemberg what they think is the best
time to issue a discard, because they would know about other hardware
than Luca.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
