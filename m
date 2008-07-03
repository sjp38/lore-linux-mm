Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <486CCFED.7010308@garzik.org>
References: <20080703020236.adaa51fa.akpm@linux-foundation.org>
	 <20080703205548.D6E5.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	 <486CC440.9030909@garzik.org>
	 <Pine.LNX.4.64.0807031353030.11033@blonde.site>
	 <486CCFED.7010308@garzik.org>
Content-Type: text/plain
Date: Thu, 03 Jul 2008 14:33:19 +0100
Message-Id: <1215091999.10393.556.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@linux-foundation.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 2008-07-03 at 09:11 -0400, Jeff Garzik wrote:
> Hugh Dickins wrote:
> > On Thu, 3 Jul 2008, Jeff Garzik wrote:
> >> KOSAKI Motohiro wrote:
> >>> Hi Michael,
> >>>
> >>> my server output following error message on 2.6.26-rc8-mm1.
> >>> Is this a bug?
> >>>
> >>> ------------------------------------------------------------------
> >>> tg3.c:v3.93 (May 22, 2008)
> >>> GSI 72 (level, low) -> CPU 0 (0x0001) vector 51
> >>> tg3 0000:06:01.0: PCI INT A -> GSI 72 (level, low) -> IRQ 51
> >>> firmware: requesting tigon/tg3_tso.bin
> >>> tg3: Failed to load firmware "tigon/tg3_tso.bin"
> >>> tg3 0000:06:01.0: PCI INT A disabled
> >>> GSI 72 (level, low) -> CPU 0 (0x0001) vector 51 unregistered
> >>> tg3: probe of 0000:06:01.0 failed with error -2
> >>> GSI 73 (level, low) -> CPU 0 (0x0001) vector 51
> >>> tg3 0000:06:01.1: PCI INT B -> GSI 73 (level, low) -> IRQ 52
> >>> firmware: requesting tigon/tg3_tso.bin
> >> This change did not come from the network developers or Broadcom, so someone
> >> else broke tg3 in -mm...
> > 
> > I think it's a consequence of not choosing CONFIG_FIRMWARE_IN_KERNEL=y.
> > 
> > That caught me out on PowerMac G5 trying mmotm yesterday, it just hung
> > for a few minutes in earlyish boot with a message about tg3_tso.bin,
> > and then proceeded to boot up but without the network.  I was unclear
> > whether I'd been stupid, or the FIRMWARE_IN_KERNEL Kconfigery was poor.

I shall respectfully refrain from commenting on the likelihood of the
former. With regard to the latter, here is the help text for the
FIRMWARE_IN_KERNEL option:

        help
          The kernel source tree includes a number of firmware 'blobs'
          which are used by various drivers. The recommended way to
          use these is to run "make firmware_install" and to copy the
          resulting binary files created in usr/lib/firmware directory
          of the kernel tree to the /lib/firmware on your system so
          that they can be loaded by userspace helpers on request.

          Enabling this option will build each required firmware blob
          into the kernel directly, where request_firmware() will find
          them without having to call out to userspace. This may be
          useful if your root file system requires a device which uses
          such firmware, and do not wish to use an initrd.

          This single option controls the inclusion of firmware for
          every driver which usees request_firmare() and ships its
          firmware in the kernel source tree, to avoid a proliferation
          of 'Include firmware for xxx device' options.

          Say 'N' and let firmware be loaded from userspace.

If you think you can improve it, please let me have a revised attempt.

> > I avoid initrd, and have tigon3 built in, if that's of any relevance.
> > 
> > I wonder if that's Andrew's problem with 2.6.26-rc8-mm1 on his G5:
> > mine here boots up fine (now I know to CONFIG_FIRMWARE_IN_KERNEL=y).
> 
> 
> dwmw2 has been told repeatedly that his changes will cause PRECISELY 
> these problems, but he refuses to take the simple steps necessary to 
> ensure people can continue to boot their kernels after his changes go in.

Complete nonsense. Setting CONFIG_FIRMWARE_IN_KERNEL isn't hard. But
shouldn't be the _default_, either.

> Presently his tg3 changes have been nak'd, in part, because of this 
> obviously, forseeable, work-around-able breakage.

They haven't even been reviewed. Nobody seems to have actually looked at
the real changes (in particular, and commented on whether the device can
run anyway without the TSO firmware being loaded, as some people seem to
report). You're just throwing your toys out of the pram because of the
'default n' on a patch about 30 commits earlier in my tree.

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
