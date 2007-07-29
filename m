Date: Sun, 29 Jul 2007 12:33:53 -0700
From: Paul Jackson <pj@sgi.com>
Subject: Re: RFT: updatedb "morning after" problem [was: Re: -mm merge plans
 for 2.6.23]
Message-Id: <20070729123353.2bfb9630.pj@sgi.com>
In-Reply-To: <2c0942db0707290820r2e31f40flb51a43846169a752@mail.gmail.com>
References: <9a8748490707231608h453eefffx68b9c391897aba70@mail.gmail.com>
	<46AAEDEB.7040003@gmail.com>
	<Pine.LNX.4.64.0707280138370.32476@asgard.lang.hm>
	<46AB166A.2000300@gmail.com>
	<20070728122139.3c7f4290@the-village.bc.nu>
	<46AC4B97.5050708@gmail.com>
	<20070729141215.08973d54@the-village.bc.nu>
	<46AC9F2C.8090601@gmail.com>
	<2c0942db0707290758p39fef2e8o68d67bec5c7ba6ab@mail.gmail.com>
	<46ACAB45.6080307@gmail.com>
	<2c0942db0707290820r2e31f40flb51a43846169a752@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ray Lee <ray-lk@madrabbit.org>
Cc: rene.herman@gmail.com, alan@lxorguk.ukuu.org.uk, david@lang.hm, dhazelton@enter.net, efault@gmx.de, akpm@linux-foundation.org, mingo@elte.hu, frank@kingswood-consulting.co.uk, andi@firstfloor.org, nickpiggin@yahoo.com.au, jesper.juhl@gmail.com, ck@vds.kolivas.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Ray wrote:
> a log structured scheme, where the writeout happens to sequential spaces
> on the drive instead of scattered about.

If the problem is reading stuff back in from swap quickly when
needed, then this likely helps, by reducing the seeks needed.

If the problem is reading stuff back in from swap at the *same time*
that the application is reading stuff from some user file system, and if
that user file system is on the same drive as the swap partition
(typical on laptops), then interleaving the user file system accesses
with the swap partition accesses might overwhelm all other performance
problems, due to the frequent long seeks between the two.

In that case, swap layout and swap i/o block size are secondary.
However, pre-fetching, so that swap read back is not interleaved
with application file accesses, could help dramatically.

===

Perhaps we could have a 'wake-up' command, analogous to the various sleep
and hibernate commands.  The 'wake-up' command could do whatever of the
following it knew to do, in order to optimize for an anticipated change in
usage patterns:
 1) pre-fetch swap
 2) clean (write out) dirty pages
 3) maximize free memory
 4) layout swap nicely
 5) pre-fetch a favorite set of apps

Stumble out of bed in the morning, press 'wake-up', start boiling the
water for your coffee, and in another ten minutes, one is ready to rock
and roll.

In case Andrew is so bored he read this far -- yes this wake-up sounds
like user space code, with minimal kernel changes to support any
particular lower level operation that we can't do already.

-- 
                  I won't rest till it's the best ...
                  Programmer, Linux Scalability
                  Paul Jackson <pj@sgi.com> 1.925.600.0401

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
