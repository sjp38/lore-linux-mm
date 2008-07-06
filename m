Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
From: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <20080706100230.GA21160@infradead.org>
References: <1215182557.10393.808.camel@pmac.infradead.org>
	 <20080704231322.GA4410@dspnet.fr.eu.org> <s5h4p746am3.wl%tiwai@suse.de>
	 <20080705105317.GA44773@dspnet.fr.eu.org> <486F596C.8050109@firstfloor.org>
	 <20080705120221.GC44773@dspnet.fr.eu.org> <486F6494.8020108@firstfloor.org>
	 <1215260166.10393.816.camel@pmac.infradead.org>
	 <20080705171316.GA3615@infradead.org>
	 <1215291312.3189.88.camel@shinybook.infradead.org>
	 <20080706100230.GA21160@infradead.org>
Content-Type: text/plain
Date: Sun, 06 Jul 2008 11:55:30 +0100
Message-Id: <1215341730.10393.931.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Andi Kleen <andi@firstfloor.org>, Olivier Galibert <galibert@pobox.com>, Takashi Iwai <tiwai@suse.de>, Hannes Reinecke <hare@suse.de>, Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sun, 2008-07-06 at 06:02 -0400, Christoph Hellwig wrote:
> The worst examples are aic7xx/aic79xx and the symbios family of drivers
> where the firmware / driver interface is entirely defined by the driver.
> But as we have opensource firmware for these and build it as part of
> the kernel build I suspect you don't want to convert them to external
> firmware either.

The fact that they're open source changes the technical situation
somewhat, mostly because it means that the firmware is much more likely
to change in step with the driver, and not have a stable ABI. So it
might make a little more sense to ship the firmware _with_ the driver in
those cases. For aic7.xx it's also a bit harder to load it as a discrete
blob, given that we generate C code in the driver which has intimate
knowledge of its internals.

There's still something to be said for keeping it in userspace and
loading it on demand though if we can, though, rather than keeping it in
kernel memory at all times.

I haven't yet come to a firm conclusion about what to do when we get to
those drivers; they're a bit of a special case. 

> aic94xx has a very similar firmware to aic7xx/aic79xx but it's only
> available as blob.  We've alredy required specific firmware versions
> there.

I don't believe we were going to touch that; it already uses
request_firmware(), doesn't it?

And what I think you're referring to is this:

    [SCSI] aic94xx: tie driver to the major number of the sequencer firmware
    
    The sequencer firmware file has both a string (currently showing
    V17/10c6) and a number (currently set to 1.1).  It has become apparent
    that Adaptec may issue sequencer firmware in the future which could be
    incompatible with the current driver.  Therefore, the driver will be
    tied to the particular major number of the firmware (i.e. the current
    driver will load any 1.x firmware). 

That's quite a good example. It hasn't happened yet but we know that
_if_ the major version changes, we can treat that like an soname bump.
The new firmware will have a new name, and the old drivers can continue
loading the old firmware.

> b43 has two totally different firmware major revisions that even require
> different drivers.

Another one we're not touching because it already uses request_firmware.
And this is one where we've _already_ used the soname trick -- there are
two versions of the firmware, and they each have different paths
in /lib/firmware. So the old and new drivers can happily coexist.

-- 
dwmw2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
