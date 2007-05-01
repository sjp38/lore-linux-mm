Date: Tue, 1 May 2007 12:52:39 +0200
From: Willy Tarreau <w@1wt.eu>
Subject: Re: pcmcia ioctl removal
Message-ID: <20070501105239.GA13539@1wt.eu>
References: <20070430162007.ad46e153.akpm@linux-foundation.org> <20070501084623.GB14364@infradead.org> <Pine.LNX.4.64.0705010514300.9162@localhost.localdomain> <20070501094400.GX943@1wt.eu> <463715E8.1060903@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <463715E8.1060903@googlemail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gabriel C <nix.or.die@googlemail.com>
Cc: "Robert P. J. Day" <rpjday@mindspring.com>, Christoph Hellwig <hch@infradead.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-pcmcia@lists.infradead.org
List-ID: <linux-mm.kvack.org>

On Tue, May 01, 2007 at 12:26:48PM +0200, Gabriel C wrote:
> Willy Tarreau wrote:
> >On Tue, May 01, 2007 at 05:16:13AM -0400, Robert P. J. Day wrote:
> >  
> >>On Tue, 1 May 2007, Christoph Hellwig wrote:
> >>
> >>    
> >>>> pcmcia-delete-obsolete-pcmcia_ioctl-feature.patch
> >>>>        
> >>>...
> >>>
> >>>      
> >>>>Dominik is busy.  Will probably re-review and send these direct to 
> >>>>Linus.
> >>>>        
> >>>The patch above is the removal of cardmgr support.  While I'd love
> >>>to see this cruft gone it definitively needs maintainer judgement on
> >>>whether they time has come that no one relies on cardmgr anymore.
> >>>      
> >>since i was the one who submitted the original patch to remove that
> >>stuff, let me make an observation.
> >>
> >>when i submitted a patch to remove, for instance, the traffic shaper
> >>since it's clearly obsolete, i was told -- in no uncertain terms --
> >>that that couldn't be done since there had been no warning about its
> >>impending removal.
> >>
> >>fair enough, i can accept that.
> >>
> >>on the other hand, the features removal file contains the following:
> >>
> >>...
> >>What:   PCMCIA control ioctl (needed for pcmcia-cs [cardmgr, cardctl])
> >>When:   November 2005
> >>...
> >>
> >>in other words, the PCMCIA ioctl feature *has* been listed as obsolete
> >>for quite some time, and is already a *year and a half* overdue for
> >>removal.
> >>
> >>in short, it's annoying to take the position that stuff can't be
> >>deleted without warning, then turn around and be reluctant to remove
> >>stuff for which *more than ample warning* has already been given.
> >>doing that just makes a joke of the features removal file, and makes
> >>you wonder what its purpose is in the first place.
> >>
> >>a little consistency would be nice here, don't you think?
> >>    
> >
> >No, it just shows how useless this file is. What is needed is a big
> >warning during usage, not a file that nobody reads. Facts are :
> >
> >  - 90% of people here do not even know that this file exists
> >  - 80% of the people who know about it do not consult it on a regular 
> >  basis
> >  - 80% of those who consult it on a regular basis are not concerned
> >  - 75% of statistics are invented
> >
> >=> only 20% of 20% of 10% of those who read LKML know that one feature
> >   they are concerned about will soon be removed = 0.4% of LKML readers.
> >
> >If you put a warning in kernel messages (as I've seen for a long time
> >about tcpdump using obsolete AF_PACKET), close to 100% of the users
> >of the obsolete code who are likely to change their kernels will notice
> >it.
> >
> >  
> 
> Hmm ? There is already a fat warning in dmesg for a long time now.
> 
> 
> snip
> 
> ...
> 
> pcmcia: Detected deprecated PCMCIA ioctl usage from process: discover.
> pcmcia: This interface will soon be removed from the kernel; please 
> expect breakage unless you upgrade to new tools.
> pcmcia: see 
> http://www.kernel.org/pub/linux/utils/kernel/pcmcia/pcmcia.html for details.
> 
> ...

Oh you're terribly right ! I have grepped my logs and found it lying
there too in the middle of the memory probe messages and the IO probe
ones. I never noticed it. I know it's my fault, but I think that
"fat warning" is not really what could characterize it though, because
of the context verbose around it :

pcmcia: parent PCI bridge Memory window: 0x90000000 - 0x903fffff
pcmcia: parent PCI bridge Memory window: 0x30000000 - 0x3dffffff
pccard: PCMCIA card inserted into slot 0
cs: memory probe 0x90000000-0x903fffff: excluding 0x90000000-0x9003ffff 0x90080000-0x900bffff 0x90100000-0x9013ffff 0x90180000-0x901bffff 0x90200000-0x9023ffff 0x90280000-0x902bffff 0x90300000-0x9033ffff 0x90380000-0x903bffff
pcmcia: registering new device pcmcia0.0
pcmcia: Detected deprecated PCMCIA ioctl usage from process: cardmgr.
pcmcia: This interface will soon be removed from the kernel; please expect breakage unless you upgrade to new tools.
pcmcia: see http://www.kernel.org/pub/linux/utils/kernel/pcmcia/pcmcia.html for details.
cs: IO port probe 0xc00-0xcff: clean.
cs: IO port probe 0x820-0x8ff: clean.
cs: IO port probe 0x800-0x80f: clean.
cs: IO port probe 0x3e0-0x4ff: clean.
cs: IO port probe 0x100-0x3af: excluding 0x140-0x14f 0x378-0x37f
cs: IO port probe 0xa00-0xaff: clean.


Now I have the URL for the details ;-)

BTW, I thing we should standardize on some formating to display messages
about deprecated/obsolete code. Maybe something like this would be more
noticeable :

cs: memory probe 0x90000000-0x903fffff: excluding 0x90000000-0x9003ffff 0x90080000-0x900bffff 0x90100000-0x9013ffff 0x90180000-0x901bffff 0x90200000-0x9023ffff 0x90280000-0x902bffff 0x90300000-0x9033ffff 0x90380000-0x903bffff
pcmcia: registering new device pcmcia0.0
WARNING !!! Detected DEPRECATED PCMCIA ioctl usage from process: cardmgr.
WARNING !!!   This process may stop working past November 2005.
WARNING !!!   see http://www.kernel.org/pub/linux/utils/kernel/pcmcia/pcmcia.html for details.
cs: IO port probe 0xc00-0xcff: clean.

Regards,
Willy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
