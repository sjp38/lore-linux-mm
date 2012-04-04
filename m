Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 9510C6B0044
	for <linux-mm@kvack.org>; Wed,  4 Apr 2012 08:48:03 -0400 (EDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: swap on eMMC and other flash
Date: Wed, 4 Apr 2012 12:47:53 +0000
References: <201203301744.16762.arnd@arndb.de> <201203301850.22784.arnd@arndb.de> <4F7C3CE2.5070803@intel.com>
In-Reply-To: <4F7C3CE2.5070803@intel.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201204041247.53289.arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Adrian Hunter <adrian.hunter@intel.com>
Cc: linaro-kernel@lists.linaro.org, linux-mm@kvack.org, "Luca Porzio (lporzio)" <lporzio@micron.com>, Alex Lemberg <alex.lemberg@sandisk.com>, linux-kernel@vger.kernel.org, Saugata Das <saugata.das@linaro.org>, Venkatraman S <venkat@linaro.org>, Yejin Moon <yejin.moon@samsung.com>, Hyojin Jeong <syr.jeong@samsung.com>, "linux-mmc@vger.kernel.org" <linux-mmc@vger.kernel.org>, kernel-team@android.com

On Wednesday 04 April 2012, Adrian Hunter wrote:
> On 30/03/12 21:50, Arnd Bergmann wrote:
> > (sorry for the duplicated email, this corrects the address of the android
> > kernel team, please reply here)
> > 
> > On Friday 30 March 2012, Arnd Bergmann wrote:
> > 
> >  We've had a discussion in the Linaro storage team (Saugata, Venkat and me,
> >  with Luca joining in on the discussion) about swapping to flash based media
> >  such as eMMC. This is a summary of what we found and what we think should
> >  be done. If people agree that this is a good idea, we can start working
> >  on it.
> 
> There is mtdswap.

Ah, very interesting. I wasn't aware of that. Obviously we can't directly
use it on block devices that have their own garbage collection and wear
leveling built into them, but it's interesting to see how this was solved
before.

While we could build something similar that remaps blocks between an
eMMC device and the logical swap space that is used by the mm code,
my feeling is that it would be easier to modify the swap code itself
to do the right thing.

> Also the old Nokia N900 had swap to eMMC.
> 
> The last I heard was that swap was considered to be simply too slow on hand
> held devices.

That's the part that we want to solve here. It has nothing to do with
handheld devices, but more with specific incompatibilities of the
block allocation in the swap code vs. what an eMMC device expects
to see for fast operation. If you write data in the wrong order on
flash devices, you get long delays that you don't get when you do
it the right way. The same problem exists for file systems, and is
being addressed there as well.

> As systems adopt more RAM, isn't there a decreasing demand for swap?

No. You would never be able to make hibernate work, no matter how much
RAM you add ;-)

More seriously, the need for swap is not to work around the fact that
we have too little memory, it's one of the fundamental assumptions of
the mm subsystem that swap exists, and it's generally a good idea to
have, so you treat file backed memory in the same way as anonymous
memory.

	Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
