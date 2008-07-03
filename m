Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20080703.133428.22854563.davem@davemloft.net>
References: <486CC440.9030909@garzik.org>
	 <Pine.LNX.4.64.0807031353030.11033@blonde.site>
	 <486CCFED.7010308@garzik.org>
	 <20080703.133428.22854563.davem@davemloft.net>
Content-Type: text/plain
Date: Thu, 03 Jul 2008 21:54:36 +0100
Message-Id: <1215118476.10393.692.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Miller <davem@davemloft.net>
Cc: jeff@garzik.org, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-03 at 13:34 -0700, David Miller wrote:
> From: Jeff Garzik <jeff@garzik.org>
> Date: Thu, 03 Jul 2008 09:11:09 -0400
> 
> > dwmw2 has been told repeatedly that his changes will cause PRECISELY 
> > these problems, but he refuses to take the simple steps necessary to 
> > ensure people can continue to boot their kernels after his changes go in.
> > 
> > Presently his tg3 changes have been nak'd, in part, because of this 
> > obviously, forseeable, work-around-able breakage.
> 
> I agree with Jeff, obviously.
> 
> We both saw this song and dance coming.  Now the reports are coming in
> from confused people who are losing their network.  It is no surprise.
> 
> And the person who introduced this swath of regressions acts like it's
> some kind of chore to enforce the obviously correct default behavior.
> 
> Why is it such a big deal to make "obviously working" the default?

> In effect, you lied to us, in that you said that by default users
> wouldn't have to do anything to keep getting a working setup.

No, I didn't lie to you. The conversation, in case you forgot, went like
this...

On Wed, 2008-06-18 at 16:23 -0700, David Miller wrote:
> On Thu, 2008-06-19 at 00:16 +0100, David Woodhouse wrote:
> > On Wed, 2008-06-18 at 16:05 -0700, David Miller wrote:
> > > Tell me this, how can I (with the default config option settings)
> > > netboot properly without an initial ramdisk after these tg3 patches
> > > and still get the proper firmware?
> > 
> > I suppose the facetious answer is that you can't, just as you can't do
> > it with a default config _before_ these patches -- because neither
> > CONFIG_TIGON3 nor the various options you need for nfsroot are enabled
> > by default.
> > 
> > But if you _have_ a working nfsroot+tg3 config and you apply these
> > patches, then all you need to do is say 'y' when you're asked if you
> > want to include the firmware for it:
> >         CONFIG_TIGON3_FIRMWARE=y
> > 
> > If you are competent enough to get nfsroot working, it isn't really very
> > credible to claim you lack the wit to say 'y' when asked that question,
> > surely?
> > 
> > Solving that problem was step #1 in the process of converting drivers to
> > use request_firmware(). You _have_ to be able to build the firmware into
> > the kernel image, and you _can_.
> 
> Fair enough.
> 
> I'll step back and let you work out the objections Jeff raised.

Since then, I responded to feedback and changed the individual
CONFIG_XXX_FIRMWARE options to a single CONFIG_FIRMWARE_IN_KERNEL which
controls them all, but basically nothing has changed. What you accepted
then is still true.

On Thu, 2008-07-03 at 13:34 -0700, David Miller wrote:
So don't be surprised how pissed off some of us are about these
> changes.  You are inflicting pain on driver maintainers because now
> they have to sift through these "firmware not found" reports in
> addition to their normal workload.

It also improves coverage testing, and found a real bug in the failure
path...

> And David make it seem like it's inconvenient for him to implement the
> correct default, which in particular pisses me personally off the
> most.  It's totally irresponsible, and I don't care what the legal or
> ideological motivation is.

It's not inconvenient at all. It's just the _wrong_ default. But if we
really can't get past it otherwise, then let's just set it to 'y' for
now. I've committed the following, which will appear in linux-next
tomorrow.

Now, can someone _please_ give me a straight response to the allegation
that the TSO firmware on the tg3 is _optional_ anyway, and that it can
work without it? If that's true, we should fix the code path where
request_firmware() fails, so it doesn't abort the initialisation. (And
most of the whining about the driver being 'broken' is nonsense too.)

----
>From 400f1b05a9707bd181a044877ca590e87c400749 Mon Sep 17 00:00:00 2001
From: David Woodhouse <dwmw2@infradead.org>
Date: Thu, 3 Jul 2008 21:36:11 +0100
Subject: [PATCH] firmware: default CONFIG_FIRMWARE_IN_KERNEL=y

This is obviously the wrong thing to do in the long (or even medium)
term -- since the recommended way of handling firmware, as used
_unconditionally_ by modern drivers, is to rely on request_firmware()
being satisfied from userspace rather than keeping the firmware in
unswappable static kernel memory.

But this change preserves the property, for now, that the fixes to make
older drivers use request_firmware() introduce _no_ "regressions" when
Aunt Tillie runs 'make oldconfig' and accepts the defaults without
looking at what she's doing.

Signed-off-by: David Woodhouse <dwmw2@infradead.org>
---
 drivers/base/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 339c148..d47482f 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -37,6 +37,7 @@ config FW_LOADER
 config FIRMWARE_IN_KERNEL
 	bool "Include in-kernel firmware blobs in kernel binary"
 	depends on FW_LOADER
+	default y
 	help
 	  The kernel source tree includes a number of firmware 'blobs'
 	  which are used by various drivers. The recommended way to
-- 
1.5.5.1


-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
