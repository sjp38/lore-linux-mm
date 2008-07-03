Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20080703173040.GB30506@mit.edu>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
	 <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <486CC440.9030909@garzik.org>
	 <Pine.LNX.4.64.0807031353030.11033@blonde.site>
	 <486CCFED.7010308@garzik.org>
	 <1215091999.10393.556.camel@pmac.infradead.org>
	 <486CD654.4020605@garzik.org>
	 <1215093175.10393.567.camel@pmac.infradead.org>
	 <20080703173040.GB30506@mit.edu>
Content-Type: text/plain
Date: Thu, 03 Jul 2008 19:56:02 +0100
Message-Id: <1215111362.10393.651.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Theodore Tso <tytso@mit.edu>
Cc: Jeff Garzik <jeff@garzik.org>, Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-03 at 13:30 -0400, Theodore Tso wrote:
> I don't think it's whining.

Neither is it an adequate review of the actual patch which was
submitted.

>   If your patch introduces changes which
> cause people .config to break by default after upgrading to a newer
> kernel and doing "make oldconfig" 

They had to 'make oldconfig' and then actually _choose_ to say 'no' to
an option which is fairly clearly documented, that they are the
relatively unusual position of wanting to have said 'yes' to. You're
getting into Aunt Tillie territory, when you complain about that.

Although it does make me wonder if it was better the way I had it
originally, with individual options like TIGON3_FIRMWARE_IN_KERNEL
attached to each driver, rather than a single FIRMWARE_IN_KERNEL option
which controls them all.

Perhaps one way to help Aunt Tillie would be to tweak Kbuild to look at
the MODULE_FIRMWARE() statements for in-kernel drivers, and to print a
warning when the build finishes: "Your static kernel image may require
the following firmware files, which are not included: ..."

It's wrong to change the CONFIG_FIRMWARE_IN_KERNEL default to 'Y',
because the _normal_ setting for that option _really_ should be 'N'.
Using request_firmware() satisfied from userspace is best practice these
days, and almost all recent drivers do it that way _unconditionally_
anyway.

What we're doing now is just cleaning up the older drivers which don't
use request_firmware(), to conform to what is now common practice. And
while we're retaining the _option_ to continue to build their firmware
into the static kernel image, it isn't recommended and really shouldn't
be the default configuration.

> Linus has ruled this way in the past, when he's gotten screwed by this
> sort of issue in the past, and he was justifiably annoyed. 

I am content to let Linus decide on what the default for the
FIRMWARE_IN_KERNEL option will be. I am adamant that it _should_ be 'N',
but it's easy enough for Linus to overrule me with a one-line change. 

In the meantime, it would be useful if Jeff would quit throwing his toys
out of the pram on that issue and actually review the _code_ changes. In
particular, are the reports correct that the device operates just fine
without the TSO firmware loaded? Should we change the request_firmware()
error path to just disable TSO and continue with the initialisation?

I can understand why he might not want to answer that if the answer is
affirmative, I suppose -- it detracts even _further_ from his already
rather dubious argument about 'breaking' the driver, if it'll actually
continue to work even when the firmware is completely absent. But it
would be nice to get an honest and straightforward review of the code
from _someone_ who actually knows the hardware.

>  And if there are licensing religious fundamentalists who feel
> strongly about the firmware issue, then fine, they can change
> the .config. 

Less of the ad hominem, please. Especially when it's so misdirected.

Updating these drivers to remove large blobs of static unswappable data
from the kernel, and having it provided from userspace on demand as
modern Linux drivers do, is a perfectly sensible technical goal all on
its own.

And given the GPL's explicit provisions with regard to collective works
there are also entirely reasonable, non-"fundamentalist" grounds for
believing that it _may_ pose a licensing problem, and for wanting to err
on the side of caution in that respect too.

Fedora is almost certain to ship with CONFIG_FIRMWARE_IN_KERNEL=n, and
I'd be very surprised if Debian and other major distributions don't
follow suit. It is the sensible, pragmatic, technically sound choice.

>  But the default should be to avoid users from having broken kernels,
> and a number of (quite clueful) users have already demonstrated that
> without setting CONFIG_FIRMWARE_IN_KERNEL=y as the default, your
> patches cause breakage.

By this argument, shouldn't we include images in the static kernel for
_all_ drivers which currently use request_firmware()? Otherwise, it's
possible for the user to 'break' them, right?

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
