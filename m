Date: Sat, 5 Jul 2008 10:08:45 -0300
From: Henrique de Moraes Holschuh <hmh@hmh.eng.br>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Message-ID: <20080705130845.GA23069@khazad-dum.debian.net>
References: <1215178035.10393.763.camel@pmac.infradead.org> <20080704141014.GA23215@mit.edu> <s5habgxloct.wl%tiwai@suse.de> <486E3622.1000900@suse.de> <1215182557.10393.808.camel@pmac.infradead.org> <20080704231322.GA4410@dspnet.fr.eu.org> <20080704235839.GA5649@khazad-dum.debian.net> <Pine.LNX.4.64.0807041742500.13075@t2.domain.actdsltmp> <20080705035215.GA15899@khazad-dum.debian.net> <20080705020124.ac73e979.billfink@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20080705020124.ac73e979.billfink@mindspring.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Bill Fink <billfink@mindspring.com>
Cc: Trent Piepho <tpiepho@freescale.com>, Olivier Galibert <galibert@pobox.com>, David Woodhouse <dwmw2@infradead.org>, Hannes Reinecke <hare@suse.de>, Takashi Iwai <tiwai@suse.de>, Theodore Tso <tytso@mit.edu>, Jeff Garzik <jeff@garzik.org>, Andi Kleen <andi@firstfloor.org>, David Miller <davem@davemloft.net>, hugh@veritas.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, netdev@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 05 Jul 2008, Bill Fink wrote:
> On Sat, 5 Jul 2008, Henrique de Moraes Holschuh wrote:
> > On Fri, 04 Jul 2008, Trent Piepho wrote:
> > > On Fri, 4 Jul 2008, Henrique de Moraes Holschuh wrote:
> > > > On Sat, 05 Jul 2008, Olivier Galibert wrote:
> > > >> Won't that break multiple kernel installs on any binary packaging
> > > >> system that cares about file collisions?  Multiple kernel rpms
> > > >> providing the same /lib/firmware files would break things wouldn't
> > > >> they ?
> > > >
> > > > We will probably need per-kernel directories, exactly like what is done for
> > > > modules.  And since there are (now) both kernel-version-specific, and
> > > > non-kernel-version-specific firmware, this means the firmware loader should
> > > > look first on the version-specific directory (say, /lib/firmware/$(uname
> > > > -r)/), then if not found, on the general directory (/lib/firmware).
> > > 
> > > How about /lib/modules/`uname -r`/firmware
> > 
> > I am fine with it, it certainly has a few advantages.
> 
> Why not put it in the same /lib/modules directory as the foo.ko
> kernel module itself?  Then those who like to scp kernel modules
> around (which I've done myself on occasion) just need to learn
> to scp foo.* instead of foo.ko.  Why replicate a separate
> /lib/modules/`uname -r`/firmware directory?

Because a single new directory tree is easier, simpler, and less prone to
breakage to implement.  This thing is way too complicated already, and
that's not good for something that must ALWAYS work right.  Also, it doesn't
assume any sort of mapping between the firmware files and their users (so,
it won't ADD constraints to the firmware loading API that do not exist right
now).  And it lets you version or un-version firmware files (if you *want*,
and in in *every* case), very easily, and without breaking the current ABI
(/lib/firmware/).

If I were to attempt to address your use case properly, I'd do it by
exporting the firmware dependency information on module metadata, and
add/modify userspace to tell you about it.  This would let you do "scp
$(findmoduledeps --include-self themodule) foo:/tmp" and get the module, its
firmware files, its dependencies, the dependencies' firmware, and so on, so
that you'd get the entire module stack and all the firmware for the stack.
Or whatever else you want "findmoduledeps" to do, the required data would be
there for the tool to be quite versatile.

But I have zero interest on firmware loading, and I am currently taking care
of more kernel work than what I am confortable with already, so someone else
would have to do it.  There are probably even better ways than the simple
one I described above, I bet...

-- 
  "One disk to rule them all, One disk to find them. One disk to bring
  them all and in the darkness grind them. In the Land of Redmond
  where the shadows lie." -- The Silicon Valley Tarot
  Henrique Holschuh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
